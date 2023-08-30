;boilerplate.asm - the most minimal .asm file that will assemble into a NES rom using the CA65 assembler.
;Here we see a number of segments - "HEARDER", "STARTUP", "ZEROPAGE", "CODE", "VECTORS" and "CHARS"

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
.segment "CODE"
.segment "VECTORS"
.segment "CHARS"  
  