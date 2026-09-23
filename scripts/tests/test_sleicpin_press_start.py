#!/usr/bin/env python3
"""Byte-level tests for the Sleic Pin-Ball PRESS START patch. Run: python3 this."""
import importlib.util, pathlib, subprocess, sys, tempfile, zlib

HERE = pathlib.Path(__file__).resolve().parent
SCRIPTS = HERE.parent
ROM = SCRIPTS.parent / 'roms/related-machines/sleic-pin-ball/sp03-1_1.rom'

def load():
    spec = importlib.util.spec_from_file_location(
        'ps', SCRIPTS / 'sleic_pin_ball_press_start_patch.py')
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m

def test_stock_rom_is_accepted():
    m = load()
    data = ROM.read_bytes()
    assert zlib.crc32(data) == 0x261b0ae4, 'wrong stock ROM'
    assert m.validate_rom(data, False) is True

def test_caves_fit_the_padding():
    m = load()
    data = ROM.read_bytes()
    for addr, blob, label in m.CAVES:
        off = m.physical_to_file(addr)
        assert 0 <= off and off + len(blob) <= len(data), f'{label} outside the ROM'
        assert all(b == 0xFF for b in data[off:off+len(blob)]), f'{label} space not empty'
        in_e000 = 0xE50EB <= addr and addr + len(blob) - 1 <= 0xEFFFF
        in_f000 = 0xFDFF0 <= addr and addr + len(blob) - 1 <= 0xFFE76
        assert in_e000 or in_f000, \
            f'{label} outside the E50EB-EFFFF or FDFF0-FE76 padding'

def test_patch_is_idempotent():
    m = load()
    once = m.apply_patches(ROM.read_bytes())
    assert m.is_already_patched(once)
    assert m.apply_patches(once) == once

def test_foreign_rom_is_refused():
    m = load()
    junk = bytes(m.ROM_SIZE)
    assert m.validate_rom(junk, False) is False

def test_digits_draw_assembles_as_written():
    m = load()
    with tempfile.TemporaryDirectory() as t:
        src = pathlib.Path(t) / 'a.asm'; out = pathlib.Path(t) / 'a.bin'
        src.write_text(m.DIGITS_DRAW_ASM)
        subprocess.run(['nasm', '-f', 'bin', '-o', str(out), str(src)], check=True)
        assert out.read_bytes() == bytes(m.DIGITS_DRAW), 'byte list != nasm output'

def test_score_digits_assembles_as_written():
    m = load()
    with tempfile.TemporaryDirectory() as t:
        src = pathlib.Path(t) / 'a.asm'; out = pathlib.Path(t) / 'a.bin'
        src.write_text(m.SCORE_DIGITS_ASM)
        subprocess.run(['nasm', '-f', 'bin', '-o', str(out), str(src)], check=True)
        assert out.read_bytes() == bytes(m.SCORE_DIGITS)

def test_prompt_record_is_eleven_glyph_pointers():
    m = load()
    assert m.PROMPT_RECORD[:2] == bytes([11, 0]), 'count word is not 11'
    assert len(m.PROMPT_RECORD) == 2 + 22, 'record is not count + 11 words'
    # 'N with tilde' sits between N and O, so every letter from O on is one
    # higher than its position in the plain Latin alphabet would suggest.
    ALPHA = 'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ'
    for k, ch in enumerate('PRESS START'):
        idx = 10 if ch == ' ' else 11 + ALPHA.index(ch)
        ptr = int.from_bytes(m.PROMPT_RECORD[2+2*k:4+2*k], 'little')
        assert ptr == 0x85EB + 8*idx, f'glyph {k} ({ch!r}) points at {ptr:#06x}'

def test_draw_screen_assembles_as_written():
    m = load()
    with tempfile.TemporaryDirectory() as t:
        src = pathlib.Path(t) / 'a.asm'; out = pathlib.Path(t) / 'a.bin'
        src.write_text(m.DRAW_SCREEN_ASM)
        subprocess.run(['nasm', '-f', 'bin', '-o', str(out), str(src)], check=True)
        assert out.read_bytes() == bytes(m.DRAW_SCREEN)

def test_draw_screen_uses_the_documented_slots():
    m = load()
    for off in (0x410, 0x418, 0x510, 0x518, 0x712):
        assert off.to_bytes(2, 'little') in bytes(m.DRAW_SCREEN), f'{off:#05x} missing'

def test_stub_assembles_as_written():
    m = load()
    with tempfile.TemporaryDirectory() as t:
        src = pathlib.Path(t) / 'a.asm'; out = pathlib.Path(t) / 'a.bin'
        src.write_text(m.STUB_ASM)
        subprocess.run(['nasm', '-f', 'bin', '-o', str(out), str(src)], check=True)
        assert out.read_bytes() == bytes(m.STUB)

def test_stub_polls_the_switch_queue_far():
    m = load()
    assert bytes([0x9A, 0xEF, 0x54, 0x00, 0xF0]) in bytes(m.STUB), 'no far call to F000:54EF'

def test_stub_hands_back_to_the_saved_step():
    m = load()
    asm = m.STUB_ASM.lower()
    assert '0x17d' in asm, 'stub never writes the sequence index'
    assert hex(m.SAVED_ADDR) in asm, 'stub never reads the saved step'
    assert '0x5090' not in asm, 'stub must not hard-code step 23; it restores the saved step'
    assert '0x50d5' not in asm, 'stub must not jump to the advance tail itself'

def test_workspace_is_above_the_vector_table():
    m = load()
    assert m.WORKSPACE_ADDR >= 0x100, 'the workspace would land in the vector table'
    assert m.DRAWN_ADDR == m.WORKSPACE_ADDR + 8, 'the flag is not the workspace tail'

if __name__ == '__main__':
    fails = 0
    for name, fn in sorted(globals().items()):
        if name.startswith('test_') and callable(fn):
            try:
                fn(); print(f'  PASS {name}')
            except AssertionError as e:
                fails += 1; print(f'  FAIL {name}: {e}')
    print('FAILED' if fails else 'OK')
    sys.exit(1 if fails else 0)
