    .model  tiny

    .data
	
	left db 61h         ;charater is 'a'
	right db 64h		;charater is 'd'
	shoot db 20h
	position db 38		;position of ship

	bullet_position db 18h
	bullet_position_mid db 00h
	bullet_char db 00f8h
	bullet_status db 0

	cls_ship db 0

    .code
    org     0100h

main:   
	
	mov ah,6    ;THIS WILL CLEAR SCREEN
    mov al,0
    mov bh,7
    mov cx,0
    mov dl,79
    mov dh,24
    int  10h


	call draw_ship

main_game:
		
	mov ah,08h         ;input control shit
	int 21h
	mov ah,02h

	mov cls_ship,00h   ; cls_ship = 0

	cmp al,left         ;if input  == a
	je _left
		
	cmp al,right        ;if input  == d jump
	je _right

	cmp al,shoot        ;if input  == spacebar jump
	je init_shoot

	
    cmp al,1bh          ;go doExit when ah = esc
    je doExitExitExit

    jmp main_game

_left:

	cmp position,00h  	;check this position is 0 ?
	je _left_0

	dec position
	jmp draw_ship

_left_0:
	mov position,00h
	jmp main_game

_right:
	cmp position,4ah  	;check this position is 79 ?
	je _right_0

	inc position
	jmp draw_ship

_right_0:
	mov position,4ah
	jmp main_game

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
    out     61h, al         ; Send the new value
	
	jmp shooting

doExitExitExit:
	jmp doExitExit

shooting:

	dec bullet_position
	add al, 00000000b  
    out 61h, al         ; Send the new value

	mov ah,02h           			 ;Set cursor position	
	mov bh,00h
	mov dh,bullet_position           ;row
	mov dl,bullet_position_mid  	 ;colum
	int 10h

	mov ah,09h
	mov cx,1
	mov bl,0eh
	mov al,bullet_char               ; print the yellow bullet
	int 10h

    ;mov dl,bullet_char              ;print
	;int 21h

	push dx                          ;delay 20480 ?
	mov ah,86h
	mov cx,0000h
	mov dx,5000h
	int 15h
	pop dx

	mov ah,02h           			 ;Set cursor position for delete last	
	mov bh,00h
	mov dh,bullet_position           ;row
	mov dl,bullet_position_mid  	 ;colum
	int 10h

    mov dl,00h                		 ;print space bar for cls bullet
	int 21h

	cmp bullet_position,00h
	jge shooting

	mov bullet_position,18h
	jmp main_game
		

doExitExit:
	jmp doExit

draw_ship:

	cmp cls_ship,4fh
	jl erase_ship

	mov ah,02h           ;Set cursor position	
	mov bh,00h
	mov dh,18h         	 ;row
	mov dl,position		 ;colum
	int 10h

	
    mov dl,28h      ;print
	int 21h

	mov dl,95h      ;print
	int 21h

	mov dl,0ech      ;print
	int 21h

	mov dl,0a2h      ;print
	int 21h

	mov dl,29h      ;print
	int 21h

    jmp main_game


erase_ship:

	mov ah,02h           ;Set cursor position	
	mov bx,0000h
	mov dh,18h         	 ;row
	mov dl,cls_ship		 ;colum
	int  10h

	mov dl,00h      ;print
	int 21h

	inc cls_ship    ; cls_ship++
	jmp draw_ship


doExit:

	mov ah,4ch      ;clear
	mov al,00
	int 21h

    int     20h                     ; Job's done!

    end     main
