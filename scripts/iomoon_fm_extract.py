"""
IO Moon Pinball YM3812 (OPL2) FM Music Extractor
------------------------------------------------
Extracts the FM music tracks from the SLEIC "IO Moon" 80188 code ROM
(`V1 3_01.bin`), driven by the song-pointer INDEX table in ROM (no
hard-coded per-track offsets), and exports them to:
  - raw    : a human-readable .txt log (+ optional binary) of register writes
  - vgm    : a standard VGM v1.51 file (OPL2-native; renders in any VGM player)
  - wav    : rendered through an offline OPL2 emulator (PyOPL / DOSBox core)

ROM / engine facts (re-derived from the 80188 disassembly, segment CS=D000;
linear Dxxxx maps to file offset 0x50000 + xxxx):

  Song-pointer table  : CS:0DE5  (file 0x50DE5), 10 little-endian uint16 offsets.
  Music sequencer     : CS:0D37  (file 0x50D37). Per song-pointer SI it reads a
                        byte pair  AH = cs:[si]; si++;  AL = cs:[si]; si++  and
                        dispatches on AH:

    AH == 0xEE  set note-duration : duration[0x12EC] = AL * tempo_scale[0x12EF];
                                    ENDS this tick (retf). Consumes the pair only.
    AH == 0xEF  set tempo scale   : tempo_scale[0x12EF] = AL; continues. Pair only.
    AH == 0xFF  end of track      : clears state; retf. Consumes the pair (AL n/u).
    AH == 0xDD  jump / loop        : reads ONE more byte hi = cs:[si];
                                    SI = (hi << 8) | AL.  i.e. 3 bytes total,
                                    target is little-endian (AL = low, next = high).
    default      YM3812 reg write  : write OPL2 register AH := value AL
                                    (index port 0xA0280, data port 0xA0281),
                                    then continue. Consumes the pair only.

  The sequencer is entered once per video frame; 0xEE installs a down-counter so
  a song advances only every duration ticks. Register writes between 0xEE markers
  happen in the same tick (instantly), so "tick time" only advances on 0xEE.

Fidelity (re-derived 2026-06; see docs/iomoon_fm_extract.md "Fidelity notes"):
  - Music tick rate ~= 72.5 Hz. The sequencer is called from the DMD frame ISR
    (D000:0343 -> music_sequencer D000:0D1B) which has a 1-bit toggle gate
    ([1142h]) so the player advances on every OTHER frame interrupt. The DMD wire
    frame rate is ~145 Hz (logic-analyser); 2 bitplanes per visible frame, so the
    player ticks once per visible frame ~= 145/2 = 72.5 Hz. (NOT 50/60 Hz.)
  - YM3812 master clock = 4.0 MHz (8 MHz / 2, IC20 YACLK divider) — NOT the
    3.579545 MHz PC colorburst value. This raises pitch ~+1.92 semitones and
    speeds FM envelopes/LFO ~11.7% vs the old default.
  - WAV render replays the ROM register stream verbatim (so WSE, per-operator
    waveforms, AM/VIB and BD depth bits are all honoured by the OPL2 core),
    clock-corrects to 4.0 MHz, and applies a YM3014B/analog reconstruction
    low-pass + DC-block + headroom.

This script is standalone (stdlib + optional pyopl). Run directly:
  python3 iomoon_fm_extract.py --rom "V1 3_01.bin" --all --format raw vgm --out out
"""

import argparse
import os
import struct
import sys
import wave
from pathlib import Path


# ---------------------------------------------------------------------------
# Engine constants (file offsets / opcodes derived from disassembly)
# ---------------------------------------------------------------------------
DEFAULT_TABLE_OFFSET = 0x50DE5   # CS:0DE5 song-pointer table
DEFAULT_SEG_BASE     = 0x50000   # D000:0000 -> file 0x50000
DEFAULT_TRACK_COUNT  = 10        # 10 entries before track-0 data begins

