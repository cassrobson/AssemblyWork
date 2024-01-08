// Constants
.equ UART_BASE, 0xff201000     // UART base address
.equ SIZE, 80        // Size of string buffer storage (bytes)
.equ VALID, 0x8000   // Valid data in UART mask
.org    0x1000       // Start at memory location 1000
.text  // Code section
.global _start
_start:

// read a string from the UART
LDR  r1, =UART_BASE
LDR  r4, =READ_STRING

ADD  r5, r4, #SIZE // store address of end of buffer

LOOP:
CMP r4, #0x0a //check for enter key
BEQ exit //jump to exist if Enter key is pressed
LDR  r0, [r1]  // read the UART data register
TST  r0, #VALID    // check if there is new data
BEQ  _stop         // if no data, return 0
STRB r0, [r4] // store the character in memory
ADD  r4, r4, #1    // move to next byte in storage buffer
CMP  r4, r5        // end program if buffer full
BEQ  _stop

//writing section
LDRB r0, [r4] //load a single byte from the string
CMP r0, #0
BEQ _stop //stop when the null character is found
STR r0, [r1] //copy the character to the UART DATA field
ADD r4, r4, #1 //move to next character in memory
B    LOOP
exit:
	MOV r7, #1
	MOV r0, #0
	SVC #0
_stop:
B    _stop

.data  // Data section
// Set aside storage for a string
READ_STRING:
.space    SIZE

.end