; stage2.asm — Stage 2 Bootloader for Long Mode Transition
[BITS 16]
ORG 0x8000

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    lgdt [gdt_descriptor]

    ; Enable A20
    in al, 0x92
    or al, 2
    out 0x92, al

    ; Enter protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp CODE_SEG:init_pm

; -------------------------------
; Protected Mode
; -------------------------------
[BITS 32]
init_pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    ; Enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; Load PML4 table
    mov eax, pml4_table
    mov cr3, eax

    ; Enable long mode (EFER.LME)
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; Enable paging
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax

    ; Far jump to long mode
    jmp 0x08:long_mode_start

; -------------------------------
; Long Mode
; -------------------------------
[BITS 64]
long_mode_start:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax

    ; Use 64-bit registers
    mov rax, 0x123456789ABCDEF0
    mov rbx, rax

    mov si, message
.print:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp .print
.done:
    hlt
    jmp $

; -------------------------------
; GDT Setup
; -------------------------------
align 8
gdt:
    dq 0
    dq 0x00AF9A000000FFFF     ; Code segment
    dq 0x00AF92000000FFFF     ; Data segment

gdt_descriptor:
    dw gdt_end - gdt - 1
    dd gdt
gdt_end:

; -------------------------------
; Page Tables (1GB with 2MB pages)
; -------------------------------
align 4096
pml4_table:
    dq pdpt_table + 0x03

align 4096
pdpt_table:
    dq pd_table + 0x03

align 4096
pd_table:
    times 512 dq (0x00000000 | 0x83)

; -------------------------------
; Segment Selectors
; -------------------------------
CODE_SEG equ 0x08
DATA_SEG equ 0x10

; -------------------------------
; Message
; -------------------------------
message db "Entered Long Mode: Group 3", 0
