## How to assemble

Step 1: Assemble asm file into an object file

ca65 file.asm -o file.o -t nes

Step 2: link the object file to the nes target (yields a .NES rom for use with emulator, tested on Fceux)

ld65 file.o -o file.nes -t nes

###

1. simple.asm
A very basic .asm file which will compile into a .NES rom. This program does nothing except enter an infinite loop. It is heavily commented for learning purposes.

2. boilerplate_no_sprites.asm

3. hello.asm A heaviliy commented 'Hello World' application for the NES.

4. boilerplate.asm A basic NES game starting point - some sprites pallette data is loaded.


###

Links

## FCEUX:

https://fceux.com/web/home.html

## CC65 (CA65)

https://www.cc65.org/

### font

![image of font](/assets/text.png)

### NTSC palette

![image of font](/assets/palette_ntsc.png)