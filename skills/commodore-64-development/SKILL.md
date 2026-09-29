---
name: commodore-64-development
description: Create, review, and debug Commodore 64 or C64-compatible programs in 6510 assembly, including PRG loading, memory banking, VIC-II graphics, SID sound, keyboard and joystick input, CIA, KERNAL, raster timing, REU expansion memory, and KickAssembler. Use for C64 software targeting real hardware, VICE, or MiSTer; default to PAL and KickAssembler for new work unless the user or project specifies otherwise.
---

# Commodore 64 development

## Defaults and workflow

1. Target a standard PAL C64 with a 6510 and documented NMOS 6502 instructions. Use KickAssembler for a new project; preserve the existing assembler, video standard, and build setup in an existing project. Do not apply C64 OS application conventions unless explicitly requested.
2. Establish the launch method, PRG load address and actual entry address; map code, data, screen, charset, sprites, zero page, stack, ROM, and I/O. For C64 machine code also consult `6502-assembly` when available.
3. Read only the references relevant to the task: [memory map](references/memory-map.md), [CPU banking](references/banking.md), [VIC-II](references/vic-ii.md), [SID sound and variants](references/sid.md), [keyboard and joystick input](references/input.md), [REU expansion](references/reu.md), [CIA and interrupts](references/cia.md), [KERNAL](references/kernal.md), [KickAssembler and PRG](references/kickassembler.md), [PAL timing](references/pal-timing.md), [NTSC timing](references/ntsc-timing.md).
4. Distinguish the CPU memory view from VIC memory view. Preserve unrelated bits in shared hardware registers; do not guess addresses, bit fields, zero-page availability, or KERNAL calling requirements.
5. Before handing over a program, assemble it where the toolchain exists; check PRG first two bytes, BASIC/SYS entry if applicable, occupied address ranges, VIC-visible data, IRQ acknowledgment and restoration, and PAL/NTSC assumptions. Exercise VICE or MiSTer when available, and state what remains untested on real hardware.

Keep machine rules in the relevant reference rather than in project-specific code. Add a verified general lesson when a real project exposes a repeated failure mode. Original sources are linked in each reference; consult them when a detail is in doubt.
