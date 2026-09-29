# PAL and timing assumptions

- Default to PAL for this user's new C64 programs, but mark raster-sensitive code as PAL-specific. Common PAL VIC-II timing is 312 lines per frame, 63 cycles per line, about 50 frames per second; check the exact VIC revision and target when precision matters.
- A badline can occupy 40 CPU cycles for character fetches; sprite DMA also steals cycles. Count free CPU cycles for the actual raster line and enabled sprites, rather than treating the full 63 cycles as uninterrupted execution time.
- Frame loops tied to the KERNAL IRQ, a raster IRQ, or polling `$D012` have different timing and jitter. For stable effects, test under the target video mode and consider IRQ latency, current raster position, branches, and page crossings.
- NTSC machines have different line and cycle counts depending on revision. Do not silently reuse PAL constants or derive musical tempo solely from a PAL frame count when NTSC support is required.

Sources: [Commodore 64 Programmer's Reference Guide](https://www.commodore.ca/manuals/c64_programmers_reference/c64-programmers_reference.htm), [Mapping the Commodore 64](https://project64.c64.org/Software/mapc6411.txt). For cycle-exact routines, verify against detailed documentation for the precise VIC-II revision.
