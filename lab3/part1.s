/* display decimal number on HEX0, while other HEX display zeros. 
KEY0 pressed, set the number back to zero;
KEY1 pressed, increment the displayed number, without larger than 9;
KEY2 pressed, decrease the displayed number, without lower than 0;
KEY3 pressed, blank the display, then press other key will light the display up again. */

.global _start
.equ	KEY_BASE, 0xFF200050

_start:	LDR 	R0, =KEY_BASE		// set r0 to base KEY port
		MOV 	R2, #0				// store if blank is needed
		MOV		R5, #1				// blank indication for other sections	
		MOV		R9, #0

/* poll memory I/O */
POLL:	LDR		R9, [R0]
		CMP		R11, #1
		BEQ		AFTER_THREE
		CMP		R9, #1				// if R0 pushed, it will be 1
		BEQ		KEY_ZERO			// go to KEY0 instruction if R9 = 1
		CMP		R9, #2				// next position for R0 is pushed, it will be 2
		BEQ		KEY_ONE				// go to KEY1 instruction if R9 = 2
		CMP		R9, #4				// third position for R0 is pushed, it will be 4
		BEQ		KEY_TWO				// go to KEY2 instruction if R9 = 4
		CMP		R9, #8				// fourth position for R0 is pushed, it will be 8
		BEQ		KEY_THREE			// go to KEY3 instruction if R9 = 8
		B		POLL				// if all keys are not pushed, repeat again
		B		POLL				// end branch
		
// reset HEX0 num to 0
KEY_ZERO:	//MOV		R9, #0			// testing
			LDR		R9, [R0]
			CMP		R9, #1			// to see if KEY0 is released
			BEQ		KEY_ZERO		// if not released, repeate this branch
			MOV		R1, #0			// change the value display to be zero
			B		DISPLAY
			MOV		PC, LR			// since R1 is changed

// increment displayed num, keep 9 if > 9
KEY_ONE:	//MOV		R9, #0			// testing
			LDR		R9, [R0]
			CMP		R9, #0			// to see if KEY1 is released
			BNE		KEY_ONE			// if not released, repeate this branch
			CMP		R1, #9			// compare whether the number is 9
			BEQ		END_ONE			// not increase if equals 9 already
			ADD		R1, #1			// add one to R1 to display if not up to 9
			B		DISPLAY
			MOV		PC, LR			// since R1 is changed
END_ONE:	B		DISPLAY
			MOV		PC, LR			// since nothing changed

// decrement displayed num, keep 0 if < 0
KEY_TWO:	//MOV		R9, #0			// testing
			LDR		R9, [R0]
			CMP		R9, #0			// to see if KEY2 is released
			BNE		KEY_TWO			// if not released, repeate this branch
			CMP		R1, #0			// compare whether the number is 0
			BEQ		END_TWO			// not increase if equals 0 already
			SUB		R1, #1			// sub one to R1 to display if not down to 0
			B		DISPLAY
			MOV		PC, LR			// since R1 is changed
END_TWO:	B		DISPLAY
			MOV		PC, LR			// since nothing changed	

// blank the display, returns 0 if other keys pressed after it
KEY_THREE:	LDR		R9, [R0]
			//MOV		R9, #0			// testing
			CMP		R9, #0			// to see if KEY3 is released
			BNE		KEY_THREE		// if not released, repeate this branch
			MOV		R2, #1			// indicates that there needs all blank
			B		DISPLAY
			
			MOV		PC, LR			// since R2 changed
		
/* display number on 7 segment displays; 0-5 example */
			// display blank on all other positions
