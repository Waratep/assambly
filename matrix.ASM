        .model tiny

        .data

    gotoy db 0
    count db 0
    char db 0
    position_y db 0
    position_x db 0
    check db 0
    color db 0fh,0fh,7h,7h,2h,2h
        .code

        org 0100h


main:
    ;mew
    mov ah ,0h		    ;text mode
	mov al ,3h
	int 10h

    mov si,0

    mov ah,00h          ;input control shit
    int 16h

    cmp al,1bh          ;go doExit when ah = esc
    je doExitExit

random_y:

    push ax
    mov ah,00h                      ; interrupts to get system time    
    int 1ah                         ; CX:DX now hold number of clock ticks since midnight
    pop ax                          ; CX:DX now hold number of clock ticks since midnight

    mov  ax, dx
    xor  dx, dx
    mov  cx, 80   
    div  cx                         ; here dx contains the remainder of the division - from 0 to 9
    ;add  dl,'0'                     ; to ascii from '0' to '9'
    mov position_y,dl
    jmp random_char

doExitExit:
    jmp doExit

random_char:

    push ax
    mov ah,00h                      ; interrupts to get system time    
    int 1ah                         ; CX:DX now hold number of clock ticks since midnight
    pop ax

    mov  ax, dx
    xor  dx, dx
    mov  cx, 122   
    div  cx                         ; here dx contains the remainder of the division - from 0 to 9
    add  dl,'0'                     ; to ascii from '0' to '9'
    cmp dl,char
    je random_char
    mov char,dl
    inc si

print:

    mov ah,02h              ;Set cursor position	
	mov bh,00h
	mov dh,position_x       ;row
	mov dl,position_y		;colum
	int 10h
	
    mov ah,09h
	mov cx,1	
	mov bl,color[0]
	mov al,char             ; print the red bullet
	int 10h

    mov ah,position_x
    mov check,ah
    jmp print_2

random_char_char:
    jmp random_char

print_2:

    mov ah,02h              ;Set cursor position	
	mov bh,0000h

    dec check               ; check += 6 for erase tail
    dec check               ; I AM THE BEST ;)
    call print_gray
    dec check
    call print_gray
    dec check
    call print_green
    dec check
    call print_green
    dec check

	mov dh,check            ;row
	mov dl,position_y		;colum
	int 10h
	
    mov ah,09h
	mov cx,1	
	mov bl,00h
	mov al,char             ; print the black bullet for clear
	int 10h

    inc position_x
    mov dl,position_x
    cmp dl,31
    jl random_char_char

erase:

    inc check

    mov ah,02h              ;Set cursor position	
	mov bh,00h
	mov dh,check       ;row
	mov dl,position_y    		;colum
	int 10h
	
    mov ah,09h
	mov cx,1	
	mov bl,00h
	mov al,00h             ; print the black bullet
	int 10h
    

    mov al,check
    cmp al,position_x               ;tasm matrix.asm
    jl erase                        ;tlink matrix.obj \t
                                    ;matrix.com
    mov position_x,0
    jmp main

print_gray:

    mov ah,02h              ;Set cursor position	
	mov bh,00h
	mov dh,check       ;row
	mov dl,position_y		;colum
	int 10h
	
    mov ah,09h
	mov cx,1	
	mov bl,color[2]
	mov al,char             ; print the red bullet
	int 10h

    ret

print_green:

    mov ah,02h              ;Set cursor position	
	mov bh,00h
	mov dh,check       ;row
	mov dl,position_y		;colum
	int 10h
	
    mov ah,09h
	mov cx,1	
	mov bl,color[4]
	mov al,char             ; print the red bullet
	int 10h

    ret

doExit:

    mov ah,4ch                      ;clear
    mov al,00
    int 21h

    int     20h                     ; Job's done!
    ret
    end     main
