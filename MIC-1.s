/* -- MIC-1.s */

.data

/* Result */
.balign 4
result: .asciz "%#.2X\n"

.balign 4
openMsg: .asciz "Op: %s\n"

.balign 4
readResult: .asciz "Read in: %d\n"

.balign 4
flags: .asciz "r"

.balign 4
data: .skip 4096

.balign 4
data_size: .word 0

.text

/* Addresses of variables */


/* Function Delcarations */
.global main

main:
	/* The name of the program to execute will be provided */
	/* as a command-line parameter. */
	mov r12, lr
	
	/*prints "Op: simple (arg number 2)"
	ldr r0, =openMsg 
	ldr r1, [r1]
	add r1, #8
	bl printf */
	
	/* Using fopen: */
	ldr r1, [r1]
 	add r0, r1, #8
 	ldr r1, =flags
 	bl fopen
 	
 	mov r4, r0          /* store FILE in r4 */
 	mov r1, r0          /* move FILE to r1 */
 	ldr r0, =readResult /* load result into r0 for printf */
 	bl printf           /* call printf */
 	mov r0, r4          /* put FILE back into r0 */
 	
 	ldr r0, =data       /* store pointer to data in r0 */
 	mov r1, #1          /* store 1 in r1 (read chunks of 1 byte) */
 	ldr r2, =4096       /* store 8 in r2 (read 8 chunks of 1 byte) */
 	mov r3, r4          /* store FILE in r3, read from FILE */
 	bl fread            /* read 8 bytes from FILE into data array */
 	
 	mov r7, r0          /* store # of bytes read in at r7, SP essentially */
 	
 	mov r6, #0          /* zero-out our counter */
    
 printData:
    /* Print using printf */
    ldr r1, =data
    add r1, r6
    ldr r1, [r1]
    
    /* trims to just the "right most" byte */
    lsl r1, r1, #24
    lsr r1, r1, #24
    
    ldr r0, =result
    bl printf
    add r6, #1
    cmp r6, r7
    bllt printData
 	
 	/* r4 is MAR    : Memory Address Register. */
    
    /* r5 is MDR    : Memory Data Register. */
    mov r5, #0
    
    /* r6 is PC     : The current Program Counter for our machine. */
    mov r6, #0      /* PC starts at 0 */
    
    /* r6 is MBR    : Memory Byte Register? */
    /* use later */
    
    /* r7 is SP     : Stack Pointer. */
    /* loaded at time of reading file. */
    
    /* r8 is LV     : Link Value. */
    /* use later */
    
    /* r9 is CPP    : Constant Pool Pointer. */
    /* use later */
    
    /* r10 is TOS   : No idea? */
    /* use later */
    
    /* r11 is OPC   : No idea? */
    /* use later */
    
    /* r12 is H     : No idea? */
    /* use later */
 	
 main1:
 
    /* fetch */
    ldr r0, =data
    add r0, r6
    ldr r0, [r0]
    
    add r4, r0, r6      /* store MAR = PC + address_of_data */
    ldr r5, [r4]        /* store MDR = *MAR */
    
    /* trims to just the "right most" byte */
    lsl r0, r0, #24
    lsr r0, r0, #24
    
    /* decode/execute */
    
    
 	
 	mov lr, r12
    
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
.global fread
.global fclose

