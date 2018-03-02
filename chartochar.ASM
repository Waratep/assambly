        .model  tiny

        .data
	
	ch_1 db 0
	ch_2 db 0


        .code
        org     0100h




main:   
	
	
	mov ah,08h
	int 21h
	mov ah,02h
	
	mov ch_1,al


	mov ah,08h
	int 21h
	mov ah,02h

	mov ch_2,al



	cmp ah,ch_2
	jl printchar
		
	

	
printchar:

	mov dl,ch_1
	int 21h

	inc ch_1
	
	mov dh,ch_1
	
	cmp dh,ch_2
	jle printchar





doExit:

	mov ah,4ch      ;clear
	mov al,00
	int 21h

        int     20h                     ; Job's done!

        end     main
