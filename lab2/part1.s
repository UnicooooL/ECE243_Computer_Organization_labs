/* Program that counts consecutive 1's */

          .text                   // executable code follows
          .global _start                  
_start:                             
          MOV     R1, #TEST_NUM   // load the data word ...
          LDR     R1, [R1]        // into R1

          MOV     R0, #0          // R0 will hold the result
LOOP:     CMP     R1, #0          // loop until the data contains no more 1's
          BEQ     END             // if no more data, goes to end
          LSR     R2, R1, #1      // perform right shift, R1 right shift by one bit, store into R2
          AND     R1, R1, R2      // perform AND gate operation for R1 and R2; store the result into R1
          ADD     R0, #1          // count the string length so far, stores into R0
          B       LOOP            

END:      B       END             

TEST_NUM: .word   0x103fe00f  

          .end                            

/*
example:
R1 1110
R2 0111
R1 0110
R0 1

R1 0110
R2 0011
R1 0010
R0 2

R1 0010
R2 0001
R1 0000
R0 3

three ones consecutive for specific word.
*/

/*
AND gate: perform bit-wise and operation.
*/