?

; PIC18F452 Configuration Bit Settings

#include "p18F452.inc"

; CONFIG1H
  CONFIG  OSC = HS              ; Oscillator Selection bits (HS oscillator)
  CONFIG  OSCS = OFF            ; Oscillator System Clock Switch Enable bit (Oscillator system clock switch option is disabled (main oscillator is source))

; CONFIG2L
  CONFIG  PWRT = OFF            ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  BOR = OFF             ; Brown-out Reset Enable bit (Brown-out Reset disabled)
  CONFIG  BORV = 20             ; Brown-out Reset Voltage bits (VBOR set to 2.0V)

; CONFIG2H
  CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
  CONFIG  WDTPS = 128           ; Watchdog Timer Postscale Select bits (1:128)

; CONFIG3H
  CONFIG  CCP2MUX = ON          ; CCP2 Mux bit (CCP2 input/output is multiplexed with RC1)

; CONFIG4L
  CONFIG  STVR = OFF            ; Stack Full/Underflow Reset Enable bit (Stack Full/Underflow will not cause RESET)
  CONFIG  LVP = OFF             ; Low Voltage ICSP Enable bit (Low Voltage ICSP disabled)

; CONFIG5L
  CONFIG  CP0 = OFF             ; Code Protection bit (Block 0 (000200-001FFFh) not code protected)
  CONFIG  CP1 = OFF             ; Code Protection bit (Block 1 (002000-003FFFh) not code protected)
  CONFIG  CP2 = OFF             ; Code Protection bit (Block 2 (004000-005FFFh) not code protected)
  CONFIG  CP3 = OFF             ; Code Protection bit (Block 3 (006000-007FFFh) not code protected)

; CONFIG5H
  CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot Block (000000-0001FFh) not code protected)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM not code protected)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Write Protection bit (Block 0 (000200-001FFFh) not write protected)
  CONFIG  WRT1 = OFF            ; Write Protection bit (Block 1 (002000-003FFFh) not write protected)
  CONFIG  WRT2 = OFF            ; Write Protection bit (Block 2 (004000-005FFFh) not write protected)
  CONFIG  WRT3 = OFF            ; Write Protection bit (Block 3 (006000-007FFFh) not write protected)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) not write protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot Block (000000-0001FFh) not write protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM not write protected)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; Table Read Protection bit (Block 0 (000200-001FFFh) not protected from Table Reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Table Read Protection bit (Block 1 (002000-003FFFh) not protected from Table Reads executed in other blocks)
  CONFIG  EBTR2 = OFF           ; Table Read Protection bit (Block 2 (004000-005FFFh) not protected from Table Reads executed in other blocks)
  CONFIG  EBTR3 = OFF           ; Table Read Protection bit (Block 3 (006000-007FFFh) not protected from Table Reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot Block (000000-0001FFh) not protected from Table Reads executed in other blocks)


CBLOCK 0X80  
  	FILTRO	
  	W_TEMP
  	STATUS_TEMP
  	BSR_TEMP
   	TEMPO
    	FLAGS
    	TEMP1
	CONTA ; variavel contador
ENDC

#DEFINE ST_BT_RB3 FLAGS,0

V_INICIO EQU .1 
T_FILTRO EQU .230

#DEFINE BOTAO_RB3 PORTB,3
#DEFINE LED_D0 PORTD,0
#DEFINE LED_D1 PORTD,1


ORG 0X00
GOTO INICIO

    ORG 0X08

    MOVWF W_TEMP
    MOVFF STATUS,STATUS_TEMP
    MOVFF BSR,BSR_TEMP

    BTFSS INTCON,TMR0IF
    GOTO SAI_INT


    BCF INTCON,TMR0IF   ;Neste bloco ele define o valor limite do TIMER0.
    MOVLW .256-.131	;Logo após definir o limite, ele decrementa, até que seja 0.
    MOVWF TMR0
    DECFSZ TEMP1,F	
    GOTO SAI_INT

    MOVLW .125 		;Coloca o valor fixo de 125 no TEMP1, que será usado para chegar ao valor de 250ms (não possivel apenas com 1 TIMER).
    MOVWF TEMP1

    DECFSZ TEMPO,F	
    GOTO SAI_INT

    MOVLW V_INICIO	
    MOVWF TEMPO

    BTFSC LED_D0
    GOTO APAGA_LED
    BSF LED_D0
	DECFSZ CONTA,1 	; decrementa em 1 o contador
    GOTO SAI_INT 	; não é zero vai para sai_int
	BSF LED_D1 	; é zero acende o led_d1
	MOVLW .4 	; reseta o contador com 4
	MOVWF CONTA 	; coloca 4 na variavel conta // variavel 'CONTA' responsável por contar a quantidade que o LED_D0 piscou, para então piscar o LED_D1 na 4º piscada do LED_D0. 
	GOTO SAI_INT 	; retorna para rotina

    APAGA_LED		;'Função' de piscar os LEDs.
 	BCF LED_D0
	BCF LED_D1 

    SAI_INT		

    MOVFF BSR_TEMP,BSR	
    MOVF W_TEMP,W
    MOVFF STATUS_TEMP,STATUS

    RETFIE


        LIGA_TIMER	;'Função' de ligar o TIMER0 responsável diretamente pelo LED_D0.

        BCF INTCON,TMR0IF
        MOVLW .256-.131
        MOVWF TMR0
        MOVLW .125
        MOVWF TEMP1
        BSF INTCON,GIE

        RETURN

        DESLIGA_TIMER	;Quando o TMR0 chega em 0, apagam-se os LEDs, para então reiniciar o programa. 

        BCF INTCON,GIE
        BCF LED_D0
        BCF LED_D1

        RETURN

INICIO
    CLRF PORTB
    CLRF PORTD
    CLRF FLAGS

    MOVLW V_INICIO
    MOVWF TEMPO

    MOVLW B'00001000'
    MOVWF TRISB
    MOVLW B'00000000'
    MOVWF TRISD
    MOVLW B'11000011' ; T0CON EM 16
    MOVWF T0CON
    MOVLW B'00100000'
    MOVWF INTCON
	MOVLW .4 ; contador para 4
	MOVWF CONTA ; variavel contador

MAIN
    MOVLW T_FILTRO	
    MOVWF FILTRO

VERIFICA_1_BT		;'Função' responsavel por verificar se o botão foi pressionado. 
    BTFSC BOTAO_RB3
    GOTO MAIN
    DECFSZ FILTRO,1
    GOTO VERIFICA_1_BT

    BTFSC ST_BT_RB3	;Caso botão não tenha sido pressionado, manter o TIMER desligado.
    GOTO TIMER_OFF

    BSF ST_BT_RB3	;Caso botão tenha sido pressionado, mantém o valor dele em 1, e aciona o TIMER.
    CALL LIGA_TIMER
    GOTO VERIFICA_2_BT

TIMER_OFF
    BCF ST_BT_RB3	
    CALL DESLIGA_TIMER

VERIFICA_2_BT	;Função de Loop até que o botão seja pressionada e inicie o programa. 
    BTFSS BOTAO_RB3	
    GOTO VERIFICA_2_BT
    GOTO MAIN

END