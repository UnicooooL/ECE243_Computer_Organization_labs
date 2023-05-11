.global _start
.equ	KEY_BASE, 0xFF200050		// base code for KEY
.equ	EDGE_BASE, 0xFF20005C		// base code for edge capture
.equ  	TIMER, 0xFFFEC600 			// base of private timer

_start:	MOV		R2, #0				// set value for notation
		MOV		R0, #0				// initialize counter
		BL		DISPLAY

/* COUNT 0.01S */
DO_DELAY: 	PUSH   {R3}
			LDR 	R7, =TIMER // Hardware time for exact time, stores the address 
			LDR     R3, =20000000 // for 0.01 seconds
			STR     R3,[R7] // load the value into thr register
			MOV     R3, #0b011 // writes to the control register (a = 1 e = 1), timer starts
			STR     R3, [R7, #0x8]
CHECK_DELAY:LDR     R3, [R7, #12]
			CMP     R3, #1
			BNE     CHECK_DELAY
			MOV     R3, #1
			STR     R3, [R7, #12]
			POP     {R3}
			B 		POLL

SUB_LOOP: 	SUBS 	R7, R7, #1
		  	BNE 	SUB_LOOP
			//B		POLL
			
/* POLL */
POLL:	LDR		R4, =KEY_BASE
		LDR		R3, [R4, #0xC]	// R3 store edge capture
		CMP		R3, #0			// check whether key is pressed or not
		BEQ		CHECK			// if not pressed, go to check directly with R2=0
		MOV		R2, #1			// if key is pressed, flip the notation R2 = 1
		
/* CHECK NOTATION */		
CHECK:	CMP		R2, #1			// check notation
		BNE		DISPLAY			// if notaation is 0, key not pressed, cnt remains
		
COUNTER:	LDR     R11, =5999 // Counter will be until 5999, resets after eaches this max point
			CMP		R0, R11
			BEQ		_start
			ADD		R0, #1		// if notation is 1, key pressed, cnt+1
			MOV		R2, #0		// flip notation to 0 for next round

//DISPLAY:	// display blank on all other positions
			// PUSH {R1, R2, R3, PC}
			//LDR		R8, =0xFF200030 // base address of HEX5-HEX4
DISPLAY:	// display blank on all other positions
			PUSH    {R11, R3}
			MOV		R11, R0
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
			/* HEX3 */
			LDR     R8, =0xFF200020 // base address of HEX3-HEX0
			MOV    	R1, #1000
            BL    	DIVIDE			// 1000 digit in R1
			MOV		R9, R0			// R9 holds the remaining 3 digits
			MOV		R0, R1			// 1000 digit in R0; R1 is useless now
			BL		SEG7_CODE		// R0 returns in bit code for 1000 digit
			LSL		R0, #24			// R0, 1000 digit bit code, is at HEX3
			MOV		R4,	R0			// store in R4 prepare to display
			/* HEX 2 */
			MOV		R0, R9			// return the cnt value to R0
			SUB		R1, R1
			MOV    	R1, #100
            BL     	DIVIDE			// 100 digit in R1
			MOV		R9, R0			// R9 holds the remaining 2 digits
			MOV		R0, R1			// 100 digit in R0; R1 is useless now
			BL		SEG7_CODE		// R0 returns in bit code for 100 digit
			LSL		R0, #16			// R0, 100 digit bit code, is at HEX2
			ORR		R4,	R0			// store in R4 prepare to display
			/* HEX 1 */
			MOV		R0, R9			// return the cnt value to R0
			MOV    	R1, #10
            BL     	DIVIDE			// 10 digit in R1
			MOV		R9, R0			// R9 holds the remaining 1 digit
			MOV		R0, R1			// 10 digit in R0; R1 is useless now
			BL		SEG7_CODE		// R0 returns in bit code for 10 digit
			LSL		R0, #8			// R0, 10 digit bit code, is at HEX1
			ORR		R4,	R0			// store in R4 prepare to display
			/* HEX 0*/
			MOV		R0, R9			// return the cnt value to R0
			BL		SEG7_CODE		// R0 returns in bit code for 1 digit
			ORR		R4,	R0			// store in R4 prepare to display
			STR		R4, [R8]        // display the numbers from R4 on HEX3-0
			MOV		R0, R11
			POP     {R11, R3}
			
            ///
            /// DON'T KNOW HOW TO DISPLAY A 4 DIDGIT NUMBER ON THE DISPLAY
            ///
			
			
			//MOV		R0, R10			// return counter value to counter
			B		DO_DELAY
		
/* DIVIDE from lab 1 */
/* Subroutine to perform the integer division R0 / R1.
 * Returns: quotient in R1, and remainder in R0 */
DIVIDE:     MOV    R2, #0
CONT:       CMP    R0, R1	// R0 stores counter value, R1 is the divisor
            BLT    DIV_END
            SUB    R0, R1
            ADD    R2, #1
            B      CONT
DIV_END:    MOV    R1, R2     // quotient in R1 (remainder in R0)
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
