/*
-------------------------------------------------------
Assignment 4
Q1
-------------------------------------------------------
Author:  Cassel Robson
ID:      210507000
Email:   robs7000@mylaurier.ca
Date:    2023-04-01
-------------------------------------------------------
*/
//Constants
.equ MaxSize, 15

.equ ZERO, 48 // The ASCII for 0
.equ NINE, 57 // The ASCII for 9

.equ TEN, 10 // Used for Insuring decimal location if there isnt a space

.equ UART_BASE, 0xff201000
.equ SPACE, 32


.equ VALID, 0x8000 	// for uart mask

.org    0x1000 

.text  
.global _start
_start:

	LDR R1, =Array
	MOV R2, #MaxSize
	BL Input
	BL SortAndPrint

_stop:
B      _stop

//-------------------------------------------------------
Input:
	STMFD SP!, {R1-R9, LR}

	// Load UART_BASE into R0
	LDR R0, =UART_BASE

	// Load EndArray into R3
	LDR R3, =EndArray

	// Initialize R4-R8 to 0
	MOV R4, #0
	MOV R5, #0
	MOV R6, #0
	MOV R8, #0

	// Begin loop to read input
	readinput:
	// Check if end of array has been reached
	CMP R1, R3 //Array to EndArray
	BEQ _readLoop
		
		// Load data from UART
		LDR R4, [R0] 		
		TST R4, #VALID 		
		BEQ EndWrite

		// Store data in memory using 'alloca' function
		LDR R9, =alloca
		STR R4, [R9]
		LDRB R4, [R9]

		// Check if input is a space character
		CMP R4, #SPACE
		BEQ Write
		B Number
		
		// Store input in memory and prepare for next input
			Write:
			STR R6, [R1], #4
			MOV R4, #0
			MOV R5, #0
			MOV R6, #0
			ADD R8, R8, #1
			B readinput

			// Convert input to an integer
			Number:
			// Subtract ASCII value of '0' to convert to integer
			SUB R4, R4, #ZERO
			// Check if input is a valid number
			CMP R4, #ZERO
			CMPGE R4, #NINE
			BLE valid
			B invalid

			// If input is a valid number
			valid:
				// Check if R6 is currently 0
				CMP R6, #0
				BEQ moveToR6
				BNE increaseDigits

				// Move input to R6 if it is the first digit
				moveToR6:
					MOV R6, R4
					B invalid

				// Increase number of digits in R6 for each subsequent digit
				increaseDigits:
					MOV R7, #TEN
					MUL R6, R6, R7
					ADD R6, R6, R4

			// If input is not a valid number
			invalid:
				B readinput

	// End of input
		EndWrite:
		CMP R6, #0
		BEQ _readLoop
		STR R6, [R1], #4	
		MOV R4, #0
		MOV R5, #0
		MOV R6, #0
		ADD R8, R8, #1
		B _readLoop
		
	// Return length of array
		_readLoop:
		MOV R0, R8
		LDMFD SP!, {R1-R9, PC}
//------------------------------------------------------------------------------------
SortAndPrint:
	//Save registers to the stack
	STMFD SP!, {R0-R9, LR}
	// Initialize R3 and R4 to 0
	MOV R3, #0 	
	MOV R4, #0 		

	// R9 contains the length of the array
	MOV R9, R0

	// Outer loop (bubble sort)
	BubbleLoop:
		// Check if sorting is done
		CMP R3, R9 
		BEQ _BubbleLoop

		// Initialize R4 to 0
		MOV R4, #0 	

		// Calculate the number of remaining elements to be sorted
		MOV R7, R9 
		SUB R7, R7, R3 
		SUB R7, R7, #1 

		// Initialize R8 to the address of the first element
		MOV R8, R1

		// Inner loop
		insideLoop:
			// Check if inner loop is done
			CMP R4, R7
			BEQ _innerLoop

			// Calculate the address of the next element
			ADD R2, R8, #4

			// Load the values of the two elements to be compared
			LDR R5, [R8]
			LDR R6, [R2]

			// Compare the values and swap if necessary
			CMP R5, R6
			BGT Swap
			B promote

			Swap:
				STR R5, [R2]
				STR R6, [R8]

			promote:
				// Increment R4 and R8
				ADD R4, R4, #1
				ADD R8, R8, #4

				// Branch to the start of the inner loop
				B insideLoop

		// Increment R3 and branch to the start of the outer loop
		_innerLoop:
			ADD R3, R3, #1
			B BubbleLoop

	// Load the address of the array and call the Print function
	_BubbleLoop:
		LDR R1, =Array
		BL Print

	// Restore registers from the stack and return
		LDMFD SP!, {R0-R9, PC}
