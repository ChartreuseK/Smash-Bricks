@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ graphics.s
@@
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.equ FB_POINTER, 0x20

.globl putPixel
.globl drawBrick


@ x, y, index
putPixel:
    ldr     r3, =framebuffer_info       @ Get our framebuffer address
    ldr     r3, [r3, #FB_POINTER]       @ Address of the frame buffer
    
    add     r0, r1, lsl #9              @ r0 = x + y << 9 + y << 7
    add     r0, r1, lsl #7              @ r0 = x + (y * 640)
                                        
    strb    r2, [r3, r0]                @ Set the pixel to the color index

    bx      lr




.equ    COLOR_BASE,     10

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Draw brick
@  Bricks are 24px wide and 12px tall
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
    add     r0, #COLOR_BASE
    add     r0, r2, lsr #4              @ Add the shade to the color + base
   

    mov     r2, #12                     @ 12px tall

    mov     r1, #24                     @ 24px wide     
drawBrick_loop:
    ldrb    r5, [r3], #1                @ Grab a byte from the brick and increment
    
    cmp     r5, #255                     @ If it's supposed to be black
    addne   r5, r0                      @ Add it to the color base
    moveq   r5, #0
    
    strb    r5, [r4], #1                @ Draw it to the screen
    
    subs    r1, #1
    bgt     drawBrick_loop              @ While we haven't finished a line
    
    ldr     r1, =616                    @ Screen width(640) - 24px
    add     r4, r1                      @ Jump to the start of the next line
    
    mov     r1, #24                     @ 24px wide     
    subs    r2, #1              
    bgt     drawBrick_loop              @ While we still have lines left
    
    pop     { r4, r5 }
    
    bx      lr                          @ And we're done
