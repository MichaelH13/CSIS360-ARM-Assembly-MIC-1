/* -- MIC-1.s */

.data

/* Result */
.balign 4
result: .asciz "%#.2X "

.balign 4
h: .asciz " + mic1H: %#.2X "

.balign 4
lvnewline: .asciz "\nLV:\n"

.balign 4
spnewline: .asciz "\nSP:\n"

.balign 4
newline: .asciz "\n"

.balign 4
tos: .asciz " mic1TOS: %#.2X "

.balign 4
cpp: .asciz " mic1LR (CPP): %#.2X "

.balign 4
sp: .asciz " mic1SP: %#.2X "

.balign 4
instructions: .asciz " Instructions: %#.8X "

.balign 4
mdr: .asciz " mic1MDR: %#.2X "

.balign 4
opc: .asciz " mic1OPC: %#.2X "

.balign 4
pc: .asciz " mic1PC: %#.2X "

.balign 4
mbru: .asciz " mic1MBRU: %#.2X "

.balign 4
mbr: .asciz " mic1MBR: %#.2X "

.balign 4
here: .asciz "HERE %#.2X\n"

.balign 4
returnValue: .asciz "%d\n"

.balign 4
mem: .asciz " mem_loc: %#.8X"

.balign 4
lv_value: .asciz " lv_value: %#.4X "

.balign 4
lv: .asciz " mic1LV: %#.4X "

.balign 4
skipping: .asciz "Skipping: %#.2X\n"

.balign 4
openMsg: .asciz "Op: %s\n"

.balign 4
sbipush: .asciz "\nBipush: %#.8X"

.balign 4
fetched: .asciz "\nfetched: %#.2X\n"

.balign 4
readResult: .asciz "Read in: %d\n"

.balign 4
result2: .asciz "\nresult2: %d\n"

.balign 4
old_lr: .asciz "\nold_lr: %d\n"

.balign 4
flags: .asciz "r"

.balign 4
smdr: .asciz " MDR: %#.2X "

.balign 4
filename: .asciz "loadstore"

.balign 4
push_ret_pc: .asciz "\npush_ret_pc: %d"

.balign 4
push_ret_lv: .asciz "\npush_ret_link_ptr: %d"

.balign 4
set_new_link_ptr: .asciz "\nset_new_link_ptr: %d"

.balign 4
push_old_lv: .asciz "\npush_old_lv: %d"

.balign 4
set_new_lv: .asciz "\nset_new_lv: %d"

.balign 4
get_old_link_pointer: .asciz "\nget_old_link_pointer: %d"

.balign 4
restore_cpp: .asciz "\nrestore_old_link_ptr: %d"

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
    add mic1PC, mic1PC, #1
    ldr r1, =memory
    add mic1MAR, mic1PC, r1
    ldrb mic1MBRU, [mic1MAR]
    ldrsb mic1MBR, [mic1MAR]
.endm

.macro _PRINT_R1
    push {r0-r3}
    bl printf
    pop {r0-r3}
.endm

.macro _PRINT_STATE
    
    ldr r0, =newline
    _PRINT_R1
    
    mov r1, mic1PC
    ldr r0, =pc
    _PRINT_R1
    
    mov r1, mic1MBRU
    ldr r0, =mbru
    _PRINT_R1
    
    mov r1, mic1SP
    ldr r0, =sp
    _PRINT_R1
    
    mov r1, mic1CPP
    ldr r0, =cpp
    _PRINT_R1
    
    mov r1, mic1OPC
    ldr r0, =opc
    _PRINT_R1
    
    mov r1, mic1MDR
    ldr r0, =mdr
    _PRINT_R1
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

    /* Addresses of variables */


    /* Function Delcarations */
.global main


