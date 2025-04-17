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
