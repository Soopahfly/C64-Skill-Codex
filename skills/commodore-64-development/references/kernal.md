# KERNAL and launch context

- Calls through the KERNAL jump table at `$FF81-$FFF3` require KERNAL ROM visibility and each routine's documented inputs and side effects. Check a routine's contract rather than inferring it from its name.
- A `SYS` launched from BASIC enters machine code in a different state from a reset, cartridge, or bare loader. A subroutine expected to return to BASIC should preserve relevant state and use `RTS`; an interrupt handler has separate return rules.
- A KERNAL-chain IRQ handler attached through `$0314/$0315` must match the ROM entry/exit convention. A handler installed at hardware `$FFFE/$FFFF` with ROM banked out must handle its own save/restore and return with `RTI`.
- When code disables ROM or replaces the IRQ path, document how keyboard, screen editor, timers, and normal system behavior are affected. Restore vectors and state if returning to BASIC.

Sources: [Commodore 64 Programmer's Reference Guide](https://www.commodore.ca/manuals/c64_programmers_reference/c64-programmers_reference.htm), [Mapping the Commodore 64](https://project64.c64.org/Software/mapc6411.txt).
