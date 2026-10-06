# KERNAL and launch context

- Calls through the KERNAL jump table at `$FF81-$FFF3` require KERNAL ROM visibility and each routine's documented inputs and side effects. Check a routine's contract rather than inferring it from its name.
- A `SYS` launched from BASIC enters machine code in a different state from a reset, cartridge, or bare loader. A subroutine expected to return to BASIC should preserve relevant state and use `RTS`; an interrupt handler has separate return rules.
- A KERNAL-chain IRQ handler attached through `$0314/$0315` must match the ROM entry/exit convention. A handler installed at hardware `$FFFE/$FFFF` with ROM banked out must handle its own save/restore and return with `RTI`.
- When code disables ROM or replaces the IRQ path, document how keyboard, screen editor, timers, and normal system behavior are affected. Restore vectors and state if returning to BASIC.

Sources: [Commodore 64 Programmer's Reference Guide](https://www.commodore.ca/manuals/c64_programmers_reference/c64-programmers_reference.htm), [Mapping the Commodore 64](https://project64.c64.org/Software/mapc6411.txt).

## Load and save a small data block

Use the repository's [storage-roundtrip.asm](../../../storage-roundtrip.asm) and [disk-image workflow](../../../README.md#run-from-a-disk-image). Start from stock BASIC with KERNAL ROM and I/O visible, no cartridge or custom IRQ, and a writable drive-8 disk. The example owns `$C000-$C003`, logical files 1 and 15, and temporarily uses `$FB/$FC`, saving and restoring that pointer.

| Routine | Inputs used by the example | Result/check |
| --- | --- | --- |
| SETNAM `$FFBD` | A = filename byte count; X/Y = low/high filename address | Filename bytes use PETSCII. |
| SETLFS `$FFBA` | A = 1; X = device 8; Y = secondary address 1 | Establish parameters before each LOAD or SAVE. |
| SAVE `$FFD8` | A = `$FB`, the zero-page pointer address; `$FB/$FC = $C000`; X/Y = `$C004` | End is exclusive, so four bytes are saved. Check carry immediately; on error retain A. |
| LOAD `$FFD5` | A = 0 for load; secondary address 1 uses the file header | Capture returned X/Y (end address) before another call; expect `$C004`. |
| READST `$FFB7` | No inputs | Inspect bus status independently of carry. EOI bit `$40` alone is normal at the end of this disk load. |

SAVE writes a two-byte little-endian address header followed by the selected memory bytes. LOAD with secondary address 0 relocates the payload to the address supplied in X/Y; secondary address 1 uses the header instead. Neither executes the loaded data. The example compares bytes only after the transfer, DOS status and end-address checks pass.

KERNAL carry and READST are not the drive's DOS error channel. A serial transfer can finish while the drive reports file exists, disk full or write protection. The example opens logical file 15 on device 8, secondary address 15, captures the first two PETSCII status digits, consumes the line with a bound, closes that file and restores default channels. Only DOS `00` passes. It does not use the overwrite prefix `@:`.

Inspect `kernalCode`, `ioStatus`, `dosTens`, `dosOnes`, `loadedEnd` and the buffer using addresses in the generated symbol file. A KERNAL error code is numeric; DOS digits are characters (for example `$36,$33` means 63, file exists). `kernalCode = 0` does not prove success: use the other checks and the border result. Try a fresh disk, a second run with the same filename, and a read-only image as separate validation cases.

This LOAD is for the four-byte file created by the example. Stock KERNAL LOAD has no destination-length limit: checking the end address afterwards cannot prevent a larger or unexpected file from overwriting RAM. For external files, design a bounded reader using OPEN/CHKIN/CHRIN/CLOSE or a validated loader. Do not reuse the buffer or zero page in a larger program without checking ownership.

Source: [Commodore Programmer's Reference Guide, KERNAL API transcription](https://github.com/mist64/c64ref/blob/main/src/kernal/kernal_prg.txt), particularly SETNAM, SETLFS, LOAD, SAVE, READST and channel routines.
