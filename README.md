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

## When a test fails

Start with the symptom below. Keep the first error message, change one thing, rebuild after source edits, and use a fresh VICE window for another test.

| Symptom | First check | Next step |
| --- | --- | --- |
| PowerShell cannot find `java` | Run `java -version`. | Install a Java runtime if missing; reopen PowerShell after updating PATH. |
| Java cannot access `KickAss.jar` | Check the current directory and JAR path. | Use its full quoted path in the [build command](#build-and-run-on-windows-powershell). |
| PowerShell cannot find `x64sc.exe` or `c1541.exe` | Locate the executables in your VICE installation. | Use `& "C:\\path\\to\\x64sc.exe"` followed by its arguments, or add that directory to PATH. |
| Assembly fails | Read the first reported error and its source line. | Confirm KickAssembler syntax and documented NMOS instructions; consult [KickAssembler](skills/commodore-64-development/references/kickassembler.md). Stop before launching a stale PRG. |
| Symbols are missing | Check that the build includes `-symbolfile`. | Look for the source basename's `.sym` beside the source, even when `-o` writes the PRG elsewhere. Rebuild symbols after edits. |
| The old result appears after an edit | Check the build succeeded and VICE loaded the intended PRG path. | Close the old window, rebuild, and launch the new file using the [commands](#build-and-run-on-windows-powershell). |
| Loading finishes but the program does not start | Check whether the PRG has a BASIC launcher or needs a documented SYS entry. | Repository tests use `RUN`; distinguish load and execution addresses in the [memory map](skills/commodore-64-development/references/memory-map.md). |
| Joystick input does nothing | Check the host keyset/controller is assigned to C64 port 2. | Try numpad fire (0) with the numpad preset. Follow the [joystick example](skills/commodore-64-development/references/input.md#worked-joystick-polling-example). |
| A key no longer exits a changed test | Check KERNAL IRQ scanning still runs and the key is outside the joystick keyset. | Compare with the unchanged source; review [input](skills/commodore-64-development/references/input.md) and [CIA/IRQ ownership](skills/commodore-64-development/references/cia.md). |
| Disk LOAD reports file not found | List drive 8's directory and confirm its exact filename. | Attach the intended D64 to drive 8 and follow the [disk workflow](#run-from-a-disk-image). |
| The storage test returns a red border | Inspect its diagnostics before loading the directory. | Decode KERNAL, bus and DOS results using [storage diagnostics](skills/commodore-64-development/references/kernal.md#load-and-save-a-small-data-block). A second run intentionally fails if C64DATA already exists. |
| A monitor breakpoint never triggers | Check the program is loaded and the breakpoint uses the current symbol address. | Start through BASIC `RUN` and follow the [debugging session](skills/commodore-64-development/references/kickassembler.md#first-vice-debugging-session). |

For a useful fault report, include the source name, the edit, the exact build/run commands, the first error, and the selected VICE video standard. For storage failures, also include the captured diagnostics and attached disk filename. State whether it fails with the unchanged example in a fresh window.

### Validation still to run

Assembly or CPU tests with mocked KERNAL calls do not validate disk emulation, controller mappings or physical hardware. When VICE is available, use these checks:

- Follow the border-test monitor walkthrough, including returning to BASIC.
- Run the joystick example: press, hold, release, press again, then exit with a non-joystick keyboard key.
- On a fresh writable D64, run the storage example once (green), then again (red, DOS 63). Repeat on a fresh read-only image and confirm failure; restore write access afterwards.
- Confirm the disk directory and saved bytes, and record VICE version, machine model, results and any physical-controller checks.

Keep these checks marked outstanding until actually run. Leave real-hardware compatibility unclaimed until tested on the target.
