#!/usr/bin/env python3
"""Byte-level tests for the Sleic Pin-Ball PRESS START patch. Run: python3 this."""
import pathlib, subprocess, sys, tempfile, types, zlib

sys.dont_write_bytecode = True  # never cache bytecode; the suite must reflect the file on disk

HERE = pathlib.Path(__file__).resolve().parent
SCRIPTS = HERE.parent
ROM = SCRIPTS.parent / 'roms/related-machines/sleic-pin-ball/sp03-1_1.rom'

def load():
    # Exec the source text directly. importlib's loader validates cached
    # bytecode against (source mtime, source size); an edit that lands at the
    # same byte length with the mtime unchanged reuses a stale .pyc instead
    # of the code actually on disk.
    path = SCRIPTS / 'sleic_pin_ball_press_start_patch.py'
    m = types.ModuleType('ps')
    m.__file__ = str(path)
    exec(compile(path.read_text(), str(path), 'exec'), m.__dict__)
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

def test_trampoline_common_assembles_as_written():
    m = load()
    with tempfile.TemporaryDirectory() as t:
        src = pathlib.Path(t) / 'a.asm'; out = pathlib.Path(t) / 'a.bin'
        src.write_text(m.TRAMPOLINE_COMMON_ASM)
        subprocess.run(['nasm', '-f', 'bin', '-o', str(out), str(src)], check=True)
        assert out.read_bytes() == bytes(m.TRAMPOLINE_COMMON)

def test_trampoline_tenth_assembles_as_written():
    m = load()
    with tempfile.TemporaryDirectory() as t:
        src = pathlib.Path(t) / 'a.asm'; out = pathlib.Path(t) / 'a.bin'
        src.write_text(m.TRAMPOLINE_TENTH_ASM)
        subprocess.run(['nasm', '-f', 'bin', '-o', str(out), str(src)], check=True)
        assert out.read_bytes() == bytes(m.TRAMPOLINE_TENTH)

def test_trampoline_credit_gate_assembles_as_written():
    m = load()
    with tempfile.TemporaryDirectory() as t:
        src = pathlib.Path(t) / 'a.asm'; out = pathlib.Path(t) / 'a.bin'
        src.write_text(m.TRAMPOLINE_CREDIT_GATE_ASM)
        subprocess.run(['nasm', '-f', 'bin', '-o', str(out), str(src)], check=True)
        assert out.read_bytes() == bytes(m.TRAMPOLINE_CREDIT_GATE)

def test_credit_gate_trampoline_jumps_resolve_correctly():
    m = load()
    b = bytes(m.TRAMPOLINE_CREDIT_GATE)
    addr = m.TRAMPOLINE_CREDIT_GATE_ADDR
    assert b[14] == 0xE9, 'byte 14 is not the leave-the-loop jmp opcode'
    rel1 = int.from_bytes(b[15:17], 'little')
    target1 = (addr + 17 + rel1) & 0xFFFF
    assert target1 == 0x106, f'leave-the-loop jmp targets {target1:#06x}, not 0x106'
    assert b[17] == 0xE9, 'byte 17 is not the dispatch jmp opcode'
    rel2 = int.from_bytes(b[18:20], 'little')
    target2 = (addr + 20 + rel2) & 0xFFFF
    assert target2 == 0xF6, f'dispatch jmp targets {target2:#06x}, not 0xF6'

def test_credit_gate_dispatches_on_the_patch_own_pending_index():
    m = load()
    asm = m.TRAMPOLINE_CREDIT_GATE_ASM.lower()
    assert '0x17d' in asm and '25' in asm, \
        'trampoline does not test the patch spare sequence index (25)'
    assert bytes([0x83, 0x3E, 0x7D, 0x01, 0x19]) in bytes(m.TRAMPOLINE_CREDIT_GATE), \
        'missing cmp word [0x17d], 25'

def test_trampoline_credit_gate_entrance_assembles_as_written():
    m = load()
    with tempfile.TemporaryDirectory() as t:
        src = pathlib.Path(t) / 'a.asm'; out = pathlib.Path(t) / 'a.bin'
        src.write_text(m.TRAMPOLINE_CREDIT_GATE_ENTRANCE_ASM)
        subprocess.run(['nasm', '-f', 'bin', '-o', str(out), str(src)], check=True)
        assert out.read_bytes() == bytes(m.TRAMPOLINE_CREDIT_GATE_ENTRANCE)

