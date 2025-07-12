.segment "HEADER"       ; Don’t forget to always add the iNES header to your ROM files
.org $7FF0
.byte $4E,$45,$53,$1A,$02,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

.segment "CODE"         ; Define a segment called "CODE" for the PRG-ROM at $8000
.org $8000

Reset:
    ; Exercise 1
    lda #$82            ; Load the A register with the literal hexadecimal value $82
    ldx #82             ; Load the X register with the literal decimal value 82
    ldy $82             ; Load the Y register with the value that is inside memory position $82

    ; Exercise 2
    lda #$A              ; Load the A register with the hexadecimal value $A
    ldx #%11111111       ; Load the X register with the binary value %11111111
    sta $80             ; Store the value in the A register into memory address $80
    stx $81             ; Store the value in the X register into memory address $81

    ; Exercise 3
    lda #15             ; Load the A register with the literal decimal value 15
    tax                 ; Transfer the value from A to X
    tay                 ; Transfer the value from A to Y
    txa                 ; Transfer the value from X to A
    tya                 ; Transfer the value from Y to A
    ldx #6              ; Load X with the decimal value 6
    txa
    tay                 ; Transfer the value from X to Y

    ; Exercise 4
    cld                 ; Make sure Decimal mode is disabled
    lda #100            ; Load the A register with the literal decimal value 100
    clc                 ; Call clc before adding
    adc #5              ; Add the decimal value 5 to the accumulator
    sec                 ; Call sec before subtracting
    sbc #10             ; Subtract the decimal value 10 from the accumulator
    cmp #95             ; Register A should now contain the decimal 95 (or $5F in hexadecimal)

    ; Exercise 5
    lda #$A             ; Load the A register with the hexadecimal value $A
    ldx #%1010           ; Load the X register with the binary value %1010
    sta $80             ; Store the value in the A register into (zero page) memory address $80
    stx $81             ; Store the value in the X register into (zero page) memory address $81
    lda #10             ; Load A with the decimal value 10
    clc                 ; Call clc before adding
    adc $80             ; Add to A the value inside RAM address $80
    adc $81             ; Add to A the value inside RAM address $81
    cmp #30             ; A should contain (#10 + $A + %1010) = #30 (or $1E in hexadecimal)
    sta $82             ; Store the value of A into RAM position $82

    ; Exercise 6
    lda #1              ; Load the A register with the decimal value 1
    ldx #2              ; Load the X register with the decimal value 2
    ldy #3              ; Load the Y register with the decimal value 3
    inx                 ; Increment X
    iny                 ; Increment Y
    clc                 ; Call clc before adding
    adc #1              ; Increment A
    dex                 ; Decrement X
    dey                 ; Decrement Y
    sec                 ; Call sec before subtracting
    sbc #1              ; Decrement A

    ; Exercise 7
    lda #10             ; Load the A register with the decimal value 10
    sta $80             ; Store the value from A into memory position $80
    inc $80             ; Increment the value inside a (zero page) memory position $80
    dec $80             ; Decrement the value inside a (zero page) memory position $80

    ; Exercise 8
    ldy #10             ; Initialize the Y register with the decimal value 10
Loop8:
    tya                 ; Transfer Y to A
    sta $80,Y           ; Store the value in A inside memory position $80+Y
    dey                 ; Decrement Y
    bpl Loop8           ; Branch back to "Loop" until we are done

    ; Exercise 9
    lda #1              ; Initialize the A register with 1
Loop9:
    clc                 ; Call clc before adding
    adc #1              ; Increment A
    cmp #10             ; Compare the value in A with the decimal value 10
    bne Loop9           ; Branch back to "Loop" if the comparison was not equals (to zero)

NMI:                    ; NMI handler
    rti                 ; doesn't do anything

IRQ:                    ; IRQ handler
    rti                 ; doesn't do anything

.segment "VECTORS"      ; Add addresses with vectors at $FFFA
.org $FFFA
.word NMI               ; Put 2 bytes with the NMI address at memory position $FFFA
.word Reset             ; Put 2 bytes with the break address at memory position $FFFC
.word IRQ               ; Put 2 bytes with the IRQ address at memory position $FFFE