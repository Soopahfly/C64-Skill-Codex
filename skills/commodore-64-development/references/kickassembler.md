# KickAssembler and PRG output

- Use the selected project's KickAssembler version and build command. The current manual uses `*=$1000 "Program"` for placement; `.pc=$1000` is older supported syntax. Do not transplant ACME or ca65 directives into KickAssembler source.
- Explicitly select documented NMOS opcodes with `.cpu _6502NoIllegals` if the installed version supports it. KickAssembler's default `_6502` also accepts undocumented opcodes. Never set `.cpu _65c02` for a stock C64.
- For a new BASIC-launched program, use the documented `BasicUpstart2(entry)` helper if present in the installed version. Place subsequent machine code at a nonoverlapping address. Do not assume the BASIC stub entry and the PRG load address are equal.
- The manual's `.file [name="output.prg", segments="Code"]` creates a PRG for the specified segment; `type="bin"` produces raw binary without a PRG load address. Inspect the assembled file's first two bytes and the listing/memory map after building.
- An assembler's `*=`/`.pc` sets placement. It is not by itself proof that the loader, BASIC stub, and entry point agree. For relocated code, distinguish where bytes load from where labels execute; verify any `.pseudopc` block and actual copy routine.

Sources: [KickAssembler manual](https://www.theweb.dk/KickAssembler/webhelp/content/index.html), [memory directives](https://www.theweb.dk/KickAssembler/webhelp/content/ch03s05.html), [file directive](https://www.theweb.dk/KickAssembler/webhelp/content/ch11s03.html).

The user's [C64 Assembly Coding Guide](https://github.com/spiroharvey/c64/blob/main/asm/C64%20Assembly%20Coding%20Guide.md) is a useful index of further tutorials and references. Use the assembler's own manual for exact directive syntax.