main:
	/* The name of the program to execute will be provided */
	/* as a command-line parameter. */
	push {lr}
	
    /*push {r0-r1}
	prints "Op: simple (arg number 2)" 
	ldr r0, =openMsg 
	ldr r1, [r1]
	add r1, #8
	_PRINT_R1
	pop {r0-r1}*/
	
	/* Using fopen: */
	ldr r1, [r1]
 	add r0, r1, #8
 	@ldr r0, =filename
 	ldr r1, =flags
 	bl fopen
 	
 	mov r4, r0          @store FILE in r4
 	ldr r0, =memory     @store pointer to memory in r0
 	mov r1, #1          @store 1 in r1 (read chunks of 1 byte)
 	ldr r2, =4096       @store 8 in r2 (read up to 4096 chunks of 1 byte)
 	mov r3, r4          @store FILE in r3, read from FILE
 	bl fread            @read bytes from FILE into memory array
 	
 	mov mic1LV, r0      @store # of bytes read in mic1SP.
 	
 	/* Make sure we are starting at 0 */
 	mov mic1PC, #0
 	mov mic1MAR, #0
 	mov mic1MBR, #0
 	mov mic1TOS, #0
    mov mic1CPP, #0
 	
 	/* get LV from program. */
 	ldr r0, =memory
    add mic1MAR, mic1PC, r0
    ldrb mic1SP, [mic1MAR]
    _INC_PC_FETCH
    lsl mic1SP, mic1SP, #8
    orr mic1SP, mic1MBRU
    lsl mic1SP, mic1SP, #2
    
    add mic1SP, mic1SP, mic1LV      @Skip LV bytes, program bytes to get SP
    sub mic1SP, mic1SP, #4
    
main1:
    _INC_PC_FETCH
    
    /*
    ldr r0, =newline
    _PRINT_R1
    push {r0-r3}
    mov r3, mic1PC          
    
printMemory:
    
    @see if we are at our LV pointer yet.
    cmp r3, mic1LV
    bne skip_nl1
    
 	ldr r0, =lvnewline
    _PRINT_R1
    
skip_nl1:

    @see if we are at our SP yet.
    mov r2, mic1SP
    @add r2, r2, #4
    cmp r3, r2
    bne skip_nl2
    
 	ldr r0, =spnewline
    _PRINT_R1
    
skip_nl2:
    
    ldr r1, =memory
    add r1, r3
    ldrb r1, [r1]
    
    ldr r0, =result
    _PRINT_R1
    
    add r3, #1
    cmp r3, #60
    bllt printMemory
    pop {r0-r3}
    
 	ldr r0, =newline
    _PRINT_R1
    */
    
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
 
end:
    mov r1, mic1TOS
    ldr r0, =returnValue
    _PRINT_R1
    pop {lr}
	bx lr
	
bipush: 
    
    add mic1SP, mic1SP, #4          @SP = MAR = SP + 1
    
    _INC_PC_FETCH                   @PC = PC + 1; fetch
    mov mic1MAR, mic1SP
                    
    mov mic1TOS, mic1MBR            @MDR = TOS = MBR; wr;
    mov mic1MDR, mic1MBR
    _WR_
    
    b main1                         @goto Main1
    
dup:
    add mic1SP, mic1SP, #4          @MAR = SP = SP + 1
    mov mic1MAR, mic1SP
    mov mic1MDR, mic1TOS            @
    _WR_
    
    b main1
    
iadd: 
    sub mic1MAR, mic1SP, #4         @MAR = SP = SP - 1
    mov mic1SP, mic1MAR
    _RD_
    mov mic1H, mic1TOS              @H = TOS
    
    add mic1TOS, mic1MDR, mic1H     @MDR = TOS = MDR + H; wr; 
    mov mic1MDR, mic1TOS            
    _WR_                            
    b main1                         @goto Main1
    
isub: 
    sub mic1MAR, mic1SP, #4         @MAR = SP = SP - 1
    mov mic1SP, mic1MAR
    _RD_
    mov mic1H, mic1TOS              @H = TOS
    
    sub mic1TOS, mic1MDR, mic1H     @TOS = MDR - H
    mov mic1MDR, mic1TOS            @MDR = TOS
    _WR_                            @wr; goto Main1
    b main1
    
imul: 
    sub mic1SP, mic1SP, #4          @MAR = SP = SP - 1
    mov mic1MAR, mic1SP
    _RD_
    mov mic1H, mic1TOS              @H = TOS
    
    mul mic1TOS, mic1MDR, mic1H     @MDR = TOS = MDR * H
    mov mic1MDR, mic1TOS            @MDR = TOS
    _WR_                            @wr; goto Main1
    b main1
    
