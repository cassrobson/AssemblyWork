// Assignment 2
//Cassel Robson, StudentID: 210507000
 

// Constants

.equ UART_BASE, 0xff201000     // UART base address

.equ MASK, 0x0F

.equ DIGIT, 0x30

.equ LETTER, 0x37

.org    0x1000    // Start at memory location 1000

.text  // Code Section

.global _start

_start:
ldr r5, =Array //assign start of array to r5
ldr r6, =endArray //assign end of array to r6
mov r7, #1//mask 1
mvn r8, #0 //set r8 to 0
mov r9, #1 //set r9 to 1
ror r9, #1// mask2

loopB:
    ldr r10, [r5], #4 //load address of array to r10
    cmp r10, r7 //compare r10 with r7
    beq loop1 //if r10 less than r7 go to loop1
    cmp r10, r8 //if r10 less than r8 go to loop2
    beq loop2
    b forward //otherwise forward
    loop1:
        str r8, [r5, #-4]
        orr r4, r9
        b forward //go to forward loop after process in loop2
    loop2:
        str r7, [r5, #-4]
        mvn r11, r9
        and r4, r11
        b forward //go to forward loop after process in loop2
    forward:
    ror r9, #1
    cmp r5,r6
    bne  loopB


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
.data // Initialize data section 
Array:
.word -15, 15, 1, 2, -1, -2, -13, -14, -99, 12, 13, 1, 2, -1, -2, -3
endArray: 

.end