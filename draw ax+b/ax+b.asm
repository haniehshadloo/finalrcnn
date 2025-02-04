            stksg segment stack       
            	db	64 dup ("stack")   
            stksg ends
            datasg	segment	'data'
            	a   dw  0
            	b   dw  0    
            	y   dw  0
            	cc  dw  300  ;center column   ;y=ax+b  
            	cr  dw  200  ;center row
            	x   dw  1              
                PROMPT_1  DB  'Enter the value a = $'
                PROMPT_2  DB  ' Enter the value b = $'              
            datasg	ends
            cseg	segment	'code'
            assume	cs:cseg,ss:stksg,ds:datasg     
            
            main	proc	far  
                
                
            	push	ds
            	push	0
            	mov	ax,datasg
            	mov	ds,ax  
            	
            	  
            	j1:        
            	
            	
                call getParameter
                
                call draw          
                
                
                                   
                l1:
                MOV AH, 1                     
                INT 16H 
                cmp     al, 1bh
                jz      exit
                cmp al,20h
                jz j1 
                jnz  l1
                
                 
                            
                            
                exit:            
                mov	ax,4c00h
                int	21h
               
                cseg	ends    
             
            
            
           
               ;********getParameter***************************************************************************************
             ;***********************************************************************************************           
                            
            getParameter PROC NEAR
                  LEA DX, PROMPT_1             ; load and display the string PROMPT_1
                  MOV AH, 9
                  INT 21H 
                  call INDEC
                  mov a,ax   
                  
                  LEA DX, PROMPT_2             ; load and display the string PROMPT_2
                  MOV AH, 9
                  INT 21H 
                  call INDEC
                  mov b,ax
                             
                             
              
              
              RET
             getParameter ENDP              
                            
                            
                            
                            
            
             ;********draw***************************************************************************************
             ;***********************************************************************************************              
            draw PROC NEAR
               
            ;***************mode graphic********************  
            mov ah,0
            mov al,12h  ;mod 13, 320 *200
            int 10h
            ;***********************************
            mov cx,200
            mov dx,200
        back1: mov ah,0ch
            mov al,1h
            int 10h
            inc cx
            cmp cx,400
            jne back1    ;draw horizantal line            
            ;***********************************  =
            mov cx,300
            mov dx,100
        back2: mov ah,0ch
            mov al,1h
            int 10h
            inc dx
            cmp dx,300
            jne back2 
            ;draw vertical line                
            ;*********************************   
            mov  x,1              ;x  cc is center column                     
            mov  y,0             ;;y  cr is center row                                  
                      
     color: 
            
            mov  ax,a     ;y=ax+b
            mov  bx,x
            mul  bx       ;ax=a*x
            add  ax,b     ;ax=ax+b  ;y=ax+b 
            
            mov y,ax
            mov ax,cr
            
            sub ax,y    
            mov dx,ax     ;dx=y
            
            mov ax,x
            add ax,cc
            mov cx,ax  ;cx=x 
            
            
            mov ah,0ch ;roshan kardan pixel
            mov al,2h   ; rang  04 is red
            int 10h 
                                
            inc x           
            cmp x,30h
            jne color 
            ret               
                
                draw ENDP  
            
   ;***********************************************************************************************
   ;*********************************************************************************************** 
   INDEC PROC
   ; this procedure will read a number indecimal form    
   ; input : none
   ; output : store binary number in AX
   ; uses : MAIN

   PUSH BX                        ; push BX onto the STACK
   PUSH CX                        ; push CX onto the STACK
   PUSH DX                        ; push DX onto the STACK
   
   JMP @READ                      ; jump to label @READ

   @SKIP_BACKSPACE:               ; jump label
   MOV AH, 2                      ; set output function
   MOV DL, 20H                    ; set DL=' '
   INT 21H                        ; print a character

   @READ:                         ; jump label
   XOR BX, BX                     ; clear BX
   XOR CX, CX                     ; clear CX
   XOR DX, DX                     ; clear DX

   MOV AH, 1                      ; set input function
   INT 21H                        ; read a character

   CMP AL, "-"                    ; compare AL with "-"
   JE @MINUS                      ; jump to label @MINUS if AL="-"

   CMP AL, "+"                    ; compare AL with "+"
   JE @PLUS                       ; jump to label @PLUS if AL="+"

   JMP @SKIP_INPUT                ; jump to label @SKIP_INPUT

   @MINUS:                        ; jump label
   MOV CH, 1                      ; set CH=1
   INC CL                         ; set CL=CL+1
   JMP @INPUT                     ; jump to label @INPUT
   
   @PLUS:                         ; jump label
   MOV CH, 2                      ; set CH=2
   INC CL                         ; set CL=CL+1

   @INPUT:                        ; jump label
     MOV AH, 1                    ; set input function
     INT 21H                      ; read a character

     @SKIP_INPUT:                 ; jump label

     CMP AL, 0DH                  ; compare AL with CR
     JE @END_INPUT                ; jump to label @END_INPUT

     CMP AL, 8H                   ; compare AL with 8H
     JNE @NOT_BACKSPACE           ; jump to label @NOT_BACKSPACE if AL!=8

     CMP CH, 0                    ; compare CH with 0
     JNE @CHECK_REMOVE_MINUS      ; jump to label @CHECK_REMOVE_MINUS if CH!=0

     CMP CL, 0                    ; compare CL with 0
     JE @SKIP_BACKSPACE           ; jump to label @SKIP_BACKSPACE if CL=0
     JMP @MOVE_BACK               ; jump to label @MOVE_BACK

     @CHECK_REMOVE_MINUS:         ; jump label

     CMP CH, 1                    ; compare CH with 1
     JNE @CHECK_REMOVE_PLUS       ; jump to label @CHECK_REMOVE_PLUS if CH!=1

     CMP CL, 1                    ; compare CL with 1
     JE @REMOVE_PLUS_MINUS        ; jump to label @REMOVE_PLUS_MINUS if CL=1

     @CHECK_REMOVE_PLUS:          ; jump label

     CMP CL, 1                    ; compare CL with 1
     JE @REMOVE_PLUS_MINUS        ; jump to label @REMOVE_PLUS_MINUS if CL=1
     JMP @MOVE_BACK               ; jump to label @MOVE_BACK

     @REMOVE_PLUS_MINUS:          ; jump label
       MOV AH, 2                  ; set output function
       MOV DL, 20H                ; set DL=' '
       INT 21H                    ; print a character

       MOV DL, 8H                 ; set DL=8H
       INT 21H                    ; print a character

       JMP @READ                  ; jump to label @READ
                                  
     @MOVE_BACK:                  ; jump label

     MOV AX, BX                   ; set AX=BX
     MOV BX, 10                   ; set BX=10
     DIV BX                       ; set AX=AX/BX

     MOV BX, AX                   ; set BX=AX

     MOV AH, 2                    ; set output function
     MOV DL, 20H                  ; set DL=' '
     INT 21H                      ; print a character

     MOV DL, 8H                   ; set DL=8H
     INT 21H                      ; print a character

     XOR DX, DX                   ; clear DX
     DEC CL                       ; set CL=CL-1

     JMP @INPUT                   ; jump to label @INPUT

     @NOT_BACKSPACE:              ; jump label

     INC CL                       ; set CL=CL+1

     CMP AL, 30H                  ; compare AL with 0
     JL @ERROR                    ; jump to label @ERROR if AL<0

     CMP AL, 39H                  ; compare AL with 9
     JG @ERROR                    ; jump to label @ERROR if AL>9

     AND AX, 000FH                ; convert ascii to decimal code

     PUSH AX                      ; push AX onto the STACK

     MOV AX, 10                   ; set AX=10
     MUL BX                       ; set AX=AX*BX
     MOV BX, AX                   ; set BX=AX

     POP AX                       ; pop a value from STACK into AX

     ADD BX, AX                   ; set BX=AX+BX
     JS @ERROR                    ; jump to label @ERROR if SF=1
   JMP @INPUT                     ; jump to label @INPUT

   @ERROR:                        ; jump label

   MOV AH, 2                      ; set output function
   MOV DL, 7H                     ; set DL=7H
   INT 21H                        ; print a character

   XOR CH, CH                     ; clear CH

   @CLEAR:                        ; jump label
     MOV DL, 8H                   ; set DL=8H
     INT 21H                      ; print a character

     MOV DL, 20H                  ; set DL=' '
     INT 21H                      ; print a character

     MOV DL, 8H                   ; set DL=8H
     INT 21H                      ; print a character
   LOOP @CLEAR                    ; jump to label @CLEAR if CX!=0

   JMP @READ                      ; jump to label @READ

   @END_INPUT:                    ; jump label

   CMP CH, 1                      ; compare CH with 1   
   JNE @EXIT                      ; jump to label @EXIT if CH!=1
   NEG BX                         ; negate BX

   @EXIT:                         ; jump label

   MOV AX, BX                     ; set AX=BX

   POP DX                         ; pop a value from STACK into DX
   POP CX                         ; pop a value from STACK into CX
   POP BX                         ; pop a value from STACK into BX

   RET                            ; return control to the calling procedure
 INDEC ENDP
               
            
            
            
            
 END MAIN            
            
            