OP_DURATION = 0xEE   # set note duration (ends tick); operand = AL
OP_TEMPO    = 0xEF   # set tempo scale; operand = AL
OP_END      = 0xFF   # end of track
OP_JUMP     = 0xDD   # jump/loop; AL = low byte, following byte = high byte

# Safety caps against runaway / malformed data
MAX_PAIRS      = 200000   # max byte-pairs decoded per track
MAX_TICKS      = 2000000  # max accumulated ticks per track

# ---------------------------------------------------------------------------
# Hardware fidelity constants (see docs/iomoon_fm_extract.md "Fidelity notes")
# ---------------------------------------------------------------------------
# YM3812 master clock (phiM) on IO Moon: IC60's clock pin is fed `YACLK` from the
# IC20 (74LS393) divider chain off the board's 8 MHz timing source — NOT a
# 3.579545 MHz PC-soundcard colorburst crystal. The only in-spec 74LS393 tap of
# 8 MHz that lands at/under the YM3812's 4.0 MHz phiM ceiling is 8 MHz / 2 = 4.0
# MHz, which is also the standard pinball OPL2 clock and the value the PinMAME
# `sleic.c` stub already uses. 4.0 MHz vs the old 3.579545 MHz default raises
# pitch by ~+1.92 semitones and speeds every FM envelope/LFO by ~11.7% — the bulk
# of the "awkwardly different" sound.  (board_011-029A_ics.md IC60; hardware_architecture.md)
DEFAULT_YM_CLOCK = 4000000       # YM3812 phiM = 8 MHz / 2 (YACLK)

# The DOSBox OPL2 core inside PyOPL always synthesises a *3.579545 MHz* chip and
# resamples to whatever rate you ask for; pitch/envelope speed are therefore
# locked to this canonical clock regardless of the render sample rate. To model
# the real 4.0 MHz part we render at the canonical native rate and then resample
# the PCM by (real_clock / canonical_clock) — this is the ONLY way to move the
# emulated OPL2 off 3.579545 MHz with PyOPL.
OPL2_CANONICAL_CLOCK = 3579545   # what the DOSBox/PyOPL core actually emulates
OPL2_NATIVE_RATE     = 49716     # 3579545 / 72, PyOPL's natural output rate

# Music sequencer tick rate. The sequencer (80188 D000:0D1B) is ticked from the
# DMD frame ISR (D000:0D343 -> call music_sequencer @ D038D). That ISR contains a
# 1-bit toggle gate ([1142h], D0352/D0359/D037E) so the sequencer is serviced on
# EVERY OTHER frame interrupt. The DMD frame ISR fires once per wire frame (one
# bitplane); the logic-analyser capture measured ~145 Hz wire frames (2 bitplanes
# per visible frame -> ~72 fps visible). So the music advances once per *visible*
# frame: 145 Hz / 2 ~= 72.5 Hz. The OPL2 settling delay (D0DA9) is a bus timing
# detail with no effect on the emulated result. The sound_timer_isr (D024F) does
# NOT tick the music (it calls dmd_strobe_clear, not the sequencer).
DEFAULT_TICK_HZ = 72.5           # ~145 Hz DMD wire frames / 2 (per visible frame)

# WAV output sample rate.
DEFAULT_WAV_RATE = 48000


def read_rom(path):
    with open(path, 'rb') as f:
        return f.read()


def read_song_table(rom, table_offset, seg_base, count):
    """Read `count` little-endian uint16 song pointers from the ROM table and
    return a list of (entry_value, file_offset)."""
    table = []
    for i in range(count):
        off = table_offset + i * 2
        if off + 1 >= len(rom):
            raise ValueError("song table runs past end of ROM at index %d" % i)
        ptr = struct.unpack_from('<H', rom, off)[0]
        table.append((ptr, seg_base + ptr))
    return table


