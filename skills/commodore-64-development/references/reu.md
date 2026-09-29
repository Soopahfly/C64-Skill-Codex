# REU expansion memory

The Commodore RAM Expansion Unit (1700/1764/1750) is separate memory controlled by the REC through DMA. The CPU cannot load or store REU bytes directly. Plan transfers between an allocated C64 RAM buffer and a selected REU bank/address. Standard capacities are 128, 256, and 512 KiB respectively; emulators and later compatible devices can be larger. Make REU support optional unless the program explicitly requires it.

## Registers at I/O 2

Keep I/O mapped in when accessing the REU at `$DF00-$DF0A`. Account for other cartridges or devices that may also use I/O 2.

| Address | Function |
| --- | --- |
| `$DF00` | Status; bit 7 IRQ pending, bit 6 end of block, bit 5 verify error. Reading clears those flags. Do not use the reported size bit alone to determine capacity. |
| `$DF01` | Command; bit 7 execute, bit 5 autoload, bit 4 immediate start when set, bits 1:0 transfer type: `00` C64 to REU, `01` REU to C64, `10` swap, `11` verify. If bit 4 is clear, execution waits for a write to `$FF00`. |
| `$DF02-$DF03` | C64 address, low byte then high byte. |
| `$DF04-$DF05` | REU address within a 64 KiB bank, low byte then high byte. |
| `$DF06` | REU bank; only bits supported by the device are meaningful. |
| `$DF07-$DF08` | Transfer length, low byte then high byte; `$0000` means 65536 bytes, not zero. |
| `$DF09` | IRQ mask. Use zero for a polling transfer. |
| `$DF0A` | Address control; zero increments both addresses. Bit 7 fixes the C64 address; bit 6 fixes the REU address. |

## Transfer procedure

1. Reserve a C64 RAM buffer that does not overlap code, stack, screen, or system data. Reserve the intended REU bank range; never assume REU contents persist across runs or power cycles.
2. Initialize address control and IRQ mask explicitly. Set the C64 address, REU offset and bank, and a nonzero length. Check that the requested capacity exists before using banks beyond the smallest supported size. A 64 KiB boundary advances the REU bank, while the C64 address wraps within 64 KiB; split a transfer if either wrap is unwanted.
3. Write `$90` to `$DF01` for an immediate C64-to-REU transfer, or `$91` for an immediate REU-to-C64 transfer. These use incrementing addresses if `$DF0A` was set to zero. Use the delayed `$FF00` trigger only when banking requirements make it necessary, such as RAM under I/O. Do not bank I/O out before programming the registers.
4. Read `$DF00` after DMA to inspect completion (and clear latched flags). Treat verify errors and missing hardware explicitly. If using REU IRQs, clear stale status before arming, install and restore the handler, and avoid assuming DMA lasts a fixed number of CPU cycles.

For detection, do a bounded write/read round trip with known bytes in a reserved C64 buffer and REU location, verify the returned bytes and status, then restore any data whose prior value matters. An open-bus read of `$DF00`, or a single status bit, is insufficient. Avoid a destructive capacity probe in data owned by another program. Test with REU disabled and with 128/256/512 KiB configurations, and on the target cartridge or compatible hardware when available.

In VICE, enable a 512 KiB REU for an `x64sc` test with `x64sc.exe -reu -reusize 512 -autostart .\program.prg`; use `+reu` to test the fallback path. VICE accepts larger emulated capacities, but a program that uses those is not automatically compatible with original Commodore REUs.

Sources: [Commodore 1764 RAM Expansion Module User's Guide, operation and register table](https://files.commodore.software/reference-material/manuals/commodore-64-manuals/hardware-manuals/1764-ram-expansion-module-users-guide.pdf); [VICE manual, REU settings](https://vice-emu.sourceforge.io/vice_7.html).
