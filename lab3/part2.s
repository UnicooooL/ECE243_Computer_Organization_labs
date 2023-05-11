.global _start
.equ	KEY_BASE, 0xFF200050		// base code for KEY
.equ	EDGE_BASE, 0xFF20005C		// base code for edge capture
.equ  	TIMER, 0xFFFEC600 			// base of private timer

_start:	MOV		R11, #0				// set value for notation
		MOV		R0, #0				// initialize counter
		MOV		R12, #0
		B		DISPLAY

/* COUNT 0.25S */
DO_DELAY: 	MOV		R11, #0
			LDR 	R7, =500000 // for CPUlator use =500000
SUB_LOOP: 	SUBS 	R7, R7, #1
		  	BNE 	SUB_LOOP
			//B		POLL
			
/* POLL */
POLL:	LDR		R4, =KEY_BASE
		LDR		R3, [R4, #0xC]	// R3 store edge capture
		CMP		R3, #0			// check whether key is pressed or not
		BEQ		CHECK			// if not pressed, go to check directly with R11 = 0
		MOV		R11, #1			// if key is pressed, flip the notation R11 = 1
		ADD		R12, #1
		B		WAIT
		
WAIT:	SUB		R12, #2
		CMP		R12, #2
		BGT		WAIT
		CMP		R12, #0
		BNE		CHECK
		STR		R3, [R4, #0xC]
		B		CHECK

/* CHECK NOTATION */		
CHECK:	CMP		R11, #1			// check notation
		BNE		DISPLAY			// if notation is 0, key not pressed, cnt remains
		
COUNTER:	CMP		R0, #99
			BEQ		_start
			ADD		R0, #1		// if notation is 1, key pressed, cnt+1
			MOV		R11, #0		// flip notation to 0 for next round

DISPLAY:	// display blank on all other positions
		    LDR		R8, =0xFF200030 // base address of HEX5-HEX4
			MOV		R9, R0			// temp store of counter value
			MOV		R6, #0			// store shift one position
			MOV		R0, #10			// store idx 10 into R0
			BL		SEG7_CODE		// R0 returns in bit code for blank
			STRB	R7, [R6]
			LSL		R0, R7			// no shift
			MOV		R4, R0			// save bit code for HEX4/1 in R0 to R4
			MOV		R0, #10			// store idx 10 into R0 again
			BL		SEG7_CODE		// R0 returns in bit code for blank
			ADD		R7, #8			// change to next position
			LSL		R0, R7			// change to next position for num
			ORR		R4, R0			// save bit code for HEX5/2 in R0 to R4
			STR		R4, [R8]        // display the numbers from R4 on HEX0
			MOV		R0, R9			// return the value store in R9 back to R0 counter
			MOV		R7, #0
			MOV		R10, R0			// temp store cnt value
			// display two decimals on HEX1-0
			LDR     R8, =0xFF200020 // base address of HEX3-HEX0
            BL      DIVIDE          // ones digit will be in R0; tens
                                    // digit in R1
            MOV     R9, R1          // save the tens digit(R1), R0 is ones
            BL      SEG7_CODE       // R0 returns ones digit in HEX display code
            MOV     R4, R0          // save bit code in R4
            MOV     R0, R9          // retrieve the tens digit, get bit
                                    // code
            BL      SEG7_CODE		// R0 returns tens digit in HEX display code  		     
            LSL     R0, #8			// left shift by 8 place, to give the pos for ones
									// so store at the next left position
            ORR     R4, R0			// ones, tens putting together into R4 to display
			// display blank on HEX2-3
			MOV		R0, #10			// store idx 10 into R0 again
			BL		SEG7_CODE		// R0 returns in bit code for blank
			ADD		R7, #16			// change to next position
			LSL		R0, R7			// change to next position for num
			ORR		R4, R0			// save bit code for HEX2 in R0 to R4
			ADD		R7, #8			// change to next position
			LSL		R0, R7			// change to next position for num
			ORR		R4, R0			// save bit code for HEX3 in R0 to R4
			STR     R4, [R8]        // display the counter
			MOV		R0, R10			// return counter value to counter
			B		DO_DELAY
		
/* DIVIDE from lab 1 */
DIVIDE:     MOV    R2, #0
			MOV	   R1, #10
CONT:       CMP    R0, R1  			// R1 stores the divisor, R0 stores remaining num
            BLT    DIV_END
            SUB    R0, R1
            ADD    R2, #1
            B      CONT
DIV_END:    MOV    R1, R2     		// quotient in R1 (remainder in R0)
            MOV    PC, LR
		  
/* Subroutine to convert the digits from 0 to 9 to be shown on a HEX display.
 *    Parameters: R0 = the decimal value of the digit to be displayed
 *    Returns: R0 = bit patterm to be written to the HEX display
 */

SEG7_CODE:  MOV     R1, #BIT_CODES  
            ADD     R1, R0         // index into the BIT_CODES "array"; R1=R1+R0
            LDRB    R0, [R1]       // load the bit pattern (to be returned)
            MOV     PC, LR              

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
			.byte   0b00000000
            .skip   2      // pad with 2 bytes to maintain word alignment		
