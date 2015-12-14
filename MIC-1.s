/* -- MIC-1.s */

.data

.balign 4
returnValue: .asciz "%d\n"

.balign 4
flags: .asciz "r"

.balign 4
memory: .skip 4096

.text

/* Macro for writing to memory. */
.macro _WR_
    ldr r1, =memory
    str mic1MDR, [r1, +mic1MAR]
.endm

/* Macro for reading from memory. */
.macro _RD_
    ldr r1, =memory
    ldr mic1MDR, [r1, +mic1MAR]
.endm

/* Macro to increment the PC and fetch the next instruction. */
.macro _INC_PC_FETCH
    add mic1PC, #1                  @ PC    = PC + 1
    ldr r1, =memory                 @ r1    = &memory
    add mic1MAR, mic1PC, r1         @ MAR   = PC + r1
    ldrb mic1MBRU, [mic1MAR]        @ MBRU  = *MAR
    ldrsb mic1MBR, [mic1MAR]        @ MBR   = *MAR
.endm

    /* Naming/Initializing Registers. Initialize to 0. */
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
    
    /* r6 is MBRU   : Memory Byte Register Unsigned. */
    mic1MBRU .req r6
    mov mic1MBRU, #0
    
    /* r7 is SP     : Stack Pointer. */
    /* loaded at time of reading file. */
    mic1SP .req r7
    mov mic1SP, #0
    
    /* r8 is LV     : Local Vars. */
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

    /* Function Delcarations */
.global main

main:
	/* The name of the program to execute will be provided */
	/* as a command-line parameter. */
	push {lr}
	
	@ Open file using fopen.
	ldr r1, [r1]                    @ load pointer to first arg into memory.
 	add r0, r1, #8                  @ increment pointer and store in r0
 	ldr r1, =flags                  @ set flags to open
 	bl fopen                        @ open file, seg-v if no file present
 	
 	mov r4, r0                      @ store FILE in r4
 	ldr r0, =memory                 @ store pointer to memory in r0
 	mov r1, #1                      @ store 1 in r1 (read chunks of 1 byte)
 	ldr r2, =4096                   @ store 4096 in r2 (read up to 4096 bytes)
 	mov r3, r4                      @ store FILE in r3, read from FILE
 	bl fread                        @ read bytes from FILE into memory array
 	
 	mov mic1LV, r0                  @ store # of bytes read in mic1SP.
 	
    mov r0, r4                      @ close the file.
 	bl fclose
 	
 	/* Make sure we are registers we just used at 0. */
 	mov r2, #0
 	mov r3, #0
 	mov r4, #0
 	
 	/* Get LV from program. */
 	ldr r0, =memory                 @ store &memory in r0
    ldrb mic1SP, [r0, +mic1PC]      @ SP = *memory + PC
    _INC_PC_FETCH                   @ PC = PC + 1; fetch
    lsl mic1SP, mic1SP, #8          @ SP = SP << 8; prepare MSB
    orr mic1SP, mic1MBRU            @ SP = SP | MBRU; MSB | LSB
    lsl mic1SP, mic1SP, #2          @ SP = SP << 2; Shift to translate to words
    
    add mic1SP, mic1SP, mic1LV      @ SP = SP + VL; skip LV (instruction) 
                                    @               bytes to get our SP
    sub mic1SP, mic1SP, #4          @ SP = SP - 1; start SP one behind 
    
main1:
    _INC_PC_FETCH
    
branch_table:
    /* decode/execute */
    cmp mic1MBRU, #0x10
    beq bipush
    cmp mic1MBRU, #0x59
    beq dup
    cmp mic1MBRU, #0xA7
    beq goto
    cmp mic1MBRU, #0x60
    beq iadd
    cmp mic1MBRU, #0x68
    beq imul
    cmp mic1MBRU, #0x6C
    beq idiv
    cmp mic1MBRU, #0x00
    beq nop
    cmp mic1MBRU, #0xA9
    beq ret
    cmp mic1MBRU, #0x7E
    beq iand
    cmp mic1MBRU, #0x99
    beq ifeq
    cmp mic1MBRU, #0x9B
    beq iflt
    cmp mic1MBRU, #0x9F
    beq if_icmpeq
    cmp mic1MBRU, #0x84
    beq iinc
    cmp mic1MBRU, #0x15
    beq iload
    cmp mic1MBRU, #0xA8
    beq jsr
    cmp mic1MBRU, #0x80
    beq ior
    cmp mic1MBRU, #0x36
    beq istore
    cmp mic1MBRU, #0x64
    beq isub
    cmp mic1MBRU, #0x57
    beq pop
    cmp mic1MBRU, #0x5F
    beq swap