def auto_track_count(rom, table_offset, seg_base):
    """Auto-detect the number of song entries.

    The table is immediately followed by track-0 data, and entry 0 points to
    just past the table. So count = (entry0 - table_ptr) / 2, where table_ptr is
    the table's own segment offset.
    """
    entry0 = struct.unpack_from('<H', rom, table_offset)[0]
    table_ptr = table_offset - seg_base
    span = entry0 - table_ptr
    if span > 0 and span % 2 == 0:
        return span // 2
    return DEFAULT_TRACK_COUNT


# ---------------------------------------------------------------------------
# Sequencer decode
# ---------------------------------------------------------------------------
def decode_track(rom, start_offset, seg_base):
    """Decode one track into a list of timed FM writes.

    Returns a dict with:
      events : list of (tick, reg, val) FM register writes (tick = accumulated
               note-duration time at which the write is applied)
      waits  : list of (after_event_index, tick_len) -- not used directly; the
               per-event tick already encodes timing
      total_ticks : total accumulated tick time of the track
      keyon_count : number of KeyOn transitions (reg 0xB0-0xB8 bit5 0->1)
      writes  : flat list of register-write events with structure described below
      end_reason : 'end-opcode' | 'loop-cap' | 'pair-cap' | 'tick-cap' | 'eof'
      loop_target : file offset the final 0xDD jumped to, or None
      invalid_regs : count of writes to out-of-range OPL2 registers (>0xF5)

    Implements the exact opcode semantics re-derived from CS:0D37.
    """
    seg_limit = (start_offset & ~0xFFFF)  # base of the 64K segment this song lives in
    si = start_offset - seg_limit         # SI within the segment (segment offset)
    seg_file_base = seg_limit             # file offset of SI=0 for this segment

    writes = []          # list of dicts: {'tick','reg','val'}
    tick = 0             # accumulated note-duration time
    tempo_scale = 1      # [0x12EF]; default 1 (most tracks set it first anyway)
    pairs = 0
    keyon_count = 0
    keyon_state = {}     # channel -> bool, for KeyOn edge detection
    invalid_regs = 0
    end_reason = 'eof'
    loop_target = None
    visited_jumps = {}   # jump source offset -> count, to bound loops

    def cs_byte(offset_in_seg):
        return rom[seg_file_base + offset_in_seg]

    while True:
        if pairs >= MAX_PAIRS:
            end_reason = 'pair-cap'
            break
        if tick >= MAX_TICKS:
            end_reason = 'tick-cap'
            break
        # Need at least the pair available in this segment window
        if seg_file_base + si + 1 >= len(rom):
            end_reason = 'eof'
            break

        ah = cs_byte(si); si = (si + 1) & 0xFFFF
        al = cs_byte(si); si = (si + 1) & 0xFFFF
        pairs += 1

        if ah == OP_TEMPO:
            tempo_scale = al
            continue

        if ah == OP_DURATION:
            # duration = AL * tempo_scale; advance song time by that many ticks
            dur = al * tempo_scale
            tick += dur
            continue

        if ah == OP_END:
            end_reason = 'end-opcode'
            break

        if ah == OP_JUMP:
            hi = cs_byte(si)             # si NOT advanced in the saved pointer
            target = ((hi << 8) | al) & 0xFFFF
            loop_target = seg_file_base + target
            # Loop guard: allow each distinct jump source to fire once, then stop
            src = (si - 2) & 0xFFFF
            visited_jumps[src] = visited_jumps.get(src, 0) + 1
            if visited_jumps[src] > 1:
                end_reason = 'loop-cap'
                break
            si = target
            continue

        # default: YM3812 register write reg=AH val=AL
        reg = ah
        val = al
        if reg > 0xF5:
            invalid_regs += 1
        writes.append({'tick': tick, 'reg': reg, 'val': val})

        # KeyOn edge detection on 0xB0-0xB8
        if 0xB0 <= reg <= 0xB8:
            ch = reg - 0xB0
            on = bool(val & 0x20)
            prev = keyon_state.get(ch, False)
            if on and not prev:
                keyon_count += 1
            keyon_state[ch] = on

    return {
        'writes': writes,
        'total_ticks': tick,
        'keyon_count': keyon_count,
        'invalid_regs': invalid_regs,
        'end_reason': end_reason,
        'loop_target': loop_target,
        'pairs': pairs,
        'start_offset': start_offset,
    }


