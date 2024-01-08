/*
-------------------------------------------------------
Bonus Assignment
Q4 
-------------------------------------------------------
Author:  Cassel Robson
ID:      210507000
Email:   robs7000@mylaurier.ca
Date:    2023-03-31
-------------------------------------------------------
*/
// Define the UART_BASE address and SIZE of data block
.equ UART_BASE, 0xff201000 
.equ SIZE, 7

// Set the program counter to 0x1000 and start the text section
.org 0x1000
.text 

// Make the _start symbol global
.global _start 

// Define _start label
_start: 
	mov r0, #0   // Initialize r0-r5 to zero
	mov r1, #0
	mov r2, #0
	mov r3, #0
	mov r4, #0
	mov r5, #0
    LDR r0, =data_block    // Load the address of the data block into r0
    LDR r1, [r0]           // Load the first word of the data block into r1

LOOP1:
	cmp r5, #30    // Compare the value in r5 to 30
	bgt _stop      // If greater than 30, jump to _stop
 	mov r2, #1     // Set r2 to 1 (binary 01)
	AND r3, r2, r1 // AND the value in r1 with 01, store result in r3
	cmp r3, r2     // Compare r3 with r2
	beq single       // If r3 equals r2, jump to ones
	bne zeros      // If r3 does not equal r2, jump to zeros
triple:        // If r3 equals r2:
	lsl r2, #1     // Shift r2 one bit to the left (binary 100)
	add r2, #1     // Add 1 to r2 (binary 101)
	and r3, r2, r1 // AND the value in r1 with 101, store result in r3
	cmp r3, r2     // Compare r3 with r2
	beq toggleone // If r3 equals r2, jump to toggleone
	bne two_submit // If r3 does not equal r2, jump to two_submit
single:          // If r3 equals r2:
	lsl r2, #1     // Shift r2 one bit to the left (binary 10)
	add r2, #1     // Add 1 to r2 (binary 11)
	and r3, r2, r1 // AND the value in r1 with 11, store result in r3
	cmp r3, r2     // Compare r3 with r2

	beq triple     // If r3 equals r2, jump to triple
	bne one_insert // If r3 does not equal r2, jump to one_insert
one_insert:    // If r3 does not equal r2:
	add r4, #1     // Add 1 to r4
	ror r4, #1     // Rotate r4 one bit to the right
	lsr r1, #1     // Shift the value in r1 one bit to the right
	add r5,#1      // Add 1 to r5
	b LOOP1         // Jump to loop
two_submit:
	add r4, #3     // add 3 to the mask in r4
	ror r4, #2     // rotate the mask right by 2 bits
	lsr r1, #2     // shift the current word right by 2 bits, discarding the two least significant bits
	add r5,#2      // increment the loop counter by 2
	b LOOP1         // branch back to the start of the loop
zeros:
	mov r2, #2     // set r2 to 2 (binary 10)
	and r3, r2, r1 // perform a bitwise AND of r1 and r2, storing the result in r3
	cmp r3, r2     // compare the result with r2
	bne togglezero // if the two least significant bits of the current word are not both 0, branch to zerotoggle

	ror r4, #1     // rotate the mask right by 1 bit
	lsr r1, #1     // shift the current word right by 1 bit, discarding the least significant bit
	add r5,#1      // increment the loop counter by 1
	b LOOP1         // branch back to the start of the loop
toggleone:    // If r3 equals r2:
	add r4, #3     // Add 3 to r4
	ror r4, #3     // Rotate r4 three bits to the right
	lsr r1, #3     // Shift the value in r1 three bits to the right
	add r5,#3      // Add 3 to r5
	b LOOP1         // Jump to loop		
togglezero:
	add r4, #2     // add 2 to the mask in r4
	ror r4, #2     // rotate the mask right by 2 bits
	lsr r1, #2     // shift the current word right by 2 bits, discarding the two least significant bits
	add r5, #2     // increment the loop counter by 2
	b LOOP1         // branch back to the start of the loop
	
_stop:
B _stop          // branch to the _stop label and halt
.data
data_block:
.word 0xfac2310f


.end