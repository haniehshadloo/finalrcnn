                       org 0100h



.data
PROMPT_1  DB  'reminder = $'
asc dw '64'
dv db  8
bcd db ?
.code
 MAIN PROC
  
   

    mov ax,word ptr asc 
    xchg ah,al
    
    mov dx,0
    and ax,0f0fh
    aad
    
    mov bh,dv
    div bh
     
    mov bh,ah
    LEA DX, PROMPT_1             ; load and display the string PROMPT_1
    MOV AH, 9
    INT 21H 
    
    mov al,bh
    mov ah,0
    
    call OUTDEC
    

     
 
      

 exit:
    
     
     MOV AH, 4CH                  ; return control to DOS
     INT 21H
 MAIN ENDP

                   
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



