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

## Dependencies

- qemu
- nasm
- make

## Building

```bash
# Build the binary
make build  

# Build the binary and spin up a VM to run from the .img file
make run
```

## Members 
- Brendan Lauterborn
- Luis Glascon
- Giancarlo Colloca
- Dheeraj Ganti
- Joseph Frishkorn
- Abdulaziz Aladdad

