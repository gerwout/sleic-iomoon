#!/usr/bin/env python3
"""Byte-level tests for the Sleic Pin-Ball FREE PLAY patch. Run: python3 this."""
import pathlib, subprocess, sys, tempfile, types, zlib

sys.dont_write_bytecode = True  # never cache bytecode; the suite must reflect the file on disk

HERE = pathlib.Path(__file__).resolve().parent
SCRIPTS = HERE.parent
ROM = SCRIPTS.parent / 'roms/related-machines/sleic-pin-ball/sp03-1_1.rom'

def load(name):
    # Exec the source text directly. importlib's loader validates cached
    # bytecode against (source mtime, source size); an edit that lands at the
    # same byte length with the mtime unchanged reuses a stale .pyc instead
    # of the code actually on disk.
    path = SCRIPTS / name
    m = types.ModuleType(name)
    m.__file__ = str(path)
    exec(compile(path.read_text(), str(path), 'exec'), m.__dict__)
    return m

def fp():
    return load('sleic_pin_ball_free_play_patch.py')

def ps():
    return load('sleic_pin_ball_press_start_patch.py')

def test_stock_rom_is_accepted():
    m = fp()
    data = ROM.read_bytes()
    assert zlib.crc32(data) == 0x261b0ae4, 'wrong stock ROM'
    assert m.validate_rom(data, False) is True

def test_hook_sites_match_stock_bytes():
    m = fp()
    data = ROM.read_bytes()
    for addr, orig, _, label in m.HOOKS:
        off = m.physical_to_file(addr)
        actual = data[off:off+len(orig)]
        assert actual == bytes([0x3E, 0xA2, 0x00, 0x01]), \
            f'{label} at {addr:#07x}: expected 3e a2 00 01, found {actual.hex()} -- wrong ROM revision?'

def test_caves_fit_the_padding():
    m = fp()
    data = ROM.read_bytes()
    for addr, blob, label in m.CAVES:
        off = m.physical_to_file(addr)
        assert 0 <= off and off + len(blob) <= len(data), f'{label} outside the ROM'
        assert all(b == 0xFF for b in data[off:off+len(blob)]), f'{label} space not empty'
        # E000:FF00 upward: the top of the E50EB-EFFFF run, clear of PRESS
        # START's own caves (which occupy the bottom of that run).
        assert 0xEFF00 <= addr and addr + len(blob) - 1 <= 0xEFFFF, \
            f'{label} outside the E000:FF00-FFFF gap'

def test_caves_do_not_collide_with_press_start():
    m, p = fp(), ps()
    fp_ranges = [(m.physical_to_file(a), m.physical_to_file(a)+len(b)) for a, b, _ in m.CAVES]
    ps_ranges = [(p.physical_to_file(a), p.physical_to_file(a)+len(b)) for a, b, _ in p.CAVES]
    for lo1, hi1 in fp_ranges:
        for lo2, hi2 in ps_ranges:
            assert hi1 <= lo2 or hi2 <= lo1, \
                f'free play cave {lo1:#x}-{hi1:#x} overlaps PRESS START cave {lo2:#x}-{hi2:#x}'

def test_patch_is_idempotent():
    m = fp()
    once = m.apply_patches(ROM.read_bytes())
    assert m.is_already_patched(once)
    assert m.apply_patches(once) == once

def test_foreign_rom_is_refused():
    m = fp()
    junk = bytes(m.ROM_SIZE)
    assert m.validate_rom(junk, False) is False

def test_apply_patches_writes_nothing_outside_caves_and_hooks():
    m = fp()
    stock = ROM.read_bytes()
    patched = m.apply_patches(stock)
    allowed = set()
    for addr, blob, _ in m.CAVES:
        allowed |= set(range(m.physical_to_file(addr), m.physical_to_file(addr)+len(blob)))
    for addr, original, _, _ in m.HOOKS:
        allowed |= set(range(m.physical_to_file(addr), m.physical_to_file(addr)+len(original)))
    diff = {i for i in range(len(stock)) if stock[i] != patched[i]}
    assert diff <= allowed, f'{len(diff - allowed)} bytes changed outside cave and hook'

def test_nvram_triple_is_never_touched():
    m = fp()
    stock = ROM.read_bytes()
    patched = m.apply_patches(stock)
    # The NVRAM image is not part of this ROM (it lives in a separate
    # segment-1000 store), but the hook sites and caves must not stray into
    # anything that reads or writes it -- checked instead by confirming the
    # only bytes touched are exactly the two 4-byte hook sites and the two
    # trampolines (test_apply_patches_writes_nothing_outside_caves_and_hooks),
    # and that neither trampoline contains a reference to segment 0x1000.
    for _, blob, label in m.CAVES:
        assert bytes([0x00, 0x10]) not in bytes(blob), \
            f'{label} references segment 0x1000 -- the NVRAM triple must stay untouched'

def test_trampoline_writer1_assembles_as_written():
    m = fp()
    with tempfile.TemporaryDirectory() as t:
        src = pathlib.Path(t) / 'a.asm'; out = pathlib.Path(t) / 'a.bin'
        src.write_text(m.TRAMPOLINE_WRITER1_ASM)
        subprocess.run(['nasm', '-f', 'bin', '-o', str(out), str(src)], check=True)
        assert out.read_bytes() == bytes(m.TRAMPOLINE_WRITER1), 'byte list != nasm output'

