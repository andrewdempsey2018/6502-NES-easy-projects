;The 'iNES 2.0' header is a virtual cartridge, we use this in place of a physical cart for emulators.
;It describes what physical chips would be present if the cart were real and some other settings.
;There are a number of headers that can be used and it is good to be familiar with these. They are all well documented in the NES dev wiki.
;The 'iNES 2.0' header is relatively simple and it has good compatibility with a wide range of emulators.
;Below we see an example of an iNES 2.0 header which is 16 bytes long. The bytes can be entered in as hex, binary or decimal (using binary here might be required if the
;developer needs access to each individual bit)

.segment "HEADER"
  .byte $4E, $45, $53, $1A ;Constant $4E $45 $53 $1A (ASCII "NES" followed by MS-DOS end-of-file). You'll often see this written as: .byte "NES", $1a
  .byte $02 ;Size of PRG ROM in 16 KB units
  .byte $01 ;Size of CHR ROM in 8 KB units (value 0 means the board uses CHR RAM)
  .byte $00 ;Mapper, mirroring, battery, trainer
  .byte $00 ;Mapper, VS/Playchoice, NES 2.0
  .byte $00 ;PRG-RAM size (rarely used extension)
  .byte $00 ;TV system (rarely used extension)
  .byte $00 ;TV system, PRG-RAM presence (unofficial, rarely used extension)
  .byte $00, $00, $00, $00, $00 ;	Unused padding (should be filled with zero)

.segment "STARTUP"
.segment "ZEROPAGE"
flag: .res 1
counter: .res 1
.segment "CODE"

WAITVBLANK:
:
    BIT $2002
    BPL :-
    RTS

RESET:
  SEI          ; disable IRQs
  CLD          ; disable decimal mode
  LDX #$40
  STX $4017    ; disable APU frame IRQ
  LDX #$FF
  TXS          ; Set up stack
  INX          ; now X = 0
  STX $2000    ; disable NMI
  STX $2001    ; disable rendering
  STX $4010    ; disable DMC IRQs

  JSR WAITVBLANK

clrmem:
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0200, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0300, x
  INX
  BNE clrmem

  LDA #%10001000
  STA flag
   
  JSR WAITVBLANK

  LDA #%00000000
  STA counter
  STA $2001
  LDA #%10001000
  STA $2000
  LDA #$3F
  STA $2006
  LDA #$00
  STA $2006
  STA $2007
  CLI
Forever:
  JMP Forever  
  
VBLANK:
  INC counter
  LDA counter
  CMP #$3C
  BNE SkipColorChange
  LDA flag
  EOR #%10000000
  STA flag
  STA $2001
  LDA #$00
  STA counter
 SkipColorChange:
  RTI

.segment "VECTORS"
    .word VBLANK
    .word RESET
    .word 0

.segment "CHARS"  
  