DISPLAY:    LDR		R8, =0xFF200030 // base address of HEX5-HEX4
			MOV		R9, R1			// temp store of R1 value
			MOV		R6, #0			// store shift one position
			//BL		BLANK
			MOV		R1, #10			// store idx 10 into R1
			BL		SEG7_CODE		// R1 returns in bit code for blank
			STRB	R7, [R6]
			LSL		R1, R7
			MOV		R4, R1			// save bit code for HEX4/1 in R1
			MOV		R1, #10			// store idx 10 into R1 again
			BL		SEG7_CODE		// R1 returns in bit code for blank
			ADD		R7, #8			// change to next position
			LSL		R1, R7			// change to next position for num
			ORR		R4, R1			// save bit code for HEX5/2 in R1 to R4
			STR		R4, [R8]        // display the numbers from R4 on HEX0
			
			MOV		R1, R9			// return the value store in R9 back to R1
			// start for display one digit of decimal
			LDR     R8, =0xFF200020 // base address of HEX3-HEX0
            BL      SEG7_CODE       // R1 returns in bit code
            MOV     R4, R1          // save bit code in R4
			// display blank on HEX1-3
			MOV		R6, #8			// store shift one positions
			//BL 		BLANK_1			// HEX1-3 blank
			MOV		R1, #10			// store idx 10 into R1
			BL		SEG7_CODE		// R1 returns in bit code for blank
			STRB	R7, [R6]
			LSL		R1, R7
			ORR		R4, R1			// save bit code for HEX4/1 in R1
			MOV		R1, #10			// store idx 10 into R1 again
			BL		SEG7_CODE		// R1 returns in bit code for blank
			ADD		R7, #8			// change to next position
			LSL		R1, R7			// change to next position for num
			ORR		R4, R1			// save bit code for HEX5/2 in R1 to R4
			ADD		R7, #8			// change to next position
			LSL		R1, R7			// change to next position for num
			ORR		R4, R1			// save bit code for HEX3 in R1 to R4
			STR     R4, [R8]        // display the numbers from R4 on HEX0
			MOV		R1, R9			// return the value for R1
			CMP		R11, #1
			BEQ		POLL
			CMP		R2, #1
			BEQ		BIT
			B		END				// go to branch end
			
END:		MOV		R9, #0
			B		POLL
		
BIT:		LDR		R9, [R0]	
			MOV		R1, #10			// store idx 10 into R1
			BL		SEG7_CODE		// R1 returns in bit code for blank
			MOV		R4, R1			// save bit code for HEX4/1 in R1
			STR     R4, [R8]        // display the numbers from R4 on HEX0
			MOV		R11, #1
			B		END_BIT
			
AFTER_THREE:			// KEY0 pushed; return 0
			LDR		R9, [R0]
			MOV		R1, #0			// next display should be 0
			CMP		R9, #1			// fourth position for R0 is pushed, it will be 1
			BNE		KEY1
			MOV		R11, #0
			B		PRESS_ANY
KEY1:			// KEY1 pushed; return 0
			LDR		R9, [R0]
			CMP		R9, #2			// fourth position for R0 is pushed, it will be 1
			BNE		KEY2
			MOV		R11, #0
			B		PRESS_ANY
KEY2:			//KEY2 pushed; return 0
			LDR		R9, [R0]
			CMP		R9, #4			// fourth position for R0 is pushed, it will be 1
			BNE		AFTER_THREE
			MOV		R11, #0
			B		PRESS_ANY

PRESS_ANY:	LDR		R9, [R0]
			CMP		R9, #0
			BNE		PRESS_ANY
			MOV		R2, #0
			B		DISPLAY

END_BIT:	B		POLL			// nothing pushed, nothing changed, return start
		
/* Subroutine to convert the digits from 0 to 9 to be shown on a HEX display.
 *    Parameters: R1 = the decimal value of the digit to be displayed
 *    Returns: R1 = bit patterm to be written to the HEX display
 */
SEG7_CODE:  MOV     R3, #BIT_CODES  
            ADD     R3, R1         // index into the BIT_CODES "array"; R3=R3+R1
            LDRB    R1, [R3]       // load the bit pattern (to be returned)
            MOV     PC, LR              

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
			.byte   0b00000000  // zero if idx is 10
            .skip   2      // pad with 2 bytes to maintain word alignment
