/*
-------------------------------------------------------
find_common.s
Working with stack frames.
-------------------------------------------------------
Author:Cassel Robson
ID:210507000
Email:robs7000@mylaurier.ca
Date:    2023-03-23
-------------------------------------------------------
*/
// Constants
.equ SIZE, 80

.org    0x1000    // Start at memory location 1000
.text  // Code section
.global _start
_start:

// push parameters onto the stack
LDR r3, =SIZE //load SIZE into r3
STMFD SP!, {r3} //push SIZE onto the stack

LDR r2, =common //load common result into r2
STMFD SP!, {r2} //push common result onto the stack

LDR r1, =second //load second string into r1
STMFD SP!, {r1} //push second onto the stack

LDR r0, =first //load first string into r0
STMFD SP!, {r0} //push first onto the stack


BL     FindCommon

// clean up the stack
ADD SP, SP, #12

_stop:
B      _stop

//-------------------------------------------------------
FindCommon:
/*
-------------------------------------------------------
Equivalent of: FindCommon(*first, *second, *common, size)
Finds the common parts of two null-terminated strings from the beginning of the
strings. Example:
first: "pandemic"
second: "pandemonium"
common: "pandem", length 6
-------------------------------------------------------
Parameters:
  first - pointer to start of first string
  second - pointer to start of second string
  common - pointer to storage of common string
  size - maximum size of common
Uses:
  R0 - address of first
  R1 - address of second
  R2 - address of common
  R3 - value of max length of common
  R4 - character in first
  R5 - character in second
-------------------------------------------------------
*/

// set up stack
STMFD SP!, {FP, LR} //push frame pointer and link register
MOV FP, SP
STMFD SP!, {r0-r1, r3-r5} //push other registers onto stack
// extract parameters

LDR r0, [FP, #8] //load address of first string to r0
LDR r1, [FP, #12] //load address of second string to r1
LDR r2, [FP, #16] //load address of common to r2
LDR r3, [FP, #20] //load SIZE of common to r3

FCLoop:
CMP    R3, #1          // is there room left in common?
BEQ    _FindCommon     // no, leave subroutine
LDRB   R4, [R0], #1    // get next character in first
LDRB   R5, [R1], #1    // get next character in second
CMP    R4, R5
BNE    _FindCommon     // if characters don't match, leave subroutine
CMP    R5, #0          // reached end of first/second?
BEQ    _FindCommon
STRB   R4, [R2], #1    // copy character to common
SUB    R3, R3, #1      // decrement space left in common
B      FCLoop

_FindCommon:
MOV    R4, #0
STRB   R4, [R2]        // terminate common with null character

// clean up stack
LDMFD SP!, {r0-r1, r3-r5}
LDMFD SP!, {FP, PC}
//-------------------------------------------------------
.data
first:
.asciz "pandemic"
second:
.asciz "pandemonium"
common:
.space SIZE

.end