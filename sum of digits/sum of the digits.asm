
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h



.data
PROMPT_1  DB  'array = $' 
PROMPT_2  DB  'sum(odd digits) = $'
str db ',$'

zero db 0   
count db 9
sum db 0
num db 0
array db 8dup(0,0ch,0Ah,3,4,5,6,7)

.code
 MAIN PROC

       LEA DX, PROMPT_1             ; load and display the string PROMPT_1
       MOV AH, 9
       INT 21H

   mov bx,offset array
   ;mov cl,8h 
   ;mov ch,0
    mov ch,2h
    mov cl,0  
    dec bx
    l1:
       
       inc cl
       cmp cl,count
       je  exit  
       inc bx  
       mov al,[bx]
       mov ah,0 
       call OUTDEC
       LEA DX,str             ; load and display the string str
       MOV AH, 9
       INT 21H 
       mov al,[bx]
       mov ah,0
       call   mysum
       jmp l1
       
       

     
 
      

 exit: 
      LEA DX, PROMPT_2             ; load and display the string PROMPT_2
       MOV AH, 9
       INT 21H
     mov al,sum
     mov ah,0
     call OUTDEC
     MOV AH, 4CH                  ; return control to DOS
     INT 21H
 MAIN ENDP
mysum proc
   PUSH BX                        ; push BX onto the STACK
   PUSH CX                        ; push CX onto the STACK
   PUSH DX 
     
   mov bl,0Ah  
   mov cl,02h 
   mov num,al
   mloop:
      
      mov al,num 
      cmp al,zero
      je endl
      div bl
      mov num,al
      mov al,ah 
      mov ah,0
      mov dl,al  
      div cl
      cmp ah,zero
      je mloop
      add sum,dl
      jmp mloop
      
   
      
      
      
      
      
   endl:   
   POP DX                         ; pop a value from STACK into DX
   POP CX                         ; pop a value from STACK into CX
   POP BX                         ; pop a value from STACK into BX
   ret
      
mysum endp
;**************************************************************************;
 ;**************************************************************************;
 ;-------------------------  Procedure Definitions  ------------------------;
 ;**************************************************************************;
 ;**************************************************************************;

 ;**************************************************************************;
 ;-------------------------------  INDEC  ----------------------------------;
 ;**************************************************************************;

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
                                  
 ;**************************************************************************;
 ;--------------------------------  OUTDEC  --------------------------------;
 ;**************************************************************************;

 OUTDEC PROC
   ; this procedure will display a decimal number
   ; input : AX
   ; output : none
   ; uses : MAIN

   PUSH BX                        ; push BX onto the STACK
   PUSH CX                        ; push CX onto the STACK
   PUSH DX                        ; push DX onto the STACK

   CMP AX, 0                      ; compare AX with 0
   JGE @START
   ;;;;;;                     ; jump to label @START if AX>=0
   
   
   PUSH AX                        ; push AX onto the STACK

   MOV AH, 2                      ; set output function
   MOV DL, "-"                    ; set DL='-'
   INT 21H                        ; print the character

   POP AX                         ; pop a value from STACK into AX

   NEG AX                         ; take 2's complement of AX

   @START:                        ; jump label

   XOR CX, CX                     ; clear CX
   MOV BX, 10                     ; set BX=10

   @OUTPUT:                       ; loop label
     XOR DX, DX                   ; clear DX
     DIV BX                       ; divide AX by BX
     PUSH DX                      ; push DX onto the STACK
     INC CX                       ; increment CX
     OR AX, AX                    ; take OR of Ax with AX
   JNE @OUTPUT                    ; jump to label @OUTPUT if ZF=0

   MOV AH, 2                      ; set output function

   @DISPLAY:                      ; loop label
     POP DX                       ; pop a value from STACK to DX
     OR DL, 30H                   ; convert decimal to ascii code
     INT 21H                      ; print a character
   LOOP @DISPLAY                  ; jump to label @DISPLAY if CX!=0

   POP DX                         ; pop a value from STACK into DX
   POP CX                         ; pop a value from STACK into CX
   POP BX                         ; pop a value from STACK into BX

   RET                            ; return control to the calling procedure
 OUTDEC ENDP

 ;**************************************************************************;
 ;--------------------------------------------------------------------------;
 ;**************************************************************************;

 END MAIN

 ;**************************************************************************;
 ;**************************************************************************;
 ;------------------------------  THE END  ---------------------------------;
 ;**************************************************************************;
 ;*************************



