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

;Clear the 2k of internal ram. ($0000–$07FF)
CLEARMEM: 
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0300, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  ;While we are looping through the ram and clearing it, we take the opportunity to clear
  ;256 bytes for holding sprite data ($0200 - $02FF). We initialise this sprite data to #$FF
  ;to ensure that every sprite is off screen and not rendered initially.
  ;We are using $0200 - $02FF by convention - we could use other space if we wished.
  LDA #$FF
  STA $0200, x
  INX
  BNE CLEARMEM

;Wait for VBLANK. We wait for VBLANK again to ensure the CPU has had time to clear the internal ram.
:
  BIT $2002
  BPL :-

;Remember that we set aside 256 bytes for the sprite data in $0200 - $02FF.
;In order to display these sprites, we use a technique called 'direct memory access'
;or 'DMA'. This technique basically copies a block of ram from the CPU memory to
;the PPU's sprite memory. All we need to do is write the high byte of the starting point in
;CPU memory were the data is and the PPU will automatically read that and the rest of the
;256 bytes.
;Here we are setting this up, but we use the same code to write the sprite data each frame, so we will see a copy
;of this code in the NMI section.
  LDA #$02
  STA $4014

;The NES has 64 available colours ($00-$3F) - but you should never use colour $0D as it can damage some TV's.
;The HEX codes for the individual colours can be found online (for example. on the NES Dev Wiki)
;Of these 64 colours, we can create two palettes of 16 bytes each. Each byte represents a colour.
;One of these 16 byte palettes will be used for the background and the other will be used for sprites.
;We store these palettes in the PPU's memory at addresses $3F00 - $3F0F (for the background) 
;and $3F10 - $3F1F (for the sprites).
;We cannot talk to the PPU directly but it is memory mapped through $2006 and $2007.
;We set the address of the PPU by writing to a high byte and a low byte to $2006.
;So, in the code below, the PPU is configured to be ready to accept palette data by setting
;its address to $3F00 - by first setting the high byte via $2006 followed by setting the low byte, again, via $2006.
  LDA #$3F
  STA $2006
  LDA #$00
  STA $2006

  LDX #$00

;When we then write to $2007, the PPU address automatically increments. So, we can then load in both 16 byte palettes
;with a loop and the PPU address will increment every time we write to memory map $2007.
LOADPALETTES:
  LDA PALETTEDATA, X
  STA $2007 ;Writing to $2007 adds the palette data in PPU memory $3F00 to $3F0F (remember the PPU address is auto incremented when writing to $2007) 
  INX
  CPX #$20 ;we branch when the X register is equal to $20 ($20 is 32 in decimal) as we have 32 colours to load in
  BNE LOADPALETTES    

;Loop through our 256 bits of sprite data. Sprite data is broken up into 4 bytes per sprite.
;The first byte is the Y position of the sprite on the screen.
;The second byte is the sprite number (taken from our CHR file)
;The third byte is used for setting special attribute of the sprite such as
;flipping it on the X axis.
;The fourth byte is the X position of the sprite on the screen.
  LDX #$00
LOADSPRITES:
  LDA SPRITEDATA, X
  STA $0200, X
  INX
  CPX #$28 ;Branch when we get to #$28 (#$28 is 40 in decimal, we have 40 pieces of sprite data)
  BNE LOADSPRITES 

;Enable interrupts (we had previously disabled interrupts during setup)
  CLI

;The PPU register refered to as 'PPUCTRL'	is mapped to $2000.
;Bit 7 is set to 1 to enable NMI. Bit 4 is set to 1 to use the second pattern table as the background.
;We have two pattern tables in our CHR file (text.chr)
;A pattern table is made up of 256 tiles (16x16) and each tile is made up of 8x8 pixels.
;A pattern table is 128x128 pixels.
  LDA #%10010000 ; enable NMI change background to use second chr set of tiles ($1000)
  STA $2000
  ; Enabling sprites and background for leftmost 8 pixels
  ; Enable sprites and background
;The PPU register referred to as 'PPUMASK' us mapped to $2001
;Bit 4 of PPUMASK enables sprites if set to 1
;Bit 3 of PPUMASK enables the background if set to 1
;Bit 2 of PPUMASK if set to 1 shows the sprites at leftmost 8 pixels of the screen, 0 hides them
;Bit 1 of PPUMASK if set to 1 shows the background at leftmost 8 pixels of the screen, 0 hides it
;Bits 2 and 1 are useful in some situations where we are scrolling the screen but in out simple
;program here, we just show those graphics.
  LDA #%00011110
  STA $2001

LOOP:
  JMP LOOP

NMI:
    LDA #$02 ; copy sprite data from $0200 => PPU memory for display
    STA $4014
    RTI

PALETTEDATA:
  .byte $22,$29,$1A,$0F,$22,$36,$17,$0f,$22,$30,$21,$0f,$22,$27,$17,$0F  ;background palette data
  .byte $22,$16,$27,$18,$22,$1A,$30,$27,$22,$16,$30,$27,$22,$0F,$36,$17  ;sprite palette data

SPRITEDATA:
; Y position, sprite number, attributes, X position
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