def test_credit_gate_entrance_trampoline_jumps_resolve_correctly():
    m = load()
    b = bytes(m.TRAMPOLINE_CREDIT_GATE_ENTRANCE)
    addr = m.TRAMPOLINE_CREDIT_GATE_ENTRANCE_ADDR
    assert b[14] == 0xE9, 'byte 14 is not the leave-the-loop jmp opcode'
    rel1 = int.from_bytes(b[15:17], 'little')
    target1 = (addr + 17 + rel1) & 0xFFFF
    assert target1 == 0x106, f'leave-the-loop jmp targets {target1:#06x}, not 0x106'
    assert b[17] == 0xE9, 'byte 17 is not the continue jmp opcode'
    rel2 = int.from_bytes(b[18:20], 'little')
    target2 = (addr + 20 + rel2) & 0xFFFF
    assert target2 == 0xE2, f'continue jmp targets {target2:#06x}, not 0xE2'

def test_credit_gate_entrance_dispatches_on_the_patch_own_pending_index():
    m = load()
    asm = m.TRAMPOLINE_CREDIT_GATE_ENTRANCE_ASM.lower()
    assert '0x17d' in asm and '25' in asm, \
        'trampoline does not test the patch spare sequence index (25)'
    assert bytes([0x83, 0x3E, 0x7D, 0x01, 0x19]) in bytes(m.TRAMPOLINE_CREDIT_GATE_ENTRANCE), \
        'missing cmp word [0x17d], 25'

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

def test_workspace_slots_are_disjoint_and_pinned():
    m = load()
    # digits +0..+7, DRAWN +8, SAVED +9..+10 (word), COUNT +11,
    # SCORE_SNAPSHOT +12..+43 (4 players x 8 digit bytes).
    assert m.DRAWN_ADDR == m.WORKSPACE_ADDR + 8
    assert m.SAVED_ADDR == m.WORKSPACE_ADDR + 9
    assert m.COUNT_ADDR == m.WORKSPACE_ADDR + 11
    assert m.SCORE_SNAPSHOT_ADDR == m.WORKSPACE_ADDR + 12
    slots = [
        ('digit buffer', m.WORKSPACE_ADDR, 8),
        ('DRAWN_ADDR', m.DRAWN_ADDR, 1),
        ('SAVED_ADDR', m.SAVED_ADDR, 2),
        ('COUNT_ADDR', m.COUNT_ADDR, 1),
        ('SCORE_SNAPSHOT_ADDR', m.SCORE_SNAPSHOT_ADDR, 32),
    ]
    ranges = sorted((addr, addr + size) for _, addr, size in slots)
    for (_, end), (start, _) in zip(ranges, ranges[1:]):
        assert end <= start, f'workspace slots overlap: {ranges}'
    lo = min(addr for _, addr, _ in slots)
    hi = max(addr + size for _, addr, size in slots)
    assert hi - lo == 44, 'the whole claim is not 44 bytes'
    assert 0x377 <= lo and hi <= 0x3E7 + 1, \
        f'workspace claim {lo:#x}-{hi-1:#x} falls outside the 0x377-0x3E7 run'

def test_hooks_are_present_and_match_the_stock_rom():
    m = load()
    data = ROM.read_bytes()
    assert len(m.HOOKS) == 5, \
        'expected the table entry, both game-over tails and both credit gates'
    for addr, original, patched, label in m.HOOKS:
        off = m.physical_to_file(addr)
        assert data[off:off+len(original)] == original, f'{label}: stock bytes differ'
        assert len(original) == len(patched), f'{label}: patch changes length'

def test_the_spare_table_entry_is_the_hook():
    m = load()
    by_addr = {addr: (o, p) for addr, o, p, _ in m.HOOKS}
    assert 0xE4FAE in by_addr, 'spare entry 25 of the E000:4F7C table is not hooked'
    original, patched = by_addr[0xE4FAE]
    assert original == bytes([0x22, 0x50]), 'stock entry 25 is not 0x5022'
    assert int.from_bytes(patched, 'little') == m.STUB_ADDR & 0xFFFF
    assert 0xE4FAA not in by_addr, 'entry 23 must be left alone, or attract shows the screen'

