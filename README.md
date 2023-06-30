# nes-simon

A memory game for the Nintendo Entertainment System.
This is in its early stages and is not very functional yet.

## Test

Open prgm.nes in an NES emulator such as Mesen or FCEUX.

Mesen: https://www.mesen.ca/

FCEUX: https://fceux.com/

The left color repeatedly lights for one second and dims for one second.

Using the memory viewer in the emulator, change the value of address $0004
to any nonzero value to change the mode to interactive.
Then the lights will light in response to the buttons on the controller D-Pad.

## Build

Install the cc65 compiler suite found at https://cc65.github.io/ in C:\cc65\.

Add C:\cc65\bin to the Windows PATH environment variable.

Run a command prompt (cmd) in the current directory.

In the command prompt, type "make" to build the program.
This will recreate prgm.o, prgm.dbg, and prgm.nes.

To edit the program, use a text editor such as Notepad++.

The file simon.nss can be opened in the NES graphics editor NEXXT.
This was used to export the nametable to file simon.asm and the CHR ROM to file simon.chr.
