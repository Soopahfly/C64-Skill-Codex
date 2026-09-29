---
name: 6502-assembly
description: Write, review, debug, and explain NMOS 6502 or 6510 assembly, including addressing, flags, stack, interrupts, and cycle timing. Use for CPU-level assembly work on Commodore 64, VIC-20, or other 6502 machines; pair with a machine-specific skill for hardware details.
---

# 6502 assembly

1. Identify the CPU variant, assembler dialect, load address, and calling or interrupt context. Use the existing project's conventions. For a C64 task, also use `commodore-64-development` if available.
2. Default to documented NMOS 6502 instructions on 6502/6510 targets. Never silently substitute 65C02 instructions such as `BRA`, `STZ`, `PHX`, or `PLY`; only use undocumented opcodes on explicit request.
3. Before writing or changing code, read the relevant reference: [instruction-set](references/instruction-set.md) for flags and control flow, [addressing-modes](references/addressing-modes.md) for operands and pointers, [timing](references/timing.md) for cycle-sensitive work.
4. Trace register, carry, decimal, interrupt, and stack state across calls. Check who owns zero-page addresses and whether self-modifying code is safe in its memory location.
5. For timing claims, show the actual instruction path and all conditional penalties. Distinguish CPU instruction cycles from the host machine's available bus cycles.
6. Assemble with the selected assembler when available, inspect output addresses and bytes, and run a relevant emulator or hardware test when available. State precisely which checks were performed.

Use the [MOS 6500 programming manual](https://archive.org/details/mos_microcomputers_programming_manual) and the target assembler's manual when an opcode detail needs confirmation; do not invent opcode encodings or cycle counts.
