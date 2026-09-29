# CPU timing

- Count base cycles for the *specific opcode and addressing mode* from a reference table. Do not infer cycles from mnemonic alone.
- Conditional branches: two cycles if not taken, three if taken within the same page, four if taken across a page.
- Indexed reads can gain a cycle on a page crossing, depending on opcode and mode. Indexed writes and read-modify-write operations have different fixed timings; check the opcode table.
- An IRQ/NMI entry, handler instructions, and return all take time. Include the interrupted machine's bus contention and interrupt sources in a raster or audio budget.
- For variable indices, prove bounds and page alignment before promising a constant duration. State whether the total is best case, worst case, or exact for a known path.

Source: [MOS 6500 Programming Manual](https://archive.org/details/mos_microcomputers_programming_manual), instruction cycle tables. For C64 bus stealing, use the `commodore-64-development` PAL timing reference as well.
