# KickAssembler and PRG output

- Use the selected project's KickAssembler version and build command. The current manual uses `*=$1000 "Program"` for placement; `.pc=$1000` is older supported syntax. Do not transplant ACME or ca65 directives into KickAssembler source.
- Explicitly select documented NMOS opcodes with `.cpu _6502NoIllegals` if the installed version supports it. KickAssembler's default `_6502` also accepts undocumented opcodes. Never set `.cpu _65c02` for a stock C64.
- For a new BASIC-launched program, use the documented `BasicUpstart2(entry)` helper if present in the installed version. Place subsequent machine code at a nonoverlapping address. Do not assume the BASIC stub entry and the PRG load address are equal.
- The manual's `.file [name="output.prg", segments="Code"]` creates a PRG for the specified segment; `type="bin"` produces raw binary without a PRG load address. Inspect the assembled file's first two bytes and the listing/memory map after building.
- An assembler's `*=`/`.pc` sets placement. It is not by itself proof that the loader, BASIC stub, and entry point agree. For relocated code, distinguish where bytes load from where labels execute; verify any `.pseudopc` block and actual copy routine.

Sources: [KickAssembler manual](https://www.theweb.dk/KickAssembler/webhelp/content/index.html), [memory directives](https://www.theweb.dk/KickAssembler/webhelp/content/ch03s05.html), [file directive](https://www.theweb.dk/KickAssembler/webhelp/content/ch11s03.html).

The user's [C64 Assembly Coding Guide](https://github.com/spiroharvey/c64/blob/main/asm/C64%20Assembly%20Coding%20Guide.md) is a useful index of further tutorials and references. Use the assembler's own manual for exact directive syntax.

## First VICE debugging session

A breakpoint stops execution before an instruction. Single stepping executes one instruction so you can inspect its effect.

1. Build `border-colour.asm` using the repository README commands and autostart its PRG in a fresh PAL VICE window. This short test may have finished before you open the monitor; that is expected.
2. Select **Activate monitor** from the VICE menu. Enter these commands, one per line:

   ```text
   device c:
   radix H
   bank cpu
   break exec $080d
   x
   ```

3. At the BASIC prompt, type `RUN` again. The breakpoint should stop at `start` before `LDA #$02`. Enter `d $080d $0812` to see the three instructions.
4. Enter `z`, then `r`: A should be `02`, with PC at `$080F`. Enter `z` again, then `m $d020 $d020`: the border register's low nibble should be `2` and PC should be `$0812`. VIC register readback may set unused high bits, so do not require the full byte to equal `02`.
5. Enter `z` to execute `RTS`, then `x` to resume BASIC. Reopen the monitor and use `break` to list checkpoint numbers, then `delete N` with your breakpoint's number to remove it.

Do not use `g $080d` as a substitute for BASIC `RUN` here: setting PC directly does not establish the return context needed by `RTS`. If interrupts intervene while stepping, inspect PC/disassembly before assuming the next instruction belongs to the test.

These addresses belong to the unchanged border test. For other sources, use the generated `.sym` file to find `start`, and compare it with the disassembly and BASIC SYS target. Rebuild after every edit and load the new PRG before trusting an old address.

Sources: [VICE monitor commands](https://vice-emu.sourceforge.io/vice_12.html), [KickAssembler symbol files](https://www.theweb.dk/KickAssembler/webhelp/content/ch02s01.html).
