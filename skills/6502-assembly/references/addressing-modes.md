# Addressing and pointers

| Form | Meaning | Common trap |
| --- | --- | --- |
| `LDA #$10` | Immediate value | `#` changes value into an operand, not an address. |
| `LDA $10` | Zero-page read | A two-byte instruction when assembler selects zero page. |
| `LDA $1234` | Absolute read | Three-byte instruction. |
| `LDA $10,X` | Indexed zero page | Effective zero-page address wraps at `$FF`. |
| `LDA $1234,X` | Indexed absolute | May cross a page, affecting some read timings. |
| `LDA ($20,X)` | Indexed indirect | Add X to zero-page pointer address, then read 16-bit address. |
| `LDA ($20),Y` | Indirect indexed | Read pointer at `$20/$21`, then add Y. |
| `BNE label` | Relative branch | Signed offset from address after the branch, range -128 to +127. |

Zero-page indirect pointers wrap within zero page. Check that both bytes of every pointer are valid and that selected zero-page locations are free on the target machine. NMOS 6502 lacks a general `LDA ($20)` mode; that syntax is available on later variants. `JMP (addr)` is the NMOS indirect jump and has the `$xxFF` high-byte wrap behavior.

Source: [MOS 6500 Programming Manual](https://archive.org/details/mos_microcomputers_programming_manual), addressing modes and instruction descriptions.