# ---------------------------------------------------------------------------
# OPL2 register naming (for the readable raw dump)
# ---------------------------------------------------------------------------
def reg_name(reg):
    if reg == 0x01:
        return 'TEST/WSE'
    if reg in (0x02, 0x03):
        return 'TIMER%d' % (reg - 1)
    if reg == 0x04:
        return 'TIMER-CTRL'
    if reg == 0x08:
        return 'CSM/NOTE-SEL'
    if 0x20 <= reg <= 0x35:
        return 'AM/VIB/EGT/KSR/MULT'
    if 0x40 <= reg <= 0x55:
        return 'KSL/TL'
    if 0x60 <= reg <= 0x75:
        return 'AR/DR'
    if 0x80 <= reg <= 0x95:
        return 'SL/RR'
    if 0xA0 <= reg <= 0xA8:
        return 'FNUM-LO ch%d' % (reg - 0xA0)
    if 0xB0 <= reg <= 0xB8:
        return 'KEYON/BLOCK/FNUM-HI ch%d' % (reg - 0xB0)
    if reg == 0xBD:
        return 'RHYTHM/DEPTH'
    if 0xC0 <= reg <= 0xC8:
        return 'FB/CNT ch%d' % (reg - 0xC0)
    if 0xE0 <= reg <= 0xF5:
        return 'WAVEFORM-SELECT'
    return '?'


# ---------------------------------------------------------------------------
# Exporters
# ---------------------------------------------------------------------------
def export_raw(track, idx, out_dir, write_binary=True):
    """Write a human-readable .txt log and an optional binary register stream."""
    txt_path = os.path.join(out_dir, 'track%02d.txt' % idx)
    with open(txt_path, 'w') as f:
        f.write("# IO Moon FM track %d\n" % idx)
        f.write("# start file offset : 0x%05X\n" % track['start_offset'])
        f.write("# FM register writes : %d\n" % len(track['writes']))
        f.write("# KeyOn events       : %d\n" % track['keyon_count'])
        f.write("# total ticks        : %d\n" % track['total_ticks'])
        f.write("# byte-pairs decoded : %d\n" % track['pairs'])
        f.write("# end reason         : %s\n" % track['end_reason'])
        if track['loop_target'] is not None:
            f.write("# loop/jump target   : 0x%05X\n" % track['loop_target'])
        f.write("# invalid registers  : %d\n" % track['invalid_regs'])
        f.write("#\n# %-8s %-6s %-6s %s\n" % ('tick', 'reg', 'val', 'meaning'))
        for w in track['writes']:
            f.write("  %-8d 0x%02X   0x%02X   %s\n"
                    % (w['tick'], w['reg'], w['val'], reg_name(w['reg'])))
    paths = [txt_path]

    if write_binary:
        bin_path = os.path.join(out_dir, 'track%02d.regs.bin' % idx)
        with open(bin_path, 'wb') as f:
            # simple framing: uint32 tick, uint8 reg, uint8 val
            for w in track['writes']:
                f.write(struct.pack('<IBB', w['tick'] & 0xFFFFFFFF, w['reg'], w['val']))
        paths.append(bin_path)
    return paths


