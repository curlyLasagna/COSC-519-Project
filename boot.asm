[BITS 16]
ORG 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Load 16 sectors (8KB) starting at sector 2 into 0x8000
    mov ah, 0x02         ; BIOS read
    mov al, 16           ; number of sectors to read (matching 8192 bytes)
    mov ch, 0            ; cylinder
    mov cl, 2            ; sector number (starts from 2)
    mov dh, 0            ; head
    mov dl, 0x80         ; boot drive
    mov bx, 0x8000       ; load address
    int 0x13

    ; Jump to stage2 code
    jmp 0x0000:0x8000

times 510 - ($ - $$) db 0
dw 0xAA55