def test_both_game_over_tails_are_redirected():
    m = load()
    by_addr = {addr: (o, p) for addr, o, p, _ in m.HOOKS}
    for addr, imm, label in ((0xE197C, 0x17, 'the common tail'),
                             (0xE1962, 0x01, 'the tenth-game tail')):
        assert addr in by_addr, f'{label} at {addr:#07x} is not hooked'
        original, _ = by_addr[addr]
        assert original == bytes([0x3E, 0xC7, 0x06, 0x7D, 0x01, imm, 0x00]), \
            f'{label}: stock bytes are not mov word ds:[0x17d], {imm:#04x}'

def test_credit_gate_hook_matches_stock_bytes():
    m = load()
    data = ROM.read_bytes()
    expected = bytes([0xA0, 0x00, 0x01, 0x22, 0xC0, 0x74, 0x03, 0xE9, 0x10, 0x00])
    off = m.physical_to_file(m.GAME_OVER_CREDIT_GATE_ADDR)
    assert data[off:off+10] == expected, \
        'E000:00EC is not the stock credit test; wrong ROM revision?'
    assert m.GAME_OVER_CREDIT_GATE_ORIGINAL == expected

def test_credit_gate_entrance_hook_matches_stock_bytes():
    m = load()
    data = ROM.read_bytes()
    expected = bytes([0xA0, 0x00, 0x01, 0x22, 0xC0, 0x74, 0x03, 0xE9, 0x24, 0x00])
    off = m.physical_to_file(m.GAME_OVER_CREDIT_GATE_ENTRANCE_ADDR)
    assert data[off:off+10] == expected, \
        'E000:00D8 is not the stock credit test; wrong ROM revision?'
    assert m.GAME_OVER_CREDIT_GATE_ENTRANCE_ORIGINAL == expected

def test_credit_gate_hook_leaves_its_jump_targets_untouched():
    m = load()
    data = ROM.read_bytes()
    # E000:00F6, the dispatcher call the trampoline jumps to, sits right
    # after the replaced range and must still be `call 0x4F4E`.
    off_f6 = m.physical_to_file(0xE00F6)
    assert data[off_f6:off_f6+3] == bytes([0xE8, 0x55, 0x4E]), \
        'E000:00F6 is not call 0x4F4E; the trampoline would dispatch nowhere'
    # E000:0106, the stock "leave the loop" target, must still be reachable
    # as ordinary code (the replaced range's own stock jmp landed there).
    off_106 = m.physical_to_file(0xE0106)
    assert off_106 < len(data), 'E000:0106 falls outside the ROM'

def test_credit_gate_entrance_hook_leaves_its_jump_targets_untouched():
    m = load()
    data = ROM.read_bytes()
    # E000:00E2, the fall-back-into-the-loop target, sits right after the
    # replaced range and must still be the stock `mov al, 0x70`.
    off_e2 = m.physical_to_file(0xE00E2)
    assert data[off_e2:off_e2+2] == bytes([0xB0, 0x70]), \
        'E000:00E2 is not mov al, 0x70; the trampoline would fall back nowhere'
    off_106 = m.physical_to_file(0xE0106)
    assert off_106 < len(data), 'E000:0106 falls outside the ROM'

def test_score_block_bases_match_the_rom_score_table():
    m = load()
    data = ROM.read_bytes()
    stock = [int.from_bytes(data[0x1911+2*i:0x1913+2*i], 'little') for i in range(4)]
    assert stock == [0x1E7, 0x209, 0x22B, 0x24D], 'block bases do not match the ROM score table at 0x1911'
    assert list(m.SCORE_BLOCK_BASES) == stock, \
        "SCORE_BLOCK_BASES does not match the ROM's own bases"

