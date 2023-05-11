/* Program that finds the largest number in a list of integers	*/
            
            .text                   // executable code follows
            .global _start                  
_start:                             
            MOV     R4, #RESULT     // R4 points to result location
            LDR     R0, [R4, #4]    // R0 holds the number of elements in the list
            MOV     R1, #NUMBERS    // R1 points to the start of the list
            BL      LARGE           
            STR     R0, [R4]        // R0 holds the subroutine return value

END:        B       END             

/* Subroutine to find the largest integer in a list
 * Parameters: R0 has the number of elements in the list
 *             R1 has the address of the start of the list
 * Returns: R0 returns the largest item in the list */
LARGE:      SUBS R0,#1  //count num of elements now, each time sub one
			BEQ DONE  //if equal zero goes to done
			ADD R1,#4  //use R1 to reach next num
			LDR R3,[R1]  //get the next num into R3
			CMP R2,R3  //compare which one is larger
			BGE LARGE  //enter loop again
			MOV R2,R3  //if new one is larger, update in R2
			B LARGE  //branch
DONE:		MOV R0,R2  //store the largest num into result
			//STR R0, [R4]  //move result into original result loc
			MOV pc,lr  //return to start mode

RESULT:     .word   0           
N:          .word   7           // number of entries in the list
NUMBERS:    .word   4, 5, 3, 6  // the data
            .word   1, 8, 2                 

            .end                            
