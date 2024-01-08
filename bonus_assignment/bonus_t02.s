/*
-------------------------------------------------------
Bonus Assignment
Q2
-------------------------------------------------------
Author:  Cassel Robson
ID:      210507000
Email:   robs7000@mylaurier.ca
Date:    2023-04-01
-------------------------------------------------------
*/

// Constants            
.equ UART_BASE, 0xff201000 // Defines the UART base address
.equ SIZE, 8 // Defines the size of each element in the array
.equ VALID, 0x8000 // Defines a valid value for the UART input
.equ LIMIT, 10 // Defines a limit for the loop counter

.org 0x1000 // Specifies the starting address of the program

.text // Code Section

.global _start
_start:

ldr r0, =UART_BASE // Loads the UART base address into register r0
mov r4 , #0x0A // Initializes the value of the newline character
ldr r5, =arr // Loads the starting address of the array into register r5
ldr r6, =endarr // Loads the ending address of the array into register r6
mov r2, #10 // Initializes the base for the numeric conversion
mov r3, #0 // Initializes the result of the numeric conversion
mov r7, #SIZE // Initializes the size of each element in the array
MOV r8, #1 // Initializes the value to be stored in the array
mov r9, #0 // Initializes the sum of the array elements to zero
mov r10, #0 // Initializes the count of array elements to zero

// initilize array with 1's
initialize:
	strb r8, [r5], #1 // Stores the value in the current index of the array and increments the pointer
	subs r7, r7, #1 // Decrements the counter
	bne initialize // Repeats if the counter is not zero

primaryloop:
	ldr r1, [r0] // Loads the value from the UART into register r1
	tst r1, #VALID // Tests if the value is valid
	beq sum_display  // Branches to print the sum if the value is not valid
	and r1, r1, #0xff // Clears any bits above the first 8 bits
	cmp r1, #10 // Compares the value to the newline character
	beq str // Branches to store the result in the array if the value is a newline
	cmp r1, #48 // Compares the value to the ASCII value for '0'
	blt sum_display  // Branches to print the sum if the value is less than '0'
	cmp r1, #57 // Compares the value to the ASCII value for '9'
	bgt sum_display  // Branches to print the sum if the value is greater than '9'
	add r1, r1, #-48 // Subtracts the ASCII value for '0' from the value to convert it to a decimal number
	mul r3, r3, r2 // Multiplies the current result by the base
	add r3, r3, r1 // Adds the converted digit to the result
	add r9, r9, r1 // Adds the converted digit to the sum
	add r10, r10, #1 // Increments the count of array elements
	b primaryloop

	str:
		str r3, [r5], #4         // Stores the result in the current index of the array and increments the pointer
		mov r3, #0               // Resets the result of the numeric conversion to zero
		cmp r5, r6               // Compares the current index to the ending index of the array
		beq sum_display           // Branches to print the sum if the array is full
		b loop

// Convert sum to string and print to UART (this is the main program)
sum_display:
	mov r1, r9 // Move the value in register r9 into r1
	ldr r7, =arr2 // Load the address of arr2 into register r7

	Sumloopmain:
		mov r2, #10		// Move the value 10 into r2
		BL Div				// Call the "Div" function to divide r1 by r2
		add r1, #48		// Add 48 to r1 (converts it to its ASCII character value)
		strb r1, [r7], #1	// Store the byte value of r1 into the memory location pointed to by r7, then increment r7 by 1
		mov r1, r2		// Move the value in r2 into r1
		cmp r1, #10		// Compare r1 to 10
		bge Sumloopmain	// If r1 is greater than or equal to 10, jump to the "Sumloopmain" label
		add r1, #48		// Add 48 to r1 (converts it to its ASCII character value)
		strb r1, [r7]		// Store the byte value of r1 into the memory location pointed to by r7
		ldr r1, =arr2	// Load the address of arr2 into r1
		BL PrintBackwards	// Call the "PrintBackwards" function to print the contents of arr2 in reverse order
		b meancalculation	// Branch to the "meancalculation" label
	
// Calculate the mean of all elements in the array; sum/count (this is the main program)
// Define the "meancalculation" function
meancalculation:
	mov r1, r9 // Move the value in register r9 into r1 (this will be the dividend)
	ldr r7, =arr2 // Load the address of arr2 into register r7

	// Loop to divide r1 by r10 and add the digits to arr2
	loopmain:
		mov r2, r10		// Move the value in register r10 into r2 (this will be the divisor)
		BL Div				// Call the "Div" function to divide r1 by r2

		add r1, #48		// Add 48 to r1 (converts it to its ASCII character value)
		strb r1, [r7], #1	// Store the byte value of r1 into the memory location pointed to by r7, then increment r7 by 1

		mov r1, r2		// Move the value in r2 into r1
		cmp r1, #10		// Compare r1 to 10
		bge loopmain		// If r1 is greater than or equal to 10, jump to the "loopmain" label

		add r1, #48		// Add 48 to r1 (converts it to its ASCII character value)
		strb r1, [r7]		// Store the byte value of r1 into the memory location pointed to by r7

		ldr r1, =arr2	// Load the address of arr2 into r1
		BL PrintBackwards	// Call the "PrintBackwards" function to print the contents of arr2 in reverse order




_stop:

B    _stop

// calculate mean and print to the UART
Div:
	STMFD sp!, {r7, lr} // Store r7 and lr on the stack
	mov r7, #0 // Initialize r7 to 0
	cmp r1, r2 // Compare r1 and r2
	blt _exitDiv // Branch to _exitDiv if r1 is less than r2
loop:
	add r7, r7, #1 // Increment r7 by 1
	sub r1, r1, r2 // Subtract r2 from r1
	cmp r1, r2 // Compare r1 and r2
	bge loop // Branch to loop if r1 is greater than or equal to r2
_exitDiv:
	mov r2, r7 // Move the division result to r2
	LDMFD sp!, {r7, pc} // Load r7 and pc from the stack and return
PrintBackwards:
	STMFD sp!, {r1, r2, r7, lr} // Store r1, r2, r7, and lr on the stack
	mov r7, r1 // Initialize r7 to r1	
loopfindnull:
	ldr r2, [r1], #4 // Load a word from memory at address r1 and increment r1 by 4
	cmp r2, #0 // Compare the loaded word with 0
	bne loopfindnull // Branch to loopfindnull if the loaded word is not equal to 0
	sub r1, r1, #4 // Decrement r1 by 4
loopPrint:
	ldrb r2, [r1] // Load a byte from memory at address r1
	strb r2, [r0] // Store the loaded byte at the address pointed to by r0
	sub r1, r1, #1 // Decrement r1 by 1
	cmp r1, r7 // Compare r1 with r7
	bge loopPrint // Branch to loopPrint if r1 is greater than or equal to r7
_PrintBackwards:
	str r4, [r0] // Store a newline character at the address pointed to by r0 to print a new line
	LDMFD sp!, {r1, r2, r7, pc} // Load r1, r2, r7, and pc from the stack and return.

.data

arr:
.space SIZE
endarr:

arr2:
.space 16


//Code comments: UART output

// first number represents the sum 
// second number represents the mean, where the first digit is the quotient and the second digit is the remainder


.end