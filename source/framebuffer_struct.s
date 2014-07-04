.globl framebuffer_info

.section .data

.equ    FB_WIDTH,       0x00
.equ    FB_HEIGHT,      0x04
.equ    FB_PITCH,       0x10
.equ    FB_POINTER,     0x20
.equ    FB_BPP,         0x14

.align 4

framebuffer_info:
    .int    640                 @ Width             0x00
    .int    480                 @ Height            0x04
    .int    640                 @ Virt. Width       0x08
    .int    480                 @ Virt. Height      0x0C
    .int    0                   @ Pitch (GPU set)   0x10
    .int    8                   @ BPP               0x14
    .int    0                   @ Offset X          0x18
    .int    0                   @ Offset Y          0x1C
    .int    0                   @ Pointer (GPU set) 0x20
    .int    0                   @ Size of FB (GPU)  0x24
    @ If in 8bpp mode the 256 16-bit palette entries would 
    @ be appended after here. Not sure if the GPU reads these
    @ live or if any changes would have to be sent over mailbox
    .hword  0x0000    @ 0 - Black
    .hword  0xFFFF    @ 1 - White
    .hword  0xF800    @ 2 - Red
    .hword  0x07E0    @ 3 - Green
    .hword  0x008F    @ 4 - Blue
    
    .hword 0
    .hword 0
    .hword 0
    .hword 0
    .hword 0

    @ Red bricks
    .hword  0xFBCF      @ Light red
    .hword  0xF800      @ Red
    .hword  0x7000      @ Medium Red
    .hword  0x4000      @ Dark Red
    .hword  0x2800      @ Dark Dark Red
    
    @ Orange bricks
    .hword  0xFCEF      @ Light orange
    .hword  0xFA00      @ Orange
    .hword  0x70E0      @ Medium Orange
    .hword  0x4080      @ Dark Orange
    .hword  0x2840      @ Dark Dark Orange
    
    @ Yellow bricks
    .hword  0xFFEF
    .hword  0xFFE0
    .hword  0x7380
    .hword  0x4200
    .hword  0x2100
    
    @ Green bricks
    .hword  0x9fef
    .hword  0x47e0
    .hword  0x1b80
    .hword  0x1200
    .hword  0x0920
    
    @ Teal bricks
    .hword  0x7fff
    .hword  0x07ff
    .hword  0x038e
    .hword  0x0208
    .hword  0x0145
    
    @ Blue bricks
    .hword  0x7cff
    .hword  0x021f
    .hword  0x00ee
    .hword  0x0088
    .hword  0x0044
    
    @ Purple bricks
    .hword  0xbbff
    .hword  0x781f
    .hword  0x380e
    .hword  0x2008
    .hword  0x1005
    
    @ Magenta Bricks
    .hword  0xfbfb
    .hword  0xf817
    .hword  0x700a
    .hword  0x4006
    .hword  0x2803
    
    
    
    
    
.rept 250
    .hword  0x0000    @ 5-255 - Unused/Black
.endr
