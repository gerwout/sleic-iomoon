# Sleic Pin-Ball EEPROM/NVRAM Reconstruction — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Get `sleicpin` (Sleic Pin-Ball, SLEIC1) to boot past the 80188 EEPROM check ("Memoria EEPROM en mal estado / Imposible Seguir") and reach attract mode, by reconstructing and seeding a factory NVRAM image — mirroring the Bike Race (SLEIC3) fix.

**Architecture:** The 80188 (`sp03` @ `0xe0000`) validates battery-backed NVRAM at boot. `sleicpin` currently uses zero-filled `generic_0fill` NVRAM, which fails the check. We disassemble `sp03` to learn the NVRAM address/size/format and the validation logic, give SLEIC1 its own dedicated NVRAM buffer + memory map (isolated from SLEIC2/iomoon, which shares the base map), seed it with a factory image captured at runtime (hybrid: static-seed to boot, let the firmware write its own defaults, capture them), and verify headless with a DMD frame dumper.

**Tech Stack:** PinMAME (historic MAME 0.76 C), `ndisasm` (80188/x86-16), `z80dasm` (Z80), `make -f makefile.unixsdl`, `Xvfb` for headless, Python for byte/PGM tooling.

**This is reverse-engineering work:** Tasks 1-3 are discovery; the exact constants they produce (NVRAM base, size, signature/checksum, factory-init entry address) are written into a findings doc and then consumed by Tasks 6-8. Where a later task needs a discovered value, it says "from Task 3 findings" — that value is *defined* in Task 3's deliverable, not a placeholder.

**Repos & git rules:**
- Disassembly + findings → `sleic-iomoon/` repo (`research/sleicpin_disasm/`).
- Driver change → `pinmame/` repo (`src/wpc/sleic.c`, `src/wpc/sleic.h`).
- **pinmame stays local:** local commits only, explicit single-file `git add`, never `git add -A`, never push. Same explicit-add discipline for `sleic-iomoon`.

---

## Task 1: Disassemble the code ROMs + scan the data ROMs

**Files:**
- Create: `sleic-iomoon/research/sleicpin_disasm/sp03_80188_ndisasm.asm`
- Create: `sleic-iomoon/research/sleicpin_disasm/sp04_z80dasm.asm`
- Create: `sleic-iomoon/research/sleicpin_disasm/sp01_i8039_strings.txt`
- Create: `sleic-iomoon/research/sleicpin_disasm/sp02_data_strings.txt`

- [ ] **Step 1: Create the workspace**

```bash
mkdir -p /home/gerwout/iomoon/sleic-iomoon/research/sleicpin_disasm
```

- [ ] **Step 2: Disassemble sp03 (80188, 16-bit real mode)**

```bash
cd /home/gerwout/iomoon/sleic-iomoon/research/sleicpin_disasm
ndisasm -b 16 -o 0 /home/gerwout/Downloads/sleic-pin-ball/sp03-1_1.rom > sp03_80188_ndisasm.asm
wc -l sp03_80188_ndisasm.asm
```
Expected: a multi-thousand-line `.asm` file. (`-o 0` = file offset 0; the ROM maps to `0xe0000`, so physical addr = `0xe0000` + file offset. Reset vector area is near the top of the `F000` segment = file offset `0x1f000`.)

- [ ] **Step 3: Disassemble sp04 (Z80)**

```bash
z80dasm -a -t -l -g 0x0000 /home/gerwout/Downloads/sleic-pin-ball/sp04-1_1.rom > sp04_z80dasm.asm
wc -l sp04_z80dasm.asm
```
Expected: a few-thousand-line `.asm`. (If `z80dasm` flags differ, match the invocation used for `bikerace_disasm/bkio07_z80dasm.asm`.)

- [ ] **Step 4: String-scan the I8039 and data ROMs**

```bash
strings -t x -n 4 /home/gerwout/Downloads/sleic-pin-ball/sp01-1_1.rom > sp01_i8039_strings.txt
strings -t x -n 4 /home/gerwout/Downloads/sleic-pin-ball/sp02-1_1.rom > sp02_data_strings.txt
```

- [ ] **Step 5: Commit (sleic-iomoon repo)**

```bash
cd /home/gerwout/iomoon/sleic-iomoon
git add research/sleicpin_disasm/sp03_80188_ndisasm.asm \
        research/sleicpin_disasm/sp04_z80dasm.asm \
        research/sleicpin_disasm/sp01_i8039_strings.txt \
        research/sleicpin_disasm/sp02_data_strings.txt
git commit -m "research: full disassembly of Sleic Pin-Ball code ROMs (sp03/sp04) + data scans"
```