/* Print TOS and exit */
end:
    mov r1, mic1TOS                 @ r1 = TOS; put TOS into r1
    ldr r0, =returnValue            @ r0 = &returnValue; load formatting
    bl printf                       @ printf
    pop {lr}                        @ pop lr
	bx lr                           @ return

/* Push byte onto stack */
bipush: 
    add mic1SP, #4                  @ SP = MAR = SP + 1
    
    _INC_PC_FETCH                   @ PC = PC + 1; fetch
    mov mic1MAR, mic1SP
                    
    mov mic1TOS, mic1MBR            @ MDR = TOS = MBR; wr;
    mov mic1MDR, mic1MBR
    _WR_
    
    b main1                         @ goto main1

/* Copy top word on stack and push onto stack */
dup:
    add mic1SP, #4                  @ MAR = SP = SP + 1
    mov mic1MAR, mic1SP
    
    mov mic1MDR, mic1TOS            @ MDR = TOS; wr
    _WR_
    
    b main1                         @ goto main1
    
/* Pop two words from stack; push their sum */
iadd: 
    sub mic1MAR, mic1SP, #4         @ MAR = SP = SP - 1; rd
    mov mic1SP, mic1MAR
    _RD_
    
    mov mic1H, mic1TOS              @ H = TOS
    
    add mic1TOS, mic1MDR, mic1H     @ MDR = TOS = MDR + H; wr; goto main1
    mov mic1MDR, mic1TOS            
    _WR_                            
    
    b main1                         @ goto main1

/* Pop two words from stack; push their difference */
isub: 
    sub mic1MAR, mic1SP, #4         @ MAR = SP = SP - 1; rd
    mov mic1SP, mic1MAR
    _RD_
    
    mov mic1H, mic1TOS              @ H = TOS
    
    sub mic1TOS, mic1MDR, mic1H     @ MDR = TOS = MDR - H; wr; goto main1
    mov mic1MDR, mic1TOS            
    _WR_
    b main1

/* Pop two words from stack; push their product */
imul: 
    sub mic1SP, mic1SP, #4          @ MAR = SP = SP - 1
    mov mic1MAR, mic1SP
    _RD_
    
    mov mic1H, mic1TOS              @ H = TOS
    
    mul mic1TOS, mic1MDR, mic1H     @ MDR = TOS = MDR * H; wr; goto main1
    mov mic1MDR, mic1TOS            
    _WR_                            
    b main1
    
/* Pop two words from stack; push their quotient */
idiv: 
    sub mic1SP, #4                  @ MAR = SP = SP - 1
    mov mic1MAR, mic1SP
    _RD_
    
    mov mic1H, mic1TOS              @ H = TOS
    
    mov r0, mic1H                   @ MDR = TOS = H / MDR; wr; goto main1
    mov r1, mic1MDR
    push {r2-r3}                    @ Preserve registers
    bl __aeabi_idiv                 @ call our div fuction
    pop {r2-r3}                     @ Preserve registers
    mov mic1TOS, r0
    mov mic1MDR, mic1TOS
    _WR_
    b main1

/* Pop two words from stack; push their boolean AND */
iand: 
    sub mic1SP, #4                  @ MAR = SP = SP - 1
    mov mic1MAR, mic1SP
    _RD_
    
    mov mic1H, mic1TOS              @ H = TOS
    
    and mic1TOS, mic1MDR, mic1H     @ MDR = TOS = MDR & H; wr; goto main1
    mov mic1MDR, mic1TOS
    _WR_   
    b main1

/* Pop two words from stack; push their boolean OR */
ior:
    sub mic1SP, #4                  @ MAR = SP = SP - 1
    mov mic1MAR, mic1SP
    _RD_
    
    mov mic1H, mic1TOS              @ H = TOS
    
    orr mic1TOS, mic1MDR, mic1H     @ MDR = TOS = MDR | H; wr; goto main1
    mov mic1MDR, mic1TOS
    _WR_
    b main1

