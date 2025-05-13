; Fixed address in real mode. Conventionally for the boot sector
org 0x7c00
main:

    ; SETTING UP STACK
    mov bp, 0x9000
    mov sp, bp

    call switch_to_pm

[ BITS 16 ]

; Setting up GDT for 32 BIT MODE
GDT32:

    .Null: equ $ - GDT32
        dd 0x0, 0x0

    .Code: equ $ - GDT32
        dw 0xffff, 0x0      
        db 0x0, 10011010b, 11001111b, 0x0

    .Data: equ $ - GDT32
        dw 0xffff, 0x0
        db 0x0, 10010010b, 11001111b, 0x0

    .Pointer:                    
        dw $ - GDT32 - 1             
        dd GDT32


switch_to_pm:
    
    cli

    ;==============================================================================
    ;PREPARING TO ENTER PROTECTED MODE: https://wiki.osdev.org/Protected_Mode 
    ;Prerequisites for switching over to protected mode:
    ;- Disable interrupts
    ;- Enable A20 line
    ;- Load the Global Descriptor Table

    ; Loading DT for 32 bit
    lgdt [GDT32.Pointer] 


    ; Changing CR0 bit to represent the shift to protected mode
    mov eax, cr0
    or eax, 0x1 
    ; Set Protection Enable bit in CR0
    mov cr0, eax

    ; Enable A20 line: https://wiki.osdev.org/A20_Line#Fast_A20_Gate
    ;  
    in al, 0x92
    or al, 2
    out 0x92, al
    ;==============================================================================
    ;ENTERS PROTECTED MODE 

    jmp GDT32.Code:ProtectedModeCode


[ BITS 32 ]

; GDT for 64 BIT MODE
; Reference: https://wiki.osdev.org/Setting_Up_Long_Mode#Entering_the_64-bit_Submode
GDT64: 

    .Null: equ $ - GDT64 
        ; ; NULL Descriptor         
        ; dw 0xFFFF, 0
        ; ; Limit, Base - low                    
        ; db 0, 0, 1, 0
        ; ; Base - middle, Access, Granularity, Base - 
        dq 0 

    .Code: equ $ - GDT64
        ; dw 0, 0
        ; ; Limit, Base - low      
        ; db 0, 10011010b, 10101111b, 0
        ; ; Base - middle, Access(X/R),(Granularity |flag for 64 bit | limit 19 - 16), Base - high
        dq (1<<43) | (1<<44) | (1<<47) | (1<<53) ; code segment

    .Data: equ $ - GDT64
        dw 0,0
        ; Limit, Base - low                      
        db 0, 10010010b, 00000000b, 0       
        ; Base - middle, Access(R/W),Granularity, Base - high  

    .Pointer:
        dw $ - GDT64 - 1
        ; Limit
        dq GDT64
        ; Base

; ax containes the values to be repeated in all other segment register
set_seg_register:
    mov ds, ax                    
    mov fs, ax
    mov gs, ax
    mov ss, ax
    ret

; RESOURCES: https://wiki.osdev.org/Setting_Up_Long_Mode#Setting_up_the_Paging

setup_paging:
    
    ; PML4T
    mov edi, 0x3000
    ; Base addres of top page table set to 0x3000
    mov cr3, edi


    xor eax, eax
    ; set eax to 0
    
    ; x86 uses a page size of 4096 bytes
    ; Each table contains 512 entries
    ; Each entry is of 8 bytes
    ; 512 * 8 = 4096 bytes (the size of page table)
    mov ecx, 4096 
    rep stosd           
    ; Clear the memory.
    mov eax, cr3

    ; DECLARING LAME PAGE TABLE AND CONNECTIONs
    ;  PML4T[0] -> PDPT[0] -> PDT[0] 00x4000-> PT[0] -> 2 MiB
    ;  0x3000 -> PML4T[0] -> 0x4003 
    ;  0x4000 -> PDT[0] -> 0x5003


    ; PDPT
    mov dword [eax], 0x4000 | 3  ; 2nd top level page table base address
    add eax, 4096  
    
    ; PDT           
    mov dword [eax], 0x5000 | 3   ; 3rd top level page table base address
    add eax, 4096   

    ; PT
    mov dword [eax], 0x6000 | 3     ; page table base address
    add eax, 4096             

    ; first page
    mov ebx, 0x00000003          ; Set the B-register to 0x00000003.

    mov ecx, 512
 
    ; Initialise Pages for first 2MiB
    ; At present eax points to base address of PT.
    SetPageEntry:
        mov dword [eax], ebx                   
        add eax, 8      ; each page entry is of 8 bytes
        add ebx, 0x1000  
        loop SetPageEntry             


    mov ecx, 0xC0000080          
    rdmsr
    ; Read MSR specified by ECX into EDX:EAX.                   
    or eax, 1 << 8               
    wrmsr   

    ; Will set PAE bit (which the bit 5) in CR4
    mov edi, cr4                
    or edi, 1 << 5               
    mov cr4, edi    

    ; Eanble PG-bit in CR0 which is the 31 bit
    mov edi, cr0              
    or edi, 1 << 31             
    mov cr0, edi

    ret


ProtectedModeCode:

    ; Setting up all the segment value for protected mode
    mov ax, GDT32.Data
    call set_seg_register

    jmp switch_to_long_mode


    ;==============================================================================
    ;PREPARING TO ENTER LONG MODE 

switch_to_long_mode:

    call setup_paging               ;Sets up Paging        

    lgdt [GDT64.Pointer]            ;Loads 64 bit GDT table

    ;==============================================================================
    ;ENTERS LONG MODE 

    jmp GDT64.Code:LongModeCode; Jumps to 64 bit code


[ BITS 64 ]
; Printing in 64 Bit Mode
; RSI - INPUT
; r10 - number of values
; RBX - Starting position in the video frame
print64:
    mov r9, 1 ; Counter set to one

    print64_loop:
        lodsb
        or al,al
        cmp r9, r10
        je done

        or rax,0x0f00
        mov qword [rbx], rax
        
        add rbx,2 ; Video Buffer Counter Update
        add r9, 1 ; Print Counter Update
        jmp print64_loop

    done:
        ret


LongModeCode:

    ; Setting up all the segment value                     
    mov ax, GDT64.Data
    call set_seg_register          

    ; Clear screen
    mov rbx, 0xb8000
    ; Print custom string
    mov rsi, MSG_3
    mov r10, 2000
    ; Execution of a known 64-bit instruction
    mov rax, 0x12345678
    call print64

    hlt

MSG_3 db "Hello professor! From: Luis, Brendan, Giancarlo, Dheeraj, Joseph, Abdulaziz", 0xA, 0xD


times 510 - ($-$$) db 0 
; Place magic boot number to allow BIOS to assume the sector is bootable
dw 0xaa55

