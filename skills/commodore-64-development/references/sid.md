# SID sound and target variants

- The SID is normally visible to the CPU at `$D400-$D41F` when I/O is banked in. Verify CPU banking before using it. The three voices occupy seven registers each: voice 1 `$D400-$D406`, voice 2 `$D407-$D40D`, voice 3 `$D40E-$D414`. Add 7 or 14 to voice 1 offsets for the other voices.
- Per voice: `+0/+1` = frequency low/high (16-bit little endian); `+2/+3` = 12-bit pulse width, with only low four bits of `+3` used; `+4` = control; `+5` = attack high nibble, decay low nibble; `+6` = sustain high nibble, release low nibble. Control bits: 7 noise, 6 pulse, 5 sawtooth, 4 triangle, 3 test, 2 ring modulation, 1 sync, 0 gate. Do not treat waveform bits as an enum; some combinations are chip-model-dependent.
- Filter and master output occupy `$D415-$D418`. `$D417` selects voices routed through the filter; `$D418` low nibble is overall volume (0-15), bits 4-6 select filter modes, and bit 7 disconnects voice 3 from the direct output. Preserve other voices' settings in a program that shares SID ownership. On a clean standalone BASIC launch, explicitly initialize what the program uses; do not pretend the previous SID contents can be read back and restored, because most SID registers are write-only.
- To play a simple note, set frequency, envelope, waveform, and volume, then set gate bit 0. To release it, clear gate while retaining waveform bits. Allow the chosen release time to elapse before lowering master volume or returning to another sound owner. Retriggering a note may require a gate-off interval.
- The frequency register is approximately `round(hertz * 16777216 / SID_clock_hz)`: use about 985248 Hz for a common PAL C64 and 1022727 Hz for a common NTSC C64. Preserve intended pitch by choosing a table for the target clock. A player updated once per video frame runs about 20% faster on NTSC if it assumes 50 Hz; separate musical tick rate from raster refresh or resample the updates. See [PAL timing](pal-timing.md) and [NTSC timing](ntsc-timing.md).
- Avoid frame-busy delays that stop keyboard scanning or break IRQ-driven playback.

## Hardware and emulator targets

| Target | What to account for |
| --- | --- |
| Original 6581 SID and later 8580 SID, including C64C boards | Same basic register map, different analog filters and combined waveform behavior. Filter cutoff tables and tricks based on changing `$D418` volume may sound different. Verify on both chip models if audio character matters. Identify the chip rather than assuming the case style determines it. |
| PAL, NTSC, and old NTSC C64 | Clock changes pitch for the same frequency word and the frame rate changes frame-driven music tempo. Select the actual video standard and VIC revision for raster work. |
| C128 in C64 mode | Treat it as a C64-compatible target, but check its installed SID and PAL/NTSC model; do not infer the SID revision from the C128 name. Native C128 mode requires separate startup and banking decisions. |
| Second SID or stereo cartridge/modification | Treat the extra SID base address and presence as an explicit configuration. `$DE00` or `$DF00` can conflict with cartridges, including an REU at `$DF00`; other modifications use `$D420` and other mapped addresses. Fall back to the primary SID when absent. Do not write to a guessed extra SID address. |
| VICE, MiSTer, FPGA or replacement SID | Configure the emulated model, video standard, filters, and any extra SID deliberately. Emulator output is a useful compatibility check; final analog sound still needs target hardware testing. C64DTV sound is a distinct variant rather than an assumed 6581/8580 replacement. |

For VICE, compare `x64sc.exe -pal -sidmodel 0 -autostart .\program.prg` with `x64sc.exe -ntsc -sidmodel 1 -autostart .\program.prg`; consult the installed version's help if options differ. These test PAL/6581 and NTSC/8580 combinations, not a promise that all original C64s have those pairings. Test combinations independently when a project supports both video and SID revisions.

Sources: [Commodore 64 Programmer's Reference Guide, sound chapter](https://www.commodore.ca/manuals/c64_programmers_reference/c64-programmers_reference_guide-04-programming_sound.pdf), [Mapping the Commodore 64](https://project64.c64.org/Software/mapc6411.txt), [VICE manual, SID settings](https://vice-emu.sourceforge.io/vice_7.html).
