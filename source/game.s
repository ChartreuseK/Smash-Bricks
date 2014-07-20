
.globl      loadBoard
.globl      drawBoard

.globl      horizBounce
.globl      vertBounce

.globl      checkWallCollisionVert
.globl      checkWallCollisionHoriz
.globl      checkCollision

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
    beq     drawBoard_air
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

drawBoard_air:
    mov     r0, r5
    mov     r1, r6
    bl      drawEmptyBrick
    
    b       drawBoard_looptail


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



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ checkWallCollisionHoriz
@  Checks if the ball collided with one of the side walls
@   Returns TRUE if it has, FALSE otherwise
@@@@
checkWallCollisionHoriz:
    ldr     r2, =game_struct
    ldr     r0, [r2, #GAME_BALL_X]          @ Get the location of the ball
    
    ldr     r2, =(BOARD_X)                  @ Check the left wall
    add     r1, r0, #BALL_1_X
    cmp     r1, r2
    
    moveq   r0, #TRUE                       @ We hit the left wall
    bxeq    lr
    
    ldr     r2, =(BOARD_X + (BOARD_WIDTH * BRICK_WIDTH))
    add     r1, r0, #BALL_2_X
    cmp     r1, r2                          @ Check the right wall
    
    moveq   r0, #TRUE                       @ We collided
    movne   r0, #FALSE                      @ We didn't
    
    bx      lr
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ checkWallCollisionVert
@  Checks if the ball collided with the top or bottom wall
@   Returns TRUE if it has, FALSE otherwise
@@@@
checkWallCollisionVert:
    ldr     r2, =game_struct
    ldr     r0, [r2, #GAME_BALL_Y]          @ Get the location of the ball
    
    ldr     r2, =(BOARD_Y)                  @ Check the top wall
    add     r1, r0, #BALL_1_Y
    cmp     r1, r2
    
    moveq   r0, #TRUE                       @ We hit the top wall
    bxeq    lr
    
    ldr     r2, =(WALL_BOTTOM_Y)
    add     r1, r0, #BALL_3_Y
    cmp     r1, r2                          @ Check the right wall
    
    moveq   r0, #TRUE                       @ We collided
    movne   r0, #FALSE                      @ We didn't
    
    bx      lr    


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ checkCollision
@  Checks if the ball has collided with a brick
@  Returns -1 if no collision, returns the bricks offset into the board
@  if it collided
@   TODO:
@       Do we want to allow multiple brick breaks per collision?
@       Should corner hits bounce directly back?
@       Might need to seperate vertical and horizontal checking???
@@@@
checkCollision:
    push    { r4, r5, r6, r7, lr }
    
    ldr     r4, =game_struct
    ldr     r5, [r4, #GAME_BALL_X]
    ldr     r6, [r4, #GAME_BALL_Y]
    
    
    @ First check if we're even at the height of the bricks
    ldr     r3, =(BOARD_Y + (BOARD_HEIGHT * BRICK_HEIGHT))
    cmp     r6, r3
    movgt   r0, #-1
    popgt   { r4, r5, r6, r7, pc }
    


    @ Okay we're in the area where bricks can be, let's check if any of our corners
    @ are in the area taken up by a brick.

    


    add     r0, r5, #BALL_1_X               @ Ball X + 1
    bl      xToBrick

    cmp     r0, #-1                         @ There is no way our ball can be invalid...
    beq     checkCollision_invalid          @ If we need the performance we can remove this
    mov     r7, r0                          @ Save our x offset
    
    add     r0, r6, #BALL_1_Y               @ Ball Y + 1
    bl      yToBrick                        @ y offset in r0 (y * BOARD_WIDTH)
    
    add     r1, r4, #GAME_BOARD             @ Get a pointer to our game board
    
    add     r1, r0                          @ Offset to the right row
    add     r1, r7                          @ Offset to the column
    
    ldrb    r2, [r1]                        @ Grab the brick pointed at
    cmp     r2, #0xFF                       @ Check if it's air
    
    bne     checkCollision_collide          @ If it's not we hit a brick



    @ Otherwise check the next corner
    

    add     r0, r5, #BALL_2_X               @ Ball X + WIDTH - 1
    bl      xToBrick
    
    cmp     r0, #-1                         @ There is no way our ball can be invalid...
    beq     checkCollision_invalid          @ If we need the performance we can remove this
    mov     r7, r0                          @ Save our x offset
    
    add     r0, r6, #BALL_2_Y               @ Ball Y + 1
    bl      yToBrick                        @ y offset in r0 (y * BOARD_WIDTH)
    
    add     r1, r4, #GAME_BOARD             @ Get a pointer to our game board
    
    add     r1, r0                          @ Offset to the right row
    add     r1, r7                          @ Offset to the column
    
    ldrb    r2, [r1]                        @ Grab the brick pointed at
    cmp     r2, #0xFF                       @ Check if it's air
    
    bne     checkCollision_collide          @ If it's not we hit a brick

    @ Otherwise check the next corner
    

    add     r0, r5, #BALL_3_X               @ Ball X + 1
    bl      xToBrick
    
    cmp     r0, #-1                         @ There is no way our ball can be invalid...
    beq     checkCollision_invalid          @ If we need the performance we can remove this
    mov     r7, r0                          @ Save our x offset
    
    add     r0, r6, #BALL_3_Y               @ Ball Y + HEIGHT - 1
    bl      yToBrick                        @ y offset in r0 (y * BOARD_WIDTH)
    
    add     r1, r4, #GAME_BOARD             @ Get a pointer to our game board
    
    add     r1, r0                          @ Offset to the right row
    add     r1, r7                          @ Offset to the column
    
    ldrb    r2, [r1]                        @ Grab the brick pointed at
    cmp     r2, #0xFF                       @ Check if it's air
    
    bne     checkCollision_collide          @ If it's not we hit a brick

    @ Otherwise check the next corner
    

    add     r0, r5, #BALL_4_X               @ Ball X + WIDTH - 1
    bl      xToBrick
    
    cmp     r0, #-1                         @ There is no way our ball can be invalid...
    beq     checkCollision_invalid          @ If we need the performance we can remove this
    mov     r7, r0                          @ Save our x offset
    
    add     r0, r6, #BALL_4_Y               @ Ball Y + HEIGHT - 1
    bl      yToBrick                        @ y offset in r0 (y * BOARD_WIDTH)
    
    add     r1, r4, #GAME_BOARD             @ Get a pointer to our game board
    
    add     r1, r0                          @ Offset to the right row
    add     r1, r7                          @ Offset to the column
    
    ldrb    r2, [r1]                        @ Grab the brick pointed at
    cmp     r2, #0xFF                       @ Check if it's air
    
    bne     checkCollision_collide          @ If it's not we hit a brick

    @ If not we didn't hit any brick so return -1
    mov     r0, #-1
    pop     { r4, r5, r6, r7, pc }          @ Return

checkCollision_collide:
    @ We hit a brick so return the offset
    add     r0, r7                          @ r0 still contained the row offset
                                            @ r7 contained the column
    pop     { r4, r5, r6, r7, pc}           @ Return

checkCollision_invalid:
    b       checkCollision_invalid          @ We entered an invalid state, ball out of board




@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ xToBrick
@  x-coord
@  Converts an x-coord to a brick index on the board
@  Returns -1 if the coord is out of range
@@@@
xToBrick:
    mov     r1, #0                  @ Start at the left
    mov     r2, #BOARD_X            @ Pixel for the left most brick
    
    cmp     r0, r2                  @ Check if the coord is past the left of the board
    movlt   r0, #-1                 @ If so then return -1
    bxlt    lr
    
    
    
    add     r2, #BRICK_WIDTH        @ The current pixel will be the top left corner of
                                    @ the brick to the right of where we're checking
xToBrick_loop:
    cmp     r0, r2                  @ If the coord is less that the current pixel
    movlt   r0, r1                  @ Then return the current brick spot
    bxlt    lr
    
    add     r1, #1                  @ Move over one brick
    cmp     r1, #BOARD_WIDTH        @ If we're past the board width
    movge   r0, #-1                 @ If so then return -1
    bxge    lr
    
    add     r2, #BRICK_WIDTH       
    b       xToBrick_loop
    
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ yToBrick
@  y-coord@  Converts an y-coord to a brick index on the board
@  Returns -1 if the coord is out of range
@@@@
yToBrick:
    mov     r1, #0                  @ Start at the top
    mov     r2, #BOARD_Y            @ Pixel for the top most brick
    
    cmp     r0, r2                  @ Check if the coord is past the top of the board
    movlt   r0, #-1                 @ If so then return -1
    bxlt    lr
    
    add     r2, #BRICK_HEIGHT       @ The current pixel will be the top left corner of
                                    @ the brick to the right of where we're checking
yToBrick_loop:
    cmp     r0, r2                  @ If the coord is less that the current pixel
    movlt   r0, r1                  @ Then return the current brick spot
    bxlt    lr
    
    add     r1, #BOARD_WIDTH        @ Move down one row
    cmp     r1, #(BOARD_HEIGHT * BOARD_WIDTH) @ If we're past the board height
    movge   r0, #-1                 @ Then return -1
    bxge    lr
    
    add     r2, #BRICK_HEIGHT     
    b       yToBrick_loop
    





@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ horizBounce
@@@@
horizBounce:
    ldr     r0, =game_struct
    ldr     r1, [r0, #GAME_BALL_H_DIR]
    cmp     r1, #1                  @ If we're moving towards positive
    moveq   r1, #-1                 @ Then we change to move towards negative
    movne   r1, #1                  @ Otherwise change to positive
    str     r1, [r0, #GAME_BALL_H_DIR]
    
    bx      lr
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ vertBounce
@@@@
vertBounce:
    ldr     r0, =game_struct
    ldr     r1, [r0, #GAME_BALL_V_DIR]
    cmp     r1, #1                  @ If we're moving towards positive
    moveq   r1, #-1                 @ Then we change to move towards negative
    movne   r1, #1                  @ Otherwise change to positive
    str     r1, [r0, #GAME_BALL_V_DIR]
    
    bx      lr
