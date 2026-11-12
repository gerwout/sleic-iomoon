# ROM Set — Bike Race V4.1, free play + PRESS START, English

The complete seven-chip set of the
[free play + PRESS START](../v4.1%20-%20free%20play%20+%20press%20start/) machine,
translated into English. Confirmed working on a real V4.1 machine.

| Filename | Chip | MD5 | CRC32 | SHA1 |
|---|---|---|---|---|
| `bkdsp01.bin` | 01, I8039 display | `f9c98453e94762f6ddf499e33e98a6cf` | `9b220fcb` | `54e82705d8ce8a26d9e1b5f0fe382ded1f2070c3` |
| `bksnd02.bin` | 02, OKI samples 1 | `1bfba7e4db786c400f76e3b94c58f885` | `d67b3883` | `712022b9b24c6ab559d020ab8e2106f68b4d7896` |
| `bk03.bin` | 03, OKI samples 2 | `8f49bf919392f32fc0366d0ec6c92ada` | `74c10536` | `43a2a63494b044fe2326ee09831ef90f37d3b432` |
| `bk04e.bin` | 04, 80188 code | `8b2521fb42c3ca6ca4266d34ed97abd3` | `99006ab6` | `41e2604d3a6a75b86b1c43776d4c815629bc5ffe` |
| `bk05e.bin` | 05, graphics (MCS2) | `2fa3c065e0f4e57bbae89a0844cfdb20` | `590aced9` | `1f81cae3e6efc150fd88488a25e615b488401a22` |
| `bk06e.bin` | 06, graphics (MCS1) | `f6125f74aac464e334a755d463c29081` | `47f41c51` | `7508cb5476c3881c465c6303c7776fac9df9b0a9` |
| `bk07.bin` | 07, Z80 I/O | `244271a47eb206f3c3fc30c1f7d8fb17` | `200ff3fc` | `96fc8561b078c5306b15e260436e3d3ba562c51d` |

Only chips 04, 05 and 06 differ from the free play + PRESS START set; the other four
are V4.1's. On a machine already running V4.1, burning those three 27C010s is the
whole conversion. Settings, audits and high scores carry over.

The three chips are generated from `bk04f.bin`, `bkcpu05.bin` and `bkcpu06.bin` by
[`scripts/bike_race_english_patch.py`](../../../../scripts/bike_race_english_patch.py)
using the translation in
[`translations/bike-race-en/`](../../../../translations/bike-race-en/), which also
documents what is translated and how. The two patches of the base set are unchanged.
The attract's "CREDITOS nn" screen shows **Freeplay** instead.

PinMAME loads the set as `bikerc3e`, "Bike Race (V4.1, press start MOD, free play, English)".
