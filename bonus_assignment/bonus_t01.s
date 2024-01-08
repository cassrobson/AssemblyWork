/*
-------------------------------------------------------
Bonus Assignment
Q1 (PLEASE NOTE YOU MUST CLICK CONTINUE TWICE FOR THE CORRECT OUTPUT)
-------------------------------------------------------
Author:  Cassel Robson
ID:      210507000
Email:   robs7000@mylaurier.ca
Date:    2023-03-31
-------------------------------------------------------
*/

// Constants
.equ UART_BASE, 0xff201000 // Define a constant UART_BASE with the value 0xff201000, which is the base address of the UART.
.equ SIZE, 5 // Define a constant SIZE with the value 5.
.org 0x1000 // Set the origin of the program to memory location 0x1000.
.text // Start the code section.
.global _start // Declare the symbol "_start" as a global symbol.
_start: // Define the starting point of the program.

LDR R0, =UART_BASE // Load the value of UART_BASE into register R0.

MOV R8, #0x20   // Move the hexadecimal value of 0x20 (which represents a space character) into register R8.
MOV R9, #0x2A   // Move the hexadecimal value of 0x2A (which represents an asterisk character) into register R9.
MOV R10, #0x0A  // Move the hexadecimal value of 0x0A (which represents a new line character) into register R10.

// print upper half of diamond

MOV R1, #1   // Move the value 1 into register R1 (for variable k).

loop1: // Define the label for the loop.

	CMP R1, #SIZE-1 // Compare the value of R1 with SIZE-1.
	BGT loop2 // If R1 is greater than SIZE-1, branch to the label loop2.
	MOV R2, #SIZE // Move the value of SIZE into register R2.
	SUB R2, R2, R1 // Subtract the value of R1 from R2 and store the result in R2.

	loop1a: // Define the label for the inner loop.
		CMP R2, #0 // Compare the value of R2 with 0.
		BLE loop1b // If R2 is less than or equal to 0, branch to the label loop1b.
        STR R8, [R0] // Store the value of R8 (which represents a space) at the address pointed to by R0 (which is the UART base address).
        SUB R2, R2, #1 // Subtract 1 from the value of R2 and store the result in R2.
        B   loop1a // Branch to the label loop1a.
	loop1b: // Define the label for the end of the inner loop.
		MOV R2, #1 // Move the value 1 into register R2 (for variable j).

		loop1c: // Define the label for the second inner loop.
			CMP R2, R1 // Compare the value of R2 with the value of R1.
            BGT loop1d // If R2 is greater than R1, branch to the label loop1d.
            STR R9, [R0] // Store the value of R9 (which represents an asterisk) at the address pointed to by R0.
            STR R8, [R0] // Store the value of R8 (which represents a space) at the address pointed to by R0.
            ADD R2, R2, #1 // Add 1 to the value of R2 and store the result in R2.
            B loop1c // Branch to the label loop1c.  
	loop1d:
		STR R10, [R0] // print end of line
        ADD R1, R1, #1   
        B loop1    

// print lower half of dimaond

MOV R1, #1   // k = 1        // Move the value 1 into register R1 to initialize the outer loop counter to 1, which will be used to control the number of rows printed
loop2:                       // Label for the outer loop
	CMP R1, #1              // Compare the value in R1 with 1 to check if the outer loop counter has reached its end condition
	BLE _stop               // Branch to the stop label if the outer loop counter is less than or equal to 1
	MOV R2, #SIZE           // Move the value of the SIZE constant into register R2, which will be used to control the number of columns printed in each row
	SUB R2, R2, R1          // Subtract the value in R1 from R2 to calculate the number of spaces that need to be printed in the current row
	loop2a:                 // Label for the inner loop that prints spaces
		CMP R2, #0       // Compare the value in R2 with 0 to check if all spaces have been printed
		BLE loop2b      // Branch to the label for the inner loop that prints asterisks if all spaces have been printed
        STR R8, [R0]        // Store the ASCII value of a space in the memory location pointed to by the UART_BASE address
        SUB R2, R2, #1   // Subtract 1 from the value in R2 to move to the next space
        B   loop2a         // Branch back to the start of the inner loop to print the next space
	loop2b:                 // Label for the inner loop that prints asterisks
		MOV R2, #1       // Move the value 1 into register R2 to initialize the counter for the number of asterisks printed in the current row
		loop2c:             // Label for the loop that prints asterisks
			CMP R2, R1  // Compare the value in R2 with the value in R1 to check if all asterisks have been printed in the current row
            BGT loop2d // Branch to the label that prints a space and ends the current row if all asterisks have been printed in the current row
            STR R9, [R0] // Store the ASCII value of an asterisk in the memory location pointed to by the UART_BASE address
            STR R8, [R0]  // Store the ASCII value of a space in the memory location pointed to by the UART_BASE address
            ADD R2, R2, #1   // Add 1 to the value in R2 to move to the next asterisk
            B   loop2c     // Branch back to the start of the loop that prints asterisks to print the next asterisk
	loop2d:                 // Label that prints a space and ends the current row
		STR R8, [R0]  // Store the ASCII value of a space in the memory location pointed to by the UART_BASE address
		STR R10, [R0] // Store the ASCII value of a newline character in the memory location pointed to by the UART_BASE address to end the current row
		SUB R1, R1, #1   // Subtract 1 from the value in R1 to move to the next row
		CMP R1, #1       // Compare the value in R1 with 1 to check if the outer loop counter has reached its end condition
		BEQ print_last_star // Branch to the label that prints the last asterisk if the outer loop counter has reached
        B   loop2   
		
		
print_last_star:
	STR R8, [R0]  @ Print a space
	STR R8, [R0]  @ Print a space
	STR R8, [R0]  @ Print a space
	STR R8, [R0]  @ Print a space
	STR R9, [R0] // Print an asterisk
	B _stop

_stop:
B _stop

.end