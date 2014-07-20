@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ main.s
@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.section    .init
.globl     _start


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Include our global .equ's
.include "defines.s"


_start:
    b       main
    
    
    
.section .text

main:
    @mov     sp, #0x8000

    bl      InstallInterrupts
    
    mov     r0, #16
    mov     r1, #1
    bl      gpio_mode
    
    
                                        
test:

@@ Was used during development and handed in with assignment
@@ jtag.s was removed before posting since the code was notmine
@   bl      EnableJTAG
    
    bl      framebuffer_init
    bl      uart_init
    
    mov     r0, #'B'
    bl      uart_writeb
   
    
    mov     r0, #(WALL_LEFT_X)
    mov     r1, #(WALL_TOP_Y)
    ldr     r2, =(WALL_RIGHT_X - WALL_LEFT_X) 
    ldr     r3, =(WALL_BOTTOM_Y - WALL_TOP_Y)
    
    mov     r4, #1
    push    {r4}
    bl      outlineBox


    ldr     r0, =level_1
    bl      loadBoard

    bl      drawBoard



    
    ldr     r0, =game_struct
    ldr     r1, =( (BOARD_X + (BOARD_WIDTH*BRICK_WIDTH)) / 2)
    str     r1, [r0, #GAME_BALL_X]
    ldr     r1, =( (BOARD_Y + ((BOARD_HEIGHT + 2)*BRICK_HEIGHT)))
    str     r1, [r0, #GAME_BALL_Y]
    
    mov     r1, #-1
    str     r1, [r0, #GAME_BALL_H_DIR]
    str     r1, [r0, #GAME_BALL_V_DIR]
    
    mov     r1, #24
    str     r1, [r0, #GAME_BALL_H_SPEED]
    str     r1, [r0, #GAME_BALL_V_SPEED]
    
    
    bl      initBallTimer               @ Set up our timer handler (starts off paused)
    bl      unpauseTimer
    
mainLoop:                               @ The main program loop

   
    b     mainLoop


haltLoop$:
    b       haltLoop$






.equ    INTERRUPT_BASE_REG,         0x2000B000
.equ    INTERRUPT_OFFSET,           0x200

.equ    INTERRUPT_BASIC_PENDING,         0x00
.equ    INTERRUPT_PENDING_1,             0x04
.equ    INTERRUPT_PENDING_2,             0x08
.equ    INTERRUPT_FIQ_CNTL,              0x0C
.equ    INTERRUPT_ENABLE_IRQ_1,          0x10
.equ    INTERRUPT_ENABLE_IRQ_2,          0x14
.equ    INTERRUPT_ENABLE_BASIC_IRQ,      0x18
.equ    INTERRUPT_DISABLE_IRQ_1,         0x1C
.equ    INTERRUPT_DISABLE_IRQ_2,         0x20
.equ    INTERRUPT_DISABLE_BASIC_IRQ,     0x24

@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ IRQHandler
@  General IRQ handler code
IRQHandler:
    push    { r0-r12, lr }              @ We need to not mess up any registers during this IRQ
    
    ldr     r1, =INTERRUPT_BASE_REG     
    add     r1, #INTERRUPT_OFFSET
    
    ldr     r0, [r1, #INTERRUPT_PENDING_1]
    
    tst     r0, #0x2                    @ Check if there is a system timer compare C1
                                        @ interrupt being fired, again not documented
    beq     IRQHandler_aftertimer       @ If there is not a timer brach over
    
    bl      timerFired                  @ We got a timer interrrupt
    
IRQHandler_aftertimer:
    pop     { r0-r12, lr }
    subs    pc, lr, #4                  @ Subs to fix condition codes after the
                                        @ IRQ Returns here
    


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ installISR
@@@@
InstallInterrupts:
    ldr     r0, =InterruptTable
    mov     r1, #0                      @ Address 0 is the start of the 
                                        @ interrupt table
    ldmia   r0!, {r2 - r9}              @ Read in the entire interrupt table
    stmia   r1!, {r2 - r9}              @ Store it at 0x00000000
    
    ldmia   r0!, {r2 - r9}              @ Read in the handler table for the 
                                        @ interrupt table. So it is close to the
                                        @ Jumps
    stmia   r1!, {r2 - r9}              @ And store it right after the interrupt
                                        @ table.
    
    
    mrs     r0, cpsr
    bic     r0, #0b11111                @ Clear the mode bits
    orr     r0, #0b10010                @ We want IRQ mode
    msr     cpsr_c, r0                  @ Change to IRQ mode
    
    mov     sp, #0x8000                 @ Set the irq stack pointer just before
                                        @ Code starts at 0x8000
   
    mov     r0, #0b01010011             @ Supervisor mode with IRQ enabled, 
                                        @ FIQ disabled and not in thumb
    msr     cpsr_c, r0                  @ Change to supervisor mode
    
    mov     sp, #0x80000000             @ Set the supervisor stack pointer way
                                        @ up high in memory
    
    
    ldr     r1, =INTERRUPT_BASE_REG     @ Enable Timer interrupts
    add     r1, #INTERRUPT_OFFSET
    
    mov     r0, #0x2                    @ We want to enable the System timer compare
                                        @ interrupt which is not documented! in the
                                        @ BCN2835 Arm peripherals document.
                                        @ http://www.raspberrypi.org/forum/viewtopic.php?f=72&t=64008
                                        @ in the post by colinh » Tue Mar 11, 2014 1:50 am 
                                        @ States it's bit 1 of Interrupt Enable Register 1
                                        @ for C1
    str     r0, [r1, #INTERRUPT_ENABLE_IRQ_1]
    
    
    
    
    
    bx      lr

.align 4     
@ Our interrupt table and the addresses of the handlers
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

InterruptTable:
    ldr pc, reset_handler
    ldr pc, undefined_handler
    ldr pc, swi_handler
    ldr pc, prefetch_handler
    ldr pc, data_handler
    ldr pc, unused_handler
    ldr pc, irq_handler
    ldr pc, fiq_handler

reset_handler:      .word InstallInterrupts       @ Install the interrupts again
undefined_handler:  .word undefinedHalt$
swi_handler:        .word swiHalt$
prefetch_handler:   .word prefetechHalt$
data_handler:       .word dataHalt$
unused_handler:     .word unusedHalt$
irq_handler:        .word IRQHandler              @ Properly handle an IRQ 
fiq_handler:        .word fiqHalt$


@ Seperate halt loops for each exception we're not handling so we can see which
@ is being fired.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

undefinedHalt$:                         
    b       undefinedHalt$
swiHalt$:
    b       swiHalt$
prefetechHalt$:
    b       prefetechHalt$
dataHalt$:
    b       dataHalt$
unusedHalt$:
    b       unusedHalt$
fiqHalt$:
    b       fiqHalt$


    
