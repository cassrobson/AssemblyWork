//Assignment3
//Cassel Robson: 210507000

// Constants

.equ UART_BASE, 0xff201000     // UART base address

.equ MASK, 0x0F

.equ DIGIT, 0x30

.equ LETTER, 0x37

.org    0x1000    // Start at memory location 1000

.text  // Code Section

.global _start

_start:
	LDR r8, =Array //assign start of Array to r8
	LDR r9, =endArray //assign end of Array to r9
	MOV r5, #0x80000000 //store in r5
LOOP:
    LDR r10, [r8] //load address of array into r10
    LSLS r3, r10, #1 //left shift 1
    BCS stop
    b forward
stop:
    ORR r4, r5 
forward:
    LSR r5, #1 //right shift
    ADD r8, r8, #4 //iterate to next value in array
    CMP r8, r9 //compare r8 to end of array
    BNE LOOP
 

// Print R4 to UART as ASCII

LDR R0, =UART_BASE

MOV R1,#8

// Print the register contents as ASCII characters

// Assumes value to print is in R4, UART address in R0

// Uses R1 for counter and R2 for temporary value

// R0 and R4 are preserved

TOP:

ROR R4,#28            // Rotate next four bits to LSB

MOV R2,R4            // Copy to R2 for masking

AND R2,R2,#MASK       // Keep last 4 bits only

CMP R2,#9            // Compare last 4 bits to 9

ADDLE R2,R2,#DIGIT    // add ASCII coding for 0 to 9

ADDGT R2,R2,#LETTER   // add ASCII coding for A to F

STR R2,[R0]           // Copy ASCII byte to UART

SUB R1,#1            // Move to next byte

CMP r1,#0            // Compare the countdown value to 0

BGT TOP              // Branch to TOP if greater than 0

 

_stop:

B    _stop
.data
Array:
.word -15, 15, 1, 2, -1, -2, -13, -14, -99, 12, 13, 1, 2, -1, -2, -3
endArray: 

.end