---

## Task 2: Locate the EEPROM error string and its cross-reference

**Files:**
- Read: the Task 1 outputs + the raw ROMs

- [ ] **Step 1: Find the error text in every ROM**

```bash
cd /home/gerwout/Downloads/sleic-pin-ball
for f in sp01-1_1.rom sp02-1_1.rom sp03-1_1.rom sp04-1_1.rom; do
  echo "=== $f ==="
  strings -t x "$f" | grep -iE "EEPROM|mal estado|Imposible|Seguir|Atenci" 
done
```
Expected: the Spanish strings appear in one ROM (likely `sp03` as ASCII, or `sp02` as font-encoded). Record the **file offset** of each match.

- [ ] **Step 2: If not ASCII anywhere, treat it as DMD-font-encoded**

If Step 1 finds nothing, the message is rendered from font glyph indices. Note this and fall back to locating the validation routine by structure (Task 3) instead of by string xref. Document which case applies in the findings file (Task 3).

- [ ] **Step 3: Find the xref to the string in the 80188 disassembly**

For an ASCII hit at 80188 file offset `OFF`, the physical address is `0xe0000 + OFF`; as `seg:off` that is typically `E000:(OFF)` or `F000:(OFF-0x10000)`. Search the disassembly for the immediate that loads that offset (the address the firmware `mov`s into a pointer register before calling its DMD-print routine):

```bash
cd /home/gerwout/iomoon/sleic-iomoon/research/sleicpin_disasm
# replace XXXX with the low 16 bits of the string offset found in Step 1
grep -niE "mov.*0x XXXX|, 0xXXXX" sp03_80188_ndisasm.asm | head
```
Record the address of the routine that references the string — this is the EEPROM-failure handler. The code just **above** it is the validation/branch.

