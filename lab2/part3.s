/* calculate longest ones and zeros separately in a word */

          .text                   // executable code follows
          .global _start  

_start:   MOV     R4, #TEST_NUM   // load the data word ...
          MOV     R5, #0          // R5 stores the longest sequence of 1's; a counter
		  MOV 	  R6, #0          // R6 stores the longest sequence of 0's; a counter
		  MOV     R7, #0          // R7 stores the longest sequence of alternating 1's and 0's; 
		  MOV	  R3, #0          // holds the current data value temporarily
          MOV     R9, #0
          MOV     R10, #0
		  MOV     R8, #ALT        // R8 holds address of data ALT
		  LDR     R8, [R8]        // R8 is loaded with value at address of R8
			
MAIN_LOOP:LDR     R1, [R4], #4    // Get next word data, R4 is incremented
          MOV 	  R3, R1
		  
		  CMP     R1, #0
          BEQ     END
          MOV     R0, #0          // Initialize counter
          BL      ONES            // Counts the longest consecutive 1s
          CMP     R5, R0          // compares R5 with R0 (R5-R0)
          MOVLT   R5, R0          // if (R0 > R5) saves new value into R5 (R5 <- R0)
// ------------------------------------------------------------------------------------------		  
		  MOV     R1, R3          // move the data from r3 to r1
		  MVN	  R1, R1          // moves one’s complement of the operand into R1
		  
		  CMP     R1, #0          // checks if data bits is 0
          BEQ     END
		  MOV 	  R0, #0          // initialize R0 counter
		  BL 	  ZEROS       
		  CMP     R6, R0          // compares if R0 > R6
		  MOVLT   R6, R0          // If R0 > R6, move R0 value to R6
// ------------------------------------------------------------------------------------------	  
		  MOV 	  R1, R3          // R1 holds the current word
          EOR     R1, R8          // XOR R1(current data) with R8 (largest alternating sequence, in this case 0x55555555)

          // --- zeros --- //
		  MVN     R1, R1          // Negates (inverses) the data bits 
		  CMP     R1, #0          // checks if data bits is 0
          BEQ     END             // if true, end loop
		  MOV 	  R0, #0          // initilize the counter
		  BL 	  ALTERNATE
		  CMP     R9, R0           // compare if R0 > R7
		  MOVLT   R9, R0           // If true, move R0 to R7
          // --- ones--- //
          
          MOV 	  R1, R3          // R1 holds the current word
          EOR     R1, R8          // XOR R1(current data) with R8 (largest alternating sequence, in this case 0x55555555)
          CMP     R1, #0          // checks if data bits is 0
          BEQ     END             // if true, end loop
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
          LSR     R2, R1, #1      // perform SHIFT right, followed by AND
          AND     R1, R1, R2      
          ADD     R0, #1          // count the string length so far
          B       ONES            

END_ONES: MOV     PC, LR   

ZEROS:	  CMP	  R1, #0
		  BEQ     END_ZEROS             
          LSR     R2, R1, #1      // perform SHIFT right, followed by AND
          AND     R1, R1, R2      
          ADD     R0, #1          // count the string length so far
          B       ZEROS
END_ZEROS: MOV	  PC, LR

ALTERNATE:CMP	  R1, #0
		  BEQ     END_ALTERNATE            
          LSR     R2, R1, #1      // perform SHIFT right, followed by AND
          AND     R1, R1, R2      
          ADD     R0, #1          // count the string length so far
          B       ALTERNATE
END_ALTERNATE: MOV	  PC, LR

TEST_NUM: .word   0x103fe00f // 9 zeros
          .word   0xA//0xDEADBEEF
          .word   0xDFFF // 13 ones
          .word   0x0  
ALT:      .word   0x55555555//.word   0xAAAAAAAA
          .end  

/*
ZEROS, ONES, ALTERNATE, can combine together as only one subroutine, since they are exactly the same. 
EOR: results true when either of the operands are true (one is true and the other one is false) but both are not true and both are not false.
*/