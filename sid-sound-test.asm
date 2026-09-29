// KickAssembler 5.x, stock PAL C64. Hear a steady A4 tone; press a key to stop.
// Run from a fresh BASIC startup: SID writes are mostly write-only and cannot
// restore another sound program's state. Keep the normal KERNAL IRQ enabled.
.cpu _6502NoIllegals

* = $0801 "BASIC launcher"
    .word basicEnd
    .word 10
    .byte $9e, $32, $30, $36, $31, 0 // SYS 2061 = $080D
basicEnd:
    .word 0

start:
    lda #$00
    sta $d404               // Voice 1 gate off while configuring it.
    sta $d402               // Pulse width, unused for triangle.
    sta $d403
    lda #$45
    sta $d400               // Frequency $1D45: approximately A4 (440 Hz) on PAL.
    lda #$1d
    sta $d401
    lda #$09
    sta $d405               // Fast attack, medium decay.
    lda #$f0
    sta $d406               // Full sustain, shortest release.
    lda #$0f
    sta $d418               // Master volume 15 (fresh BASIC machine).
    lda #$11
    sta $d404               // Triangle waveform + gate on.

waitRelease:
    jsr $ffe4               // Discard a key already in the KERNAL buffer.
    bne waitRelease
waitKey:
    jsr $ffe4               // GETIN returns zero while no key is queued.
    beq waitKey

    lda #$10
    sta $d404               // Gate off, triangle waveform still selected.
    lda #$00
    sta $d418               // Silence master output before returning to BASIC.
    rts
