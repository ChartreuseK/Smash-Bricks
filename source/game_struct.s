
.globl game_struct
.globl initGameStruct

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Include our globally defined equ's
.include "defines.s"

.equ    STARTING_LIVES, 3                   



game_struct:
    @ Player Score
    .int    0
    
    @ Player Level
    .int    0
    
    @ High Score
    .int    0
    
    @ Lives
    .int    0
    
    @ Bricks left
    .int    0
    
    @ Ball X        - Are we going to need mutexes? 
    .int    0
    @ Ball Y
    .int    0
    
    @ Ball H-dir
    .int    0
    
    @ Ball V-dir
    .int    0
    
    @ Ball H-speed      (Smaller is faster)
    .int    0
    
    @ Ball V-speed      (Smaller is faster)
    .int    0           
    
    @ Ball H-count      (counting up to the speed)
    .int    0
    
    @ Ball V-count
    .int    0
    
    @ Game board
    .skip   BOARD_HEIGHT * BOARD_WIDTH      @ Buffer for the currently loaded board
                                            @ One byte per tile
    



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ initGameStruct
@  Fills in the game struct with the starting values
@@@@
initGameStruct:
    ldr     r0, =game_struct

    mov     r1, #STARTING_LIVES
    str     r1, [r0, #GAME_LIVES]                   @ Set the starting lives
    
    mov     r1, #0
    str     r1, [r0, #GAME_SCORE]                   @ Set the score, level, and high score to 0
    str     r1, [r0, #GAME_LEVEL]
    str     r1, [r0, #GAME_HISCORE]
    str     r1, [r0, #GAME_BRICKS_LEFT]
    
initgs_clearboard:
    ldr     r2, =(BOARD_HEIGHT * BOARD_WIDTH)       @ Number of spaces to clear
    add     r0, #GAME_BOARD                         @ Get the offset into the structure
    
    strb    r1, [r0], #1                            @ Iterate through the board storing 0
    
    subs    r2, #1                                  
    bgt     initgs_clearboard                       @ While we still have spaces to clear
    
    
    bx      lr
    
