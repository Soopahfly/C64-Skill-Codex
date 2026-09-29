# NTSC C64 timing

Select the actual VIC-II model before using cycle or raster constants. VICE distinguishes current NTSC from old NTSC; neither has PAL's 312 lines by 63 cycles. Approximate frame rates follow from the common clock and the frame cycle count.

| Video target | Raster lines | Cycles per line | Cycles per frame | Approximate frames/s |
| --- | ---: | ---: | ---: | ---: |
| PAL 6569/8565, for comparison | 312 | 63 | 19656 | 50.1 |
| NTSC 6567R8 / 8562 | 263 | 65 | 17095 | 59.8 |
| Old NTSC 6567R56A | 262 | 64 | 16768 | About 60; verify the actual clock |

- A modern NTSC C64 runs near 1.022727 MHz, versus about 0.985248 MHz PAL. The same SID frequency word therefore plays higher on NTSC. Compute notes from the actual clock, and drive music from a target rate rather than assuming one call per PAL frame.
- An IRQ at one selected raster line per frame arrives at roughly 60 Hz on NTSC instead of 50 Hz PAL. Frame counters, animation, repeat rates, and music tempos need time-based conversion. For example, a 50 Hz event cannot simply run once per NTSC frame; distribute or time its updates.
- A PAL raster compare at line 300 cannot occur on an NTSC frame. Choose valid lines and account for the shorter border and fewer total cycles per frame. `$D011` bit 7 is the raster compare's ninth bit on write; `$D012` holds its low byte. Read semantics differ from write semantics.
- Badlines and sprite DMA steal bus cycles. A nominal 65-cycle line does not guarantee 65 CPU cycles of uninterrupted work. Check the target VIC revision and enabled sprites for cycle-exact effects.
- Test `x64sc.exe -ntsc -autostart .\program.prg` and `x64sc.exe -ntscold -autostart .\program.prg` as distinct cases, as well as `-pal`; check the selected VIC model in VICE. Do not silently call 6567R56A timing the default NTSC machine.

Sources: [VICE manual, C64 video-standard options](https://vice-emu.sourceforge.io/vice_7.html), [VICE VIC-II model mapping](https://github.com/VICE-Team/svn-mirror/blob/main/vice/src/viciisc/vicii-resources.c), [Christian Bauer, VIC-II timing research](https://github.com/vossi1/pm500/blob/master/Info/C64%206567-6569%20VIC.txt).
