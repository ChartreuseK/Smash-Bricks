@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ timer.s
@@
@ Functions dealing with the system timer
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.globl st_sleep
.globl timerFired
.globl initBallTimer

.globl resetTimer
.globl pauseTimer
.globl unpauseTimer


.equ    SYSTIMER_BASE,      0x20003000
.equ    SYSTIMER_CS,        0x00
.equ    SYSTIMER_CLO,       0x04
.equ    SYSTIMER_CHI,       0X08
.equ    SYSTIMER_C0,        0X0C
.equ    SYSTIMER_C1,        0X10
.equ    SYSTIMER_C2,        0X14
.equ    SYSTIMER_C3,        0X18


.equ    TIMER_SPEED,        512


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Include our globally defined equ's
.include "defines.s"

.section .text

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ st_sleep(int)
@@ Simple timer sleep in micro seconds
@@@@
st_sleep:
    ldr     r2, =SYSTIMER_BASE
    ldr     r1, [r2, #SYSTIMER_CLO]
    add     r0, r1                      @ Get the timer offset to end
    
st_sleep_loop:
    ldr     r1, [r2, #SYSTIMER_CLO]
    cmp     r0, r1
    bgt     st_sleep_loop               @ While the wanted time is still
                                        @ Greater than the current time.
    
    bx      lr                          @ Otherwise return
@@ END ST_SLEEP
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ initBallTimer
@ Sets up a timer for one second from now in C1
@@@@
initBallTimer:
    ldr     r2, =SYSTIMER_BASE
    mov     r0, #0x2                    @ We want the C1 bit in CS
    str     r0, [r2, #SYSTIMER_CS]      @ Clear the match on C1
    
    ldr     r1, [r2, #SYSTIMER_CLO]
    ldr     r0, =TIMER_SPEED            @ 1000000us = 1s 
    add     r1, r0
    str     r1, [r2, #SYSTIMER_C1]

    bx      lr
    

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ timerFired
@  Called by the ISR when the timer in C1 is matched
@@@@
timerFired:
    push    { lr }
    
    
    
    
    
    bl      initBallTimer               @ Reset the timer so it will fire again 

    ldr     r1, =SYSTIMER_BASE
    mov     r0, #0x2                    @ We want the C1 bit in CS
    str     r0, [r1, #SYSTIMER_CS]      @ Clear the match on C1

    ldr     r0, =paused
    ldr     r0, [r0]
    cmp     r0, #1                      @ Check if we are paused
    popeq   { pc }                      @ If we are then we're done
    
    ldr     r0, =game_struct
    ldr     r1, [r0, #GAME_BALL_H_COUNT]
    ldr     r2, [r0, #GAME_BALL_H_SPEED]
    add     r1, #1                      @ Increment the horizontal count
    cmp     r1, r2
    strne   r1, [r0, #GAME_BALL_H_COUNT]     @ Store the updated count if not overflow
    bne     timer_vertical
    
    @ We had a timer overflow
    push    { r0 }
    bl      clearCurBall
    pop     { r0 }
    
    mov     r1, #0
    str     r1, [r0, #GAME_BALL_H_COUNT]
    
    ldr     r1, [r0, #GAME_BALL_X]
    ldr     r2, [r0, #GAME_BALL_H_DIR]
    add     r1, r2
    str     r1, [r0, #GAME_BALL_X]
    
    bl      drawCurBall
    
    bl      checkCollision              @ Check if we hit a brick
    cmp     r0, #-1
    beq     timer_horiz_nobrick

   
    @ We hit a brick, remove it and bounce
    ldr     r1, =game_struct

    add     r1, r0                      @ Add our offset into the game board, we'll add the game board offset later
    mov     r2, #BRICK_NONE    
    strb    r2, [r1, #GAME_BOARD]       @ Brick is now removed from the board
    
    bl      drawBoard                   @ Not an ideal solution but good enough for now

    
    @ Now bounce, since we were moving sideways when hitting a brick we must have hit a side
    @ Therefore we want to change our x axis
    bl      horizBounce
    
timer_horiz_nobrick:
    
    @ Now check for a left/right wall 
    bl      checkWallCollisionHoriz
    cmp     r0, #TRUE                   @ Did we hit a side wall?
    bne     timer_vertical
    
    bl      horizBounce                 @ We hit a wall so bounce off it
    
    
timer_vertical:
    ldr     r0, =game_struct
    ldr     r1, [r0, #GAME_BALL_V_COUNT]
    ldr     r2, [r0, #GAME_BALL_V_SPEED]
    add     r1, #1                      @ Increment the vertical count
    cmp     r1, r2
    
    strne   r1, [r0, #GAME_BALL_V_COUNT]
    popne   { pc }                      @ Return if not overflow
    
    @ We had a timer overflow
    push    { r0 }
    bl      clearCurBall
    pop     { r0 }
    
    mov     r1, #0
    str     r1, [r0, #GAME_BALL_V_COUNT]
    
    ldr     r1, [r0, #GAME_BALL_Y]
    ldr     r2, [r0, #GAME_BALL_V_DIR]
    add     r1, r2
    str     r1, [r0, #GAME_BALL_Y]
    
    bl      drawCurBall
    
    bl      checkCollision              @ Check if we hit a brick
    cmp     r0, #-1
    beq     timer_vert_nobrick
    
    @ We hit a brick, remove it and bounce
    ldr     r1, =game_struct

    add     r1, r0                      @ Add our offset into the game board, we'll add the game board offset later
    mov     r2, #BRICK_NONE    
    strb    r2, [r1, #GAME_BOARD]       @ Brick is now removed from the board
    
    bl      drawBoard                   @ Not an ideal solution but good enough for now

    
    @ Now bounce, since we were moving sideways when hitting a brick we must have hit a side
    @ Therefore we want to change our x axis
    bl      vertBounce
    
timer_vert_nobrick:
    
    @ Now check for a top  wall 
    bl      checkWallCollisionVert
    cmp     r0, #TRUE                   @ Did we hit a side wall
    
    bleq    vertBounce                  @ We hit a wall so bounce off it
        
    
    
        
    pop     { pc }

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ resetTimer
@ Resets the timer's counter to 0
@@@@
resetTimer:
    push    { lr }
    ldr     r1, =seconds
    mov     r0, #0
    str     r0, [r1]
    
    bl      initBallTimer
    
    ldr     r0, =pause_timeleft         @ Reset the time left for the pause 
    ldr     r1, =TIMER_SPEED            @ So that it will go one second from now
    str     r1, [r0]

    pop     { pc }



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ pauseTimer
@  Pauses the timer 
@@@@
pauseTimer:
    ldr     r1, =paused
    mov     r0, #1
    str     r0, [r1]
    
    ldr     r2, =SYSTIMER_BASE
    ldr     r1, [r2, #SYSTIMER_CLO]
    ldr     r2, [r2, #SYSTIMER_C1]
    sub     r2, r1                      @ Get the number of microseconds we had
                                        @ Left to the next second
    ldr     r1, =pause_timeleft
    str     r2, [r1]
    
    bx      lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ unpauseTimer
@  Unpauses the timer so that it resumes counting
@@@@
unpauseTimer:
    ldr     r1, =paused
    mov     r0, #0
    str     r0, [r1]

    ldr     r0, =pause_timeleft
    ldr     r0, [r0]

    ldr     r2, =SYSTIMER_BASE
    ldr     r1, [r2, #SYSTIMER_CLO]     @ Get the current time
    add     r0, r1                      @ Add the time we had remaining to it
    str     r0, [r2, #SYSTIMER_C1]      @ And set it in the compare register 1
    
    bx      lr


.section .data

.align 4

seconds:    .int 0
showtimer:  .int 0                      @ Start with the timer hidden
paused:     .int 0
pause_timeleft: .int TIMER_SPEED       @ Time left till the next second was supposed to occur
timer_str:  .ascii "TIME:"
                        
