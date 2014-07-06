
.globl      loadBoard
.globl      drawBoard

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Include our globally defined equ's
.include "defines.s"




@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ loadBoard
@  &board
@  Loads a board as the current board
@@@@
loadBoard:
    ldr     r1, =game_struct
    add     r1, #GAME_BOARD
    
    ldr     r3, =(BOARD_WIDTH * BOARD_HEIGHT)
loadBoard_loop:
    ldrb    r2, [r0], #1        @ Grab from the passed board
    strb    r2, [r1], #1        @ Give to the current board
    subs    r3, #1              @ While we have spaces left to fill
    bgt     loadBoard_loop

    bx      lr
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ drawBoard
@  Draws the entire current board to the screen
@@@@
drawBoard:
    push    { r4, r5, r6, lr }
    ldr     r4, =game_struct
    add     r4, #GAME_BOARD
    
    mov     r5, #BOARD_X        @ Current x (column * tile_width + start x)
    mov     r6, #BOARD_Y        @ Current y (row    * tile_height + start y)
drawBoard_loop:    
    ldrb    r2, [r4], #1        @ Grab the value from the board
                                
    cmp     r2, #255            @ Air block
    beq     drawBoard_looptail
                                @ Any other special blocks
                                
    ldr     r3, =brick_tile     @ If not, it's a standard block
    
    mov     r0, r5              
    mov     r1, r6
    bl      drawBrick           @ Draw the block to the screen
    
drawBoard_looptail:
    add     r5, #BRICK_WIDTH    @ Move over to the next brick
    ldr     r0, =((BOARD_WIDTH * BRICK_WIDTH) + BOARD_X)
    cmp     r5, r0              @ Check if there's more left on the row
    blt     drawBoard_loop
    
    mov     r5, #BOARD_X        @ Move over to the left side
    add     r6, #BRICK_HEIGHT   @ Move down to the next row
    ldr     r0, =((BOARD_HEIGHT * BRICK_HEIGHT) + BOARD_Y)
    cmp     r6, r0              @ If we still have more rows left
    blt     drawBoard_loop
    
    pop     { r4, r5, r6, pc }  @ If not we're done

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ checkWin
@  Checks if there are no more bricks left to break on the stage
@  Returns TRUE if no more are left, FALSE otherwise
@@@@
checkWin:
    ldr     r0, =game_struct
    ldr     r1, [r0, #GAME_BRICKS_LEFT]
    cmp     r1, #0
    moveq   r0, #TRUE
    movne   r0, #FALSE
    
    bx      lr