- [ ] **Step 4: No commit** (analysis only; captured in Task 3's findings file)

---

## Task 3: Analyze the validation routine + write findings  *(REVIEW CHECKPOINT)*

**Files:**
- Create: `sleic-iomoon/research/sleicpin_disasm/eeprom_findings.md`

- [ ] **Step 1: Trace the validation routine**

From the failure handler found in Task 2, read backwards/upwards to the conditional branch that reaches it. Determine and write down:
  - **NVRAM physical base address and size** (Bike Race was `0x10400`, 8 KB / 28C64A — SLEIC1 may differ; confirm from the addresses the routine reads).
  - **What is validated:** signature byte string (e.g. `"(C) SLEIC ..."`), a checksum/CRC over a range, a magic constant, and/or **a stored pointer/jump vector** the firmware reads from NVRAM and `jmp`/`call`s through.
  - The exact **pass condition** (which bytes must equal what; checksum formula if any).

- [ ] **Step 2: Explicitly verify the "memory address to jump to" recollection**

Confirm or refute: does the validation (or nearby init) read a 16/20-bit address out of NVRAM and transfer control through it? Quote the opcodes. State the verdict plainly in the findings file: confirmed / refuted / partially (explain).

- [ ] **Step 3: Identify the factory-reset / NVRAM-init subroutine**

Find the routine that *writes* default NVRAM contents (the one a service "BORRADO DE TODO" / factory reset calls, or that runs when validation fails on real hardware). Record its **entry address** (`seg:off` and physical) — Task 7 may force-run it via the debugger. Note how it is normally triggered (service menu, switch combo, or automatic).

- [ ] **Step 4: Write the findings file**

Write `eeprom_findings.md` containing: NVRAM base/size, the pass condition, the jump-address verdict, the factory-init entry address + trigger, and a concrete **reconstruction recipe** (what minimal bytes pass the gate, and the plan to capture the full image). Quote the relevant disassembly lines (do not copy large blocks verbatim — cite addresses).

- [ ] **Step 5: Commit (sleic-iomoon repo)**

```bash
cd /home/gerwout/iomoon/sleic-iomoon
git add research/sleicpin_disasm/eeprom_findings.md
git commit -m "research: Sleic Pin-Ball EEPROM validation analysis + reconstruction recipe"
```

- [ ] **Step 6: STOP — present findings to the user for review before any driver edits.**

---

## Task 4: Add an env-gated DMD frame dumper to the driver

**Files:**
- Modify: `pinmame/src/wpc/sleic.c` (inside `sleic_submit_dmd_frame()`, ~line 136-161)

- [ ] **Step 1: Confirm the rawDMD buffer shape**

```bash
cd /home/gerwout/iomoon/pinmame
grep -n "rawDMD" src/wpc/sleic.c
grep -n "lcdLayout\|128\|32" src/wpc/sleic.c | head
```
Record the dimensions (Sleic DMD is 128x32) and the element type of `locals.rawDMD` so the dumper writes the right byte count.

- [ ] **Step 2: Check for an existing dump hook (don't reinvent)**

```bash
grep -niE "getenv|DMD_DUMP|fwrite|fopen" src/wpc/sleic.c
```
If a usable hook already exists, use it and skip Steps 3-4.

- [ ] **Step 3: Add the dumper** inside `sleic_submit_dmd_frame()`, right after `locals.rawDMD` is fully populated and before/after the `core_dmd_submit_frame(...)` call. Adjust `W`/`H` to the values from Step 1:

```c
/* DEBUG: env-gated DMD capture for headless verification.
 * Set SLEIC_DMD_DUMP=/path/prefix to append one PGM (P5) per frame:
 * /path/prefix.<seq>.pgm.  Off by default. */
{
  const char *dumppfx = getenv("SLEIC_DMD_DUMP");
  if (dumppfx) {
    static int sleic_dmd_seq = 0;
    const int W = 128, H = 32;          /* from Step 1 */
    char fn[512];
    FILE *fp;
    snprintf(fn, sizeof fn, "%s.%05d.pgm", dumppfx, sleic_dmd_seq++);
    fp = fopen(fn, "wb");
    if (fp) {
      int i;
      fprintf(fp, "P5\n%d %d\n255\n", W, H);
      for (i = 0; i < W * H; i++) {
        unsigned v = (unsigned)locals.rawDMD[i];
        unsigned char px = (v > 3) ? (unsigned char)v : (unsigned char)(v * 85); /* 0..3 -> 0..255 */
        fputc(px, fp);
      }
      fclose(fp);
    }
  }
}
```

- [ ] **Step 4: Build**

```bash
cd /home/gerwout/iomoon/pinmame
make -f makefile.unixsdl 2>&1 | tail -15
```
Expected: builds to `xpinmame.sdl` with no errors.

- [ ] **Step 5: Commit (pinmame repo, local, explicit add)**

```bash
cd /home/gerwout/iomoon/pinmame
git add src/wpc/sleic.c
git commit -m "sleic: add env-gated DMD frame dumper (SLEIC_DMD_DUMP) for headless verification"
```

---

## Task 5: Capture the baseline "before" DMD (confirm the error headless)

**Files:**
- Create: `/tmp/sleicpin_before/` (PGM frames — not committed)

- [ ] **Step 1: Run headless with DMD capture**

```bash
cd /home/gerwout/iomoon/pinmame
pkill Xvfb 2>/dev/null; Xvfb :99 -screen 0 1280x1024x24 & sleep 1; export DISPLAY=:99
rm -f roms/sleicpin.nv 2>/dev/null   # also clear the nvram dir copy if present
mkdir -p /tmp/sleicpin_before
SDL_AUDIODRIVER=dummy SLEIC_DMD_DUMP=/tmp/sleicpin_before/f \
  ./xpinmame.sdl sleicpin --rompath roms \
  -nosound -skip_disclaimer -skip_gameinfo -skip_gamewarnings -ftr 400
ls /tmp/sleicpin_before/ | wc -l
```
Expected: PGM frames written; run exits with `Average FPS:`.

- [ ] **Step 2: Confirm the error frame is present**

Convert a few late frames to viewable PNGs (or open the PGMs) and confirm the "EEPROM EN MAL ESTADO" text is visible. Use `sleic-iomoon/scripts/dmd_viewer.py` or ImageMagick:
```bash
command -v convert && convert /tmp/sleicpin_before/f.00200.pgm -scale 512x128 /tmp/sleicpin_before_200.png
```
Record that the baseline shows the error (evidence for before/after).

- [ ] **Step 3: No commit** (baseline artifacts are throwaway under /tmp)

---

## Task 6: Give SLEIC1 a dedicated NVRAM buffer + isolated memory map  *(uses Task 3 findings)*

**Files:**
- Modify: `pinmame/src/wpc/sleic.c` (add SLEIC1 NVRAM block + SLEIC1 80188 maps + machine-driver wiring)

> **Template — the working SLEIC3 block to copy (sleic.c:331-413).** Adapt the names to `sleic1_*`, and set the NVRAM region/base to the address+size from **Task 3 findings** (do NOT assume `0x10400`/8 KB; use what the disassembly showed). For now seed only the **minimal bytes that pass the gate** (signature + checksum from Task 3) — the full image is captured in Task 7.

- [ ] **Step 1: Add the SLEIC1 NVRAM buffer, handlers, and NVRAM_HANDLER** near the SLEIC3 block. `NV_BASE`/`NV_SIZE` come from Task 3:

```c
/* Sleic Pin-Ball (SLEIC1) NVRAM: dedicated buffer persisted by NVRAM_HANDLER(SLEIC1).
 * On a fresh boot core_nvram zero-fills, then we overlay the captured factory image
 * (sleic1_nvram_init) so the firmware's EEPROM validation passes. Base/size per
 * research/sleicpin_disasm/eeprom_findings.md. */
static UINT8 sleic1_nvram[NV_SIZE];                 /* NV_SIZE from Task 3 */
static const UINT8 sleic1_nvram_init[] = {
  /* Task 6: minimal signature+checksum bytes that pass the gate (from Task 3).
   * Task 8 replaces this with the full captured factory image (non-zero head). */
};
static READ_HANDLER(sleic1_nvram_r)  { return sleic1_nvram[offset]; }
static WRITE_HANDLER(sleic1_nvram_w) { sleic1_nvram[offset] = data; }
static NVRAM_HANDLER(SLEIC1) {
  core_nvram(file, read_or_write, sleic1_nvram, sizeof sleic1_nvram, 0x00);
  if (!read_or_write && !file)
    memcpy(sleic1_nvram, sleic1_nvram_init, sizeof sleic1_nvram_init);
}
```

- [ ] **Step 2: Add SLEIC1-specific 80188 memory maps** so editing them never touches SLEIC2/iomoon (which keeps the shared `SLEIC_80188_readmem/writemem`). Copy `SLEIC_80188_readmem/writemem` (sleic.c:298-310), rename to `SLEIC1_80188_readmem/writemem`, and replace the `generic_nvram` line with the dedicated NVRAM region at the Task 3 base/size:

```c
static MEMORY_READ_START(SLEIC1_80188_readmem)
  /* ... identical to SLEIC_80188_readmem except the NVRAM region: */
  {NV_BASE, NV_BASE+NV_SIZE-1, sleic1_nvram_r},
  /* ... remaining entries copied from SLEIC_80188_readmem ... */
MEMORY_END

static MEMORY_WRITE_START(SLEIC1_80188_writemem)
  {NV_BASE, NV_BASE+NV_SIZE-1, sleic1_nvram_w},
  /* ... remaining entries copied from SLEIC_80188_writemem ... */
MEMORY_END
```

- [ ] **Step 3: Wire the SLEIC1 machine driver** (`MACHINE_DRIVER_START(SLEIC1)`, sleic.c:688). Override the inherited `generic_0fill` and the shared map:

```c
MACHINE_DRIVER_START(SLEIC1)
  MDRV_IMPORT_FROM(SLEIC)

  MDRV_NVRAM_HANDLER(SLEIC1)
  MDRV_CPU_REPLACE("mcpu", I188, 8000000)
  MDRV_CPU_MEMORY(SLEIC1_80188_readmem, SLEIC1_80188_writemem)
  MDRV_CPU_PORTS(SLEIC_80188_readport, SLEIC_80188_writeport)
  MDRV_CPU_VBLANK_INT(SLEIC_interface_update, 1)
  MDRV_CPU_PERIODIC_INT(SLEIC_irq_i80188, 120)

  /* ... existing SLEIC1 display/sound section unchanged (I8039 + YM3812 + OKI + DAC) ... */
MACHINE_DRIVER_END
```
(Keep the existing display/sound `MDRV_*` lines that already follow.)

- [ ] **Step 4: Clean build** (NVRAM struct/region change → clean rebuild per CLAUDE.md)

```bash
cd /home/gerwout/iomoon/pinmame
make -f makefile.unixsdl clean && make -f makefile.unixsdl 2>&1 | tail -15
```
Expected: builds cleanly to `xpinmame.sdl`.

- [ ] **Step 5: Smoke-run — does it pass the gate?**

```bash
export DISPLAY=:99; rm -f roms/sleicpin.nv
mkdir -p /tmp/sleicpin_seed
SDL_AUDIODRIVER=dummy SLEIC_DMD_DUMP=/tmp/sleicpin_seed/f \
  ./xpinmame.sdl sleicpin --rompath roms -nosound -skip_disclaimer -skip_gameinfo -skip_gamewarnings -ftr 400
```
Expected: the minimal seed gets past the "mal estado" halt (frames now advance beyond the error). If it still halts, the seed/checksum is wrong — revisit Task 3 before proceeding.

- [ ] **Step 6: Commit (pinmame repo, local, explicit add)**

```bash
cd /home/gerwout/iomoon/pinmame
git add src/wpc/sleic.c
git commit -m "sleic: SLEIC1 dedicated NVRAM buffer + isolated 80188 map; minimal gate-passing seed"
```

---

## Task 7: Runtime-capture the full factory image

**Files:**
- Produces: the on-disk `sleicpin.nv` (PinMAME-written) → source for Task 8

- [ ] **Step 1: Locate where PinMAME writes the .nv**

```bash
cd /home/gerwout/iomoon/pinmame
./xpinmame.sdl sleicpin --rompath roms -listconfig 2>/dev/null | grep -i nvram || true
find . -name "sleicpin.nv" 2>/dev/null
```
Record the nvram directory (default is the `nvram` rc-option path; commonly `<cwd>/nvram/` or `release/nvram/`).

- [ ] **Step 2: Drive the firmware to write full defaults.** Two options — prefer (a):

  **(a) Firmware factory-reset path.** If Task 3 found the factory-init is reachable by input (service switch / menu), run long enough (`-ftr 2000+`) and/or inject the switch so the firmware initializes every table itself.

  **(b) Debugger-forced init.** Use the debug build to force the factory-init routine found in Task 3:
```bash
make -f makefile.unixsdl_debug 2>&1 | tail -5
export DISPLAY=:99; rm -f nvram/sleicpin.nv
./xpinmamed.sdl sleicpin --rompath roms -debug -nosound \
  -skip_disclaimer -skip_gameinfo -skip_gamewarnings
# In the MAME debugger: set PC to the factory-init entry (Task 3), run a few thousand
# cycles so it writes NVRAM, then quit so core_nvram flushes sleicpin.nv.
```

- [ ] **Step 3: Confirm a populated .nv exists**

```bash
ls -l nvram/sleicpin.nv 2>/dev/null || ls -l release/nvram/sleicpin.nv
xxd nvram/sleicpin.nv | head -20   # expect the signature string + non-zero config tables
```
Expected: the head shows the `"(C) SLEIC ..."`-style signature and non-zero config/coin tables (not all zeros).

- [ ] **Step 4: No commit** (the `.nv` is an intermediate; the bytes go into source in Task 8)

---

## Task 8: Embed the captured factory image as the seed

**Files:**
- Create: `sleic-iomoon/research/sleicpin_disasm/sleicpin_factory.nv` (archived capture)
- Modify: `pinmame/src/wpc/sleic.c` (replace `sleic1_nvram_init[]` contents)

- [ ] **Step 1: Archive the capture**

```bash
cp /home/gerwout/iomoon/pinmame/nvram/sleicpin.nv \
   /home/gerwout/iomoon/sleic-iomoon/research/sleicpin_disasm/sleicpin_factory.nv
```

- [ ] **Step 2: Generate the C array (non-zero head only)** — mirror the SLEIC3 style (embed the non-zero head; `core_nvram` zero-fills the tail):

```bash
cd /home/gerwout/iomoon/sleic-iomoon/research/sleicpin_disasm
python3 - <<'PY'
data = open("sleicpin_factory.nv","rb").read()
end = len(data)
while end > 0 and data[end-1] == 0: end -= 1   # trim trailing zeros
head = data[:end]
print(f"/* {end} non-zero head bytes of {len(data)} total */")
for i in range(0, len(head), 16):
    row = ",".join(f"0x{b:02X}" for b in head[i:i+16])
    print("  " + row + ",")
PY
```

- [ ] **Step 3: Paste the array** into `sleic1_nvram_init[]` in `sleic.c`, replacing the Task 6 minimal seed. Keep the explanatory comment.

- [ ] **Step 4: Clean build**

```bash
cd /home/gerwout/iomoon/pinmame
make -f makefile.unixsdl clean && make -f makefile.unixsdl 2>&1 | tail -15
```
Expected: clean build to `xpinmame.sdl`.

- [ ] **Step 5: Commit both repos (local, explicit adds)**

```bash
cd /home/gerwout/iomoon/sleic-iomoon
git add research/sleicpin_disasm/sleicpin_factory.nv
git commit -m "research: archive captured Sleic Pin-Ball factory NVRAM image"

cd /home/gerwout/iomoon/pinmame
git add src/wpc/sleic.c
git commit -m "sleic: seed SLEIC1 factory NVRAM image so sleicpin passes the EEPROM check"
```

---

## Task 9: Verify headless — error gone, attract reached

**Files:**
- Create: `/tmp/sleicpin_after/` (PGM frames — not committed)

- [ ] **Step 1: Fresh-boot run with capture**

```bash
cd /home/gerwout/iomoon/pinmame
export DISPLAY=:99; rm -f nvram/sleicpin.nv roms/sleicpin.nv
mkdir -p /tmp/sleicpin_after
SDL_AUDIODRIVER=dummy SLEIC_DMD_DUMP=/tmp/sleicpin_after/f \
  ./xpinmame.sdl sleicpin --rompath roms \
  -nosound -skip_disclaimer -skip_gameinfo -skip_gamewarnings -ftr 800
ls /tmp/sleicpin_after/ | wc -l
```

- [ ] **Step 2: Confirm the error is gone and attract is reached**

Convert a spread of frames and inspect:
```bash
for n in 00100 00300 00500 00700; do
  convert /tmp/sleicpin_after/f.$n.pgm -scale 512x128 /tmp/sleicpin_after_$n.png 2>/dev/null
done
```
Expected: **no** "MAL ESTADO" text; frames show attract content (game name / score / animation). This is the success criterion.

- [ ] **Step 3: If still failing**, the seed is incomplete — return to Task 7 (capture more of the firmware's init, e.g. run the factory-reset fully) and Task 8. Use `superpowers:systematic-debugging`.

---

## Task 10: Persistence check, cleanup, and final summary

**Files:**
- Modify: none (verification + optional doc update)

- [ ] **Step 1: Persistence round-trip**

```bash
cd /home/gerwout/iomoon/pinmame
export DISPLAY=:99; rm -f nvram/sleicpin.nv
./xpinmame.sdl sleicpin --rompath roms -nosound -skip_disclaimer -skip_gameinfo -skip_gamewarnings -ftr 400
ls -l nvram/sleicpin.nv      # created on first run
./xpinmame.sdl sleicpin --rompath roms -nosound -skip_disclaimer -skip_gameinfo -skip_gamewarnings -ftr 400
```
Expected: second run loads the existing `.nv` (no re-seed) and still boots clean — confirms persistence works, not just first-boot seeding.

- [ ] **Step 2: Decide on the GAME_NOT_WORKING flag**

Leave `GAME_NOT_WORKING` set unless attract+input clearly work — this fix only clears the EEPROM gate. Note status in the findings file.

- [ ] **Step 3: Optional — record the result** in `sleic-iomoon/research/sleicpin_disasm/eeprom_findings.md` (what the seed contained, what now works, what's still blocked). Commit (sleic-iomoon, explicit add).

- [ ] **Step 4: Confirm git hygiene**

```bash
cd /home/gerwout/iomoon/pinmame && git status -s   # only untracked build/roms artifacts; no -A commits; nothing pushed
```

---

## Self-review notes
- **Spec coverage:** Phase 1→Task 1; Phase 2→Tasks 2-3 (incl. jump-address verification, Task 3 Step 2); Phase 3→Tasks 7-8; Phase 4→Task 6; Phase 5 + DMD capture→Tasks 4,5,9; persistence→Task 10. Review checkpoints: Task 3 Step 6 (after analysis) and Task 6 (first driver edit, gated on Task 3 findings).
- **Discovery-gated constants** (`NV_BASE`, `NV_SIZE`, signature/checksum, factory-init entry) are defined in Task 3's `eeprom_findings.md` and consumed by name in Tasks 6-8 — intentional data dependency, not placeholders.
- **Isolation:** SLEIC1 gets its own maps + `MDRV_CPU_REPLACE`; SLEIC2/iomoon's shared base map is untouched.
- **Git:** every commit is local + explicit-add; no `git add -A`; no push.
