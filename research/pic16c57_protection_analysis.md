# PIC16C57 Code Protection — How the Locked IC23 Was Cracked, and Whether Hobbyists Can Repeat It

Preservation research for SLEIC **IO Moon** (1994). Chip in question: **IC23 = Microchip PIC16C57‑HS/P**
(PDIP‑28, OTP EPROM, no UV window), the DMD raster coprocessor. Owner holds full legal rights to this
preservation work.

**Evidence legend:** `[LOCAL]` = fact verified on our own files (given, not re‑derived here) · `[SPEC]` =
Microchip programming spec DS30190H · `[SRC]` = other cited web source · `[INFER]` = reasoning/opinion.

---

## Executive summary — the verdicts

**(a) Is the nibble‑XOR readback the *documented* protected‑read behaviour? — YES, verbatim in Microchip's spec.**
DS30190H §3.0 states a code‑protected location "will read as: `0000 0000 xxxx` where `xxxx` is the XOR of the
three nibbles," with a worked example `0xC04 → 0x008` (C^0^4 = 8). `[SPEC]` This is *exactly* our locally
verified transform `old[i] == (new>>8) ^ ((new>>4)&0xF) ^ (new&0xF)`. Our lab dump is authentic; there is no
mystery in the scramble. Confidence: **certain.**

**(b) Decap + UV fuse‑erase vs. non‑invasive glitch — most likely method: semi‑invasive decap.**
The dominant, commercially‑offered technique for OTP PIC16C5x — and the one arcade/pinball preservers have
used *on the PIC16C57 specifically* — is decap, mask the EPROM array, and UV‑erase the security fuse.
`[SRC]` The only documented non‑invasive route (over‑voltage "PIC Burnout") is **not confirmed for the plain
PIC16C5x family** and is destructive to memory. `[SRC]` The lab's refusal to give a die photo is weak evidence
either way. Best estimate: **decap + UV fuse‑erase, ~65% confidence**; non‑invasive glitch ~25%; other ~10%.
A non-invasive crack is **plausible but not supported by the balance of evidence** — see Q4.

**(c) A pure‑software decryptor is mathematically impossible.** The protected read maps a 12‑bit word to a
single 4‑bit XOR — a 3‑nibble→1‑nibble fold. Each observed nibble has **256 (16×16) pre‑images**. Information
is destroyed at read time, inside the chip, before any bit leaves the package. No algorithm — however clever —
can invert 4 bits back into the original 12. No tool that "decrypts" the locked read can exist.
Confidence: **certain (information theory, not opinion).**

**(d) Practical guidance for other SLEIC owners.** There is no cheap software unlock. The realistic paths are:
(1) copy the already‑recovered dump we hold onto a **PIC16F57** (flash, reusable) and drop it in; or (2) send a
locked chip to an IC‑recovery lab. A DIY glitch attack is *published research*, not a turnkey recipe for this
part. Full details in Q5, plus a genuinely useful **dump‑authentication cross‑check** anyone can run with a $50
programmer.

---

## Q1. Is the nibble‑XOR readback documented / known behaviour?

**Yes — it is Microchip's own specified behaviour, stated three independent ways in DS30190H** ("PIC16C5XX
EPROM/ROM Memory Programming/Verify Specification," 1999). `[SPEC]`
<https://ww1.microchip.com/downloads/en/DeviceDoc/30190h.pdf>

1. **§3.0 Code Protection (p.7):** *"In code protected parts, the contents of the program memory cannot be read
   out in a way that the program code can be reconstructed. A location when read out will read as:
   `0000 0000 xxxx` where `xxxx` is the XOR of the three nibbles."* Worked example: *"if the memory location
   contains `0xC04` (movlw 4), after code protection the output will be `0x008`."* `[SPEC]`
2. **§3.3 Checksum (p.11)** defines `SUM_XOR4` = *"XOR of the four high order bits with the four middle and the
   four low ... bits"* — the identical fold, used so a protected part's checksum can still be predicted. `[SPEC]`
3. The 16C5x programming flow only ever outputs the low nibble on PORTA when protected (PORTB reads 0). `[SPEC]`

