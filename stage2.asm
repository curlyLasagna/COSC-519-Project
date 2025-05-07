[BITS 16]
ORG 0x8000

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x9000

    lgdt [gdt_descriptor]

    ; Enable protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 0x08:protected_mode


[BITS 32]
protected_mode:
    mov ax, 0x10
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

    ; Setup paging structures
    mov dword [pt], 0x00000083
    mov dword [pt+8], 0x00200083

    mov dword [pdpt], pt
    mov dword [pdpt+8], 0
    mov dword [pdpt+16], 0
    mov dword [pdpt+24], 0

    mov eax, pdpt
    mov cr3, eax

    ; Enable long mode
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; Enable paging
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax

    jmp 0x18:long_mode_start


[BITS 64]
long_mode_start:
    mov rsi, message
    mov rdi, 0xb8000

.print:
    lodsb
    test al, al
    jz .hang
    mov ah, 0x0F
    mov [rdi], ax
    add rdi, 2
    jmp .print

.hang:
    hlt
    jmp .hang

message db "Entered Long Mode Successfully, Hello Group 1", 0

align 8
pt:
    dq 0x0000000000000083
    dq 0x0000000000200083

align 8
pdpt:
    dq pt
    dq 0
    dq 0
    dq 0

align 8
gdt:
    dq 0x0000000000000000 ; Null
    dq 0x00af9a000000ffff ; 32-bit code
    dq 0x00af92000000ffff ; 32-bit data
    dq 0x00affa000000ffff ; 64-bit code

gdt_descriptor:
    dw gdt_descriptor_end - gdt - 1
    dd gdt

gdt_descriptor_end:
