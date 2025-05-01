    ;; Set assembler location counter to start at address 0x7C00
    ;; 0x7C00 is the memory location that BIOS uses
ORG 0x7C00

    ;; Real mode
BITS 16
    ;; Halt CPU until next interrupt
main:
    hlt
    ;; Infinite loop
.halt:
    jmp .halt
    ;; Ensure that the binary is 512 bytes long
times 510-($-$$) db 0
    ;; Append 0xAA55 at the end of the 512 bytes to show BIOS that the disk is bootable
dw 0AA55h

cli

gdt_start:
gdt_null:       dq 0                    ; Null descriptor
gdt_code:       dw 0xFFFF               ; Lower 16 bits. Size of the GDT
                dw 0x0000               ; Base low
                db 0x00                 ; Base middle
                db 10011010b            ; Access byte
                db 11001111b            ; Flags + limit high
                db 0x00                 ; Base high
gdt_data:       dw 0xFFFF
                dw 0x0000
                db 0x00
                db 10010010b
                db 11001111b
                db 0x00
gdt_end:

gdtr:
    dw gdt_end - gdt_start - 1
    dd gdt_start

lgdt [gdtr]

mov eax, cr0

or al, 1

mov cr0, eax

jmp 08h:PModeMain

PModeMain
