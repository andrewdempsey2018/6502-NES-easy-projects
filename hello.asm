.segment "HEADER"

  .byte $4E, $45, $53, $1A
  .byte $02
  .byte $01
  .byte $00
  .byte $00
  .byte $00
  .byte $00
  .byte $00
  .byte $00, $00, $00, $00, $00

.segment "STARTUP"

RESET:
  SEI ;Disable all interrupts.
  CLD ;Disable decimal mode.

  ;Disable sound IRQ
  LDX #$40 ;$40 = 01000000. In binary we refer to the most significant bit as bit 7, the next significant bit is bit 6 and so on...
  STX $4017 ;The APU frame counter is at $4017. Bit 6 here will disable sound IRQ if set. Hence we store 01000000 at $4017.

  ;Initialize stack register (not needed for now but it is a good habit to initialise it).
  LDX #$FF
  TXS ;Transfer X to stack pointer.

  ;The stack in a 6502 processor is just like any other stack - values are pushed onto it and popped (“pulled” in 6502 parlance) off it.
  ;The current depth of the stack is measured by the stack pointer, a special register. The stack lives in memory between $0100 and $01ff. The stack pointer is initially $ff,
  ;which points to memory location $01ff. When a byte is pushed onto the stack, the stack pointer becomes $fe, or memory location $01fe, and so on.
  ;Two of the stack instructions are PHA and PLA, “push accumulator” and “pull accumulator”. Below is an example of these two in action.

  INX ;#$FF + 1 so now x register is = #$00

  ;Zero out the PPU registers.
  STX $2000
  STX $2001

  ;Disable pcm.
  STX $4010

  ;To determine when everything has been set up, we check to see if the PPU is in vblank.
  ;If the PPU is in vblank, we know that everything has been set up successfully.
  ;The BIT instruction transfers the value of the operand to the status register.
  ;So in the below case, the N flag (bit 7) of the status register will be 1 if in
  ;vblank or 0 if not in vblank. BPL will branch if N=1 and loop to the anonymous label otherwise.
:
  BIT $2002
  BPL :-

  TXA

CLEARMEM:
  ;LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0300, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FF
  STA $0200, x
  INX
  BNE CLEARMEM

;Wait for VBLANK.
:
  BIT $2002
  BPL :-

  LDA #$02
  STA $4014
  NOP

  ; $3F00
  LDA #$3F
  STA $2006
  LDA #$00
  STA $2006

  LDX #$00

LoadPalettes:
  LDA PaletteData, X
  STA $2007 ; $3F00, $3F01, $3F02 => $3F1F
  INX
  CPX #$20
  BNE LoadPalettes    

  LDX #$00
LoadSprites:
  LDA SpriteData, X
  STA $0200, X
  INX
  CPX #$28
  BNE LoadSprites 

; Enable interrupts
  CLI

  LDA #%10010000 ; enable NMI change background to use second chr set of tiles ($1000)
  STA $2000
  ; Enabling sprites and background for left-most 8 pixels
  ; Enable sprites and background
  LDA #%00011110
  STA $2001

LOOP:
  JMP LOOP

NMI:
    LDA #$02 ; copy sprite data from $0200 => PPU memory for display
    STA $4014
    RTI

PaletteData:
  .byte $22,$29,$1A,$0F,$22,$36,$17,$0f,$22,$30,$21,$0f,$22,$27,$17,$0F  ;background palette data
  .byte $22,$16,$27,$18,$22,$1A,$30,$27,$22,$16,$30,$27,$22,$0F,$36,$17  ;sprite palette data

SpriteData:
  .byte $28, $07, $00, $28
  .byte $28, $04, $00, $30
  .byte $28, $0B, $00, $38
  .byte $28, $0B, $00, $40
  .byte $28, $0E, $00, $48
  
  .byte $30, $16, $00, $28
  .byte $30, $0E, $00, $30
  .byte $30, $11, $00, $38
  .byte $30, $0B, $00, $40
  .byte $30, $03, $00, $48

.segment "ZEROPAGE"

.segment "CODE"

.segment "VECTORS"
  .word NMI
  .word RESET
  
.segment "CHARS"
  .incbin "text.chr"
