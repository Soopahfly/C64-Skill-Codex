// PAL C64 raster IRQ test for KickAssembler 5.x.
// A red band appears from raster line 50 to 200; press a key to exit.
// Keeps the normal KERNAL timer/keyboard IRQ running and restores its vector.
// Run on a fresh BASIC machine: the original VIC raster IRQ mask is 0.
.cpu _6502NoIllegals

* = $0801 "BASIC launcher"
    .word basicEnd
    .word 10
    .byte $9e, $32, $30, $36, $31, 0 // SYS 2061 = $080D
basicEnd:
    .word 0

start:
    jmp setup

// This pointer is at $0810, so NMOS JMP (oldIrq) cannot hit the $xxFF bug.
oldIrq:     .word 0
oldVicMask: .byte 0
oldD011Mode: .byte 0
oldBorder:  .byte 0
phase:      .byte 0

setup:
    sei
    lda $0314
    sta oldIrq
    lda $0315
    sta oldIrq+1
    lda $d01a
    sta oldVicMask
    lda $d011
    and #$7f            // Read bit 7 is current raster, not compare MSB.
    sta oldD011Mode
    lda $d020
    sta oldBorder
    lda #0
    sta phase

    lda #<rasterIrq
    sta $0314
    lda #>rasterIrq
    sta $0315
    lda oldD011Mode    // Set compare MSB to 0; preserve display mode.
    sta $d011
    lda #50
    sta $d012
    lda #$01
    sta $d019           // Clear an old raster IRQ flag, if set.
    lda oldVicMask
    ora #$01
    sta $d01a           // Enable the VIC raster IRQ.
    cli

waitRelease:
    jsr $ffe4            // KERNAL GETIN
    bne waitRelease
waitKey:
    jsr $ffe4
    beq waitKey

    // Disable our raster source before restoring the old vector.
    // $D012 read gives current raster, so the prior compare is not readable.
    // On fresh BASIC, raster IRQ was disabled. Leave compare at line 0.
    sei
    lda $d01a
    and #$fe
    sta $d01a
    lda #$01
    sta $d019
    lda oldD011Mode
    sta $d011
    lda #0
    sta $d012
    lda oldIrq
    sta $0314
    lda oldIrq+1
    sta $0315
    lda oldVicMask
    sta $d01a
    lda oldBorder
    sta $d020
    cli
    rts

// The KERNAL ROM has already stacked A/X/Y before jumping through $0314.
rasterIrq:
    lda $d019
    and #$01
    beq chainOldIrq     // CIA timer or another source: use original handler.
    lda #$01
    sta $d019           // VIC flags clear by writing 1.
    lda phase
    bne endRedBand

beginRedBand:
    lda #$02
    sta $d020           // Red border from line 50.
    lda #200
    sta $d012
    lda #1
    sta phase
    jmp $ea81           // KERNAL restores A/X/Y, then RTI.

endRedBand:
    lda oldBorder
    sta $d020           // Original border after line 200.
    lda #50
    sta $d012
    lda #0
    sta phase
    jmp $ea81

chainOldIrq:
    jmp (oldIrq)        // Original KERNAL path handles timer and keyboard.
