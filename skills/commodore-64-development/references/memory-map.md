# C64 memory map and data forms

| CPU address | Usual power-on view | Check before using |
| --- | --- | --- |
| `$0000-$00FF` | Zero page; `$0000/$0001` are 6510 port registers | BASIC/KERNAL use much of zero page. Allocate deliberately. |
| `$0100-$01FF` | Hardware stack | Leave headroom for calls and interrupts. |
| `$0400-$07E7` | Default 1000-byte screen matrix | It can move within the selected VIC bank. |
| `$0801` | Default BASIC program start | A BASIC `SYS` stub lives here if used. |
| `$A000-$BFFF` | BASIC ROM visible for reads | RAM exists underneath; BASIC execution depends on ROM mapping. |
| `$D000-$DFFF` | VIC, SID, color RAM, CIA and other I/O | Mapping out I/O changes CPU access; color RAM is distinct hardware. |
| `$E000-$FFFF` | KERNAL ROM visible for reads | RAM exists underneath; hardware vectors at `$FFFA-$FFFF` are affected by mapping. |

- A PRG starts with a **two-byte little-endian load address**, followed by data bytes. This load address is not automatically the execution address. BASIC `LOAD`, `RUN`, `SYS`, direct machine-code entry and cartridge startup are different flows.
- Screen character codes, PETSCII, and character bitmaps are different representations. Use an explicit conversion or the right assembler encoding when placing text into screen RAM. The default color RAM at `$D800-$DBE7` stores four meaningful color bits per cell, and cannot be treated as ordinary banked RAM.
- Never assume that an address is free because it is RAM. Consider BASIC/KERNAL variables, I/O mapping, VIC fetches, and the user's loader and assets.

Sources: [Commodore 64 Programmer's Reference Guide](https://www.commodore.ca/manuals/c64_programmers_reference/c64-programmers_reference.htm), [Mapping the Commodore 64](https://project64.c64.org/Software/mapc6411.txt).
