// Stock BASIC/KERNAL context, KickAssembler 5.x. Attach a fresh writable D64.
// Saves four bytes to C64DATA, clears RAM, reloads, checks bytes and DOS status.
// Green border = pass, red = failure. Returns to BASIC; no overwrite prefix.
.cpu _6502NoIllegals
BasicUpstart2(start)
.label buffer = $c000
.label endBuffer = buffer + 4
.label savePointer = $fb

start:
    cld
    lda #0
    sta kernalCode
    sta ioStatus
    sta dosTens
    sta dosOnes
    lda savePointer
    sta oldPointer
    lda savePointer+1
    sta oldPointer+1
    ldx #3
fill:
    lda expected,x
    sta buffer,x
    dex
    bpl fill

    jsr setDataFile
    lda #<buffer
    sta savePointer
    lda #>buffer
    sta savePointer+1
    lda #savePointer        // Address of zero-page pointer, not buffer low byte.
    ldx #<endBuffer
    ldy #>endBuffer         // Exclusive end: save $C000..$C003.
    jsr $ffd8              // SAVE.
    bcc saved
    sta kernalCode
    jmp failed
saved:
    jsr $ffb7              // READST, separate from DOS error channel.
    sta ioStatus
    beq saveBusOK
    jmp failed
saveBusOK:
    jsr checkDrive
    bcc clearBuffer
    jmp failed
clearBuffer:
    ldx #3
    lda #0
clear:
    sta buffer,x
    dex
    bpl clear

    jsr setDataFile
    lda #0
    ldx #<buffer
    ldy #>buffer
    jsr $ffd5              // LOAD; SA=1 uses the file's address header.
    bcc loaded
    sta kernalCode
    jmp failed
loaded:
    stx loadedEnd
    sty loadedEnd+1
    jsr $ffb7
    sta ioStatus
    and #$bf               // EOI ($40) alone is normal at end of load.
    beq loadBusOK
    jmp failed
loadBusOK:
    jsr checkDrive
    bcs failed
    lda loadedEnd
    cmp #<endBuffer
    bne failed
    lda loadedEnd+1
    cmp #>endBuffer
    bne failed
    ldx #3
compare:
    lda buffer,x
    cmp expected,x
    bne failed
    dex
    bpl compare
    lda #5                 // Green.
    bne finish
failed:
    lda #2                 // Red; inspect diagnostics via .sym addresses.
finish:
    sta $d020
    lda oldPointer
    sta savePointer
    lda oldPointer+1
    sta savePointer+1
    jsr $ffcc              // Restore default input/output channels.
    rts

setDataFile:
    lda #nameEnd-name
    ldx #<name
    ldy #>name
    jsr $ffbd              // SETNAM: length and filename pointer.
    lda #1
    ldx #8
    ldy #1
    jmp $ffba              // SETLFS: logical file, device, secondary address.

// Read DOS status on channel 15. Only 00 is accepted.
// Drain the line with a bounded loop, close our file, restore channels.
checkDrive:
    lda #0
    jsr $ffbd
    lda #15
    ldx #8
    ldy #15
    jsr $ffba
    jsr $ffc0              // OPEN.
    bcs driveKernalFail
    ldx #15
    jsr $ffc6              // CHKIN.
    bcs driveKernalFail
    jsr $ffcf
    sta dosTens
    jsr $ffcf
    sta dosOnes
    lda #40
    sta remaining
drainStatus:
    jsr $ffcf              // CHRIN: consume message through carriage return.
    sta statusChar
    jsr $ffb7
    and #$bf
    bne driveBusFail
    lda statusChar
    cmp #13
    beq driveLineDone
    dec remaining
    bne drainStatus
driveBusFail:
    jsr closeStatus
    sec
    rts
driveKernalFail:
    sta kernalCode
    jsr closeStatus
    sec
    rts
driveLineDone:
    jsr closeStatus
    lda dosTens
    cmp #$30               // PETSCII '0'.
    bne driveNotOK
    lda dosOnes
    cmp #$30
    bne driveNotOK
    clc
    rts
driveNotOK:
    sec
    rts
closeStatus:
    lda #15
    jsr $ffc3
    jmp $ffcc

.encoding "petscii_upper"
name:       .text "C64DATA"
nameEnd:
expected:   .byte $12,$34,$56,$78
oldPointer: .word 0
loadedEnd:  .word 0
kernalCode: .byte 0
ioStatus:   .byte 0
dosTens:    .byte 0
dosOnes:    .byte 0
remaining: .byte 0
statusChar: .byte 0