def build_vgm(track, ym_clock, tick_hz):
    """Build a VGM v1.51 byte stream from the decoded track.

    Command stream uses:
      0x5A aa dd   : YM3812 write reg aa = dd
      0x61 nn nn   : wait nn samples (44100 Hz)
      0x66         : end of sound data
    """
    SAMPLE_RATE = 44100
    samples_per_tick = SAMPLE_RATE / float(tick_hz)

    body = bytearray()
    total_samples = 0
    cur_tick = 0
    emitted_sample_pos = 0  # samples already waited for

    def wait_until(target_tick):
        nonlocal total_samples, emitted_sample_pos
        target_samples = int(round(target_tick * samples_per_tick))
        delta = target_samples - emitted_sample_pos
        while delta > 0:
            n = min(delta, 65535)
            body.append(0x61)
            body.extend(struct.pack('<H', n))
            delta -= n
        emitted_sample_pos = target_samples
        total_samples = max(total_samples, emitted_sample_pos)

    for w in track['writes']:
        if w['tick'] > cur_tick:
            wait_until(w['tick'])
            cur_tick = w['tick']
        if w['reg'] <= 0xFF:
            body.append(0x5A)
            body.append(w['reg'] & 0xFF)
            body.append(w['val'] & 0xFF)
    # trailing wait to the song's total tick length so the tail rings out
    wait_until(track['total_ticks'])
    body.append(0x66)  # end

    total_samples = emitted_sample_pos

    # --- VGM header (0x40 bytes, version 1.51) ---
    header = bytearray(0x40)
    header[0x00:0x04] = b'Vgm '
    data_offset = 0x40
    eof_offset = 0x04 + len(header) + len(body) - 0x04
    struct.pack_into('<I', header, 0x04, len(header) + len(body) - 0x04)  # EOF offset
    struct.pack_into('<I', header, 0x08, 0x151)                           # version 1.51
    struct.pack_into('<I', header, 0x18, total_samples)                   # total # samples
    struct.pack_into('<I', header, 0x24, 0)                               # loop offset
    struct.pack_into('<I', header, 0x28, 0)                               # loop # samples
    struct.pack_into('<I', header, 0x2C, ym_clock)                        # YM3812 clock
    struct.pack_into('<I', header, 0x34, data_offset - 0x34)             # VGM data offset (rel)

    return bytes(header) + bytes(body), total_samples


def export_vgm(track, idx, out_dir, ym_clock, tick_hz):
    data, total_samples = build_vgm(track, ym_clock, tick_hz)
    vgm_path = os.path.join(out_dir, 'track%02d.vgm' % idx)
    with open(vgm_path, 'wb') as f:
        f.write(data)
    return vgm_path, total_samples


# ---------------------------------------------------------------------------
# Output post-processing (YM3014B DAC + analog reconstruction model)
# ---------------------------------------------------------------------------
def _resample_linear(samples, n_in, ratio):
    """Linear-resample an interleaved-stereo float list to `round(n_in*ratio)`
    output frames (ratio>1 stretches/lowers, <1 compresses/raises)."""
    n_out = int(round(n_in * ratio))
    if n_out <= 0 or n_in <= 0:
        return [0.0, 0.0] * max(n_out, 0), max(n_out, 0)
    out = [0.0] * (n_out * 2)
    step = (n_in - 1) / float(n_out - 1) if n_out > 1 else 0.0
    for i in range(n_out):
        pos = i * step
        i0 = int(pos)
        frac = pos - i0
        i1 = i0 + 1 if i0 + 1 < n_in else i0
        b0 = 2 * i0
        b1 = 2 * i1
        out[2 * i] = samples[b0] + (samples[b1] - samples[b0]) * frac
        out[2 * i + 1] = samples[b0 + 1] + (samples[b1 + 1] - samples[b0 + 1]) * frac
    return out, n_out


def _one_pole_lowpass(samples, n_frames, sample_rate, cutoff_hz):
    """In-place one-pole low-pass on interleaved-stereo float `samples`. Models the
    YM3014B sample-and-hold + the board's analog reconstruction filter so the raw,
    aliased OPL2 staircase is softened the way the real audio path softens it."""
    import math
    if cutoff_hz <= 0 or n_frames <= 0:
        return
    dt = 1.0 / sample_rate
    rc = 1.0 / (2.0 * math.pi * cutoff_hz)
    a = dt / (rc + dt)
    yl = samples[0]
    yr = samples[1]
    for i in range(n_frames):
        yl += a * (samples[2 * i] - yl)
        yr += a * (samples[2 * i + 1] - yr)
        samples[2 * i] = yl
        samples[2 * i + 1] = yr


