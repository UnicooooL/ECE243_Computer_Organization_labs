/* perform the results on the HEX display */ 
 
 .text                   // executable code follows
 .global _start 
/* code for Part III (not shown) */
_start:   MOV     R4, #TEST_NUM   // load the data word ...
          MOV     R5, #0          // R5 stores the longest sequence of 1's
		  MOV 	  R6, #0          // R6 stores the longest sequence of 0's
		  MOV     R7, #0          // R7 stores the longest sequence of alternating 1's and 0's
		  MOV	  R3, #0
		  MOV     R8, #ALT
		  LDR     R8, [R8]
			
MAIN_LOOP:LDR     R1, [R4], #4    // Get next word data, R4 is incremented
          MOV 	  R3, R1
		  
		  CMP     R1, #0
          BEQ     DISPLAY
          MOV     R0, #0
          BL      ONES
          CMP     R5, R0          // compares R5 with R0 (R5-R0)
          MOVLT   R5, R0          // if (R0 > R5) saves new value into R5 (R5 <- R0)
		  //------------------------------------------------------------------------------------------------
		  MOV     R1, R3
		  MVN	  R1, R1          // moves one’s complement of the operand into R1
		  
		  CMP     R1, #0
          BEQ     DISPLAY
		  MOV 	  R0, #0
		  BL 	  ZEROS
		  CMP     R6, R0
		  MOVLT   R6, R0
		  
          //------------------------------------------------------------------------------------------------
          MOV 	  R1, R3          // R1 holds the current word
          EOR     R1, R8          // XOR R1(current data) with R8 (largest alternating sequence, in this case 0x55555555)

                                // --- zeros --- //
		  MVN     R1, R1          // Negates (inverses) the data bits 
		  CMP     R1, #0          // checks if data bits is 0
          BEQ     DISPLAY             // if true, end loop
		  MOV 	  R0, #0          // initilize the counter
		  BL 	  ALTERNATE
		  CMP     R9, R0           // compare if R0 > R7
		  MOVLT   R9, R0           // If true, move R0 to R7
                                // --- ones--- //
          MOV 	  R1, R3          // R1 holds the current word
          EOR     R1, R8          // XOR R1(current data) with R8 (largest alternating sequence, in this case 0x55555555)
          CMP     R1, #0          // checks if data bits is 0
          BEQ     DISPLAY          // if true, end loop
		  MOV 	  R0, #0          // initilize the counter
		  BL 	  ALTERNATE
		  CMP     R10, R0           // compare if R0 > R7
		  MOVLT   R10, R0           // If true, move R0 to R7

          CMP     R9, R10          // R10 - R9
          MOV     R7, R9
          MOV     R7, R10
        
		  	
          B       MAIN_LOOP  
END:      B       END

ONES:     CMP     R1, #0          // loop until the data contains no more 1's
          BEQ     END_ONES             
          LSR     R2, R1, #1      // perform SHIFT, followed by AND
          AND     R1, R1, R2      
          ADD     R0, #1          // count the string length so far
          B       ONES            

END_ONES: MOV     PC, LR   

ZEROS:	  CMP	  R1, #0
		  BEQ     END_ZEROS             
          LSR     R2, R1, #1      // perform SHIFT, followed by AND
          AND     R1, R1, R2      
          ADD     R0, #1          // count the string length so far
          B       ZEROS
END_ZEROS: MOV	  PC, LR

ALTERNATE:CMP	  R1, #0
		  BEQ     END_ALTERNATE            
          LSR     R2, R1, #1      // perform SHIFT, followed by AND
          AND     R1, R1, R2      
          ADD     R0, #1          // count the string length so far
          B       ALTERNATE
END_ALTERNATE: MOV	  PC, LR

/* Display R5 on HEX1-0, R6 on HEX3-2 and R7 on HEX5-4 */
DISPLAY:    LDR     R8, =0xFF200020 // base address of HEX3-HEX0
            MOV     R0, R5          // display R5 on HEX1-0
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
            
            //code for R6 (not shown)
			MOV     R0, R6			// display R6 on HEX3-2
			BL		DIVIDE			// ones digit in R0, tens in R1
			MOV		R9, R1			// save tens in R1 to R9, R0 still ones
			BL		SEG7_CODE		// R0 returns ones' bit code
			LSL		R0, #16			// move ones' bit code for R6 to two position left
			ORR		R4, R0			// R6 ones put into R4's third position to left
			MOV		R0, R9			// retrieve the tens digit, get bit code
			BL		SEG7_CODE		// R0 returns tens' bit code
			LSL		R0, #24			// R0 left shift by 24 space three position
			ORR		R4, R0			// put R6 tens together with others
            
            STR     R4, [R8]        // display the numbers from R6 and R5
			// start for HEX5-4
            LDR     R8, =0xFF200030 // base address of HEX5-HEX4
            
            //code for R7 (not shown)
			MOV     R0, R7          // display R7 on HEX5-4
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
            
            STR     R4, [R8]        // display the number from R7
			BL		END

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
            .skip   2      // pad with 2 bytes to maintain word alignment
			
/* test part for part 3 */
TEST_NUM: .word   0xfff00AAA
          .word   0x0  
ALT:      .word   0x55555555//.word   0x55555555
          .end
		  