The community knows this too: the CAPS0ff arcade‑preservation project describes 16C57 protection as
*"intentionally leak[ing] a 4‑bit xor of the 12‑bit words."* `[SRC]`
<http://caps0ff.blogspot.com/2017/01/conquering-pic16c57-234-241-242.html> · Skorobogatov's Cambridge work on
MCU copy protection is the standard academic reference for these mechanisms. `[SRC]`
<https://www.cl.cam.ac.uk/~sps32/mcu_lock.html> ·
<https://www.cl.cam.ac.uk/techreports/UCAM-CL-TR-630.pdf>

**So our June 2026 `pic16c57.rom` is not a corrupt or half‑working read — it is a *textbook* protected read**,
behaving exactly as Microchip designed the fuse to behave.

## Q2. Which parts of the chip are protected? (Correcting a common assumption)

The idea that "only program memory is scrambled; the ID words and config word stay readable" is
the model for the mask‑ROM (`CR`) parts, **not** for our OTP part. DS30190H Table for **PIC16C57**
(CP‑enable pattern `XXXXXXXX0XXX`, p.9) reads, in *Protected* mode: `[SPEC]`

| Segment | Read in Protected Mode | Read in Unprotected Mode |
|---|---|---|
| Configuration Word (`0xFFF`) | **Read Scrambled** | Read Unscrambled |
| ID Words `[0x800:0x803]` | **Read Scrambled** | Read Unscrambled |
| Main array `[0x040:0x7FF]` | **Read Scrambled**, Write Disabled | Read Unscrambled |
| `[0x000:0x03F]` | **Read Scrambled** | Read Unscrambled |

So on a locked PIC16C57 **everything reads scrambled — including the ID and config words.** (Only the ceramic
mask‑ROM variants CR54A/B/C, CR56A, CR58A read ID/config in the clear.) `[SPEC]`

**Why our data still shows the ID words as `0x00F` in *both* dumps.** `[LOCAL]` This is *not* evidence that the
ID region escaped protection. The recommended ID convention stores data only in the low nibble with the upper
8 bits zero, i.e. `0x00F`. Its scrambled read is `0 ^ 0 ^ F = F → 0x00F` — **identical to the plaintext.** The
ID words are *scramble‑invariant*, so a locked read and an unlocked read of them coincide by coincidence of the
convention, not because the fuse exempts them. Net: the ID match authenticates nothing about protection state;
it is simply consistent with both readings.

**No prefix of the locked read is plaintext either.** `[LOCAL]` Word 0 of the locked read is `0xD`, which is
precisely the nibble‑XOR of the real word `0x4A3` (`0x4 ^ 0xA ^ 0x3 = 0xD`) — the scramble, not the code. Such a
prefix *looks* like data because scrambled nibbles are varied and nonzero (not `FF`/`00`). The transform holds
for **all 2048 words with zero exceptions**, from word 0 onward, so **no program‑memory byte was ever available
in plaintext on the locked chip.** The only genuinely un‑obscured region is the ID words — and, as shown above, only because they are
scramble‑invariant. Any crypto/entropy analysis of the old dump must treat the *entire* array (word 0 included)
as XOR‑folded ciphertext, never as leaked plaintext.

## Q3. How labs actually crack a protected PIC16C57 — ranked

**#1 — Semi‑invasive: decap + selective UV erase of the security fuse (the standard commercial method).**
On EPROM‑based PICs the code‑protect bit is itself a floating‑gate cell that **UV light erases**, and on this
family it sits *outside* the main array, so it can be cleared while the program cells are shielded. Skorobogatov:
on the PIC12C508 *"security fuses are located outside the program memory array ... and can be easily disabled
with UV light."* `[SRC]` <https://www.cl.cam.ac.uk/~sps32/mcu_lock.html> Preservers have done exactly this on
the **PIC16C57**: decap, mask the array (even nail polish has been used as the UV mask), expose the fuse for
~5–15 min, then read the now‑unprotected chip normally. `[SRC]`
<http://caps0ff.blogspot.com/2017/01/conquering-pic16c57-234-241-242.html> ·
<https://burninsheep.wordpress.com/2013/05/21/pic16c57c-unlocking-and-code-dumping/> ·
<http://caps0ff.blogspot.com/2018/05/mostly-pic16c57.html> This is the method most IC‑recovery shops offer for
OTP PICs, priced per‑project by family/package/protection. `[SRC]` <https://icdecryption.com/> ·
<https://pcbsync.com/ic-unlock-decryption-services/> **This is the single most likely method used on IC23.**

