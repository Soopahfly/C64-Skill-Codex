# 6510 CPU banking

- `$0000` is the 6510 port direction register and `$0001` is its data register. Their lower three output bits (`LORAM`, `HIRAM`, `CHAREN`) control the usual ROM/I/O visibility, subject to cartridge lines. Preserve unrelated bits and check direction before changing them.
- With `LORAM=0`, BASIC ROM at `$A000-$BFFF` disappears from the CPU read view. KERNAL ROM visibility at `$E000-$FFFF` depends on `HIRAM`. In `$D000-$DFFF`, I/O, character ROM, or RAM can be visible depending on the combination, not `CHAREN` alone.
- RAM under BASIC and KERNAL ROM can be written while ROM is visible for reads. To *read* the underlying RAM, change the banking. I/O writes in `$D000-$DFFF` affect devices when I/O is mapped in; do not assume they write the underlying RAM.
- Before switching KERNAL out, account for IRQ/NMI vectors and any calls into ROM. Restore the original `$01` when returning to an environment expecting it; changing `$01` also interacts with cassette lines and possibly cartridge modes.
- VIC-II bank selection through CIA2 is separate from this CPU map. Never calculate VIC-visible addresses from `$01` alone.

Sources: [Commodore Programmer's Reference Guide](https://www.commodore.ca/manuals/c64_programmers_reference/c64-programmers_reference.htm), [Mapping the Commodore 64](https://project64.c64.org/Software/mapc6411.txt). Verify exact banking combinations against their tables before modifying live code.
