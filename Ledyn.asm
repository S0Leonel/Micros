#include "p16F628a.inc"    
 __CONFIG _FOSC_INTOSCCLK & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF    

 
RES_VECT  CODE    0x0000; processor reset vector
    GOTO    START                  

INT_VECT  CODE	  0x0004
  
   ; el código de la interrupción
    GOTO ISR
    
    ; TODO ADD INTERRUPTS HERE IF USED
MAIN_PROG CODE   
 ; ... Lo de siempre, (variables para rutinas de tiempo)                   
i equ 0x30
j equ 0x31
k equ 0x32
cont equ 0x33
 
START
    ; ... Lo de siempre, puertos, comparadores, etc.
    MOVLW b'10010000'  ;HABILITAR INTERRUPCIÓN EXTERNA
    MOVWF INTCON 
    BCF STATUS, RP1 ;Cambiar al banco 1
    BSF STATUS, RP0 
    MOVLW b'00000001' ;Establecer puerto B.0 como entrada los demas como salida
    MOVWF TRISB 
    MOVLW b'00000000' ;Establecer puerto A como salida (los 8 bits del puerto)
    MOVWF TRISA 
    BCF STATUS, RP0 ;Regresar al banco 0
    
    
    
inicio:	
    ; ... El programa principal
    BSF PORTB, 7
    CALL tiempo
    NOP
    NOP
    BCF PORTB, 7
    CALL tiempo
    NOP
    NOP
    goto inicio  ;regresar y repetir
  
;rutina de tiempo
tiempo:MOVLW d'252'
       MOVWF i
 iloop:MOVLW d'180';
       MOVWF j
 jloop:MOVLW d'5';
       MOVWF k
       NOP
       NOP
       NOP
 kloop:DECFSZ k, f
       GOTO kloop
       DECFSZ j, f
       GOTO jloop
       NOP
       NOP
       NOP
       NOP
       DECFSZ i,f
       GOTO iloop
       movlw d'18'
       movwf cont
       DECFSZ cont,f
       goto $-1

    return	;salir de la rutina de tiempo y regresar al 
			;valor de contador de programa
			
    
ISR: 
    BCF INTCON, GIE ;Disable all interrupts inside interrupt service routine
    
    ;... Código de la interrupción
    INCF PORTA, 1    ;incrementa en uno, despues de la coma 1 para guardar en el mismo lugar [F] o poner el lugar donde gaurdar
    MOVLW d'10'
    XORWF PORTA,W    ;XOR 'W' CON 'F'[PORTA],donde se va a goardar '0' en 'w' o donde indiquies
    BTFSS STATUS,Z   ;si el bir 'z' en STATUA es '1' se salta la sig instruccion
    GOTO $+2
    CLRF PORTA	     ;limpiar el PORTA   
    BCF INTCON,INTF ;Clear external interrupt flag bit
    BSF INTCON, GIE ;Enable all interrupts on exit
    RETFIE		
			
    END