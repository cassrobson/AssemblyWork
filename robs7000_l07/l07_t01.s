/*
-------------------------------------------------------
characters.s
Subroutines for working with characters.
-------------------------------------------------------
Author:  Cassel Robson
ID:      210507000
Email:   robs7000@mylaurier.ca
Date:    2023-03-16
-------------------------------------------------------
*/
.org    0x1000    // Start at memory location 1000
.text  // Code section
.global _start
_start:

// Type a character into the UART to test
BL  ReadChar
MOV R2, R0
LDR R4, =characterStr
BL  PrintString
BL  PrintChar
BL  PrintEnter

LDR R4, =isLetterStr
BL  PrintString
BL  isLetter
BL  PrintTrueFalse
BL  PrintEnter

LDR R4, =isLowerStr
BL  PrintString
BL  isLowerCase
BL  PrintTrueFalse
BL  PrintEnter

LDR R4, =isUpperStr
BL  PrintString
BL  isUpperCase
BL  PrintTrueFalse
BL  PrintEnter

_stop:
B    _stop

// Constants
.equ UART_BASE, 0xff201000     // UART base address
.equ ENTER, 0x0a     // enter character
.equ VALID, 0x8000   // Valid data in UART mask


ReadChar:
/*
-------------------------------------------------------
Reads single character from UART.
-------------------------------------------------------
Uses:
  R1 - address of UART
Returns:
  R0 - value of character, null if UART Read FIFO empty
-------------------------------------------------------
*/
STMFD  SP!, {R1, LR}
LDR    R1, =UART_BASE   
LDR    R0, [R1]         
TST    R0, #VALID       
MOVEQ  R0, #0           
ANDNE  R0, R0, #0x00FF  
_ReadChar:
LDMFD  SP!, {R1, PC}


PrintChar:
/*
-------------------------------------------------------
Prints single character to UART.
-------------------------------------------------------
Parameters:
  R2 - address of character to print
Uses:
  R1 - address of UART
-------------------------------------------------------
*/
STMFD  SP!, {R1, LR}
LDR    R1, =UART_BASE  
STRB   R2, [R1]         
LDMFD  SP!, {R1, PC}


PrintEnter:
/*
-------------------------------------------------------
Prints the ENTER character to the UART.
-------------------------------------------------------
Uses:
  R2 - holds ENTER character
-------------------------------------------------------
*/
STMFD  SP!, {R2, LR}
MOV    R2, #ENTER       // Load ENTER character
BL     PrintChar
LDMFD  SP!, {R2, PC}


PrintString:
/*
-------------------------------------------------------
Prints a null terminated string to the UART.
-------------------------------------------------------
Parameters:
  R4 - address of string
Uses:
  R1 - address of UART
  R2 - current character to print
-------------------------------------------------------
*/
STMFD  SP!, {R1-R2, R4, LR}
LDR    R1, =UART_BASE
psLOOP:
LDRB   R2, [R4], #1     
CMP    R2, #0           
BEQ    _PrintString     
STRB   R2, [R1]         
B      psLOOP
_PrintString:
LDMFD  SP!, {R1-R2, R4, PC}

PrintTrueFalse:
/*
-------------------------------------------------------
Prints "T" or "F" as appropriate
-------------------------------------------------------
Parameter
  R0 - input parameter of 0 (false) or 1 (true)
Uses:
  R2 - 'T' or 'F' character to print
-------------------------------------------------------
*/
STMFD  SP!, {R2, LR}
CMP    R0, #0           // Is R0 False?
MOVEQ  R2, #'F'         // load "False" message
MOVNE  R2, #'T'         // load "True" message
BL     PrintChar
LDMFD  SP!, {R2, PC}

isUpperCase:
/*
-------------------------------------------------------
Determines if a character is an upper case letter.
-------------------------------------------------------
Parameters
  R2 - character to test
Returns:
  R0 - returns True (1) if upper case, False (0) otherwise
-------------------------------------------------------
*/
MOV    R0, #0           // default False
CMP    R2, #'A'
BLT    _isUpperCase     // less than 'A', return False
CMP    R2, #'Z'
MOVLE  R0, #1           // less than or equal to 'Z', return True
_isUpperCase:
MOV    PC, LR

isLowerCase:
/*
-------------------------------------------------------
Determines if a character is a lower case letter.
-------------------------------------------------------
Parameters
  R2 - character to test
Returns:
  R0 - returns True (1) if lower case, False (0) otherwise
-------------------------------------------------------
*/
MOV    R0, #0           // default False
CMP    R2, #'a'
BLT    _isLowerCase     // less than 'a', return False
CMP    R2, #'z'
MOVLE  R0, #1           // less than or equal to 'z', return True
_isLowerCase:
MOV    PC, LR

isLetter:
/*
-------------------------------------------------------
Determines if a character is a letter.
-------------------------------------------------------
Parameters
  R2 - character to test
Returns:
  R0 - returns True (1) if letter, False (0) otherwise
-------------------------------------------------------
*/

STMFD  SP!, {LR} //keep link register
BL     isLowerCase      // test for lowercase
CMP    R0, #0
BLEQ   isUpperCase      // not lowercase? Test for uppercase.
LDMFD  SP!, {PC}

.data
characterStr:
.asciz "char?: "
isLetterStr:
.asciz "is it a letter?: "
isLowerStr:
.asciz "lowercase?: "
isUpperStr:
.asciz "uppercase?: "
_Data:

.end