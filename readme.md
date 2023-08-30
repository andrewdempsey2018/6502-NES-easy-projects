Step 1: Assemble asm file into an object file

ca65 project.asm -o project.o -t nes

Step 2: link the object file to the nes target

ld65 project.o -o project.nes -t nes

###

If using VSCode, ctrl + shift + b