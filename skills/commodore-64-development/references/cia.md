# CIA and interrupt checks

- CIA1 registers begin at `$DC00`; CIA2 at `$DD00`. CIA1 handles keyboard/joystick and common timer IRQ duties; CIA2 port A also selects the VIC bank. Do not casually overwrite CIA2 port A or its data-direction register while configuring graphics.
- The CIA interrupt control registers are `$DC0D` and `$DD0D`. Write bit 7 as 1 to set mask bits, 0 to clear mask bits. Read the ICR to learn and clear pending CIA interrupt sources. Do not use the VIC `$D019` write-one acknowledgment rule for a CIA.
- On a default KERNAL setup, the standard IRQ path can invoke the RAM vector at `$0314/$0315`. With KERNAL ROM banked out, the CPU hardware IRQ vector at `$FFFE/$FFFF` must point to RAM code. The two approaches need different interrupt entry/exit treatment.
- `SEI` masks maskable IRQs only. Account separately for NMI, CIA2, RESTORE, KERNAL's timer IRQ, and any loader or music routine using interrupts. Save/restore registers, masks, vectors, and interrupt state appropriate to the program's exit path.
- Joystick inputs share CIA1 port bits with keyboard scanning. Confirm port, active-low polarity, and effect on existing input handling before writing routines.

Sources: [Commodore 64 Programmer's Reference Guide](https://www.commodore.ca/manuals/c64_programmers_reference/c64-programmers_reference.htm), [Mapping the Commodore 64](https://project64.c64.org/Software/mapc6411.txt).