//-------------------------------------------------------
Print:
	// Save registers to the stack
	STMFD SP!, {R0-R12, LR}

	// Copy R0 and R1 into R8 and R3, respectively
	MOV R8, R0 
	MOV R3, R1

	// Initialize R4 to 0
	MOV R4, #0 

	// Loop through the array
	Loop:
		// If R4 is equal to R8, printing is done, so jump to the end of the function
		CMP R4, R8 
		BEQ _Loop

		// Load the current value from the array into R5
		LDR R5, [R3] 

		// Move the value to be printed into R0 and set R2 to point to the buffer where the output will be stored
		MOV R0, R5
		LDR R2, =allocatemore

		// Loop to print each digit of the number
		printLoop:
			// Divide the number by 10 and print the remainder
			MOV R1, #10
			BL printDiv
			ADD R0, #ZERO
			STRB R0, [R2], #1
			MOV R0, R1
			CMP R0, #10
			BGE printLoop

			// Add a space character to the end of the output
			ADD R0, #ZERO
			STRB R0, [R2], #1

			// Load the UART base address into R12
			LDR R12, =UART_BASE

			// Print the output buffer in reverse order
			LDR R0, =allocatemore
			BL printBackwards

			// Reset the buffer and add a space character to separate the numbers
			LDR R0, =allocatemore
			MOV R6, #0
			STR R6, [R0]
			MOV R6, #SPACE
			STRB R6, [R12]

			// Increment the counter and pointer, then loop again
			ADD R4, R4, #1
			ADD R3, R3, #4
			B Loop

	// End of the Print function
	_Loop:
		LDMFD SP!, {R0-R12, PC}
//-------------------------------------------------------
printDiv:
	STMFD SP!, {R2, LR}
	
	MOV R2, #0 				// Initialize quotient to zero
	CMP R0, R1 				// Compare dividend with divisor
	BLT _exitDiv			// If dividend < divisor, exit division function

	Div:
		ADD R2, R2, #1 		// Increment quotient
		SUB R0, R0, R1 		// Subtract divisor from dividend
		CMP R0, R1 			// Compare remainder with divisor
		BGE Div	// If remainder >= divisor, continue division

	_exitDiv:
	MOV R1, R2 				// Store quotient in R1
	LDMFD SP!, {R2, PC} 	// Restore registers and return
//-------------------------------------------------------
printBackwards:
	STMFD SP!, {R1-R3, LR}
	
	MOV R3, R0 				// Store the memory region address in R3
	limit:
		// Loop until the net 8bits contains all zeroes
		LDR R1, [R0], #4 		// Load a word from memory
		CMP R1, #0 				// Check if it contains all zeroes
		BNE limit				// If not, continue looping

	SUB R0, R0, #4 				// Adjust the memory region address
	LDR R2, =UART_BASE 			// Load the address of the UART_BASE

	printcontents:
		LDRB R1, [R0] 			// Load a byte from memory
		STRB R1, [R2] 			// Store the byte in UART_BASE

		SUB R0, R0, #1 			// Move to the previous byte
		CMP R0, R3 				// Check if we have printed all bytes
		BGE printcontents	// If not, continue printing

	// Restore registers and return
	LDMFD SP!, {R1-R3, PC}
//-------------------------------------------------------
.data
	Array:
		.space 4*MaxSize
	EndArray:
	allocatemore:
		.space 16
	alloca:
		.space 4
.end