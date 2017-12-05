list p=16F873A
status	equ   03
porta equ 06
portb equ 07
trisa equ 06
trisb equ 07
org 00
start bsf status, 5
movlw B'00000001'
movlw trisb
movlw trisa
end
