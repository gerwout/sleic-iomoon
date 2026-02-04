# 80188 Peripheral Configuration

[← Back to main README](../README.md)

## Boot-time Register Configuration

At boot, the 80188 configures its internal peripheral registers from code at `0xFFF00`:

```asm
FFF00:  MOV DX, FFA0h      ; RELREG address
        MOV AX, C03Ch       ; Configuration value
        OUT DX, AX          ; Write RELREG
        JMP FAR D000:0000   ; Jump to main init
```

---

## Chip Select Registers

| Register | Port | Value | Description |
|----------|------|-------|-------------|
| RELREG | `FFA0h` | `C03Ch` | Relocation Register |
| UMCS | `FFA2h` | `3FFCh` | Upper Memory Chip Select |
| LMCS | `FFA4h` | `A03Ch` | Lower Memory Chip Select |
| PACS | `FFA6h` | `41FCh` | Peripheral Address Chip Select |
| MMCS | `FFA8h` | `A0FCh` | Mid-range Memory Chip Select |

---

## Register Analysis

### RELREG — `C03Ch`

```
C03C = 1100 0000 0011 1100
       ││         └────────── Relocation bits (003C → FC00h base)
       │└─────────────────── M/IO = 0 (memory-mapped peripherals)
       └──────────────────── ET = 1 (Escape mode enabled for Z80 bus sharing)
```

The **ET=1** bit is critical: it enables the HOLD/HLDA bus arbitration mechanism that allows the Z80 coprocessor to access the shared memory bus.

### UMCS — `3FFCh` (Upper Memory)

```
3FFC = 0011 1111 1111 1100
       └────────────────── Start address: F0000h
       Memory block enabled, 3 wait states
```

Maps the upper memory code segments (F000h) where system/BIOS code resides.

### LMCS — `A03Ch` (Lower Memory)

```
A03C = 1010 0000 0011 1100
       └────────────────── Start address: 00000h
       Memory block enabled, 3 wait states
```

Maps the lower memory (ROM2) where the DMD graphics data is stored.

### PACS — `41FCh` (Peripheral)

```
41FC = 0100 0001 1111 1100
       └────────────────── I/O base: 4000h (segment 4000)
       Block enabled, 3 wait states
```

Maps the shared RAM area at segment `4000h` used for 80188↔Z80 communication.

### MMCS — `A0FCh` (Mid-range Memory)

```
A0FC = 1010 0000 1111 1100
       └────────────────── Start address: A0000h (hardware registers)
       Block enabled, 3 wait states
```

Maps the DMD controller hardware registers at segment `A000h`.

---

## Wait States

All memory regions are configured with **3 wait states**, reflecting the relatively slow EPROM access times of the 27C040 chips and the shared-bus architecture.

---

## I/O Port Configuration Table

At startup, the 80188 main init routine at `D0000` configures additional I/O ports from a table stored at `DS:0041`:

```asm
D0000:  CLI                  ; Disable interrupts
        MOV AX, 4152h        ; Stack segment
        MOV SS, AX
        MOV AX, 0205h        ; Stack pointer
        MOV SP, AX
        MOV AX, 4000h        ; Data segments
        MOV DS, AX
        MOV ES, AX
        ; Configure I/O ports from table at DS:0041
        ...
```

The exact port configuration sequence initializes timer registers, interrupt controllers, and DMA channels used by the 80188 for DMD refresh and game timing.