/* Unconditional branch */
goto: 
    sub mic1OPC, mic1PC, #1         @ OPC = PC - 1
goto2:
    _INC_PC_FETCH                   @ PC = PC + 1; fetch
    mov mic1H, mic1MBR, lsl #8      @ H = MBR << 8;
    _INC_PC_FETCH                   @ PC = PC + 1; fetch
    orr mic1H, mic1MBR, mic1H       @ H = MBRU | H
    add mic1PC, mic1OPC, mic1H      @ PC = OPC + H
    b main1                         @ goto main1

/* Pop word from stack and branch if it is zero */
ifeq:
    sub mic1SP, #4                  @ MAR = SP = SP - 1; rd
    mov mic1MAR, mic1SP
    _RD_
    
    mov mic1OPC, mic1TOS            @ OPC = TOS
    
    mov mic1TOS, mic1MDR            @ TOS = MDR
    
    cmp mic1OPC, #0                 @ Z = OPC; if (Z) goto T; else goto F
    beq T
    b F
    
/* Pop word from stack and branch if it is less than zero */
iflt:
    sub mic1SP, #4                  @ MAR = SP = SP - 1; rd
    mov mic1MAR, mic1SP
    _RD_
    
    mov mic1OPC, mic1TOS            @ OPC = TOS
    
    mov mic1TOS, mic1MDR            @ TOS = MDR
    
    cmp mic1OPC, #0                 @ N = OPC; if (N) goto T; else goto F
    blt T
    b F

/* Pop two words from stack; branch if equal */
if_icmpeq:

    sub mic1SP, #4                  @ MAR = SP = SP - 1; rd
    mov mic1MAR, mic1SP         
    _RD_
    
    sub mic1SP, #4                  @ MAR = SP = SP - 1
    mov mic1MAR, mic1SP
    
    mov mic1H, mic1MDR              @ H = MDR; rd
    _RD_
    
    mov mic1OPC, mic1TOS            @ OPC = TOS
    
    mov mic1TOS, mic1MDR            @ TOS = MDR
    
    cmp mic1OPC, mic1H              @ Z = OPC; if (Z) goto T; else goto F
    beq T
    b F

/* Branch if previous cmp operation resulted T */    
T:
    sub mic1OPC, mic1PC, #1         @ OPC = PC - 1; goto goto2
    b goto2

/* If previous cmp operation resulted F, skip offset */    
F:
    _INC_PC_FETCH                   @ PC = PC + 1; fetch
    _INC_PC_FETCH                   @ PC = PC + 1; fetch
    b main1                         @ goto main1

/* Add a constant to a local variable */
iinc:
    _INC_PC_FETCH                   @ PC = PC + 1; fetch
    
    mov mic1H, mic1LV               @ H = LV
    
    add mic1MAR, mic1MBRU, mic1H    @ MAR = MBRU + H; rd
    push {mic1MAR}                  @ save MAR to write after inc op
    _RD_
    
    _INC_PC_FETCH                   @ PC = PC + 1; fetch
    
    mov mic1H, mic1MDR              @ H = MDR
    
    add mic1MDR, mic1MBR, mic1H     @ MDR = MBR + H; wr; goto main1
    pop {mic1MAR}                   @ restore MAR for write
    _WR_
    b main1                         

/* Push local variable onto stack */    
iload: 
    _INC_PC_FETCH                   @ PC = PC + 1; fetch
    lsl mic1MBRU, mic1MBRU, #2      @ Change to bytes instead of words
    mov mic1H, mic1LV               @ H = LV
    
    add mic1MAR, mic1MBRU, mic1H    @ MAR = MBRU + H; rd
    _RD_
    
    add mic1SP, #4                  @ MAR = SP = SP + 1; wr
    mov mic1MAR, mic1SP
    _WR_
    
    mov mic1TOS, mic1MDR            @ TOS = MDR; goto Main1
    b main1

/* Pop word from stack and store in local variable */
istore: 
    _INC_PC_FETCH                   @ PC = PC + 1; fetch
    
    lsl mic1MBRU, mic1MBRU, #2      @ Change to bytes instead of words
    mov mic1H, mic1LV               @ H = LV
    
    add mic1MAR, mic1MBRU, mic1H    @ MAR = MBRU + H
    mov mic1MDR, mic1TOS            @ MDR = TOS; wr
    _WR_
    
    sub mic1SP, #4                  @ MAR = SP = SP - 1; rd
    mov mic1MAR, mic1SP
    _RD_
    
    mov mic1TOS, mic1MDR            @ TOS = MDR; goto Main1
    b main1

