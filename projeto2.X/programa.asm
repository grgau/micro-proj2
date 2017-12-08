; Alunos:
; Gabriel Bueno
; Paulo Paim
; Pedro Ferracini

    list    p=16f873A	    ; Especificando qual o tipo de microcontrolador
    #include "p16f873a.inc"	; Include do arquivo de configuracao (ta em header files) precisa disso pro mplab
    
    __CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_ON & _RC_OSC & _WRT_OFF & _LVP_ON & _CPD_OFF	; Algumas configuracoes que peguei de exemplos
    
    ; Variaveis
    
    
    ; ************************
    org 0x000
    goto main
    
    main
    
    
    end