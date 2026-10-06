# Keyboard and joystick input

- Standard digital joystick port 2 is read from CIA1 port A `$DC00`; joystick port 1 from CIA1 port B `$DC01`. Bits 0-4 mean up, down, left, right, fire. Each line is active low (0 = pressed). Mask with `$1F`, then invert those five bits if the application wants pressed = 1. Preserve other port bits and the CIA data-direction settings. Joystick 1 shares keyboard matrix lines especially visibly; port 2 is a practical default for single-player examples, not a fixed control scheme.
- For BASIC/KERNAL-friendly text or menu input, `GETIN` at `$FFE4` returns a queued character in A, with zero when none. It does not report held or released key state. The normal KERNAL IRQ scans the keyboard; a custom IRQ or ROM banking can stop that update. For real-time movement, choose a verified matrix-scanning approach and account for the CIA configuration, ghosting, and joystick interaction; do not infer held keys from repeated `GETIN` characters.
- Keep hardware reads in a small input routine returning a project-defined state (directions, fire/actions). Sample once per game frame, distinguish held state from a new press, and document keys, joystick port, and emulator mapping. Do not assume a standard C64 joystick has more than one digital fire button. Treat paddles, mouse, and adapter-specific pads as separately specified devices.
- In VICE, explicitly assign a host keyboard keyset, numpad, or USB device to the intended **C64 port** and test that port; host controller enumeration and key maps vary. The numpad preset uses 1-9 for directions and 0 for fire. Prefer a keyboard-only test when physical controllers are unavailable, and mark the physical device path untested. Keyboard typing may differ when the emulator's joystick keyset intercepts keys.

Sources: [Commodore 64 service manual, keyboard and joystick interface](https://www.commodore.ca/manuals/funet/cbm/schematics/computers/c64/manual-html/Page_12.html), [Commodore 64 Programmer's Reference Guide, I/O chapter](https://www.commodore.ca/manuals/c64_programmers_reference/c64-programmers_reference_guide-06-input_output_guide.pdf), [VICE manual, joystick emulation](https://vice-emu.sourceforge.io/vice_1.html), [VICE manual, joystick settings](https://vice-emu.sourceforge.io/vice_6.html).

## Worked joystick polling example

Save the following as `joystick-poll-test.asm` beside the repository tests and use the README build/run commands with that name. It assumes a fresh stock PAL BASIC machine with KERNAL ROM and I/O visible. It samples at raster line 250 once per frame without installing an IRQ.

The returned state uses pressed = 1. A **held** button is present in the current sample; a **new press** is present now but absent from the previous sample: `new = current & ~previous`. This example changes the border once per fire press, rather than repeatedly while fire is held.

```asm
.cpu _6502NoIllegals
BasicUpstart2(start)

start:
    lda $d020
    sta oldBorder
    lda #0
    sta presses
    jsr readJoystick2
    sta previous           // A button held at launch is not a new press.

nextFrame:
    lda $d012
    cmp #250
    bne nextFrame
leaveLine:
    lda $d012
    cmp #250
    beq leaveLine          // Avoid sampling twice on the same raster line.

    jsr readJoystick2
    sta current
    lda previous
    eor #$1f
    and current
    and #$10               // New fire press only.
    beq noNewFire
    inc presses
    lda presses
    and #$0f
    sta $d020
noNewFire:
    lda current
    sta previous
    jsr $ffe4              // Any queued keyboard character exits.
    beq nextFrame
    lda oldBorder
    sta $d020
    rts

// Return A = up/down/left/right/fire in bits 0..4, pressed = 1.
// Clobbers A and X; preserves Y, CIA direction and interrupt-enable state.
// Briefly prevent KERNAL IRQ scanning while changing the port direction.
readJoystick2:
    php
    sei
    lda $dc02
    pha
    and #$e0               // Make only joystick lines inputs.
    sta $dc02
    lda $dc00
    and #$1f
    eor #$1f
    tax
    pla
    sta $dc02
    txa
    plp
    rts

oldBorder: .byte 0
presses:   .byte 0
current:   .byte 0
previous:  .byte 0
```

In VICE's joystick settings, assign a keyset or host controller to **C64 port 2**. With the numpad preset, use 0 for fire. Press, hold, release, and press again: the border should change once on each press and remain steady while held. Directions update `current` without changing the border; inspect that byte in the monitor using its address from the symbol file. With no input, expect `$00`; fire alone gives `$10`. Exit with a keyboard key outside the joystick keyset.

The first poll initializes history, so release fire before checking the first press. Keyboard matrix sharing can affect joystick reads; avoid typing during the joystick check. This short routine preserves the existing port configuration but is not a general replacement for keyboard scanning. Test with keyboard-only emulation first, then separately with the intended physical controller. For custom IRQs, other CIA owners, or NTSC targets, revisit the input and timing assumptions before reusing the loop.