**#2 — Non‑invasive: over‑voltage / over‑programming "burnout" (published 2025, but not for this exact part).**
"PIC Burnout" (Prehistoricman / recessim) over‑programs cells at ~14 V for pulses ~50× the spec, forcing whole
bit‑lines high and defeating the scramble, driven by a cheap **RP2040** ICSP rig. `[SRC]`
<https://hackaday.com/2025/07/09/pic-burnout-dumping-protected-otp-memory-in-microchip-pic-mcus/> ·
<https://wiki.recessim.com/view/PIC_Burnout> Two important caveats for us: (i) the listed target families are
PIC12C5XX / PIC12C67X / PIC14000 / PIC16C55X / PIC16C6XX / PIC16C7XX / PIC16C9XX — **the plain PIC16C5X /
PIC16C57 is *not* on that confirmed list**; (ii) it is *destructive to memory* (often one usable dump), and can
take hours. Glitch/over‑voltage attacks on PICs are real, but a turnkey PIC16C57 recipe is not published. `[INFER]`

**#3 — Fully invasive: microprobing / e‑beam / delayering the EPROM array.** Would read cells directly and
**necessarily produce die imagery**; expensive, low‑yield, reserved for when the fuse can't be reset. `[SRC]`
<https://forums.parallax.com/discussion/123993/how-to-recover-code-of-pic16c57> ·
<https://siliconpr0n.org/wiki/doku.php?id=tutorial:mcu_security>

## Q4. Weighing the "cracked without decapping" possibility

**Verdict: plausible, but the evidence leans the other way. Do not treat "no die photo" as proof of
non‑invasive.** `[INFER]`

- *For:* a non‑invasive over‑voltage/glitch attack would leave no die to photograph, which fits the
  lab's refusal. And a lab may refuse photos simply to protect a proprietary process. `[INFER]`