def _dc_block(samples, n_frames):
    """In-place DC-blocking high-pass (models AC coupling after the DAC)."""
    if n_frames <= 0:
        return
    r = 0.9995
    x1l = samples[0]
    x1r = samples[1]
    yl = 0.0
    yr = 0.0
    for i in range(n_frames):
        xl = samples[2 * i]
        xr = samples[2 * i + 1]
        yl = xl - x1l + r * yl
        yr = xr - x1r + r * yr
        x1l = xl
        x1r = xr
        samples[2 * i] = yl
        samples[2 * i + 1] = yr


# ---------------------------------------------------------------------------
# WAV render via offline OPL2 emulator (PyOPL / DOSBox core)
# ---------------------------------------------------------------------------
def render_wav(track, idx, out_dir, ym_clock, tick_hz,
               sample_rate=DEFAULT_WAV_RATE, analog_filter=True,
               filter_hz=12000.0, headroom_db=3.0):
    """Render the decoded track to a WAV using PyOPL (the DOSBox OPL2 core),
    clock-corrected for IO Moon's real YM3812 master clock.

    PyOPL's DOSBox core always emulates a 3.579545 MHz chip (see
    OPL2_CANONICAL_CLOCK). To model the real `ym_clock` (4.0 MHz on IO Moon) we
    render at the canonical native rate and then resample the PCM by
    canonical/ym_clock, which shifts pitch and FM envelope/LFO speed by the clock
    ratio while we pre-compensate the tick scheduling so the musical *tempo*
    (driven by tick_hz, real wall-clock) is preserved.

    Returns (wav_path, stats_dict) or raises if pyopl is unavailable.
    """
    try:
        import pyopl
    except ImportError as e:
        raise RuntimeError("pyopl not installed (pip install pyopl): %s" % e)

    import array
    import math

    # Clock correction ratio: how much to stretch the canonical-clock render so
    # the result sounds like the real ym_clock part. >1 => lower/slower (real
    # clock slower than canonical), <1 => higher/faster (4 MHz > 3.579545 MHz).
    clock_ratio = OPL2_CANONICAL_CLOCK / float(ym_clock)

    # Render through PyOPL at its canonical native rate.
    native_rate = OPL2_NATIVE_RATE
    opl = pyopl.opl(native_rate, sampleSize=2, channels=2)

    # Tick scheduling at the native rate, PRE-COMPENSATED by 1/clock_ratio so that
    # after the clock_ratio resample below, one tick spans native_rate/tick_hz
    # samples at the final time base => true wall-clock tempo from tick_hz.
    samples_per_tick = (native_rate / float(tick_hz)) / clock_ratio

    pcm16 = bytearray()
    BUF = 512

    def render_samples(n):
        remaining = n
        while remaining > 0:
            chunk = min(remaining, BUF)
            buf = bytearray(chunk * 2 * 2)  # channels * sampleSize
            opl.getSamples(buf)
            pcm16.extend(buf)
            remaining -= chunk

    cur_tick = 0
    rendered_samples = 0

    def opl_write(reg, val):
        opl.writeReg(reg & 0xFF, val & 0xFF)

    # Replay the register writes in exact ROM order. The index-port (0xA0280) and
    # data-port (0xA0281) ordering and the in-ROM (reg,val) sequence are preserved
    # verbatim; the hardware OPL2 settling delay (D0DA9) is a bus-timing detail
    # that does not change the emulated result, so it is not modelled here.
    for w in track['writes']:
        if w['tick'] > cur_tick:
            n = int(round(w['tick'] * samples_per_tick)) - rendered_samples
            if n > 0:
                render_samples(n)
                rendered_samples += n
            cur_tick = w['tick']
        opl_write(w['reg'], w['val'])

    # tail: render to total length plus a ring-out (in the pre-compensated base)
    target = int(round(track['total_ticks'] * samples_per_tick))
    if target > rendered_samples:
        render_samples(target - rendered_samples)
        rendered_samples = target
    render_samples(int(round(0.3 * native_rate / clock_ratio)))

    # --- to float, interleaved stereo ---
    raw = array.array('h')
    raw.frombytes(bytes(pcm16))
    n_frames_in = len(raw) // 2
    fsamples = [s / 32768.0 for s in raw]

    # --- clock correction: resample native-rate render by clock_ratio ---
    if abs(clock_ratio - 1.0) > 1e-9:
        fsamples, n_frames = _resample_linear(fsamples, n_frames_in, clock_ratio)
    else:
        n_frames = n_frames_in
    # Now `fsamples` is at native_rate samples/sec and clock-accurate.

    # --- resample to the requested output sample rate ---
    out_ratio = sample_rate / float(native_rate)
    if abs(out_ratio - 1.0) > 1e-9:
        fsamples, n_frames = _resample_linear(fsamples, n_frames, out_ratio)

    # --- analog reconstruction model (YM3014B + board filter) ---
    if analog_filter:
        _dc_block(fsamples, n_frames)
        _one_pole_lowpass(fsamples, n_frames, sample_rate, filter_hz)

    # --- headroom / peak normalisation to avoid clipping ---
    peakf = 0.0
    for v in fsamples:
        av = v if v >= 0 else -v
        if av > peakf:
            peakf = av
    target_peak = 10.0 ** (-headroom_db / 20.0)  # e.g. -3 dBFS
    gain = (target_peak / peakf) if peakf > 0 else 1.0
    # only attenuate; never amplify quiet tracks into noise
    if gain > 1.0:
        gain = 1.0

    out16 = array.array('h', bytes(2 * len(fsamples)))
    for i, v in enumerate(fsamples):
        s = int(round(v * gain * 32767.0))
        if s > 32767:
            s = 32767
        elif s < -32768:
            s = -32768
        out16[i] = s

    wav_path = os.path.join(out_dir, 'track%02d.wav' % idx)
    with wave.open(wav_path, 'wb') as wf:
        wf.setnchannels(2)
        wf.setsampwidth(2)
        wf.setframerate(sample_rate)
        wf.writeframes(out16.tobytes())

    if len(out16):
        peak = max(abs(s) for s in out16)
        rms = math.sqrt(sum(s * s for s in out16) / len(out16))
    else:
        peak = rms = 0
    dur = (len(out16) // 2) / float(sample_rate)
    stats = {
        'wav_path': wav_path,
        'duration_s': dur,
        'peak': peak,
        'rms': rms,
        'sample_rate': sample_rate,
        'ym_clock': ym_clock,
        'tick_hz': tick_hz,
        'emulator': 'PyOPL (DOSBox OPL2 core), clock-corrected to %.3f MHz'
                    % (ym_clock / 1e6),
    }
    return wav_path, stats


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    ap = argparse.ArgumentParser(
        description='Extract YM3812 (OPL2) FM music tracks from the SLEIC '
                    'IO Moon 80188 code ROM, driven by the in-ROM song table.')
    ap.add_argument('--rom', required=True, help='Path to V1 3_01.bin (80188 code ROM)')
    ap.add_argument('--table-offset', type=lambda x: int(x, 0),
                    default=DEFAULT_TABLE_OFFSET,
                    help='File offset of song-pointer table (default 0x%X)'
                         % DEFAULT_TABLE_OFFSET)
    ap.add_argument('--seg-base', type=lambda x: int(x, 0), default=DEFAULT_SEG_BASE,
                    help='File offset for segment D000:0000 (default 0x%X)'
                         % DEFAULT_SEG_BASE)
    ap.add_argument('--count', default='auto',
                    help='Number of tracks in the table ("auto" or an integer)')
    ap.add_argument('--track', type=int, default=None, help='Extract a single track index')
    ap.add_argument('--all', action='store_true', help='Extract all tracks')
    ap.add_argument('--out', default='out_fm', help='Output directory')
    ap.add_argument('--format', nargs='+', default=['raw'],
                    choices=['raw', 'vgm', 'wav'], help='Output formats (multiple allowed)')
    ap.add_argument('--ym-clock', type=int, default=DEFAULT_YM_CLOCK,
                    help='YM3812 master clock phiM in Hz (default %d = 8 MHz/2, '
                         'IO Moon YACLK). Sets VGM header clock AND corrects WAV '
                         'pitch/envelope speed. Old PC value was 3579545.'
                         % DEFAULT_YM_CLOCK)
    ap.add_argument('--tick-hz', type=float, default=DEFAULT_TICK_HZ,
                    help='Sequencer (music) tick rate in Hz. Default %.1f = the '
                         '~145 Hz DMD wire-frame rate / 2 (one tick per visible '
                         'frame; see fidelity notes). Controls tempo.'
                         % DEFAULT_TICK_HZ)
    ap.add_argument('--wav-rate', type=int, default=DEFAULT_WAV_RATE,
                    help='WAV output sample rate in Hz (default %d)' % DEFAULT_WAV_RATE)
    ap.add_argument('--no-filter', action='store_true',
                    help='Disable the YM3014B/analog reconstruction low-pass + '
                         'DC-block + headroom post-processing on the WAV')
    ap.add_argument('--filter-hz', type=float, default=12000.0,
                    help='Reconstruction low-pass cutoff in Hz (default 12000)')
    ap.add_argument('--no-bin', action='store_true', help='Skip binary register dump in raw')
    args = ap.parse_args()

    rom = read_rom(args.rom)

    if args.count == 'auto':
        count = auto_track_count(rom, args.table_offset, args.seg_base)
    else:
        count = int(args.count, 0)

    table = read_song_table(rom, args.table_offset, args.seg_base, count)

    print("ROM: %s (%d bytes)" % (args.rom, len(rom)))
    print("Song table @ file 0x%05X, %d entries:" % (args.table_offset, count))
    for i, (ptr, foff) in enumerate(table):
        print("  track %d: ptr=0x%04X -> file 0x%05X" % (i, ptr, foff))

    if args.track is not None:
        indices = [args.track]
    elif args.all:
        indices = list(range(count))
    else:
        ap.error("specify --track N or --all")

    os.makedirs(args.out, exist_ok=True)

    print("\nDecoding...")
    print("%-6s %-9s %-7s %-7s %-9s %-13s %s" %
          ('track', 'file-off', 'writes', 'keyon', 'ticks', 'secs@%g' % args.tick_hz, 'end'))
    rendered = []
    for i in indices:
        ptr, foff = table[i]
        track = decode_track(rom, foff, args.seg_base)
        secs = track['total_ticks'] / args.tick_hz
        flag = '' if track['invalid_regs'] == 0 else ' [!%d INVALID REGS]' % track['invalid_regs']
        print("%-6d 0x%05X  %-7d %-7d %-9d %-13.2f %s%s" %
              (i, foff, len(track['writes']), track['keyon_count'],
               track['total_ticks'], secs, track['end_reason'], flag))

        if 'raw' in args.format:
            export_raw(track, i, args.out, write_binary=not args.no_bin)
        if 'vgm' in args.format:
            vgm_path, nsamp = export_vgm(track, i, args.out, args.ym_clock, args.tick_hz)
        if 'wav' in args.format:
            try:
                wav_path, stats = render_wav(
                    track, i, args.out, args.ym_clock, args.tick_hz,
                    sample_rate=args.wav_rate,
                    analog_filter=not args.no_filter,
                    filter_hz=args.filter_hz)
                rendered.append((i, stats))
            except RuntimeError as e:
                print("    wav: %s" % e)

    if rendered:
        print("\nWAV render (OPL2 emulator):")
        for i, st in rendered:
            print("  track %d: %s  %.2fs  peak=%d rms=%.1f  [%s]" %
                  (i, os.path.basename(st['wav_path']), st['duration_s'],
                   st['peak'], st['rms'], st['emulator']))

    print("\nOutput written to: %s" % os.path.abspath(args.out))


if __name__ == '__main__':
    main()
