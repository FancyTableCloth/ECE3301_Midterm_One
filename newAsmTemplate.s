config OSC = INTIO2
config BOR = OFF        ; Brown-out Reset Enable bits (Brown-out Reset disabled in hardware and software)
config STVREN = OFF     ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will not cause Reset)
config WDT = OFF        ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
config MCLRE = ON       ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)
#include <xc.inc>	
	goto start	

	psect data
rotation:   DB	0xfc, 0xf9, 0xf3, 0xe7, 0xaf, 0xbe
   
   psect code
SSEG	EQU 0x41    ; 7segment pattern table starting address in data memory
I	EQU 0x70    ; used as a counter index	
UP	EQU 0x71
DOWN	EQU 0x72

; Delay = 0.5 seconds
; Clock frequency = 8 MHz
d1	EQU	0x73
d2	EQU	0x74
d3	EQU	0x75
delay_500_ms:			
	movlw	0x08
	movwf	d1
	movlw	0x2F
	movwf	d2
	movlw	0x03
	movwf	d3
delay_500_ms_0:
	decfsz	d1, f
	goto	$+2
	decfsz	d2, f
	goto	$+2
	decfsz	d3, f
	goto	delay_500_ms_0
			;3 cycles
	goto	$+1
	nop	
	
start:	
    ;move input values into file registers
	movlw	0x00
	movwf	0x10, f, a
	movlw	0x01
	movwf	0x11, f, a
	movlw	0x02
	movwf	0x12, f, a
	movlw	0x03
	movwf	0x13, f, a
	movlw	0x00
	movwf	UP, f, a
	movlw	0x06
	movwf	DOWN, f, a
    ; Move the 7seg pattern from program memory into data memory
	movlw	low lookup
	movwf	TBLPTRL, f, a
	movlw	high lookup
	movwf	TBLPTRH, f, a
	movlw	low highword lookup
	movwf	TBLPTRU, f, a
	
	lfsr	0, SSEG ; starting address in data memory
	movlw	10
	movwf	I, f, a ; initialize counter with 10
	
loop:	TBLRD*+    ; read 1B from program memory and advance TBLPTR by 1
	movff	TABLAT, POSTINC0 ;copy TABLAT into INDF0 them move FSR0 pointer forward
	decf	I, f, a;
	bnz	loop	
	
	; set the I/O port directions
	setf	ADCON1, a   ; turn off the ADC
	clrf	TRISA, a    ; output connected to 7seg
	setf	TRISD, a    ; input  connected to 4 switches
    
infloop:
	movf	PORTD, w, a
	andlw	0x03	    ;keep lowest 2 bits
	CPFSLT	0x13, a	    ;code siphons out accepted bits bit descending order and puts them in respective subroutines
	bra	three
	CPFSLT	0x12, a
	bra	two
	CPFSLT	0x11, a
	bra	one
	bra	zero
	bra	infloop
	
three:	;clockwise rotation
	movf	UP, w, a
	call	bcd2sseg, 0
	movf	PORTA, a
	incf	UP, w, a
	bra	infloop
	
two:	;counterclockwise rotation
	movf	DOWN, w, a
	call	bcd2sseg, 0
	movf	PORTA, a
	decf	DOWN, w, a
	bz	resetDOWN
	bra	infloop
	
one:	;turns on middle segment for .5 seconds
	movlw	0xdf
	movf	PORTA
	call	delay_500_ms
	bra	zero
zero:	;turns off seven segment, .5 second delay
	movlw	0xff
	movf	PORTA, a
	call	delay_500_ms
	bra	infloop
bcd2sseg: 
	lfsr	0, SSEG; move fsr0 pointer back to start of table
	movf	PLUSW0, w, a
	return 0; WREG will have the sseg pattern upon return
	
resetUP:    movlw   0x00	;resets counter to bottom of the SSEG
	    movwf   UP, f, a
	    return  0
	
resetDOWN:  movlw   0x06	;resets counter to top of SSEG
	    movwf   DOWN, f, a
	    return  0
	    
end

