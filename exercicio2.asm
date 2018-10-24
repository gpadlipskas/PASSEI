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

ORG 0X00
	DCounter1 EQU 0X0C
	DCounter2 EQU 0X0D
	DCounter3 EQU 0X0E
	DCounter4 EQU 0X0F
	GOTO INICIO
ORG	0X08
	RETFIE
ORG	0X18
	RETFIE
INICIO
	CLRF TRISB
	CLRF TRISD
	BSF TRISA,0;	RA0=ENTRADA
	MOVLW B'10000001'
	MOVWF ADCON0;		FOSC/64,CANAL 0,
						;A/D HABILITADO
	MOVLW B'11001110'
	MOVWF ADCON1;
ESPERA_1
	CALL ESPERA_CONF;APROX 13US PARA CONF.
	BSF ADCON0,GO;INICIA CONVERSÃO
ESPERA
	BTFSC ADCON0,DONE;AGUARDA FIM DA CONVERSAO
	GOTO ESPERA
	MOVFF ADRESL,PORTB;BYTE BAIXO PARA O PORTB
	MOVFF ADRESH,PORTD;BYTE ALTO PARA O PORTD
	CALL DELAY_3S;
	GOTO ESPERA_1

DELAY_3S
	

DELAY
MOVLW 0X1d ; seta o valor 1d em hexadecimal
MOVWF DCounter1
MOVLW 0X71 ; seta o valor 71 em hexadecimal
MOVWF DCounter2
MOVLW 0X1f ; seta o valor 1f em hexadecimal
MOVWF DCounter3
LOOP
DECFSZ DCounter1, 1
GOTO LOOP
DECFSZ DCounter2, 1
GOTO LOOP
DECFSZ DCounter3, 1
GOTO LOOP
RETURN

ESPERA_CONF
	MOVLW 0X03
	MOVWF DCounter4
	LOOP1
	DECFSZ DCounter4, 1
	GOTO LOOP1
	NOP
	RETURN

	END