idiv: @TODO NOT TESTED
    sub mic1SP, mic1SP, #4          @MAR = SP = SP - 1
    mov mic1MAR, mic1SP
    _RD_
    mov mic1H, mic1TOS              @H = TOS
    
    mov r0, mic1H                   @Div
    mov r1, mic1MDR
    
    push {r2-r3}
    bl __aeabi_idiv
    pop {r2-r3}
    
    mov mic1TOS, r0
    mov mic1MDR, mic1TOS            @MDR = TOS
    
    _WR_                            @wr; goto Main1
    b main1

iand: @TODO NOT TESTED
    sub mic1SP, mic1SP, #4          @MAR = SP = SP - 1
    mov mic1MAR, mic1SP
    _RD_
    mov mic1H, mic1TOS              @mic1H = TOS
    
    and mic1TOS, mic1MDR, mic1H     @MDR = TOS = MDR & H
    mov mic1MDR, mic1TOS            @MDR = TOS
    _WR_   
    b main1

ior: @TODO NOT TESTED
    sub mic1SP, mic1SP, #4          @MAR = SP = SP - 1
    mov mic1MAR, mic1SP
    _RD_
    mov mic1H, mic1TOS              @mic1H = TOS
    
    orr mic1TOS, mic1MDR, mic1H     @MDR = TOS = MDR | H
    mov mic1MDR, mic1TOS            @MDR = TOS
    _WR_   
    b main1

goto: 
    sub mic1OPC, mic1PC, #1         @OPC = PC - 1
goto2:
    _INC_PC_FETCH                   @PC = PC + 1; fetch
    mov mic1H, mic1MBR, lsl #8      @H = MBR << 8;
    _INC_PC_FETCH
    orr mic1H, mic1MBR, mic1H       @H = MBRU | H
    add mic1PC, mic1OPC, mic1H      @PC = OPC + H
    b main1
    
ifeq:
    sub mic1SP, mic1SP, #4          @MAR = SP = SP - 1; rd
    mov mic1MAR, mic1SP
    _RD_
    
    mov mic1OPC, mic1TOS            @OPC = TOS
    mov mic1TOS, mic1MDR            @TOS = MDR
    cmp mic1OPC, #0
    beq T
    b F
    
iflt:
    sub mic1SP, mic1SP, #4          @MAR = SP = SP - 1; rd
    mov mic1MAR, mic1SP
    _RD_
    
    mov mic1OPC, mic1TOS            @OPC = TOS
    mov mic1TOS, mic1MDR            @TOS = MDR
    cmp mic1OPC, #0
    blt T
    b F
    
T:
    sub mic1OPC, mic1PC, #1         @OPC = PC - 1; goto goto2
    b goto2
    
F:
    _INC_PC_FETCH
    _INC_PC_FETCH
    b main1
    
if_icmpeq:
    sub mic1MAR, mic1SP, #4         @MAR = SP = SP - 1; rd
    mov mic1SP, mic1MAR         
    _RD_
    
    sub mic1MAR, mic1SP, #4         @MAR = SP = SP - 1
    mov mic1SP, mic1MAR 
    mov mic1H, mic1MDR
    _RD_
    mov mic1OPC, mic1TOS
    mov mic1TOS, mic1MDR
    cmp mic1OPC, mic1H
    beq T
    b F
    
iinc:
    _INC_PC_FETCH
    mov mic1H, mic1LV               @H = LV
    add mic1MAR, mic1MBRU, mic1H    @MAR = MBRU + H; rd
    push {mic1MAR}
    _RD_
    
    _INC_PC_FETCH                   @PC = PC + 1; fetch
    
    mov mic1H, mic1MDR              @H = MDR
    
    add mic1MDR, mic1H, mic1MBR     @MDR = MBR + H; wr; goto main1
    
    pop {mic1MAR}
    _WR_
    b main1
    
iload: 
    _INC_PC_FETCH
    lsl mic1MBRU, mic1MBRU, #2      @ Change to bytes instead of words
    mov mic1H, mic1LV               @ H = LV
    
    add mic1MAR, mic1MBRU, mic1H    @ MAR = MBRU + H; rd
    _RD_
    
    add mic1MAR, mic1SP, #4         @ MAR = SP = SP + 1; wr
    mov mic1SP, mic1MAR
    _WR_
    mov mic1TOS, mic1MDR            @ TOS = MDR; goto Main1
    
    b main1
    
