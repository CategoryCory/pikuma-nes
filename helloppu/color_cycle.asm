;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants for PPU registers mapped from addresses $2000 to $2007
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PPU_CTRL   = $2000
PPU_MASK   = $2001
PPU_STATUS = $2002
OAM_ADDR   = $2003
OAM_DATA   = $2004
PPU_SCROLL = $2005
PPU_ADDR   = $2006
PPU_DATA   = $2007
COUNT_BYTE = $00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The iNES header (contains a total of 16 bytes with the flags at $7F00)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.segment "HEADER"
.byte $4E,$45,$53,$1A        ; 4 bytes with the characters 'N','E','S','\n'
.byte $02                    ; How many 16KB of PRG-ROM we'll use (=32KB)
.byte $01                    ; How many 8KB of CHR-ROM we'll use (=8KB)
.byte %00000000              ; Horz mirroring, no battery, mapper 0
.byte %00000000              ; mapper 0, playchoice, NES 2.0
.byte $00                    ; No PRG-RAM
.byte $00                    ; NTSC TV format
.byte $00                    ; Extra flags for TV format and PRG-RAM
.byte $00,$00,$00,$00,$00    ; Unused padding to complete 16 bytes of header

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PRG-ROM code located at $8000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.segment "CODE"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reset handler (called when the NES resets or powers on)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Reset:
    sei                      ; Disable all IRQ interrupts
    cld                      ; Clear decimal mode (not supported by the NES)
    ldx #$FF
    txs                      ; Initialize the stack pointer at address $FF

    inx                      ; Increment X, causing a rolloff from $FF to $00
    txa                      ; A = 0
ClearRAM:
    sta $0000,x              ; Zero RAM addresses from $0000 to $00FF
    sta $0100,x              ; Zero RAM addresses from $0100 to $01FF
    sta $0200,x              ; Zero RAM addresses from $0200 to $02FF
    sta $0300,x              ; Zero RAM addresses from $0300 to $03FF
    sta $0400,x              ; Zero RAM addresses from $0400 to $04FF
    sta $0500,x              ; Zero RAM addresses from $0500 to $05FF
    sta $0600,x              ; Zero RAM addresses from $0600 to $06FF
    sta $0700,x              ; Zero RAM addresses from $0700 to $07FF
    inx
    bne ClearRAM

Main:
    lda #$00                ; Initialize accumulator to zero
    sta COUNT_BYTE          ; Store 0 into counter byte

    ; Basic NES initialization
    lda #$00                
    sta PPU_CTRL            ; Disable NMI
    lda #%00011110      
    sta PPU_MASK            ; Enable rendering

    ; Clear PPU_STATUS by reading it
    bit PPU_STATUS

ColorLoop:
    ; Call delay subroutine
    jsr DelayLoop           ; Jump to subroutine DelayLoop

    ; Increment the counter byte
    inc COUNT_BYTE          ; Increment the value at COUNT_BYTE

    ; Check if the count byte has reached $40 (meaning it has just incremented from $3F)
    lda COUNT_BYTE          ; Load current counter value into accumulator
    cmp #$40                ; Compare accumulator with $40 (the value after $3F)
    bne SetColor            ; If not equal to $40, continue with loop (no reset needed)

    ; If the counter is $40, it has just wrapped from $3F. Reset to $00
    lda #$00                ; Load $00 back into accumulator
    sta COUNT_BYTE          ; Store $00 back into COUNT_BYTE

SetColor:
    lda #$3F
    sta PPU_ADDR            ; Send high byte of PPU_ADDR
    lda #$00
    sta PPU_ADDR            ; Send low byte of PPU_ADDR
    lda COUNT_BYTE          ; Grab current count byte (corresponds to color index)
    sta PPU_DATA            ; Send current color to PPU_DATA
    jmp ColorLoop           ; Jump unconditionally to continue loop

DelayLoop:
    ldx #$05                ; Load X with outer loop counter
OuterDelay:
    ldy #$FF                ; Load Y with middle loop counter
MiddleDelay:
    lda #$FF                ; Load A with inner loop counter
InnerDelay:
    sec
    sbc #01                 ; Decrement accumulator
    bne InnerDelay          ; Branch back if A is not zero
    dey                     ; Decrement Y
    bne MiddleDelay         ; Branch back if Y is not zero
    dex                     ; Decrement X
    bne OuterDelay          ; Branch back if X is not zero
    rts


LoopForever:
    jmp LoopForever

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NMI interrupt handler
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NMI:
    rti                      ; Return from interrupt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; IRQ interrupt handler
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IRQ:
    rti                      ; Return from interrupt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Vectors with the addresses of the handlers that we always add at $FFFA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.segment "VECTORS"
.word NMI                    ; Address (2 bytes) of the NMI handler
.word Reset                  ; Address (2 bytes) of the Reset handler
.word IRQ                    ; Address (2 bytes) of the IRQ handler