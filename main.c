/*
 *
 */

#include <msp430.h>

int main(void)
{
    WDTCTL = WDTPW | WDTHOLD;   // Stop watchdog timer

    int R5_SW = 0, R6_LED = 0;  // Change to volatile if warnings

    P1OUT = 0b00000000;         // mov.b    #00000000b, &P1OUT
    P1DIR = 0b11111111;         // mov.b    #11111111b, &P1DIR
    P2DIR = 0b00000000;         // mov.b    #00000000b, &P2DIR


    while (1)
    {
        R5_SW = P2IN;           // mov.b    &P2IN, R5

    // Check P2.0 for read mode. Change this to match the
    // specification in the manual (P2.0 logic low is on).
        if (R5_SW & BIT0)
        {
            R6_LED = R5_SW & (BIT7);
            P1OUT = R6_LED;


        }
        else
        {

            if(R5_SW & BIT1) { // Rotate left
                            int temp = R6_LED << 1;
                            temp &= 0x0100;
                            R6_LED = (R6_LED << 1) | (temp >> 8);
                        }
                        else { // Rotate right
                            R6_LED = (R6_LED >> 1) | (R6_LED << 7);
                        }
                        R6_LED &= 0xFF;
                        P1OUT = R6_LED;// Display rotation mode
           // if(R5_SW & BIT1)
             //   R6_LED = (R6_LED << 1)|(R6_LED >> 7);//rotate left
           // else
              //  R6_LED = (R6_LED >> 1)|(R6_LED << 7);

          //  R6_LED *= 2;
          //  R6_LED ^=0xFF;  // Toggle pattern
          //  R6_LED &=0xFF;  // Mask any excessive bits
           // P1OUT = R6_LED; // Display the pattern


            if(R5_SW & BIT2)

            __delay_cycles(500000); // Fast

        else
            _delay_cycles(1000000);
        }
    }


}
