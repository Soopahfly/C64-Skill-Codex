# NMOS 6502 instruction checks

- Registers: `A`, `X`, `Y` are 8 bit; `PC` is 16 bit; `SP` indexes the stack at `$0100-$01FF`. Track processor flags `N V D I Z C` explicitly.
- `CMP`, `CPX`, `CPY` subtract for flags without saving the result. After unsigned comparison, `C=1` means greater than or equal; `Z=1` means equal. Signed comparison needs overflow-aware logic, not merely `BCC`/`BCS`.
- `ADC` adds carry; `SBC` subtracts the inverse of carry. Set or clear carry deliberately before arithmetic. `BIT` takes `N` and `V` from memory and sets `Z` from `A & memory`.
- `JSR` pushes a return address; `RTS` resumes after it. `RTI` restores status and PC for interrupt return. Do not use `RTS` to exit an interrupt handler unless the surrounding ROM wrapper specifically requires it.
- On entry to IRQ/NMI, the CPU stacks PC and status. `BRK` consumes a padding byte and uses the IRQ/BRK vector. `SEI` masks IRQ, not NMI. Interrupt handlers must preserve registers they change when required by the caller.
- NMOS decimal `ADC`/`SBC` have subtle flag behavior. Set `CLD` before binary arithmetic if prior code could have set decimal mode; validate decimal flag semantics against the target CPU when they matter.
- NMOS `JMP (addr)` reads its high byte from the same page when the pointer ends in `$FF`. Avoid placing an indirect jump pointer across that page boundary.
- Avoid `BRA`, `STZ`, `PHX`, `PLY`, `INC A`, and other 65C02-only forms for an NMOS 6502/6510. An assembler accepting them does not make them run on the machine.

Source: [MOS Technology, MCS6500 Microcomputer Family Programming Manual](https://archive.org/details/mos_microcomputers_programming_manual). Verify exact opcode tables there or in the assembler manual for the chosen CPU.
