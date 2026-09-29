// VIC-II bank test for a standard C64, KickAssembler 5.x.
// Assemble, autostart in VICE, then press a key to return to BASIC.
// Uses $8400-$87FF as temporary screen RAM on a fresh machine.
.cpu _6502NoIllegals

* = $0801 "BASIC launcher"
    .word basicEnd
    .word 10
    .byte $9e, $32, $30, $36, $31, 0 // SYS 2061 = $080D
basicEnd:
    .word 0

start:
    // Save all registers that this test changes.
    lda $dd00
    sta oldDD00
    lda $dd02
    sta oldDD02
    lda $d018
    sta oldD018
    lda $d020
    sta oldBorder

    // Fill a 1 KiB matrix at $8400 with screen code 1 ("A").
    // The VIC sees character ROM at bank 2's $9000-$9FFF.
    lda #$01
    ldx #$00
fillScreen:
    sta $8400,x
    sta $8500,x
    sta $8600,x
    sta $8700,x
    inx
    bne fillScreen

    // Make CIA2 port A bits 0 and 1 outputs, preserving other pins.
    lda oldDD02
    ora #$03
    sta $dd02

    // Bank code 01 selects $8000-$BFFF. Preserve the serial bus bits.
    lda oldDD00
    and #$fc
    ora #$01
    sta $dd00

    // Screen: bank 2 + $0400 = $8400.
    // Charset: bank 2 + $1000 = VIC-visible character ROM at $9000.
    lda #$14
    sta $d018
    lda #$05             // Green border marks the active test.
    sta $d020

    // Release any key used to launch RUN, then wait for a new key.
waitRelease:
    jsr $ffe4            // KERNAL GETIN, returns 0 if no key.
    bne waitRelease
waitKey:
    jsr $ffe4
    beq waitKey

    // Put the VIC, CIA2 and border back as they were.
    lda oldD018
    sta $d018
    lda oldDD00
    sta $dd00
    lda oldDD02
    sta $dd02
    lda oldBorder
    sta $d020
    rts

oldDD00:   .byte 0
oldDD02:   .byte 0
oldD018:   .byte 0
oldBorder: .byte 0
