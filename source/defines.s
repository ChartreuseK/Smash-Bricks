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
@ Ball collision points (just a square inset 0)
.equ    BALL_1_X,       0 
.equ    BALL_1_Y,       0

.equ    BALL_2_X,       (BALL_WIDTH + 1)
.equ    BALL_2_Y,       0

.equ    BALL_3_X,       0
.equ    BALL_3_Y,       (BALL_HEIGHT + 1 )

.equ    BALL_4_X,       (BALL_WIDTH + 1)
.equ    BALL_4_Y,       (BALL_HEIGHT + 1)



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Walls of the game board
.equ    WALL_LEFT_X,    3
.equ    WALL_RIGHT_X,   (WALL_LEFT_X + (BOARD_WIDTH * BRICK_WIDTH)+1)
.equ    WALL_TOP_Y,     31
.equ    WALL_BOTTOM_Y,  (SCREEN_HEIGHT - 32 + 1)

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Board coords
.equ    BOARD_X,        (WALL_LEFT_X + 1)
.equ    BOARD_Y,        (WALL_TOP_Y + 1)

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Special bricks
.equ    BRICK_NONE,         255         @ -1

@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@
@ Game structure offsets
.equ    GAME_SCORE,         0
.equ    GAME_LEVEL,         4
.equ    GAME_HISCORE,       8
.equ    GAME_LIVES,         12
.equ    GAME_BRICKS_LEFT,   16
.equ    GAME_BALL_X,        20
.equ    GAME_BALL_Y,        24
.equ    GAME_BALL_H_DIR,    28
.equ    GAME_BALL_V_DIR,    32
.equ    GAME_BALL_H_SPEED,  36
.equ    GAME_BALL_V_SPEED,  40
.equ    GAME_BALL_H_COUNT,  44
.equ    GAME_BALL_V_COUNT,  48
.equ    GAME_BOARD,         52

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ True/False
.equ    TRUE,               1
.equ    FALSE,              0



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Named colours
.equ    BLACK,              0
.equ    WHITE,              1
.equ    RED,                2
.equ    GREEN,              3
.equ    BLUE,               4