- *Against:* (i) decap + UV‑fuse‑erase is the *default* commercial service for OTP PICs and the
  method with a documented track record **on the PIC16C57 itself** (Q3 #1); (ii) the confirmed non‑invasive
  technique isn't validated for this family; (iii) a refusal to share photos is at least as consistent with
  "we decapped it and don't publish die shots" (or "the die was consumed/damaged"); (iv) most decisive — **the
  deliverable was a `PIC16F57` file** (`PIC16F57-DIP28-1D05-20260815.bin`) that runs the machine on a *flash*
  replacement part. That means the machine no longer depends on the fragile original at all, which *removes* the
  incentive to keep the original OTP intact and *raises* the odds they decapped/sacrificed it (or a donor) to
  get a clean read. A lab that decaps for the read, then hands you a 16F57 clone, matches the artefacts we have
  better than a non‑invasive story does. `[INFER]`

Net confidence (repeat of the summary): **decap + UV fuse‑erase ≈ 65%**, non‑invasive glitch ≈ 25%, other/
microprobe ≈ 10%. The die‑photo refusal moves the needle only slightly and should not be read as confirmation
of a glitch attack.

## Q5. Can a cheap DIY decryptor / unlock path be documented for other SLEIC owners?

**A pure‑software "decrypt the locked .rom" tool is impossible — here is the whole argument in three lines.**
The protected read computes `f(w) = n2 ^ n1 ^ n0` where `w`'s nibbles are `n2 n1 n0`. That is a map from
**4096 possible words → 16 possible outputs**; every output nibble has **256 pre‑images**. The lost bits are
discarded *inside the die at read time*, before anything reaches the pins, so the information is not "encrypted"
(recoverable with a key) — it is **destroyed** (unrecoverable in principle). `[LOCAL]`/`[SPEC]` No decryptor,
AI, or brute‑force can reconstruct 150 program words from their XOR shadows. That expectation has to be set
aside — gently, but with certainty.

**What *does* exist, at research/overview level (cite, don't follow as a recipe):**
- Decap + UV fuse‑erase — low cost in materials, but needs decapsulation skill and risks destroying the chip.
  Documented by CAPS0ff and burninsheep on the PIC16C57. `[SRC]` (links in Q3).
- Over‑voltage "PIC Burnout" on an RP2040 — cheap hardware, *published*, but **not confirmed for PIC16C5x** and
  memory‑destructive. Treat as experimental for this part. `[SRC]`
  <https://hackaday.com/2025/07/09/pic-burnout-dumping-protected-otp-memory-in-microchip-pic-mcus/>

**The pragmatic path for a SLEIC owner (recommended):** you do **not** need to crack anything. Program the
already‑recovered, verified code onto a **PIC16F57** (a modern flash pin‑compatible part — exactly what the lab
delivered) and fit it. Preserve/publish that dump so no future owner has to pay a lab. If a physical original
must be read from scratch, budget for a lab decap job; DIY glitching is a project, not a guarantee.

---

## Appendix — Authenticate a lab dump against *your own* locked‑chip read (community‑useful)

Anyone with a locked SLEIC PIC and a ~$50 TL866‑class programmer can prove a published "unlocked" dump matches
**their** chip revision, without trusting the lab and without any decap. The locked read *is* a
per‑chip‑revision fingerprint. `[LOCAL]`/`[SPEC]`

1. Read your locked chip in the programmer's "PIC16C57" mode. You will get the scrambled read: each 12‑bit word
   comes back as `0x00X`, where `X` is the XOR of its three real nibbles (Q1). Save it.
2. For every word `w` in the candidate unlocked dump, compute `x = (w>>8) ^ ((w>>4)&0xF) ^ (w&0xF)`.
3. Compare `x` against the low nibble of your locked read at the same address, for **all** words (blanks
   included: `0xFFF → F`; ID words `0x00F → F`).
4. **A genuine dump matches on 100% of words.** A mismatch means either a different ROM revision or a bad dump.

Reference numbers from our set: word 0 real `0x4A3` → locked `0xD`; every one of 2048 words matched; blanks and
the four ID words matched too. `[LOCAL]` One‑liner:

```python
# old = list of locked-read low-nibbles; new = candidate unlocked 12-bit words
assert all(old[i] == ((new[i]>>8) ^ ((new[i]>>4)&0xF) ^ (new[i]&0xF)) for i in range(len(new)))
```

This cross‑check is the one place the mathematically‑lossy scramble becomes *useful*: it can't recover code,
but it lets the community verify a recovered dump against any surviving locked chip for pennies.

---

### Sources
- Microchip DS30190H, PIC16C5XX EPROM/ROM Programming/Verify Spec — <https://ww1.microchip.com/downloads/en/DeviceDoc/30190h.pdf>
- Skorobogatov, *Copy Protection in Modern Microcontrollers* — <https://www.cl.cam.ac.uk/~sps32/mcu_lock.html>
- Skorobogatov, *Semi‑invasive attacks* (UCAM‑CL‑TR‑630) — <https://www.cl.cam.ac.uk/techreports/UCAM-CL-TR-630.pdf>
- CAPS0ff, *Conquering PIC16C57 #234/241/242* — <http://caps0ff.blogspot.com/2017/01/conquering-pic16c57-234-241-242.html>
- CAPS0ff, *Mostly PIC16C57* — <http://caps0ff.blogspot.com/2018/05/mostly-pic16c57.html>
- Burnin' Sheep, *PIC16C57C Unlocking and code dumping* — <https://burninsheep.wordpress.com/2013/05/21/pic16c57c-unlocking-and-code-dumping/>
- Hackaday, *PIC Burnout: Dumping Protected OTP Memory* — <https://hackaday.com/2025/07/09/pic-burnout-dumping-protected-otp-memory-in-microchip-pic-mcus/>
- RECESSIM wiki, *PIC Burnout* — <https://wiki.recessim.com/view/PIC_Burnout>
- siliconpr0n, *MCU security tutorial* — <https://siliconpr0n.org/wiki/doku.php?id=tutorial:mcu_security>
- Parallax Forums, *how to recover code of PIC16C57* — <https://forums.parallax.com/discussion/123993/how-to-recover-code-of-pic16c57>
- IC decryption service listings — <https://icdecryption.com/> · <https://pcbsync.com/ic-unlock-decryption-services/>
