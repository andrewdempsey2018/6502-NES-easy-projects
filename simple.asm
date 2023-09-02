;simple.asm - the most minimal .asm file that will assemble into a NES rom using the CA65 assembler.
;Here we see a number of segments - "HEARDER", "STARTUP", "ZEROPAGE", "CODE", "VECTORS" and "CHARS"

;The 'iNES 2.0' header is a virtual cartridge, we use this in place of a physical cart for emulators.
;It describes what physical chips would be present if the cart were real and some other settings.
;There are a number of headers that can be used - it is good to be familiar with these and
;they are all well documented in the NES dev wiki.
;The 'iNES 2.0' header is relatively simple and it has good compatibility with a wide range of emulators.
;Below we see an example of an iNES 2.0 header which is 16 bytes long. The bytes can be entered in as hex,
;binary or decimal (using binary here might be required if the
;developer needs access to each individual bit)

.segment "HEADER"
  .byte $4E, $45, $53, $1A ;Constant $4E $45 $53 $1A (ASCII "NES" followed by MS-DOS end-of-file). You'll often see this written as: .byte "NES", $1a
  .byte $02 ;Size of PRG ROM in 16 KB units (so here we are saying we want two 16kb units of prg rom)
  .byte $01 ;Size of CHR ROM in 8 KB units (value 0 means the board uses CHR RAM)
  .byte $00 ;Mapper, mirroring, battery, trainer
  .byte $00 ;Mapper, VS/Playchoice, NES 2.0
  .byte $00 ;PRG-RAM size (rarely used extension)
  .byte $00 ;TV system (rarely used extension)
  .byte $00 ;TV system, PRG-RAM presence (unofficial, rarely used extension)
  .byte $00, $00, $00, $00, $00 ;	Unused padding (should be filled with zero values)

;In the STARTUP segment, we add the program initialization code
.segment "STARTUP"
From CC65 docs:

NMI:
  RTI

RESET:

LOOP:
  JMP LOOP

;The 'zero page' is the first of 8 pages of 256k internal NES ram.
;The zero page is special as it can be accessed using a 1 byte address,
;making it faster. All other memory requires 2 byte addresses.
;so, addresses $00 to $FF constitute the zero page and addresses $0100 to $07FF constitute the rest of the NES 2kb internal ram.
.segment "ZEROPAGE"

;In the CODE segment, we add the main program code
.segment "CODE"

;In the VECTORS segment, we describe what to do when an 'interrupt' happens.
;An interrupt is when the NES processor 'interrupts' your code and jumps to a different point in code.
;There are three times when the NES processor will interrupt your code: 1.Reset 2.NMI 3.IRQ
;1. Reset occurs when the NES is switched on or the reset button is pressed
;2. NMI or 'non-maskable interrupt' happens once per video frame (when NMI is enabled). The PPU tells the processor it is starting the VBlank time and
;is available for graphics updates. VBlank time is when the TV cathode ray gun is going back to the top of the screen. The PPU handles the timing of VBlank
;and the time will of course differ between NTSC and PAL models of the NES.
;3. IRQ or 'interrupt request'. This is triggered by specialised hardware such as mapper chips and is also triggered by the APU.
.segment "VECTORS"
  .word NMI
  .word RESET

;In the CHARS segment, we tell the assembler what it needs to know about our graphical data
.segment "CHARS"