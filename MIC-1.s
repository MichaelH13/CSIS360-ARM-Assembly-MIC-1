/* -- MIC-1.s */

.data

/* Result */
.balign 4
result: .asciz "%s\n"

.text

/* Addresses of variables */


/* Function Delcarations */
.global main

main:
	/* The name of the program to execute will be provided */
	/* as a command-line parameter. */
 	ldr r0, =result
 	ldr r1, [r1]
 	add r0, r1, #8
 	bl fopen
 	
 	mov r0, r1
 	ldr r0, =result
 	bl printf
 	
/* 	ldr r2, =result */
/* 	mov r0, r4 			; Counter */
/* 	ldr r0, =result     ; Printf */
/* 	bl printf */
/* 	sub r3, r3, #1	    ; Decrement counter */
    
	bx lr
	
	/* Open that file and read it byte-by-byte into an array */
	/* of bytes that will represent our memory. */
	
	/* The array should be larger than the program as it will */
	/* need to hold the call-stack for any methods as well. */
	
	/* First two bytes in the file is the number of local */
	/* variables for "main". That value determines where to */
	/* set the initial value of the stack pointer (SP) relative */
	/* to the local variable base pointer (LV). LV should point */
	/* to the index in the byte-array just beyond the last byte */
	/* of the program code. You need to compose a 16-bit value */
	/* for LV from these first two bytes (see below). */
	/* The first two bytes of the file are not part of the code. */


/* External */
.global printf
.global fopen


