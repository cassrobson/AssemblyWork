/*
-------------------------------------------------------
Bonus Assignment
Q3 
-------------------------------------------------------
Author:  Cassel Robson
ID:      210507000
Email:   robs7000@mylaurier.ca
Date:    2023-03-31
-------------------------------------------------------
*/
.equ UART_BASE, 0xff201000
.org 0x1004
.text
.global _start

_start:
	mov r6, #0x61   // Load character 'a' into r6
	mov r7, #0x62   // Load character 'b' into r7
	mov r8, #0x63   // Load character 'c' into r8

	ldr r0, =UART_BASE   // Load the UART_BASE address into r0
	ldr r1, =array       // Load the address of the 'array' variable into r1
	mov r12, #0          // Set r12 to 0 (will be used as an index)

Loop1:
	cmp r12, #32         // Compare r12 to 32
	beq _stop            // If r12 == 32, exit loop and go to _stop label
	ldr r2, [r1, r12]    // Load the first word of the array into r2
	mov r4, #0x80000000  // Set r4 to a bit mask for comparing the bits
	mov r5, #0           // Set r5 to 0 (will be used as a counter)

BitLOOP:
	and r9, r2, r4       // Compare the bit in r2 with the bit mask in r4
	cmp r9, #0
	beq zero_found       // If the bit is 0, go to zero_found label
	bne iterate          // If the bit is 1, go to iterate label

iterate:
	add r5, r5, #1       // Increase the 1's tally
	cmp r5, #3           // If the tally is already 3, go to print_c label
	beq print_c
	lsl r2, r2, #1       // Shift r2 to the next bit
	cmp r4, #0           // If all 4 bits in the word have been counted, go to the next word
	bne BitLOOP
	beq next_word

next_word:
	add r12, r12, #1     // Increase the index
	b Loop1

zero_found:
	lsl r2, r2, #1       // Shift r2 to the next bit
	b print_char

print_char:
	cmp r5, #1           // If the tally is 1, print 'a'
	beq print_a
	cmp r5, #2           // If the tally is 2, print 'b'
	beq print_b
	cmp r5, #3           // If the tally is 3, print 'c'
	beq print_c
	b BitLOOP            // If the tally is none of the above, go back to BitLOOP

print_a:
	strb r6, [r0]        // Write character 'a' to the UART
	mov r5, #0           // Reset the tally
	cmp r2, #0           // If all bits in the word have been counted, go to the next word
	bne BitLOOP
	beq next_word

print_b:
	strb r7, [r0]        // Write character 'b' to the UART
	mov r5, #0
	cmp r2, #0           // If all bits in the word have been counted, go to the next word
	bne BitLOOP
	beq next_word

print_c:
	strb r8, [r0]        // Write character 'c' to the UART
	mov r5, #0
	lsl r2, r2, #1       // Shift r2 to the next bit
	cmp r2, #0 //if all bits in the word have been counted, go to the next word
	bne BitLOOP
	beq next_word

_stop:
b _stop

.data
array:
.word 0xaeed76d6
endarray:
.end