/* 
 * File:   newmain.c
 * Author: Bryan Shum
 *
 * Created on July 11, 2022, 2:57 PM
 * ECE3301L-02
 */

#include <stdio.h>
#include <stdlib.h>
#include "config.h"

/*
 * 
 */
#define _XTAL_FREQ 1000000
int main() {

    char sseg[6] = {0xfc, 0xf9, 0xf3, 0xe7, 0xaf, 0xbe};
    //2 segment loop, pattern for common cathode seven segment display
    char zero = 0xff;    //pattern for 00
    char one = 0xDF;     //pattern for 01
            
    ADCON1 = 0xff;// Turn off ADC        
    TRISA = 0x00;// PORTA is output (connected to 7segment display)
    TRISD = 0xff;// PORTD is input (connected to switch)
    
    char counter = 1000;
    char counterTemp = 0;
    while(1)
    {
        while(PORTD == 2){       //clockwise rotation 
            counter = abs(counter + 1) % 6;
            PORTA = sseg[counter];
            __delay_ms(500);
        }
        while(PORTD == 3){       //counter clockwise rotation 
            counterTemp = (counter - 1) % 6;
            PORTA = sseg[counterTemp];
            counter = counter - 1;
            __delay_ms(500);
        }
        if(PORTD == 1){
            PORTA = one;
            __delay_ms(500);
            PORTA = zero;
            __delay_ms(500);
        }
        PORTA = zero;
        //__delay_ms(500);
    }    
    
    return (EXIT_SUCCESS);
}