def test_draw_screen_does_not_reference_the_live_score_blocks():
    m = load()
    # The live blocks are zeroed by the attract loop's entry preamble before
    # the stub's first tick, so draw_screen must read the trampolines' score
    # snapshot instead -- never the live block bases directly.
    b = bytes(m.DRAW_SCREEN)
    for base in (0x1E7, 0x209, 0x22B, 0x24D):
        assert base.to_bytes(2, 'little') not in b, \
            f'draw_screen still references live block {base:#05x}; it must use the snapshot'

def test_trampolines_snapshot_all_four_score_blocks():
    m = load()
    for base in m.SCORE_BLOCK_BASES:
        src = (base + 4).to_bytes(2, 'little')
        assert src in bytes(m.TRAMPOLINE_COMMON), \
            f'common trampoline does not copy from block {base:#05x} + 4'
        assert src in bytes(m.TRAMPOLINE_TENTH), \
            f'tenth trampoline does not copy from block {base:#05x} + 4'
    dest = m.SCORE_SNAPSHOT_ADDR.to_bytes(2, 'little')
    assert dest in bytes(m.TRAMPOLINE_COMMON), 'common trampoline never targets SCORE_SNAPSHOT_ADDR'
    assert dest in bytes(m.TRAMPOLINE_TENTH), 'tenth trampoline never targets SCORE_SNAPSHOT_ADDR'

def test_draw_screen_reads_the_score_snapshot():
    m = load()
    # score_digits is called with BX = SCORE_SNAPSHOT_ADDR - 4, so its own
    # [BX+4]..[BX+11] indexing lands on the snapshot, not the live block.
    anchor = ((m.SCORE_SNAPSHOT_ADDR - 4) & 0xFFFF).to_bytes(2, 'little')
    assert anchor in bytes(m.DRAW_SCREEN), \
        'draw_screen never computes BX = SCORE_SNAPSHOT_ADDR - 4'

def test_score_digits_reads_offsets_4_through_11():
    m = load()
    b = bytes(m.SCORE_DIGITS)
    assert bytes([0x83, 0xC6, 0x0B]) in b, 'does not start at block+11 (add si, 11)'
    assert bytes([0xB9, 0x08, 0x00]) in b, 'does not read 8 digits down to block+4 (mov cx, 8)'

def test_stock_tails_end_in_ret_right_after_the_hooked_mov():
    m = load()
    data = ROM.read_bytes()
    assert data[m.physical_to_file(0xE197C) + 7] == 0xC3, \
        "stock byte past the common tail's hooked mov is not ret"
    assert data[m.physical_to_file(0xE1962) + 7] == 0xC3, \
        "stock byte past the tenth-game tail's hooked mov is not ret"

def test_draw_screen_and_trampolines_share_the_count_snapshot():
    m = load()
    read_snapshot = bytes([0xA0]) + m.COUNT_ADDR.to_bytes(2, 'little')
    assert read_snapshot in bytes(m.DRAW_SCREEN), 'draw_screen does not read COUNT_ADDR'
    assert bytes([0xA0, 0x06, 0x01]) not in bytes(m.DRAW_SCREEN), \
        'draw_screen reads the live [0x106], which is already zeroed by the time it runs'
    write_snapshot = bytes([0xA0, 0x06, 0x01, 0xA2]) + m.COUNT_ADDR.to_bytes(2, 'little')
    assert write_snapshot in bytes(m.TRAMPOLINE_COMMON), 'common trampoline does not snapshot [0x106]'
    assert write_snapshot in bytes(m.TRAMPOLINE_TENTH), 'tenth trampoline does not snapshot [0x106]'

def test_apply_patches_writes_nothing_outside_caves_and_hooks():
    m = load()
    stock = ROM.read_bytes()
    patched = m.apply_patches(stock)
    allowed = set()
    for addr, blob, _ in m.CAVES:
        allowed |= set(range(m.physical_to_file(addr), m.physical_to_file(addr)+len(blob)))
    for addr, original, _, _ in m.HOOKS:
        allowed |= set(range(m.physical_to_file(addr), m.physical_to_file(addr)+len(original)))
    diff = {i for i in range(len(stock)) if stock[i] != patched[i]}
    assert diff <= allowed, f'{len(diff - allowed)} bytes changed outside cave and hook'

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
