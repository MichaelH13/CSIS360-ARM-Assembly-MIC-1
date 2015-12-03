/* -- MIC-1.s */

.data

/* Result */
.balign 4
result: .asciz "%#.2X\n"

.balign 4
here: .asciz "HERE %#.2X\n"

.balign 4
openMsg: .asciz "Op: %s\n"

.balign 4
readResult: .asciz "Read in: %d\n"

.balign 4
flags: .asciz "r"

.balign 4
memory: .skip 4096

.text

.macro _WR_
    ldr r1, =memory
    str mic1MDR, [r1, +mic1MAR]
.endm

.macro _RD_
    ldr r1, =memory
    ldr mic1MDR, [r1, +mic1MAR]
.endm

.macro _INC_PC_FETCH
    add mic1PC, #1
    ldr r0, =memory
    add r0, mic1PC
.endm

    /* Naming Registers */
    /* r2 is MAR    : Memory Address Register. */
    mic1MAR .req r2
    mov mic1MAR, #0
    
    /* r3 is MDR    : Memory Data Register. */
    mic1MDR .req r3
    mov mic1MDR, #0
    
    /* r4 is PC     : The current Program Counter for our machine. */
    mic1PC .req r4
    mov mic1PC, #0      /* PC starts at 0 */
    
    /* r5 is MBR    : Memory Byte Register. */
    mic1MBR .req r5
    mov mic1MBR, #0
    
    /* r6 is MBRU   : Memory Byte Register, unsigned. */
    mic1MBRU .req r6
    mov mic1MBRU, #0
    
    /* r7 is SP     : Stack Pointer. */
    /* loaded at time of reading file. */
    mic1SP .req r7
    mov mic1SP, #0
    
    /* r8 is LV     : Link Value. */
    mic1LV .req r8
    mov mic1LV, #0
    
    /* r9 is CPP    : Constant Pool Pointer. */
    mic1CPP .req r9
    mov mic1CPP, #0
    
    /* r10 is TOS   : Top Of Stack. */
    mic1TOS .req r10
    mov mic1TOS, #0
    
    /* r11 is OPC   : Old PC. */
    mic1OPC .req r11
    mov mic1OPC, #0
    
    /* r12 is H     : Scratch register for loading when told to. */
    mic1H .req r12
    mov mic1H, #0

    /* Addresses of variables */


    /* Function Delcarations */
.global main

main:
	/* The name of the program to execute will be provided */
	/* as a command-line parameter. */
	push {lr}
	
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
 	
 	ldr r0, =memory       /* store pointer to memory in r0 */
 	mov r1, #1          /* store 1 in r1 (read chunks of 1 byte) */
 	ldr r2, =4096       /* store 8 in r2 (read 8 chunks of 1 byte) */
 	mov r3, r4          /* store FILE in r3, read from FILE */
 	bl fread            /* read 8 bytes from FILE into memory array */
 	
 	mov r7, r0          /* store # of bytes read in at r7, SP essentially */
 	
 	mov r6, #0          /* zero-out our counter */
    
 printMemory:
    /* Print using printf */
    /*ldr r1, =memory
    add r1, r6
    ldrb r1, [r1]
    
    ldr r0, =result
    bl printf
    add r6, #1
    cmp r6, r7
    bllt printMemory*/
 	
 	/* Make sure we are starting at 0 */
 	mov mic1PC, #0
 	mov mic1MAR, #0
 	mov mic1MBR, #0
 	
 main1:
    /* load first byte */
    /*ldr r1, =memory
    add r1, #2
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf*/
    /**/
    
    /* fetch byte instruction. */
    ldr r0, =memory
    add r0, mic1PC
    mov mic1MAR, r0
    ldrb mic1MBR, [mic1MAR]
    
    /* decode/execute */
    cmp mic1MBR, #0x10
    beq bipush
    cmp mic1MBR, #0x59
    beq dup
    cmp mic1MBR, #0xA7
    beq goto
    cmp mic1MBR, #0x60
    beq iadd
    cmp mic1MBR, #0x00
    beq nop
    cmp mic1MBR, #0xA9
    beq ret
    cmp mic1MBR, #0x7E
    beq iand
    cmp mic1MBR, #0x99
    beq ifeq
    cmp mic1MBR, #0x9B
    beq iflt
    cmp mic1MBR, #0x9F
    beq if_icmpeq
    cmp mic1MBR, #0x84
    beq iinc
    cmp mic1MBR, #0x15
    beq iload
    cmp mic1MBR, #0xA8
    beq jsr
    cmp mic1MBR, #0x80
    beq ior
    cmp mic1MBR, #0x36
    beq istore
    cmp mic1MBR, #0x64
    beq isub
    cmp mic1MBR, #0x57
    beq pop
    cmp mic1MBR, #0x5F
    beq swap
 
 end:
 	pop {lr}
 	/* print TOS, then exit
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf */
	bx lr
	
bipush:
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    b main1
    
dup:
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    b main1

goto:
    /*print goto*/
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    
    /*offset*/
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    b main1
    
iadd:
     sub mic1SP, mic1SP, #4        @MAR = SP = SP - 1
     mov mic1MAR, mic1SP
     mov mic1H, mic1TOS            @mic1H = TOS
     _RD_                          @TOS = MDR + H
     add mic1TOS, mic1MDR, mic1H
     mov mic1MDR, mic1TOS          @ MDR = TOS
     _WR_
     b main1

iand:
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    add mic1PC, #1
    b main1
    
ifeq:
    /*print ifeq*/
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    
    /*offset*/
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    b main1
    
iflt:
    /*print iflt*/
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    
    /*print offset*/
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    b main1
    
if_icmpeq:
    /*print if_icmpeq*/
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    
    /*print offset*/
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    b main1   
    
iinc:
    /*print iinc*/
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    
    /*print varnum*/
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    
    /*print const*/
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    b main1
    
iload:
    /*print iload*/
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    
    /*print varnum*/
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1

    b main1
    
jsr:
    /*print jsr*/
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    
    /*print disp*/
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    
    b main1

ior:
    /*print ior*/
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    add mic1PC, #1
    b main1
    
istore:
    /*print istore*/
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1
    
    /*print varnum*/
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    
    add mic1PC, #1

    b main1
    
isub:
    /*print isub*/
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    add mic1PC, #1
    b main1
    
nop:
    /*print nop*/
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    add mic1PC, #1
    b main1
    
pop:
    /*print pop*/
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    add mic1PC, #1
    b main1
    
swap:
    /*print swap*/
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    add mic1PC, #1
    b main1

ret:
    ldr r1, =memory
    add r1, mic1PC
    ldrb r1, [r1]
    
    ldr r0, =here
    bl printf
    b end
	
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

