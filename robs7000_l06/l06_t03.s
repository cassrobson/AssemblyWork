/*
-------------------------------------------------------
sub_read.s
Uses a subroutine to read strings from the UART into memory.
-------------------------------------------------------
Author:  Cassel Robson
ID:      210507000
Email:   robs7000@mylaurier.ca
Date:    2023-03-11
-------------------------------------------------------
*/
// Constants
.equ SIZE, 20    	// Size of string buffer storage (bytes)
.text  // Code section
.org	0x1000	// Start at memory location 1000
.global _start
_start:

MOV    R5, #SIZE
LDR    R4, =First
BL	   ReadString
LDR    R4, =Second
BL	   ReadString
LDR    R4, =Third
BL     ReadString
LDR    R4, =Last
BL     ReadString
    
_stop:
B	_stop

// Subroutine constants
.equ UART_BASE, 0xff201000     // UART base address
.equ VALID, 0x8000	// Valid data in UART mask
.equ DATA, 0x00FF	// Actual data in UART mask
.equ ENTER, 0x0A	// End of line character
ReadString:
/*
-------------------------------------------------------
read_string.s
Reads a string from the UART
-------------------------------------------------------
Author:  Cassel Robson
ID:      210507000
Email:   robs7000@mylaurier.ca
Date:    2023-03-11
-------------------------------------------------------
*/
STMFD SP!, {R0-R1, R4, R5, LR}
// read a string from the UART
LDR  R1, =UART_BASE
ADD  R5, R4, #SIZE // store address of end of buffer
        
		
		
LOOP:
LDRB  R0, [R1]  // load the UART data register in R0

CMP R0, #ENTER //Check if the value stored in R0 matches the ENTER character hexidecimal value
BEQ String 

STRB R0, [R4]	//Store character in r4 in memory location pointed to by r0
STRB R0, [R1]      //Store character in r1 in memory located pointed to by r0
ADD  R4, R4, #1    //increment r4, move to the next byte

CMP  R4, R5   //If the buffer is full, end the program     
BEQ  String
B    LOOP


String:
/*
-------------------------------------------------------
Reads an ENTER terminated string from the UART.
-------------------------------------------------------
Parameters:
  R4 - address of string buffer
  R5 - size of string buffer
Uses:
  R0 - holds character to print
  R1 - address of UART
-------------------------------------------------------
*/
LDR R0,=ENTER //add an enter after the string is processed
STR R0, [R1] //store address of UART in register that holds the character to print
LDMFD SP!, {R0-R1, r4,r5,PC}
	
	
	
.data
.align
// The list of strings
First:
.space  SIZE
Second:
.space	SIZE
Third:
.space	SIZE
Last:
.space	SIZE
_Last:    // End of list address

.end
	
	
	