istore: 
    _INC_PC_FETCH
    
    lsl mic1MBRU, mic1MBRU, #2      @ Change to bytes instead of words
    mov mic1H, mic1LV               @ H = LV
    
    add mic1MAR, mic1MBRU, mic1H    @ MAR = MBRU + H
    mov mic1MDR, mic1TOS            @ MDR = TOS; wr
    _WR_
    
    sub mic1MAR, mic1SP, #4         @ SP = MAR = SP − 1; rd
    mov mic1SP, mic1MAR
    _RD_
    
    mov mic1TOS, mic1MDR            @ TOS = MDR; goto Main1
    
    b main1
    
nop:
    b main1                         @ goto main1
    
pop: 
    sub mic1SP, mic1SP, #4          @ MAR = SP = SP - 1; rd
    mov mic1MAR, mic1SP
    _RD_
    mov mic1TOS, mic1MDR            @ TOS = MDR; goto main1
    b main1
    
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
    
jsr:
    _INC_PC_FETCH                   @Get MBRU
    
    lsl mic1MBRU, mic1MBRU, #2      @Multiply MBRU by 4
    
    add mic1SP, mic1SP, #4
    add mic1SP, mic1SP, mic1MBRU    @jsr1 SP = SP + MBRU + 1
    
    mov mic1MDR, mic1CPP            @jsr2 MDR = CPP
    
    mov mic1CPP, mic1SP             @jsr3 MAR = CPP = SP; wr
    mov mic1MAR, mic1CPP        
    _WR_
    
    
    add mic1MDR, mic1PC, #4         @jsr4 MDR = PC + 4
    
    
    add mic1MAR, mic1SP, #4         @jsr5 MAR = SP = SP + 1; wr
    mov mic1SP, mic1MAR
    _WR_
    
    mov mic1MDR, mic1LV             @jsr6 MDR = LV
    
    add mic1MAR, mic1SP, #4         @jsr7 MAR = SP = SP + 1; wr
    mov mic1SP, mic1MAR
    _WR_
    
    sub mic1LV, mic1SP, #8          @jsr8 LV = SP - 2 - MBRU
    sub mic1LV, mic1LV, mic1MBRU
    _INC_PC_FETCH                   @jsr9 PC = PC + 1; fetch
                                    @jsr10 NOP
                                    
    lsl mic1MBRU, mic1MBRU, #2      @Multiply MBRU by 4
    sub mic1LV, mic1LV, mic1MBRU    @jsr11 LV = LV - MBRU
    _INC_PC_FETCH                   @jsr12 PC = PC + 1; fetch
                                    @jsr13 NOP
          
    lsl mic1MBR, mic1MBR, #8        @jsr14 H = MBR << 8
    mov mic1H, mic1MBR   
    
    _INC_PC_FETCH                   @jsr15 PC = PC + 1; fetch
                                    @jsr16 NOP
    orr mic1MBRU, mic1H, mic1MBRU   @jsr17 PC = PC - 4 + (H OR MBRU)
    add mic1PC, mic1PC, mic1MBRU
    
    
    sub mic1PC, mic1PC, #5
    
    
    b main1                         @jsr18 goto main1
    
ret:
    
    cmp mic1CPP, #0                 @ret0 check for ret from main 
    beq end                         @(i.e. CPP==0) & exit, ELSE
    
    
    mov mic1MAR, mic1CPP            @ret1 MAR = CPP; rd
    _RD_
                                    @ret2 NOP
    mov mic1CPP, mic1MDR            @ret3 CPP = MDR
    
    add mic1MAR, mic1MAR, #4        @ret4 MAR = MAR + 1; rd
    _RD_
    
                                    @ret5 NOP
    mov mic1PC, mic1MDR             @ret6 PC = MDR; fetch
    ldr r1, =memory
    ldrb mic1MBRU, [r1, +mic1PC]    @fetching
    ldrsb mic1MBR, [r1, +mic1PC]    @fetching
    
    
    add mic1MAR, mic1MAR, #4        @ret7 MAR = MAR + 1; rd
    _RD_
    
    mov mic1MAR, mic1LV             @ret8 SP = MAR = LV
    mov mic1SP, mic1MAR  
    
    mov mic1LV, mic1MDR             @ret9 LV = MDR
    mov mic1MDR, mic1TOS            @ret10 MDR = TOS; wr
    _WR_
    
    b branch_table

/* External */
.global printf
.global fopen
.global fread
.global fclose
.global __aeabi_idiv
