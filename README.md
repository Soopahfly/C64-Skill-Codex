# C64 development skills and KickAssembler tests

## Skills

The complete, portable skill folders are in [`skills/commodore-64-development`](skills/commodore-64-development/SKILL.md) and [`skills/6502-assembly`](skills/6502-assembly/SKILL.md). Keep each `SKILL.md` together with its `references`, `agents`, and `assets` folders. The C64 skill covers VIC-II, SID, input, REU, PAL and NTSC timing, memory banking, KERNAL, CIA, and KickAssembler. The 6502 skill covers CPU instructions, addressing, and timing. The C64 skill calls for the 6502 skill on CPU-level tasks.

On another computer, get a local source copy with:

```powershell
git clone https://github.com/Soopahfly/C64-Skill-Codex.git
```

Your installed ChatGPT skills also follow your account; this repository is a source copy you can inspect and use separately.

## Start here

Use the build/run commands below for each source. Make one change at a time, rebuild, and start a fresh VICE window.

| Order | Program | Learn | Small exercise | Reference |
| --- | --- | --- | --- | --- |
| 1 | `border-colour.asm` | Write a register and return to BASIC. | Change colour `$02` to `$05`; expect green. | [Debugging](skills/commodore-64-development/references/kickassembler.md#first-vice-debugging-session) |
| 2 | `vic-bank-test.asm` | Separate VIC and CPU memory views. | Change the screen fill `$01` to `$02`; expect B characters. | [VIC-II](skills/commodore-64-development/references/vic-ii.md) |
| 3 | `sid-sound-test.asm` | Configure and stop a voice. | Change gate-on `$11` to `$21`; expect sawtooth at the same pitch. | [SID](skills/commodore-64-development/references/sid.md) |
| 4 | `raster-irq-test.asm` | Run raster IRQs alongside keyboard scanning. | Change both line-200 compare values to 150; expect a shorter red band. | [CIA](skills/commodore-64-development/references/cia.md) |

Next, try the [worked joystick example](skills/commodore-64-development/references/input.md#worked-joystick-polling-example). Keep these first exercises on PAL; consult the timing references before changing video standard.

## Test programs

Four small PAL C64 programs for KickAssembler 5.x. Each PRG includes a BASIC `SYS 2061` launcher and can be autostarted in VICE (`x64sc`). The source uses documented NMOS 6502 instructions.

| Source | Expected result |
| --- | --- |
| `border-colour.asm` | Red border, then returns to BASIC. |
| `vic-bank-test.asm` | Green border and full screen of A characters. Press a key to restore the screen. |
| `raster-irq-test.asm` | Red band in the border, driven by raster interrupts. Press a key to exit. |
| `sid-sound-test.asm` | Steady SID tone. Press a key to stop and return to BASIC. |

Run each test in a fresh VICE window, especially the VIC bank, raster IRQ, and SID tests, which assume stock BASIC machine state. Physical C64 hardware has not been tested.

## Build and run on Windows PowerShell

Put `KickAss.jar` beside these source files, or adjust its path in the command. From this directory:

```powershell
java -jar .\KickAss.jar .\sid-sound-test.asm -o .\sid-sound-test.prg -symbolfile
x64sc.exe -autostart .\sid-sound-test.prg
```

Replace `sid-sound-test` in both commands with any of the other source names. If `x64sc.exe` is not on your PATH, use its full path with PowerShell's `&` call operator.

## Run from a disk image

A PRG is one program file. A D64 is a disk image containing a directory and files, as a 1541 disk would. Autostart hides the loading steps; this exercise makes them explicit.

Build `border-colour.prg` with the commands above. VICE includes `c1541.exe`; add its directory to PATH or invoke its full path with PowerShell's `&` operator. Create a new practice image and add the program:

```powershell
if (Test-Path .\practice.d64) { throw "practice.d64 already exists; choose another filename." }
c1541.exe -format "PRACTICE,01" d64 .\practice.d64
c1541.exe -attach .\practice.d64 -write .\border-colour.prg BORDER
c1541.exe -attach .\practice.d64 -list
x64sc.exe -pal -8 .\practice.d64
```

The guard avoids formatting an existing image. Run one command at a time and stop on errors. The directory should contain `BORDER` as a PRG. At the C64 BASIC prompt, type:

```basic
LOAD "$",8
LIST
LOAD "BORDER",8,1
RUN
```

Loading the directory replaces the BASIC program in memory, so load the test afterwards. `8` selects drive 8; `,1` loads the PRG at its stored address. This test includes a BASIC launcher, so `RUN` starts it. A bare machine-code PRG may instead require its documented `SYS` address.

### Save and reload data

Build `storage-roundtrip.asm` with `-symbolfile`, then add the result to the same writable practice disk:

```powershell
java -jar .\KickAss.jar .\storage-roundtrip.asm -o .\storage-roundtrip.prg -symbolfile
c1541.exe -attach .\practice.d64 -write .\storage-roundtrip.prg STORAGE
```

Close VICE before modifying its attached image with c1541, then reopen with `x64sc.exe -pal -8 .\practice.d64`. Use `LOAD "STORAGE",8,1`, then `RUN`. The test saves four bytes as `C64DATA`, clears its buffer, reloads and compares them. Green means the round trip passed; red means a transfer, drive-status, length or data check failed. Disk activity can take time.

The test deliberately does not overwrite an existing `C64DATA`: running it a second time should fail with DOS code 63 (file exists). Use a fresh practice image for another successful run. See [KERNAL load/save contracts and diagnostics](skills/commodore-64-development/references/kernal.md#load-and-save-a-small-data-block). Do not format or scratch files on a disk containing data you want to keep.

After returning to BASIC, `LOAD "$",8` and `LIST` should show `C64DATA`. For a failure, inspect the test's diagnostic variables before loading the directory. To inspect the drive's current status from BASIC:

```basic
OPEN 15,8,15
INPUT#15,E,M$,T,S
PRINT E;M$;T;S
CLOSE 15
```

Reading the error channel acknowledges its status, so the test's captured digits are the useful record of an earlier error.

Sources: [VICE c1541 commands](https://vice-emu.sourceforge.io/vice_14.html), [VICE C64 command-line options](https://vice-emu.sourceforge.io/vice_7.html).
