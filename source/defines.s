@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ defines.s @@     Global .equ directives       @@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Screen size
.equ    SCREEN_WIDTH,   640
.equ    SCREEN_HEIGHT,  480

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Number of bricks in the game board
.equ    BOARD_HEIGHT,   15
.equ    BOARD_WIDTH,    14

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Size of bricks
.equ    BRICK_WIDTH,    36
.equ    BRICK_HEIGHT,   12

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Size of the ball
.equ    BALL_WIDTH,     8
.equ    BALL_HEIGHT,    8

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Walls of the game board
.equ    WALL_LEFT_X,    3
.equ    WALL_RIGHT_X,   (WALL_LEFT_X + (BOARD_WIDTH * BRICK_WIDTH))
.equ    WALL_TOP_Y,     31
.equ    WALL_BOTTOM_Y,  (SCREEN_HEIGHT - 32)

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Board coords
.equ    BOARD_X,        (WALL_LEFT_X + 1)
.equ    BOARD_Y,        (WALL_TOP_Y + 1)


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Game structure offsets
.equ    GAME_SCORE,         0
.equ    GAME_LEVEL,         4
.equ    GAME_HISCORE,       8
.equ    GAME_LIVES,         12
.equ    GAME_BRICKS_LEFT,   16
.equ    GAME_BOARD,         20

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ True/False
.equ    TRUE,               1
.equ    FALSE,              0

