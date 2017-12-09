; Especificacao do projeto: 
;   Escrever um programa que a cada 2s, leia um valor na porta B, representando um inteiro de
; 16 bits, e um valor de 5 bits na porta A. Seu programa deve então dividir o valor de 16
; bits pelo de 5 bits, duas vezes, retornando o resultado na porta B.
; resultado = B/(A^2)

; Alunos:
; Gabriel Bueno
; Paulo Paim
; Pedro Ferracini

    list    p=16f873A	    ; Especificando qual o tipo de microcontrolador
    #include "p16f873a.inc"	; Include do arquivo de configuracao (ta em header files) precisa disso pro mplab
    
    __CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_ON & _RC_OSC & _WRT_OFF & _LVP_ON & _CPD_OFF	; Algumas configuracoes que peguei de exemplos
    
; Definicoes
status  equ	H'03'
porta   equ	H'05'	; Precisa verificar se aqui é 05 e portb é 06 mesmo
portb   equ	H'06'
trisa   equ	H'05'
trisb   equ	H'06'

; Variaveis
divisor		equ H'20'	; Valor de 5 bits lido na porta
parte1dividendo	equ H'25'	; Primeiros 8 bits do valor lido na portb
parte2dividendo	equ H'33'	; Segunda parte de 8 bits lida na portb
resultado	equ H'41'	; Resultado da divisao B/(A^2)
contadordelay1	equ H'52'	; Contador de delay auxiliar
contadordelay2	equ H'64'	; Contador de delay auxiliar
   
    org 00	    ; Comecando programa em 0x00
    
; Inicializacao
start	bsf status,5	    ; Seleciona o banco 1
    movlw   B'11111111'	    ; Move 1 para w
    movwf   trisb	    ; Move valor de w para portb (definindo portb como entrada)
    movwf   trisa	    ; Move valor de w para porta (definindo porta como entrada)
    bcf	status,5	    ; Seleciona o banco 0    
    
; Inicio programa    
loop
    movf    porta,0	    ; Move valor da porta para registrador 0 (registrador w)    
    movwf   divisor	    ; Move valor de w para variavel divisor
    clrw		    ; Limpa o registrador w
    movf    portb,0	    ; Move valor da portb para o registrador 0 (registrador w)
    movwf   parte1dividendo ; Move valor de w para variavel parte1dividendo
    clrf    porta	    ; Limpa o valor de porta
    clrf    portb	    ; Limpa valor de portb
    			    ; Le mais 8 bits na portb (Talvez fosse interessante por algum condicional aqui)
    movf    portb,0	    ; Move valor da portb para registrador 0 (registrador w)
    movwf   parte2dividendo ; Move valor de w para variavel parte2dividendo
    clrf    portb	    ; Limpa valor de portb
    
    call dividir	    ; Chama subrotina de divisao
    ;call delay		    ; Chama subrotina de realizar delay de 2 segundos
    
    goto loop		    ; Volta para inicio do programa
    
dividir
			    ; Começo dividir (divisor = A, parte1dividendo primeiros 8 bits a direita, parte2dividendo restante dos 8 bits a esquerda)
			    ; Ex: divisor = 10, parte1dividendo = 30, parte2dividendo = 40 => Fazer: resultado = 4030/10 e depois resultado = resultado/10
    return

delay				; Subrotina de delay, acredito que esteja fazendo 2 segundos de delay
    movlw   D'4000'		; Move valor 1000 para w
    movwf   contadordelay2	; Move valor de w para contadordelay2

outer movlw   D'1999'		; Move valor 1999 para w		(1 ciclo)
    movwf   contadordelay1	; Move valor de w para contador 1	(1 ciclo)
    
inner nop			;					(1 ciclo)
    nop				;					(1 ciclo)
    decfsz  contadordelay1, 1	; Decrementa em 1 o contadordelay1	(1 ciclo)
    goto inner			;					(2 ciclos)
    
    decfsz  contadordelay2, 1	; Decrementa em 1 o contadordelay2	(1 ciclo)
    goto outer			;					(2 ciclos)
				; OBS: ((5 ciclos laco interno * 1999) + 5 ciclos laco externo) * 4000 = 40000000 ciclos
				; OBS2: PIC 16F873A possui clock de 20MHZ => 1 ciclo = 5*10^-8 segundos, portanto 40000000 ciclos = 2 segundos 
    return
    
    end
