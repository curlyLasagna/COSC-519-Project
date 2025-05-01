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
gdt_code64:	dw 0xFFFF
		dw 0x0000
		db 0x00
		db 10011010b
		db 10101111b
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

[BITS 32]
PModeMain:

	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	; Stack
	mov esp, 0x90000

	; Enable Page Address Extension
	mov eax, cr4
	or eax,  1 << 5
	mov cr4, eax

	; Paging
	align 4096
	pml4_table:	dq pdpt_table + 0x03
	align 4096
	pdpt_table:	dq pd_table + 0x03
	align 4096
	pd_table:	dq pt + 0x03
	align 4096
	pt:
		%assign i 0
		%rep 512
			dq (i << 12) | 0x03
			%assign i i + 1
		%endrep

	mov eax, pml4_table
	mov cr3, eax

	; Enable long mode
	mov ecx, 0x0C0000080
	rdmsr
	or eax, 1 << 8
	wrmsr

	; Enable Paging
	mov eax, cr0
	or eax, 1 << 31
	mov cr0, eax

	; Jump to Long Mode
	jmp 0x18:LongModeStart

[BITS 64]
LongModeStart:
	mov rsi, message
	mov rdi, 0xb8000

.print_loop:
	lodsb
	test al, al
	jz .done
	mov ah, 0x0F
	mov [rdi], ax
	add rdi, 2
	jmp .print_loop
.done:
	hlt
message: db "Entered Long Mode Successfully, Hello", 0
