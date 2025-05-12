# COSC 519 Project

## Bootloader: Transitioning to 64-bit Long Mode (x86-64)

This project involves designing and implementing a bootloader in NASM that brings a virtual x86 PC from power-on into 64-bit long mode. It provides hands-on experience with the low-level boot process and the necessary transitions through real mode, protected mode, and finally into long mode.

### Overview

The objective of this bootloader is to demonstrate a functional transition through the following stages:

- Real Mode: Where the CPU begins execution after reset.

- Protected Mode: Enables access to extended memory and segmentation features.

- Long Mode (64-bit): Final stage where 64-bit instructions can be executed.

This bootloader showcases a minimal working setup that successfully enters long mode and executes a 64-bit instruction.

### Features

- Starts in real mode, just like the BIOS on legacy x86 hardware.
- Switches into protected mode with paging initially disabled.
- Enables Physical Address Extension (PAE) and activates paging.
- Loads a Global Descriptor Table (GDT) with a valid 64-bit code segment.
- Enters 64-bit long mode by properly setting the relevant CPU control registers.
- Executes at least one 64-bit instruction, such as a message output using rax, to confirm successful transition.

### Technical Details

Written in NASM assembly.

Compiled as a raw (flat) binary, not in ELF or PE format.

Entire bootloader fits into a 512-byte boot sector.

The bootloader image can be loaded from a `.img` file or hard disk image.

## Building

```bash
# Build the binary
make

# Spin up a VM to run from the .img file
make run
```


## Members 
- Brendan Lauterborn
- Luis Glascon
- Giancarlo Colloca
- Dheeraj Ganti
- Joseph Frishkorn
- Abdulaziz Aladdad


## Usage 

```
nasm -f bin boot.nasm & qemu-system-x86_64 boot
```
This will open a window with the following things printed in it:
- "Entered Long Mode: Group 1"
- Value of CR3 register

## Implementation

- print16.nasm: Printing in Real Mode 
- print32.nasm: Printing in Protected Mode
- print64.nasm: Printing in Long Mode 
- print_register.nasm: Print value of 64 bit register in binary
- gdt32.nasm: contains lame gdt for for protected mode
- gdt64.nasm: contains lame gdt for for long mode
- paging.nasm:setups paging and enable paging and also enables 64 bit mode

`boot.nasm` is the main file. It is will commented to show the order in which things happens.  


### References

- How stuffs work(GDT, Paging and Segments in AMD):- http://developer.amd.com/wordpress/media/2012/10/24593_APM_v21.pdf
- Same at above: https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-vol-3a-part-1-manual.pdf
- Everything combined: https://wiki.osdev.org/Entering_Long_Mode_Directly
- Best: https://wiki.osdev.org/Setting_Up_Long_Mode
- Remember to do this: http://www.win.tue.nl/~aeb/linux/kbd/A20.html
- Nice links: https://wiki.osdev.org/Bootloader
- BIOS documentation: ftp://ftp.embeddedarm.com/old/old-software-pages/Manuals/EBIOS-UM.PDF
- Linux insiders: https://0xax.gitbooks.io/linux-insides/content/Booting/linux-bootstrap-1.html
- Best for stuff not related to long mode: http://www.cs.bham.ac.uk/~exr/lectures/opsys/10_11/lectures/os-dev.pdf
- Because I need ANSWERS: https://github.com/psychomario/asmos/
- https://www.codeproject.com/Articles/45788/The-Real-Protected-Long-mode-assembly-tutorial-for
- https://stackoverflow.com/questions/41085245/setting-up-paging-for-real-mode-to-64-bit-long-mode-switch
- https://0xax.gitbooks.io/linux-insides/content/Booting/linux-bootstrap-4.html
- Writing OS in Rust: lol: https://os.phil-opp.com/entering-longmode/ 
