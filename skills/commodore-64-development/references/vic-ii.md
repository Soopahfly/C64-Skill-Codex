# VIC-II address and register checks

- CIA2 port A at `$DD00`, bits 0-1, selects a 16 KiB VIC bank with inverted coding: `11 -> $0000`, `10 -> $4000`, `01 -> $8000`, `00 -> $C000`. Make these bits outputs via `$DD02`, and preserve the other port bits when changing the bank.
- In character modes, `$D018` bits 4-7 select a 1 KiB screen offset within the bank: `bank + ((D018 >> 4) * $0400)`. Bits 1-3 select a 2 KiB character offset: `bank + (((D018 >> 1) & 7) * $0800)`. Bitmap mode interprets the bitmap select differently; check mode bits before reusing this formula.
- VIC has its own memory view. In bank 0 or 2 it sees character ROM at its local `$1000-$1FFF` window, even when the CPU sees RAM there. Plan screen, charset, bitmap, and sprite data using the VIC view.
- Sprite pointers occupy the last eight bytes of the selected screen matrix (screen base plus `$3F8-$3FF`). Each pointer selects a 64-byte block within the current VIC bank. The sprite image uses 63 bytes, with the 64th byte unused.
- Writing `$D012` sets the low eight bits of the raster IRQ compare; reading it returns the **current** raster line. Writing `$D011` bit 7 sets the compare's ninth bit; reading bit 7 returns the current raster's ninth bit. The previous compare cannot be saved by reading these registers. Preserve `$D011` bits 0-6 separately, and keep a software shadow of compare settings when another program owns raster IRQs.
- `$D019` IRQ flags acknowledge by writing **1** to the corresponding pending bits; `$D01A` enables selected VIC interrupt sources. Preserve unrelated bits when changing mode or enables.
- Color RAM at `$D800-$DBFF` is 4-bit device storage and not relocated with screen RAM. The visible 1000 character cells use `$D800-$DBE7`.

Sources: [Commodore 64 Programmer's Reference Guide](https://www.commodore.ca/manuals/c64_programmers_reference/c64-programmers_reference.htm), [Mapping the Commodore 64](https://project64.c64.org/Software/mapc6411.txt).
