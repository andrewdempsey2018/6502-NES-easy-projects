# Simple NES .asm files for study

## How to assemble

Step 1: Assemble asm file into an object file

**ca65 file.asm -o file.o -t nes**

Step 2: link the object file to the nes target (yields a .NES rom for use with emulator, tested on Fceux)

**ld65 file.o -o file.nes -t nes**

###

1. **simple.asm**
Heavily commented NES code that will assemble into a rom. Does nothing.

2. **hello.asm**
Heavily commented NES code that will assemble into a rom. Displays 'HELLO WORLD' on screen.

3. **boilerplate.asm**
Same as hello.asm but with the majority of comments removed - boiler plate code ready for expansion into something more complex.

###

Links

## FCEUX:

Emulator used for testing

https://fceux.com/web/home.html

## CC65 (CA65)

Assembler used

https://www.cc65.org/

### Font

This is the font sprites within text.chr

![image of font](/assets/text.png)

### NTSC palette

This is a reference for the NES NTSC palette

![image of font](/assets/palette_ntsc.png)