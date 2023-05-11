/* make a copy of Part1 and convert the calculation step into a subroutine */

.text								// executable code follows
.global _start
_start:	MOV		R4, #TEST_NUM		// load the data word ...
		MOV		R5, #0				// R5 stores the longest sequence of 1's

MAIN_LOOP:	LDR		R1, [R4], #4	// get next word data, R4 is incremented; load, then increment
			CMP		R1, #0			// compare R1 with number zero
			BEQ		END
			MOV		R0, #0			// clear R0 by setting it to zero
			BL		ONES
			CMP		R5, R0			// compares R5 with R0 (R5 - R0)
			MOVLT	R5, R0			// if R0>R5, saves new value into R5 (R5 <- R0)
			B		MAIN_LOOP
END:		B		END

ONES:		CMP		R1, #0			// loop until the data contains no more 1s
			BEQ		END_ONES
			LSR		R2, R1, #1		// perform shift, followed by AND
			AND		R1, R1, R2
			ADD		R0, #1			// count the string length so far
			B		ONES
END_ONES:   MOV		PC, LR

TEST_NUM:   .word	0x103fe00f
			.word	0xDRADBEEF
			.word	0xDFFF
			.word	0x0
			.end
	
	