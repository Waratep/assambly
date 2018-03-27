    .model tiny

    .data

    char db 0
    position_y db 0                 ; for random axis y 
    position_x db 0                 ; for random axis x
    check db 0


    left db 61h         ;charater is 'a'
	right db 64h		;charater is 'd'
	shoot db 20h
	position db 38		;position of ship

	bullet_position db 17h
	bullet_position_mid db 00h
	bullet_char db 00f8h
	bullet_status db 0

	life_point dw 9

	cls_ship db 0

    count_possition db 0

    .code

    org 0100h



main:
    
    mov ah ,0h		                ;text mode
	mov al ,3h
	int 10h

    mov si,0

    call draw_ship


random_y:

    push ax
    mov ah,00h                      ; interrupts to get system time    
    int 1ah                         ; CX:DX now hold number of clock ticks since midnight
    pop ax                          ; CX:DX now hold number of clock ticks since midnight

    mov  ax, dx
    xor  dx, dx
    mov  cx, 80   
    div  cx                         ; here dx contains the remainder of the division - from 0 to 9
    ;add  dl,'0'                    ; to ascii from '0' to '9'
    mov position_y,dl
    ret

loop_1:

    mov si,0

    mov ah,02h           			;Set cursor position	
	mov bh,00h
	mov bl,0eh
	mov dh,18h         	 			;row
	mov dl,00h		 	 			;colum
	int 10h

	mov ah,09h
	mov cx,9
	mov bl,00h
	mov al,00h               		; erase red <3 
	int 10h

    mov ah,09h
	mov cx,life_point	
	mov bl,0ch
	mov al,03h               		; print red <3 
	int 10h

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

    cmp life_point,0
    je doExitExitExit

input:
    
    mov ah,1h                       ;input control 
    int 16h

    jz print
    
    cmp al,1bh                      ;go doExit when ah = esc
    je doExitExitExit

    mov ah,00h          		    ;input control shit
    int 16h

	mov cls_ship,00h    		    ; cls_ship = 0

	cmp al,left        		        ;if input  == a
	je _left
		
	cmp al,right        		    ;if input  == d jump
	je _right

	cmp al,shoot        		    ;if input  == spacebar jump
	je init_shoot_0

    xor ax,ax
    int 16h

doExitExitExit:
    jmp doExitExit


print:

    mov ah,02h              ;Set cursor position	
	mov bh,00h
	mov dh,position_x       ;row
	mov dl,position_y		;colum
	int 10h
	
    mov ah,09h
	mov cx,1	
	mov bl,0fh
	mov al,char             ; print the red bullet
	int 10h

    mov ah,position_x
    mov check,ah
    jmp print_2


_left:

	cmp position,00h  			;check this position is 0 ?
	je _left_0

	dec position
	jmp draw_ship

_left_0:
	mov position,00h
	jmp random_char

random_char_char:
    jmp random_char

_right:
	cmp position,4ah  			;check this position is 79 ?
	je _right_0

	inc position
	jmp draw_ship

_right_0:
	mov position,4ah
	jmp random_char

init_shoot_0:
    jmp init_shoot

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

    mov ah,02h                  ;Set cursor position	
	mov bh,00h
	mov dh,check                ;row
	mov dl,position_y    		;colum
	int 10h
	
    mov ah,09h
	mov cx,1	
	mov bl,00h
	mov al,00h                  ; print the black bullet
	int 10h
    

    mov al,check
    cmp al,position_x               ;tasm matrix.asm
    jl erase                        ;tlink matrix.obj \t
                                    ;matrix.com
    mov position_x,0

    dec life_point

    call random_y

    jmp loop_1



print_gray:

    mov ah,02h              ;Set cursor position	
	mov bh,00h
	mov dh,check            ;row
	mov dl,position_y		;colum
	int 10h
	
    mov ah,09h
	mov cx,1	
	mov bl,7h
	mov al,char             ; print the gray char
	int 10h

    ret

print_green:

    mov ah,02h              ;Set cursor position	
	mov bh,00h
	mov dh,check            ;row
	mov dl,position_y		;colum
	int 10h
	
    mov ah,09h
	mov cx,1	
	mov bl,2h
	mov al,char             ; print the green char
	int 10h

    ret

