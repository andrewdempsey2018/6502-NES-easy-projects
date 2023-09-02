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

LOOP:
  JMP LOOP

.segment "ZEROPAGE"

.segment "CODE"

.segment "VECTORS"
  .word NMI
  .word RESET
  
.segment "CHARS"