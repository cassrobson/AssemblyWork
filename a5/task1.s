/*
-------------------------------------------------------
Assignment 5
-------------------------------------------------------
Author:  Cassel Robson
ID:      210507000
Email:   robs7000@mylaurier.ca
Date:    2023-04-04
-------------------------------------------------------
*/
.org    0x1000    // Start at memory location 1000
.equ UART_BASE, 0xff201000 
.equ N, 11
.text

.global _start
_start:
    ldr r0, =arr    // Load address of array arr into register r0
    ldr r1, =N      // Load the value of constant N into register r1
    bl buildHeap     // Call the function buildHeap

stop:
    b stop           // Infinite loop to halt execution

heapify:
    stmfd sp!, {fp, lr}     // Save frame pointer and return address on stack
    mov fp, sp              // Set frame pointer to current stack pointer
    stmfd sp!, {r4-r7, r11, r8}    // Save registers r4-r7, r11, r8 on stack

    ldr r4, [fp, #8]     // Load variable i from stack
    ldr r5, [fp, #12]      // Load array arr from stack
    ldr r6, [fp, #16]     // Load constant N from stack

    lsl r7, r4, #1        // Shift left i by 1 (equivalent to multiplication by 2)
    add r7, r7, #1        // Add 1 to 2*i to get index of left child node
    lsl r8, r4, #1        // Shift left i by 1
    add r8, r8, #2        // Add 2 to 2*i to get index of right child node

    ldr r9, [r5, r7, lsl #2]    // Load value of left child node
    ldr r10, [r5, r8, lsl #2]   // Load value of right child node

    cmp r7, r6            // Compare left child index with N
    bge exit1             // If left child index >= N, exit heapify function
    lsl r3, r4, #2        // Shift left i by 2 (equivalent to multiplication by 4)
	ldr r9, [r5, r3]      // Load value of parent node
	cmp r9, #0            // Compare parent node value with 0
    ble largest_is_i      // If parent node value <= 0, jump to largest_is_i label
    mov r11, r7           // Set r11 to index of left child node
    b compare_r10         // Jump to compare_r10 label

largest_is_i:
    mov r11, r4           // Set r11 to index of parent node
    cmp r8, r6            // Compare right child index with N
    bge exit1             // If right child index >= N, exit heapify function
    lsl r3, r4, #2        // Shift left i by 2
	ldr r10, [r5, r3]     // Load value of parent node
	cmp r10, #0           // Compare parent node value with 0
    ble exit1             // If parent node value <= 0, exit heapify function
    b compare_r10         // Jump to compare_r10 label

compare_r10:
    cmp r10, r9           // Compare value of right child node with left child node
    bgt swap              // If right child node value > left child node value, jump to swap label
    b exit1              // Else, exit heapify

swap:
    str r10, [r5, r4, lsl #2]   // arr[i] = r10
    str r9, [r5, r11, lsl #2]   // arr[largest] = r9
    mov r4, r11                // i = largest

exit1:
    ldmfd sp!, {r4-r7, r11, r8} // pop registers
    ldmfd sp!, {fp, pc}         // pop function call and return

buildHeap:
    stmfd sp!, {fp, lr}    // push frame pointer and return address
    mov fp, sp             // set frame pointer
    stmfd sp!, {r4-r6}     // push registers

    ldr r4, [fp, #8]       // arr pointer
    ldr r5, [fp, #12]      // N
    mov r6, r5
    lsr r6, #1             // startIdx = N // 2 - 1

    mov r4, r4, lsl #2     // Multiply by 4 to get byte offset
    sub r4, r4, #4         // arr[startIdx] is at arr[startIdx-1]

buildHeapLoop:
    cmp r6, #0             // while startIdx >= 0
    blt exit2              //   exit loop
    sub r6, r6, #1         //   decrement startIdx
    bl heapify             //   heapify subtree rooted at startIdx
    b buildHeapLoop        // end loop

exit2:
    ldmfd sp!, {r4-r6}     // pop registers
    ldmfd sp!, {fp, pc}    // pop function call and return

.data
arr:
    .word 1, 3, 5, 4, 6, 13, 10, 9, 8, 15, 17
	
.end