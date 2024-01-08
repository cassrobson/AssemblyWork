/*
-------------------------------------------------------
Assignment 4
Q2
-------------------------------------------------------
Author:  Cassel Robson
ID:      210507000
Email:   robs7000@mylaurier.ca
Date:    2023-04-01
-------------------------------------------------------
*/

.equ INPUT, 10  // num. of fibonacci terms to compute

// Start at memory location 1000
.org 0x1000

// Code Section
.text

// Declare '_start' as a global symbol
.global _start

// Start of program execution
_start:
	MOV r0, #0 // set return value to 0
	MOV r1, #INPUT // set input parameter to 10
	// Call the function Fibonacci
	BL Fibonacci
	// Infinite loop
_stop:
B _stop
// Fibonacci function definition
Fibonacci:
	// Save registers to the stack
	STMFD sp!, {r1-r3,r6, lr}
	// Base case: if n <= 1, return n
	CMP r1, #1
	MOV r0, r1
	BLE _endFibonacci
	B otherwise
	// Recursive case: r0 = Fibonacci(n-1) + Fibonacci(n-2)
otherwise:
	SUB r2, r1, #1 // Fibonacci(n-1) stored in r2
	SUB r3, r1, #2 // Fibonacci(n-2) stored in r3
	MOV r1, r2
	BL Fibonacci // recursive call with n-1
	MOV r6, r0 // save result of recursive call
	MOV r1, r3
	BL Fibonacci // recursive call with n-2
	ADD r0, r6, r0 // add results of recursive calls
_endFibonacci:
// Restore registers from the stack
LDMFD sp!, {r1-r3,r6, pc}
// Data Section
.data

// End of program
.end
	