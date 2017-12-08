; Alunos:
; Gabriel Bueno
; Paulo Paim
; Pedro Ferracini

    list    p=16f873A	    ; Especificando qual o tipo de microcontrolador
    #include "p16f873a.inc"	; Include do arquivo de configuracao (ta em header files) precisa disso pro mplab
    
    __CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_ON & _RC_OSC & _WRT_OFF & _LVP_ON & _CPD_OFF	; Algumas configuracoes que peguei de exemplos
    
; Definicoes
status  equ	03
porta   equ	05	; Precisa verificar se aqui é 05 e portb é 06 mesmo
portb   equ	06
trisa   equ	05
trisb   equ	06
   
    org 00	    ; Comecando programa em 0x00

   
; Variaveis
divisor	equ 05
parte1dividendo	equ 08
parte2dividendo	equ 08
    
; Inicializacao
start	bsf status,5	    ; Seleciona o banco 1
    movlw   1F		    ; Move 1 para w
    movwf   trisb	    ; Move valor de w para portb (definindo portb como entrada)
    movwf   trisa	    ; Move valor de w para porta (definindo porta como entrada)
    bcf	status,5	    ; Seleciona o banco 0
    
    
    
    
; Inicio programa
    
    
    end