def test_trampoline_writer2_assembles_as_written():
    m = fp()
    with tempfile.TemporaryDirectory() as t:
        src = pathlib.Path(t) / 'a.asm'; out = pathlib.Path(t) / 'a.bin'
        src.write_text(m.TRAMPOLINE_WRITER2_ASM)
        subprocess.run(['nasm', '-f', 'bin', '-o', str(out), str(src)], check=True)
        assert out.read_bytes() == bytes(m.TRAMPOLINE_WRITER2), 'byte list != nasm output'

def test_trampolines_floor_before_writing_the_cache():
    m = fp()
    # or al,al / jnz short +2 / mov al,1 / mov ds:[0x100],al -- the floor
    # happens strictly before the write, for both trampolines.
    floor_then_write = bytes([0x08, 0xC0, 0x75, 0x02, 0xB0, 0x01, 0x3E, 0xA2, 0x00, 0x01])
    assert bytes(m.TRAMPOLINE_WRITER1).startswith(floor_then_write)
    assert bytes(m.TRAMPOLINE_WRITER2).startswith(floor_then_write)

def test_hook_patches_are_jmp_near_plus_one_nop():
    m = fp()
    for addr, orig, patched, label in m.HOOKS:
        assert len(patched) == 4 == len(orig), f'{label}: patch changes length'
        assert patched[0] == 0xE9, f'{label}: byte 0 is not jmp near'
        assert patched[3] == 0x90, f'{label}: byte 3 is not nop padding'

def test_hook_jumps_resolve_to_their_own_trampoline():
    m = fp()
    for (addr, orig, patched, label), (cave_addr, _, cave_label) in zip(m.HOOKS, m.CAVES):
        off = m.physical_to_file(addr)
        rel = int.from_bytes(patched[1:3], 'little')
        target = (off + 3 + rel) & 0xFFFF
        assert target == m.physical_to_file(cave_addr), \
            f'{label} jumps to {target:#06x}, not {cave_label} at {m.physical_to_file(cave_addr):#06x}'

def test_trampolines_rejoin_right_after_their_own_hook():
    m = fp()
    # Each trampoline's closing jmp must land exactly 4 bytes past its own
    # hook site -- the lcall that splits AL into the two display digits.
    for trampoline, (addr, orig, _, label) in zip((m.TRAMPOLINE_WRITER1, m.TRAMPOLINE_WRITER2), m.HOOKS):
        b = bytes(trampoline)
        assert b[-3] == 0xE9, f'{label} trampoline: last instruction is not jmp near'
        cave_addr = next(a for a, blob, _ in m.CAVES if blob == trampoline)
        cave_off = m.physical_to_file(cave_addr)
        rel = int.from_bytes(b[-2:], 'little')
        target = (cave_off + len(b) + rel) & 0xFFFF
        assert target == m.physical_to_file(addr) + 4, \
            f'{label} trampoline rejoins at {target:#06x}, not hook+4 ({m.physical_to_file(addr)+4:#06x})'

def test_crc_families_agree_between_scripts():
    m, p = fp(), ps()
    assert m.FREE_PLAY_FAMILY_CRC32[0] == p.V11_FAMILY_CRC32[0], 'stock CRC disagrees'
    assert 0x7861e7cd in m.FREE_PLAY_FAMILY_CRC32, 'free play does not accept a PRESS START-only ROM'
    freeplay_only = zlib.crc32(m.apply_patches(ROM.read_bytes()))
    assert freeplay_only in p.V11_FAMILY_CRC32, \
        'PRESS START does not accept a free-play-only ROM'
    both = zlib.crc32(p.apply_patches(m.apply_patches(ROM.read_bytes())))
    assert both in m.FREE_PLAY_FAMILY_CRC32 and both in p.V11_FAMILY_CRC32, \
        "both scripts' families are missing the combined CRC"

def test_stacks_with_press_start_regardless_of_order():
    m, p = fp(), ps()
    stock = ROM.read_bytes()

    fp_then_ps = p.apply_patches(m.apply_patches(stock))
    ps_then_fp = m.apply_patches(p.apply_patches(stock))

    assert fp_then_ps == ps_then_fp, \
        'free play then PRESS START != PRESS START then free play -- the patches collide'
    assert zlib.crc32(fp_then_ps) in m.FREE_PLAY_FAMILY_CRC32
    assert zlib.crc32(fp_then_ps) in p.V11_FAMILY_CRC32

def test_free_play_accepts_a_press_start_only_rom():
    m, p = fp(), ps()
    ps_only = p.apply_patches(ROM.read_bytes())
    assert m.validate_rom(ps_only, False) is True

def test_press_start_still_accepts_its_own_family_unchanged():
    # Confirms touching V11_FAMILY_CRC32 for the two new entries did not
    # disturb the stock/PRESS-START-only pair the original suite depends on.
    p = ps()
    data = ROM.read_bytes()
    assert p.validate_rom(data, False) is True
    assert p.validate_rom(p.apply_patches(data), False) is True

if __name__ == '__main__':
    fails = 0
    for name, fn in sorted(globals().items()):
        if name.startswith('test_') and callable(fn):
            try:
                fn(); print(f'  PASS {name}')
            except Exception as e:
                fails += 1; print(f'  FAIL {name}: {e}')
    print('FAILED' if fails else 'OK')
    sys.exit(1 if fails else 0)
