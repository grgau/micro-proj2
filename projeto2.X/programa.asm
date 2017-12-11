; Especificacao do projeto: 
;   Escrever um programa que a cada 2s, leia um valor na porta B, representando um inteiro de
; 16 bits, e um valor de 5 bits na porta A. Seu programa deve então dividir o valor de 16
; bits pelo de 5 bits, duas vezes, retornando o resultado na porta B.
; resultado = B/(A^2)

; OBS: Numero de 16 bits sendo tratado como 2 numeros de 8 bits:
;EX: 1101 1111       0001 1010
;   |---------|     |---------|
; parte1dividendo  parte2dividendo
    
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
divisor		    equ H'20'	; Valor de 5 bits lido na porta
parte1dividendo	    equ H'25'	; Primeiros 8 bits a esquerda do valor lido na portb
parte2dividendo	    equ H'2D'	; Segunda parte de 8 bits lida na portb (8 bits a direita)
parte1resultado	    equ H'35'	; Primeiros 8 bits a esquerda do valor do resultado
parte2resultado	    equ h'3D'	; Segunda parte dos 8 bits do resultado (8 bits a direita)
aux		    equ H'45'	; Variavel auxiliar, uso geral
aux2		    equ H'4D'	; Variavel auxiliar, usada para verificar valor a ser "emprestado" por parte1dividendo para parte2dividendo em caso de borrow
quantidadeDivisoes  equ H'55'	; Variavel de 4 bits que especifica quantas divisoes serao realizadas. Ex: quantidadeDivisoes = 3 => ((B/A)/A)/A
contadordelay1	    equ H'59'	; Contador de delay auxiliar (8 bits)
contadordelay2	    equ H'67'	; Contador de delay auxiliar (8 bits)
		
    org 00	    ; Comecando programa em 0x00
    
; Inicializacao
start	bsf status,5		; Seleciona o banco 1
    movlw   B'11111111'		; Move 1 para w
    movwf   trisb		; Move valor de w para portb (definindo portb como entrada)
    movwf   trisa		; Move valor de w para porta (definindo porta como entrada)
    bcf	status,5		; Seleciona o banco 0    
    
; Inicio programa    
loop
    movf    porta,0		; Move valor da porta para registrador 0 (registrador w)    
    movwf   divisor		; Move valor de w para variavel divisor
    clrw			; Limpa o registrador w
    movf    portb,0		; Move valor da portb para o registrador 0 (registrador w)
    movwf   parte1dividendo	; Move valor de w para variavel parte1dividendo
    clrf    porta		; Limpa o valor de porta
    clrf    portb		; Limpa valor de portb
				; Le mais 8 bits na portb em sequencia (Talvez fosse interessante por algum condicional aqui)
    movf    portb,0		; Move valor da portb para registrador 0 (registrador w)
    movwf   parte2dividendo	; Move valor de w para variavel parte2dividendo
    clrf    portb		; Limpa valor de portb

    movlw   D'2'		; Move valor 2 para w
    movwf   quantidadeDivisoes	; Move para variavel quantidadeDivisoes valor 2, isto é, será realizado (B/A)/A conforme especificação do projeto
    
    movlw   B'11111111'		; Sera realizada verificacao se divisor é zero
    addwf   divisor		; Adiciona, se houver carry divisor não é zero
    btfss   status, 0		; Não houve carry, pulará escrever resultado e realizará as divisões seguintes
    goto escreverResultado
    subwf   divisor		; Restaura o valor de divisor
    
    goto dividir		; Chama subrotina de divisao
    
    goto loop			; Volta para inicio do programa
    
dividir				; Começo dividir (divisor = A, parte1dividendo primeiros 8 bits a esquerda, parte2dividendo restante dos 8 bits a direita), Ex: divisor = 10, parte1dividendo = 30, parte2dividendo = 40 => Fazer: resultado = 3040/10 e depois resultado = resultado/10
    movfw   divisor		; Move valor de divisor para registrador w
    subwf   parte2dividendo	; Subtrai de parte2dividendo o valor de w (f - w)
    btfss   status, 0		; Verifica se subtracao deu valor menor que zero em parte2dividendo
    call    subtrairparte1	; Se deu menor que zero, chama subrotina de diminuir parte1 em 1 (pegar emprestado), Se nao deu, resultado = resultado + 1 (nas proximas linhas)
    incf    parte2resultado, 1	; Incrementa em um no resultado, divisao foi possivel
    movf    parte2resultado, 0	; W esta com valor de parte2resultado
    movwf   aux			; Move valor de w (parte2resultado) para aux
    movlw   B'11111111'		; Move 255 para w
    subwf   aux			; Verifica se aux (com valor de parte2resultado) é 255, se sim, call aumentarresultado
    btfsc   status, 2		; Verifica se resultado foi zero
    call aumentarResultado	; Chama subrotina de aumentar parte1resultado
    goto dividir
    
aumentarResultado
    decf    parte1dividendo, 1
    subwf   parte1dividendo
    btfsc   status, 2		; Verifica se subtracao menor que zero, se sim chama escreverResultado
    goto    finalizarEssaDivisao; Chama subrotina de finalizar divisoes e chamar funcao de realizar novaDivisao
    incf    parte1resultado, 1	; Se resultado zero, soma 1 nos primeiros 8 bits de resultado (parte1resultado) (isto, é, "vai 1") 
    incf    parte1dividendo, 1	; Restaura valor em parte1dividendo
    addwf   parte1dividendo	; Restaura valor em parte1dividendo
    return

