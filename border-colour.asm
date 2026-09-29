// C64 border colour test, KickAssembler, documented 6510/6502 opcodes.
// LOAD "BORDER-COLOUR",8,1 then RUN. The border becomes red and BASIC returns.
.cpu _6502NoIllegals

* = $0801 "BASIC launcher"
    .word basicEnd       // Pointer to the BASIC end marker at $080B
    .word 10             // Line number
    .byte $9e            // BASIC token for SYS
    .byte $32,$30,$36,$31 // PETSCII digits "2061" ($080D)
    .byte 0              // End of BASIC line
basicEnd:
    .word 0              // End of BASIC program

start:                   // $080D = decimal 2061
    lda #$02             // C64 colour 2: red
    sta $d020            // VIC-II border colour register
    rts                  // Return to BASIC
