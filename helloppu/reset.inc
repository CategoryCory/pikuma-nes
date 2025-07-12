;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Macro to initialize NES by disabling rendering and clearing RAM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.macro INIT_NES
    sei                     ; Disable all IRQ interrupts
    cld                     ; Clear decimal mode (not supported by the NES)
    ldx #$FF
    txs                     ; Initialize the stack pointer at address $FF

    inx                     ; Increment X, causing a rolloff from $FF to $00
    stx PPU_CTRL            ; Disable NMI
    stx PPU_MASK            ; Disable rendering
    stx $4010               ; Disable DMC IRQs

    lda #$40
    sta $4017               ; Disable APU frame IRQ

WaitVBlank1:                ; Await the first VBlank from PPU
    bit PPU_STATUS          ; Perform bitwise check with PPU_STATUS
    bpl WaitVBlank1         ; Loop until 7th bit (sign bit) is 1

    txa                     ; A = 0
ClearRAM:
    sta $0000,x             ; Zero RAM addresses from $0000 to $00FF
    sta $0100,x             ; Zero RAM addresses from $0100 to $01FF
    sta $0200,x             ; Zero RAM addresses from $0200 to $02FF
    sta $0300,x             ; Zero RAM addresses from $0300 to $03FF
    sta $0400,x             ; Zero RAM addresses from $0400 to $04FF
    sta $0500,x             ; Zero RAM addresses from $0500 to $05FF
    sta $0600,x             ; Zero RAM addresses from $0600 to $06FF
    sta $0700,x             ; Zero RAM addresses from $0700 to $07FF
    inx
    bne ClearRAM

WaitVBlank2:                ; Await the second VBlank from PPU
    bit PPU_STATUS          ; Perform bitwise check with PPU_STATUS
    bpl WaitVBlank2         ; Loop until 7th bit (sign bit) is 1

.endmacro