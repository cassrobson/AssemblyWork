/*
-------------------------------------------------------
palindrome.s
Subroutines for determining if a string is a palindrome.
-------------------------------------------------------
Author: Cassel Robson
ID: 210507000
Email: robs7000@mylaurier.ca
Date: March 16, 2023
-------------------------------------------------------
*/
.org    0x1000    // Start at memory location 1000
.text  // Code section
.global _start
_start:

LDR    R4, =test1
LDR    R5, =_test1 - 2
BL     PrintString
BL     PrintEnter
BL     Palindrome
LDR    R4, =palindromeStr
BL     PrintString
BL     PrintTrueFalse
BL     PrintEnter
LDR    R4, =test2
LDR    R5, =_test2 - 2
BL     PrintString
BL     PrintEnter
BL     Palindrome
LDR    R4, =palindromeStr
BL     PrintString
BL     PrintTrueFalse
BL     PrintEnter
LDR    R4, =test3
LDR    R5, =_test3 - 2
BL     PrintString
BL     PrintEnter
BL     Palindrome
LDR    R4, =palindromeStr
BL     PrintString
BL     PrintTrueFalse
BL     PrintEnter

LDR    R4, =test4
LDR    R5, =_test4 - 2

BL     PrintString

BL     PrintEnter
BL     Palindrome
LDR    R4, =palindromeStr
BL     PrintString
BL     PrintTrueFalse
BL     PrintEnter
_stop:
B    _stop



// Constants
.equ UART_BASE, 0xff201000     // UART base address
.equ ENTER, 0x0a     // enter character
.equ VALID, 0x8000   // Valid data in UART mask
.equ DIFF, 'a' - 'A' // Difference between upper and lower case letters


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
LDR    R1, =UART_BASE   // Load UART base address
STRB   R2, [R1]         // copy the character to the UART DATA field
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
MOV    R2, #ENTER
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
MOVEQ  R2, #'F'         // output F
MOVNE  R2, #'T'         // output T
BL     PrintChar
LDMFD  SP!, {R2, PC}


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
MOV    R0, #0           // false is default value
CMP    R2, #'a'
BLT    _isLowerCase // less than 'a', False
CMP    R2, #'z'
MOVLE  R0, #1     // less than or equal to 'z', return True
_isLowerCase:
MOV    PC, LR


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
BLT    _isUpperCase   // less than 'A',  False
CMP    R2, #'Z'
MOVLE  R0, #1    // less than or equal to 'Z', True
_isUpperCase:
MOV    PC, LR

toLower:
/*
-------------------------------------------------------
Converts a character to lower case.
-------------------------------------------------------
Parameters
  R2 - character to convert
Returns:
  R2 - lowercase version of character
-------------------------------------------------------
*/
STMFD  SP!, {LR}
BL     isUpperCase      // test for upper case
CMP    R0, #0
ADDNE  R2, #DIFF        // Convert to lower case
LDMFD  SP!, {PC}


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

Palindrome:
/*
-------------------------------------------------------
Determines if a string is a palindrome.
-------------------------------------------------------
Parameters
  R4 - address of first character of string to test
  R5 - address of last character of string to test
Uses:
  R? - ?
Returns:
  R0 - returns True (1) if palindrome, False (0) otherwise
-------------------------------------------------------
*/

STMFD     SP!, {R4-R7, LR}

MOV     R0, #0
CMP     R4, R5
MOVGE     R0, #1
CMP     R0, #1
BEQ     _Palindrome // end if true

//left side
LDRB     R2, [R4]      
BL         isLetter
CMP     R0, #0
ADDEQ     R4, #1        
BLEQ     Palindrome    
BEQ     _Palindrome

//right side
LDRB     R2, [R5]      
BL         isLetter
CMP     R0, #0  
SUBEQ     R5, #1        
BLEQ     Palindrome    
BEQ     _Palindrome

//lower case both sides
LDRB     R2, [R4]      
BL         toLower
MOV     R6, R2
LDRB     R2, [R5]      
BL         toLower
MOV     R7, R2

CMP     R6, R7
ADDEQ     R4, #1
SUBEQ     R5, #1
BLEQ     Palindrome

MOVNE     R0, #0        
BNE     _Palindrome

_Palindrome:
LDMFD SP!, {R4-R7, PC}



.data
palindromeStr:
.asciz "pal: "
test1:
.asciz "Kayak"
_test1:
test2:
.asciz "rotor"
_test2:
test3:
.asciz "Cassel"
_test3:
test4:
.asciz "A man, a anama!"
_test4:

.end