finalizarEssaDivisao		; Verificacao acrescentada em casos onde ha divisao por 1
    incf    parte1dividendo, 1	; Restaura valor em parte1dividendo
    addwf   parte1dividendo	; Restaura valor em parte1dividendo
    goto novaDivisao		; Essa divisao acabou, chamar novaDivisao
    
subtrairparte1
    addwf   parte2dividendo	; Restaura valor de parte2dividendo
    decfsz  parte1dividendo, 1	; Diminui em 1 parte1dividendo
    movlw   B'11111111'		; Move 255 para w (equivalente a -1)
    subwf   parte1dividendo	; Subtracao = 0 implica que parte1dividendo é -1
    btfsc   status, 2		; Verifica se subtracao menor que zero, se sim chama escreverResultado
    goto    novaDivisao		; Realiza a divisao mais uma vez, conforme solicitado
    addwf   parte1dividendo	; Restaura valor de parte1dividendo
    
    movlw   B'11111111'		; Passa para w valor 255
    movwf   aux2		; Passa para aux2 valor 255

    movf    divisor, 0		; Move valor de divisor para w
    movwf   aux			; Move valor de w (divisor) para aux
    decf    aux, 1		; Decrementa aux em 1
    movf    aux, 0		; Move valor de aux (divisor-1) para w
    
    subwf   aux2		; Faz (255-(divisor-1)) que é o valor que vai ser "emprestado"
    movf    aux2, 0		; Passa valor de aux2 para w
    
    addwf   parte2dividendo	; Adiciona valor de w em parte2dividendo
    return

novaDivisao
    ; O resultado da primeira divisao (parte1resultado e parte2resultado) viram o novo numero de 16 bits que sera dividido novamente (parte1dividendo e parte2dividendo). Os valores de resultado são zerados
    movf    parte1resultado, 0	; Move o que esta em parte1resultado para w
    movwf   parte1dividendo	; Move o que esta em w para parte1dividendo
    movf    parte2resultado, 0	; Move o que esta em parte2resultado para w
    movwf   parte2dividendo	; Move o que esta em w para parte2dividendo
    movlw   B'00000000'		; Move 0 para w
    movwf   parte1resultado	; Zera valor de parte1resultado
    movwf   parte2resultado	; Zera valor de parte2resultado
    
    decf    quantidadeDivisoes, 1   ; Decrementa em 1 quantidadeDivisoes
    btfss   status, 2		; Se valor não é zero, realiza mais uma divisão
    goto    dividir
    
    ; Nas proximas linhas, os valores de parte1dividendo e parte2dividendo, que foram usados na operacao de divisao, são passados para parte1resultado e parte2resultado novamente
    movf    parte1dividendo, 0	; Move o que esta em parte1dividendo para w
    movwf   parte1resultado	; Move o que esta em w para parte1resultado
    movf    parte2dividendo, 0	; Move o que esta em parte2dividendo para w
    movwf   parte2resultado	; Move o que esta em 2 para parte2resultado
    
    
    goto    escreverResultado	; Chama subrotina de imprimir resultado
    
escreverResultado
    bsf status,5		;modifica o banco para 1
    movlw   B'00000000'		;carrega registrador w com 0
    movwf   trisb		;modifica o trisb para saida
    bcf	status,5		;modifica o banco para 0
    movf    parte1resultado,0	;carrega o valor do primeiro resultado para o registrador w
    movwf   portb		;move o resultado para portb
    movf    parte2resultado,0	;carrega o valor do segundo resultado para o registrador w
    movwf   portb		;move o resultado para portb
    bsf status,5		;modifica o banco para 1
    movlw   B'11111111'		;carrega registrador w com 1
    movwf   trisb		;modifica o trisb para entrada
    bcf	status,5		;modifica o banco para 0
    goto delay
    
    ; OBS: Precisa ajustar o tamanho dos laços (valores movidos para contadordelay2 e contadordelay1 de modo que faça dar 2 segundos de delay)
    ; Tem que dar um jeito de satisfazer a conta da linha 159 (pode fazer contadordelay1 e contadordelay2 receber outros valores sem ser 255 tambem)
    ; O problema é que essas variaveis precisam ser de 8 bits, então não da pra passar valor maior que 255
delay				; Subrotina de delay
    movlw   D'255'		; Move valor 255 para w
    movwf   contadordelay2	; Move valor de w para contadordelay2

outer movlw   D'255'		; Move valor 255 para w			(1 ciclo)
    movwf   contadordelay1	; Move valor de w para contadordelay1	(1 ciclo)
    
inner nop			;					(1 ciclo)
    nop				;					(1 ciclo)
    decfsz  contadordelay1, 1	; Decrementa em 1 o contadordelay1	(1 ciclo)
    goto inner			;					(2 ciclos)
    
    decfsz  contadordelay2, 1	; Decrementa em 1 o contadordelay2	(1 ciclo)
    goto outer			;					(2 ciclos)
				; OBS: ((x ciclos laco interno * 255) + x ciclos laco externo) * 255 = 40000000 ciclos
				; OBS2: PIC 16F873A possui clock de 20MHZ => 1 ciclo = 5*10^-8 segundos, portanto 40000000 ciclos = 2 segundos 
    goto loop
    
    end