/* Do nothing */
nop:
    b main1                         @ goto Main1

/* Delete word on top of stack */
pop: 
    sub mic1SP, #4                  @ MAR = SP = SP + 1; rd
    mov mic1MAR, mic1SP
    _RD_
    
    mov mic1TOS, mic1MDR            @ TOS = MDR; goto main1
    b main1

/* Swap the two top words on the stack */
swap:
    sub mic1MAR, mic1SP, #4         @ MAR = SP − 1; rd
    _RD_
    
    mov mic1MAR, mic1SP             @ MAR = SP
    
    mov mic1H, mic1MDR              @ H = MDR; wr
    _WR_
    
    mov mic1MDR, mic1TOS            @ MDR = TOS
    
    sub mic1MAR, mic1SP, #4         @ MAR = SP − 1; wr
    _WR_
    
    mov mic1TOS, mic1H              @ TOS = H; goto Main1
    b main1

/* Invoke a method */
jsr:
    _INC_PC_FETCH                   @ fetch MBRU
    
    lsl mic1MBRU, mic1MBRU, #2      @ multiply MBRU by 4 to convert to bytes
    
    add mic1SP, #4                  @ SP = SP + MBRU + 1
    add mic1SP, mic1SP, mic1MBRU    
    
    mov mic1MDR, mic1CPP            @ MDR = CPP
    
    mov mic1CPP, mic1SP             @ MAR = CPP = SP; wr
    mov mic1MAR, mic1CPP        
    _WR_
    
    add mic1MDR, mic1PC, #4         @ MDR = PC + 4
    
    add mic1SP, #4                  @ MAR = SP = SP + 1; wr
    mov mic1MAR, mic1SP
    _WR_
    
    mov mic1MDR, mic1LV             @ MDR = LV
    
    add mic1SP, #4                  @ MAR = SP = SP + 1; wr
    mov mic1MAR, mic1SP
    _WR_
    
    sub mic1LV, mic1SP, #8          @ LV = SP - 2 - MBRU
    sub mic1LV, mic1MBRU
    
    _INC_PC_FETCH                   @ PC = PC + 1; fetch
                                    @ NOP
                                    
    lsl mic1MBRU, mic1MBRU, #2      @ multiply MBRU by 4
    sub mic1LV, mic1MBRU            @ LV = LV - MBRU
    
    _INC_PC_FETCH                   @ PC = PC + 1; fetch
                                    @ NOP
          
    lsl mic1H, mic1MBR, #8          @ H = MBR << 8
    
    _INC_PC_FETCH                   @ PC = PC + 1; fetch
                                    @ NOP
    
    orr mic1MBRU, mic1H, mic1MBRU   @ PC = PC - 4 + (H OR MBRU)
    add mic1PC, mic1MBRU
    sub mic1PC, #5
    
    b main1                         @ goto main1

/* Return from a method */
ret:
    cmp mic1CPP, #0                 @ check for ret from main 
    beq end                         @ (i.e. CPP==0) & exit, ELSE
    
    mov mic1MAR, mic1CPP            @ MAR = CPP; rd
    _RD_
                                    @ NOP
    mov mic1CPP, mic1MDR            @ CPP = MDR
    
    add mic1MAR, #4                 @ MAR = MAR + 1; rd
    _RD_
                                    @ NOP
                                    
    mov mic1PC, mic1MDR             @ PC = MDR; fetch
    ldr r1, =memory
    ldrb mic1MBRU, [r1, +mic1PC]    @ fetching
    ldrsb mic1MBR, [r1, +mic1PC]    @ fetching
    
    add mic1MAR, #4                 @ MAR = MAR + 1; rd
    _RD_
    
    mov mic1MAR, mic1LV             @ SP = MAR = LV
    mov mic1SP, mic1MAR  
    
    mov mic1LV, mic1MDR             @ LV = MDR
    mov mic1MDR, mic1TOS            @ MDR = TOS; wr
    _WR_
    
    b branch_table                  @ goto branch_table to decode instruction

/* External */
.global printf
.global fopen
.global fread
.global fclose
.global __aeabi_idiv
