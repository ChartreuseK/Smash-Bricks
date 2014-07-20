@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ graphics.s
@@
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.equ FB_POINTER, 0x20
.equ BRICK_COLOR_BASE,     10
.equ BALL_COLOR_BASE,      50

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Include our globally defined equ's
.include "defines.s"


.globl putPixel
.globl drawBrick
.globl clearBrick
.globl drawEmptyBrick
.globl outlineBox
.globl drawBall
.globl clearBall
.globl drawCurBall
.globl clearCurBall

clearCurBall:
    push    { lr } 
    ldr     r3, =game_struct
    
    ldr     r0, [r3, #GAME_BALL_X]
    ldr     r1, [r3, #GAME_BALL_Y]
    ldr     r2, =ball_tile
    bl      clearBall
    
    pop     { pc }

drawCurBall:
    push    { lr } 
    ldr     r3, =game_struct
    
    ldr     r0, [r3, #GAME_BALL_X]
    ldr     r1, [r3, #GAME_BALL_Y]
    ldr     r2, =ball_tile
    bl      drawBall
    
    pop     { pc }

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Draw ball
@  Ball is 8px wide and 8 px tall
@  x, y, &ball
@@@@
drawBall:
    push    { r4 }
    ldr     r4, =framebuffer_info       @ Framebuffer struct
    ldr     r4, [r4, #FB_POINTER]       @ Pointer to the frame buffer
    
    add     r0, r1, lsl #9              @ r0 = x + y << 9 + y << 7
    add     r0, r1, lsl #7              @ r0 = x + (y * 640)
                                        
    add     r4, r0                      @ r4 is now our starting point in the framebuffer
                                        
    mov     r0, #BALL_HEIGHT
drawBall_loop:

.rept   BALL_WIDTH
    ldrb    r3, [r2], #1                @ Read a byte from the ball
    cmp     r3, #255                    @ Check if it's to be transparent
    addne   r3, #BALL_COLOR_BASE        @ If it's not change it to an offset in the palette
    strneb  r3, [r4]                    @ And draw it to the scren
    
    add     r4, #1                      @ And move along the line
.endr

    ldr     r1, =(SCREEN_WIDTH - BALL_WIDTH)    
    add     r4, r1                      @ Jump to the next line
    
    subs    r0, #1
    bgt     drawBall_loop
    
    pop     { r4 }
    bx      lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ clearBall
@  Clears a ball shape using the transparency
@ x, y, &ball
@@@@
clearBall:
    push    { r4 }
    ldr     r4, =framebuffer_info       @ Framebuffer struct
    ldr     r4, [r4, #FB_POINTER]       @ Pointer to the frame buffer
    
    add     r0, r1, lsl #9              @ r0 = x + y << 9 + y << 7
    add     r0, r1, lsl #7              @ r0 = x + (y * 640)
                                        
    add     r4, r0                      @ r4 is now our starting point in the framebuffer
                                        
    mov     r0, #BALL_HEIGHT
clearBall_loop:

.rept   BALL_WIDTH
    ldrb    r3, [r2], #1                @ Read a byte from the ball
    cmp     r3, #255                    @ Check if it's to be transparent
    movne   r3, #0                      @ Just draw black to clear for now
    strneb  r3, [r4]                    @ And draw it to the scren
    
    add     r4, #1                      @ And move along the line
.endr

    ldr     r1, =(SCREEN_WIDTH - BALL_WIDTH)    
    add     r4, r1                      @ Jump to the next line
    
    subs    r0, #1
    bgt     clearBall_loop
    
    pop     { r4 }
    bx      lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Draw brick
@  Bricks are 36px wide and 12px tall
@  x, y, color(Upper nybble is shade, lower is color), &brick
@@@@
drawBrick:
    push    { r4, r5 }
    ldr     r4, =framebuffer_info       @ Framebuffer struct
    ldr     r4, [r4, #FB_POINTER]       @ Pointer to the frame buffer
    
    add     r0, r1, lsl #9              @ r0 = x + y << 9 + y << 7
    add     r0, r1, lsl #7              @ r0 = x + (y * 640)
                                        
    add     r4, r0                      @ r4 is now our starting point in the framebuffer
                                        
    and     r5, r2, #0x0F
    add     r0, r5, r5, lsl #2          @ 5 * color
    add     r0, #BRICK_COLOR_BASE
    add     r0, r2, lsr #4              @ Add the shade to the color + base
   

    mov     r2, #BRICK_HEIGHT           @ 12px tall

    mov     r1, #BRICK_WIDTH            @ 24px wide     
drawBrick_loop:
    ldrb    r5, [r3], #1                @ Grab a byte from the brick and increment
    
    cmp     r5, #255                    @ If it's supposed to be black
    addne   r5, r0                      @ Add it to the color base
    moveq   r5, #0
    
    strb    r5, [r4], #1                @ Draw it to the screen
    
    subs    r1, #1
    bgt     drawBrick_loop              @ While we haven't finished a line
    
    ldr     r1, =(640 - BRICK_WIDTH)    @ Screen width(640) - brickwidth
    add     r4, r1                      @ Jump to the start of the next line
    
    mov     r1, #BRICK_WIDTH            
    subs    r2, #1              
    bgt     drawBrick_loop              @ While we still have lines left
    
    pop     { r4, r5 }
    
    bx      lr                          @ And we're done



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Clear brick
@  Bricks are 36px wide and 12px tall
@  x, y
@@@@
clearBrick:
    push    { r4, r5 }
    ldr     r4, =framebuffer_info       @ Framebuffer struct
    ldr     r4, [r4, #FB_POINTER]       @ Pointer to the frame buffer
    
    add     r0, r1, lsl #9              @ r0 = x + y << 9 + y << 7
    add     r0, r1, lsl #7              @ r0 = x + (y * 640)
                                        
    add     r4, r0                      @ r4 is now our starting point in the framebuffer
                                    

    mov     r1, #BRICK_HEIGHT           @ 12px tall

    mov     r0, #BRICK_WIDTH            @ 24px wide     
clearBrick_loop:
    mov     r5, #0
    strb    r5, [r4], #1                @ Draw it to the screen
    
    subs    r0, #1
    bgt     clearBrick_loop             @ While we haven't finished a line
    
    ldr     r0, =(640 - BRICK_WIDTH)    @ Screen width(640) - brickwidth
    add     r4, r0                      @ Jump to the start of the next line
    
    mov     r0, #BRICK_WIDTH            
    subs    r1, #1              
    bgt     clearBrick_loop             @ While we still have lines left
    
    pop     { r4, r5 }
    
    bx      lr                          @ And we're done










@ x, y, index
putPixel:
    ldr     r3, =framebuffer_info       @ Get our framebuffer address
    ldr     r3, [r3, #FB_POINTER]       @ Address of the frame buffer
    
    add     r0, r1, lsl #9              @ r0 = x + y << 9 + y << 7
    add     r0, r1, lsl #7              @ r0 = x + (y * 640)
                                        
    strb    r2, [r3, r0]                @ Set the pixel to the color index

    bx      lr



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ drawEmptyBrick
@  x, y
@@@@
drawEmptyBrick:
    ldr     r3, =framebuffer_info       @ Framebuffer struct
    ldr     r3, [r3, #FB_POINTER]       @ Pointer to the frame buffer
    
    add     r0, r1, lsl #9              @ r0 = x + y << 9 + y << 7
    add     r0, r1, lsl #7              @ r0 = x + (y * 640)
                                        
    add     r3, r0                      @ r3 is now our starting point in the framebuffer
    
    mov     r0, #BRICK_WIDTH
    mov     r1, #BRICK_HEIGHT
    mov     r2, #BLACK
drawEmptyBrick_loop:
    strb    r2, [r3], #1                @ Write out background color to screen and increment
    subs    r0, #1
    bgt     drawEmptyBrick_loop
    
    
    ldr     r0, =(640 - BRICK_WIDTH)    @ Screen width(640) - brickwidth
    add     r3, r0                      @ Jump down to the start of the next line
    
    mov     r0, #BRICK_WIDTH
    
    subs    r1, #1
    bgt     drawEmptyBrick_loop
     
    bx      lr




@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Horizontal Line
@ Simple horizontal line function, width must be positive
@  x,y, width, color index
@@@@
horizLine:
    @ Offset into the FB
    add     r0, r1, lsl #9
    add     r0, r1, lsl #7              @ r0 = x + (y * 640) 
    
    ldr     r1, =framebuffer_info       @ Get our framebuffer address
    ldr     r1, [r1, #FB_POINTER]       @ Address of the frame buffer
    add     r1, r0                      @ Move to our starting offset
    
horizLine_loop:
    strb    r3, [r1], #1                @ Draw each pixel
    
    subs    r2, #1                      @ Count down the width
    bne     horizLine_loop              @ While we still have some width to go
    
    bx      lr
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Vertical Line
@ Simple vertical line function, height must be positive
@  x,y, width, color index
@@@@
vertLine:
    @ Offset into the FB
    add     r0, r1, lsl #9
    add     r0, r1, lsl #7              @ r0 = x + (y * 640) 
    
    ldr     r1, =framebuffer_info       @ Get our framebuffer address
    ldr     r1, [r1, #FB_POINTER]       @ Address of the frame buffer
    add     r1, r0                      @ Move to our starting offset
    
vertLine_loop:
    strb    r3, [r1], #640              @ Draw each pixel and advance a line
    
    subs    r2, #1                      @ Count down the height
    bne     vertLine_loop               @ While we still have some height to go
    
    bx      lr








@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ outlineBox(int x, int y, int width, int height, short colour)
outlineBox:
    push    { r4, r5, r6, r7, r8, lr }  @ We pushed 6x4 bytes onto the stack
    
    ldr     r8, [sp, #(0 + 6*4)]        @ We want the 5th argument, but we have
                                        @ To add the offset that we pushed
    mov     r4, r0
    mov     r5, r1
    mov     r6, r2
    mov     r7, r3
                
    mov     r3, r8                                              
    bl      horizLine                   @ horizLine(x,y,w,colour)
    
    mov     r0, r4                      @ x
    add     r1, r5, r7                  @ y + height ( -1 ?)
    sub     r1, #1
    mov     r2, r6                      @ width
    mov     r3, r8                      @ colour
    bl      horizLine                   @ horizLine(x,y+height,w,colour)
    
    mov     r0, r4                      @ x
    mov     r1, r5                      @ y
    mov     r2, r7                      @ height
    mov     r3, r8                      @ colour
    bl      vertLine
    
    add     r0, r4, r6                  @ x + width ( -1 ?)
    sub     r0, #1                      @ -1
    mov     r1, r5                      @ y 
    mov     r2, r7                      @ height
    mov     r3, r8                      @ colour
    bl      vertLine

    
    pop     { r4, r5, r6, r7, r8, lr }
    add     sp, #4                      @ Pop off the argument on the stack
    bx      lr

