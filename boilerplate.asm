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

NMI:
  RTI

RESET:
  SEI ;disable all interrupts
  CLD ;disable decimal mode

  ;disable sound irq
  LDX #$40 ;$40 = 01000000. In binary we refer to the most significant bit as bit 7, the next significant bit is bit 6 and so on...
  STX $4017 ;the apu frame counter is at $4017. Bit 6 here will disable sound irq if set. Hence we store 01000000 at $4017

LOOP:
  JMP LOOP

.segment "ZEROPAGE"

.segment "CODE"

.segment "VECTORS"
  .word NMI
  .word RESET
  
.segment "CHARS"