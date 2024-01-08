/*
-------------------------------------------------------
sub_demo.s
Demonstrates the use of a subroutine to print to the UART.
-------------------------------------------------------
Author:  Cassel Robson
ID:      210507000
Email:   robs7000@mylaurier.ca
Date:    2023-03-11
-------------------------------------------------------
*/
.org    0x1000    // Start at memory location 1000
.text  // Code section
.global _start
_start:

LDR R4, =First
BL  PrintString
LDR R4, =Second
BL  PrintString
LDR R4, =Third
BL  PrintString
LDR R4, =Last
BL  PrintString

_stop:
B    _stop

// Subroutine constants
.equ UART_BASE, 0xff201000     // UART base address

PrintString:
/*
-------------------------------------------------------
Prints a null terminated string.
-------------------------------------------------------
Parameters:
  R4 - address of string
Uses:
  R0 - holds character to print
  R1 - address of UART
-------------------------------------------------------
*/
STMFD  SP!, {R0-R1, R4, LR}
LDR R1, =UART_BASE
MOV R2, #0x0A //Load ASCII value for end of line character

psLOOP:
LDRB R0, [R4], #1   // load a single byte from the string
CMP  R0, #0
BEQ  _PrintString   // stop when the null character is found
STR  R0, [R1]       // copy the character to the UART DATA field
B    psLOOP
_PrintString:
STR R2, [R1] //write end of line character to UART
LDMFD  SP!, {R0-R1, R4, PC}


.data
.align
// The list of strings
First:
.asciz  "First string"
Second:
.asciz  "Second string"
Third:
.asciz  "Third string"
Last:
.asciz  "Last string"
_Last:    // End of list address

.end