init_shoot:

	pop ax
	mov ah,position
	mov bullet_position_mid,ah
	push ax
	add bullet_position_mid,2

	mov     al, 182         ; meaning that we're about to load
    out     43h, al         ; a new countdown value

    mov     ax, 2153        ; countdown value is stored in ax. It is calculated by 
                            ; dividing 1193180 by the desired frequency (with the
                            ; number being the frequency at which the main system
                            ; oscillator runs
    out     42h, al         ; Output low byte.
    mov     al, ah          ; Output high byte.
    out     42h, al               

    in      al, 61h         
                            	   ; to connect the speaker to timer 2
    or      al, 00000011b  
    out     61h, al         	   ; Send the new value

    jmp shooting


doExitExit:
    jmp doExit

shooting:

	dec bullet_position

	add al, 00000000b  
    out 61h, al         		   ; Send the new value of buzzer

	mov ah,02h           		   ;Set cursor position	
	mov bh,00h
	mov dh,bullet_position         ;row
	mov dl,bullet_position_mid     ;colum
	int 10h

	mov ah,09h
	mov cx,1	
	mov bl,0eh
	mov al,bullet_char             ; print the yellow bullet
	int 10h


	;mov ax, 0B800h                ;use diract vram 
    ;mov es, ax

    ;mov di,(80*24+79)*2
    ;mov cx,0001h                  ;print 1 time
    ;mov ah,0fh                    ;ah set color first 4 bit set the color backgound of text second 4 bit set the color of text
    ;mov al,char                   ;set ascii
    ;rep stosw



	push dx                         ;delay 20480 ?
	mov ah,86h
	mov cx,0000h
	mov dx,5000h
	int 15h
	pop dx

	mov ah,02h           			;Set cursor position for delete last	
	mov bh,00h
	mov dh,bullet_position          ;row
	mov dl,bullet_position_mid  	;colum
	int 10h

    mov dl,00h                		;print space bar for cls bullet
	int 21h

	cmp bullet_position,00h
	jge shooting

	mov bullet_position,17h
	jmp random_char


erase_ship:

	mov ah,02h           			;Set cursor position	
	mov bx,0000h
	mov dh,17h         	 			;row
	mov dl,cls_ship		 			;colum
	int  10h

	mov dl,00h      				;print
	int 21h

	inc cls_ship    				; cls_ship++
	jmp draw_ship


draw_ship:

	cmp cls_ship,4fh
	jl erase_ship

    mov al,position
    mov count_possition,al 

	mov ah,02h           			;Set cursor position	
	mov bh,00h
	mov bl,0eh
	mov dh,17h         	 			;row
	mov dl,count_possition		 			;colum
	int 10h
	
    mov ah,09h
	mov cx,1	
	mov bl,7h
	mov al,28h             ; print char
	int 10h

    mov ah,02h           			;Set cursor position	
	mov bh,00h
	mov bl,0eh
	mov dh,17h
    inc count_possition         	 			;row
	mov dl,count_possition		 			;colum
	int 10h
	
    mov ah,09h
	mov cx,1	
	mov bl,7h
	mov al,95h             ; print char
	int 10h

    
    mov ah,02h           			;Set cursor position	
	mov bh,00h
	mov bl,0eh
	mov dh,17h
    inc count_possition         	 			;row
	mov dl,count_possition		 			;colum
	int 10h
	
    mov ah,09h
	mov cx,1	
	mov bl,7h
	mov al,0ech             ; print char
	int 10h

    
    mov ah,02h           			;Set cursor position	
	mov bh,00h
	mov bl,0eh
	mov dh,17h
    inc count_possition         	 			;row
	mov dl,count_possition		 			;colum
	int 10h
	
    mov ah,09h
	mov cx,1	
	mov bl,7h
	mov al,0a2h             ; print char
	int 10h

    
    mov ah,02h           			;Set cursor position	
	mov bh,00h
	mov bl,0eh
	mov dh,17h
    inc count_possition         	 			;row
	mov dl,count_possition		 			;colum
	int 10h
	
    mov ah,09h
	mov cx,1	
	mov bl,7h
	mov al,29h             ; print char
	int 10h

    jmp loop_1



doExit:

    mov ah,4ch                      ;clear
    mov al,00
    int 21h

    int     20h                     ; Job's done!
    ret
    end     main
