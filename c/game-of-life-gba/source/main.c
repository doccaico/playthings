#include <gba.h>
#include <gba_video.h>
#include <gba_input.h>
/* #include <string.h> */
/* #include <stdlib.h> */
/* #include <stdio.h> */
/* #include <stdio.h> */
#include <time.h>
#include <stdlib.h>
/* #include "bricks.h" */
/* #include "main.h" */

typedef unsigned short  w16_t;
#define REG_BASE_ADDRESS 0x4000000
#define REG_KEY_STATUS (*(w16_t *)(REG_BASE_ADDRESS + 0x130))

#define CELL_SIZE 2
#define BOARD_COL (240/CELL_SIZE)
#define BOARD_ROW (160/CELL_SIZE)
/* #define INITIAL_RAND 0.35 // 0 - 1 */
#define INITIAL_RAND 0.25 // 0 - 1

#define LIVE_CELL_COLOR (u16)RGB5(0,255,0) // green
#define DEAD_CELL_COLOR (u16)RGB5(0,0,0) //black

u16 cccc = (u16)RGB5(0,255,0); // green 
int count = 0;

// get_key_state()
static unsigned get_key_state(void){
    return ~REG_KEY_STATUS;
}
typedef enum {KeyA, KeyB, KeySelect, KeyStart, KeyRight, KeyLeft, KeyUp, KeyDown, KeyShoulderRight, KeyShoulderLeft, KeyEnd, KeySentry = KeyEnd} Key;


unsigned char board[BOARD_ROW * BOARD_COL] = {0};
u16 seed = 1;


void suffle(void) {

	for (int i = 0; i < BOARD_ROW * BOARD_COL; i++) {
		if (i < abs(BOARD_ROW * BOARD_COL)*INITIAL_RAND) {
			board[i] = 1;
		}
    }

	for (int i = 0; i < BOARD_ROW * BOARD_COL; i++) {
        int j = rand() % (BOARD_ROW * BOARD_COL);
        int tmp = board[i];
        board[i] = board[j];
        board[j] = tmp;
	}
}

void drawCell(int x, int y, u16 color)
{
    u16* buf = (u16*)0x6000000;
    u32 col =  y * SCREEN_WIDTH + x;


    for (int i = 0; i < CELL_SIZE; i++) {
        for (int j = 0; j < CELL_SIZE; j++) {
            buf[col+j] = color;
        }
        col += SCREEN_WIDTH;
    }
}

void drawLiveCell(int x, int y)
{
    x *= CELL_SIZE;
    y *= CELL_SIZE;
    /* drawCell(x, y, LIVE_CELL_COLOR); */
    drawCell(x, y, cccc);
}

void drawDeadCell(int x, int y)
{
    x *= CELL_SIZE;
    y *= CELL_SIZE;
    drawCell(x, y, DEAD_CELL_COLOR);
}

void clear(void) {

    for (int i = 0; i < BOARD_ROW; i++) {
        for (int j = 0; j < BOARD_COL; j++) {
            /* board[BOARD_ROW*i+j] = 0; */
            board[BOARD_ROW*i+j] = 0;
            drawDeadCell(j, i);
        }
    }
}

int main(void) {
	/* REG_BG0CNT = CHAR_BASE(0) | SCREEN_BASE(10) | BG_16_COLOR | BG_SIZE_0; */
	/* REG_DISPCNT = MODE_0 | BG0_ON | OBJ_ON | OBJ_1D_MAP; */
	/* REG_DISPCNT = MODE_3 | BG2_ON; // | OBJ_ON | OBJ_1D_MAP; */
    /* srand((unsigned) time(NULL)); */
    srand(seed);

    SetMode(MODE_3 | BG2_ENABLE);
	
	//allow vblank bios interrupt to save battery
	irqInit();
	irqEnable(IRQ_VBLANK);

    suffle();

	for (int i = 0; i < BOARD_ROW; i++) {
        for (int j = 0; j < BOARD_COL; j++) {
            if (board[BOARD_ROW*i+j] == 1)
                drawLiveCell(j, i);
        }
    }

	for(;;){

        w16_t key_state = get_key_state();

        if(key_state & (1<<KeySelect)){
            seed++;
            count++;
            switch(count) {
                case 1:
                    cccc = (u16)RGB5(255,255,0); //yello
                    break;
                case 2:
                    cccc = (u16)RGB5(255,0,0); //yello
                    break;
                case 3:
                    cccc = (u16)RGB5(255,255,255); //yello
                    break;
            }
            clear();
        }
        if(key_state & (1<<KeyStart)){
            seed++;
            suffle();
            for (int i = 0; i < BOARD_ROW; i++) {
                for (int j = 0; j < BOARD_COL; j++) {
                    if (board[BOARD_ROW*i+j] == 1)
                        drawLiveCell(j, i);
                }
            }
        }

        VBlankIntrWait();
    }
	return 0;
}



	/* u32 x   = 47; */
	/* u32 y   = 31; */
	/* drawLiveCell(x, y); */
    /*  */
	/* #<{(| Mode3PutPixel(x, y, col); |)}># */
    /*  */
    /* x = 0; */
    /* y = 0; */
	/* drawLiveCell(x, y); */
    /*  */
    /* x = 47; */
    /* y = 0; */
	/* drawLiveCell(x, y); */
    /*  */
    /* x = 0; */
    /* y = 31; */
	/* drawLiveCell(x, y); */
    /*  */
    /* x = 0; */
    /* y = 30; */
	/* drawDeadCell(x, y); */

	//load palette, tiles, map
	/* memcpy(BG_PALETTE, bgPal, bgPalLen); */
	/* memcpy(CHAR_BASE_BLOCK(0), bgTiles, bgTilesLen); */
	/* memcpy(SCREEN_BASE_BLOCK(10), bgMap, bgMapLen); */
	/* memcpy(SPRITE_PALETTE, bricksPal, bricksPalLen); */
	/* memcpy(SPRITE_GFX, bricksTiles, bricksTilesLen); */
	/*  */
	/* init_oam(obj_buffer, 128); */
	
	//bricks
	/* restartGame: */
	/* for (u32 j=0;j<5;j++){ */
	/* 	for (u32 i=0;i<13;i++){ */
	/* 		obj_buffer[i+j*13].attr0 = OBJ_Y(16+j*8) | ATTR0_COLOR_256 | ATTR0_NORMAL | ATTR0_WIDE | OBJ_TRANSLUCENT; */
	/* 		obj_buffer[i+j*13].attr1 = OBJ_X(16+16*i) | ATTR1_SIZE_8; */
	/* 		obj_buffer[i+j*13].attr2 = OBJ_CHAR(j*4);	 */
	/* 	} */
	/* } */
	
	/* //paddle */
	/* u32 paddleX = 108; */
	/* u32 key_states = 0; */
	/* obj_buffer[65].attr0 = OBJ_Y(150) | ATTR0_COLOR_256 | ATTR0_NORMAL | ATTR0_WIDE | OBJ_TRANSLUCENT; */
	/* obj_buffer[65].attr1 = OBJ_X(paddleX) | ATTR1_SIZE_8;	 */
	/* obj_buffer[65].attr2 = OBJ_CHAR(22); */
	/* obj_buffer[66].attr0 = OBJ_Y(150) | ATTR0_COLOR_256 | ATTR0_NORMAL | ATTR0_WIDE | OBJ_TRANSLUCENT; */
	/* obj_buffer[66].attr1 = OBJ_X(paddleX+16) | ATTR1_SIZE_8;	 */
	/* obj_buffer[66].attr2 = OBJ_CHAR(26); */
	/*  */
	/* //ball */
	/* u32 ballX = 120; */
	/* u32 ballY = 70; */
	/* s32 xVel = 2; */
	/* s32 yVel = 1; */
	/* obj_buffer[67].attr0 = OBJ_Y(ballY) | ATTR0_COLOR_256 | ATTR0_NORMAL | ATTR0_SQUARE | OBJ_TRANSLUCENT; */
	/* obj_buffer[67].attr1 = OBJ_X(ballX) | ATTR1_SIZE_8;	 */
	/* obj_buffer[67].attr2 = OBJ_CHAR(20);		 */
			
	/* oam_copy(OAM, obj_buffer, 128); */
	/*  */
    /* int i = 4+(2*13); */
    /* obj_buffer[i].attr0 |= OBJ_DISABLE; */

    /* obj_buffer[i+j*13].attr0 = OBJ_Y(16+j*8) | ATTR0_COLOR_256 | ATTR0_NORMAL | ATTR0_WIDE | OBJ_TRANSLUCENT; */
    /* obj_buffer[i+j*13].attr1 = OBJ_X(16+16*i) | ATTR1_SIZE_8; */
    /* obj_buffer[i].attr2 = OBJ_CHAR(2*4);	 */



    /* VBlankIntrWait(); */
    /* oam_copy(OAM, obj_buffer, 128); */


    /* obj_buffer[i].attr0 = OBJ_Y(0+4*8) | ATTR0_COLOR_256 | ATTR0_NORMAL | ATTR0_WIDE | OBJ_TRANSLUCENT; */
    /* obj_buffer[i].attr0 = OBJ_Y(0+4*8) | ATTR0_COLOR_16 | ATTR0_NORMAL | ATTR0_SQUARE | OBJ_TRANSLUCENT; */
    /* VBlankIntrWait(); */
    /* oam_copy(OAM, obj_buffer, 128); */
  
	/* for(;;){ */
	/* 	//paddle */
	/* 	scanKeys(); */
	/* 	key_states = ~REG_KEYINPUT & KEY_ANY; */
	/* 	u32 paddleDir = 0; */
	/* 	if (key_states & KEY_LEFT && paddleX > 16) */
	/* 	  paddleDir = -1; */
	/* 	else if (key_states & KEY_RIGHT && paddleX < 192) */
	/* 	  paddleDir = 1; */
	/* 	else if (key_states & KEY_L && key_states & KEY_R) */
	/* 		goto restartGame; */
	/* 	if (paddleDir != 0) */
	/* 		paddleX += paddleDir * 2; */
	/* 	obj_buffer[65].attr1 = OBJ_X(paddleX) | ATTR1_SIZE_8; */
	/* 	obj_buffer[66].attr1 = OBJ_X(paddleX+16) | ATTR1_SIZE_8; */
	/* 	 */
	/* 	//collision management */
	/* 	if (ballX < 17){ */
	/* 		ballX += 3; */
	/* 		xVel *= -1; */
	/* 	} */
	/* 	if (ballX > 215){ */
	/* 		ballX -= 3; */
	/* 		xVel *= -1; */
	/* 	} */
	/* 	if (ballY > 138 && ballY < 152){ */
	/* 		if (checkCollision(ballX,ballY,paddleX,150,32,8)){ */
	/* 			yVel = -1 * abs(yVel); */
	/* 			ballY -= 3; */
	/* 			if (ballX-paddleX < 10)  //left third */
	/* 				xVel = -1 * abs(xVel); */
	/* 			else if (ballX-paddleX > 20) //right third */
	/* 				xVel = abs(xVel); */
	/* 		} */
	/* 	} */
	/* 	if (ballY > 159){ //out of bounds */
	/* 		ballX = 120; */
	/* 		ballY = 70; */
	/* 	}		 */
	/* 	if (ballY < 2){ */
	/* 		ballY += 3; */
	/* 		yVel = abs(yVel); */
	/* 	} */
	/* 	 */
	/* 	//let's break some bricks! */
	/* 	for (u32 j=0;j<5;j++){ */
	/* 		u32 brickY = 16+j*8; */
	/* 		for (u32 l=0;l<13;l++){ */
	/* 			if (checkCollision(ballX,ballY,(l+1)*16,brickY+1,3,6) && !(obj_buffer[l+j*13].attr0 & OBJ_DISABLE)){ //hits left end of brick  */
	/* 				xVel = -1 * abs(xVel); */
	/* 				ballX -= 2; */
	/* 				obj_buffer[l+j*13].attr0 |= OBJ_DISABLE; */
	/* 				goto skipCollisionCheck; */
	/* 			} */
	/* 			else if (checkCollision(ballX,ballY,((l+1)*16)+15,brickY+1,3,6) && !(obj_buffer[l+j*13].attr0 & OBJ_DISABLE)){ //hits right end of brick  */
	/* 				xVel = abs(xVel); */
	/* 				ballX += 2; */
	/* 				obj_buffer[l+j*13].attr0 |= OBJ_DISABLE; */
	/* 				goto skipCollisionCheck; */
	/* 			} */
	/* 		} */
	/* 		 */
	/* 		if (checkCollision(ballX,ballY,16,brickY+4,210,5)){  //hits bottom of row */
	/* 			for (u32 l=0;l<13;l++){ */
	/* 				if (!(obj_buffer[l+j*13].attr0 & OBJ_DISABLE) && checkCollision(ballX,ballY,(l+1)*16,brickY,16,8)){ */
	/* 					yVel = abs(yVel); */
	/* 					ballY += 3; */
	/* 					obj_buffer[l+j*13].attr0 |= OBJ_DISABLE; */
	/* 				} */
	/* 			} */
	/* 		} */
	/* 		else if (checkCollision(ballX,ballY,16,brickY,210,5)){ //hits top of row */
	/* 			for (u32 l=0;l<13;l++){ */
	/* 				if (!(obj_buffer[l+j*13].attr0 & OBJ_DISABLE) && checkCollision(ballX,ballY,(l+1)*16,16+j*8,16,8)){ */
	/* 					yVel = -1*abs(yVel); */
	/* 					ballY -= 3; */
	/* 					obj_buffer[l+j*13].attr0 |= OBJ_DISABLE; */
	/* 				}	 */
	/* 			} */
	/* 		} */
	/* 		skipCollisionCheck: ; */
	/* 		 */
	/* 	} */
	/* 	 */
	/* 	//ball movement */
	/* 	ballX += xVel; */
	/* 	ballY += yVel; */
	/* 	obj_buffer[67].attr0 = OBJ_Y(ballY) | ATTR0_COLOR_256 | ATTR0_NORMAL | ATTR0_SQUARE | OBJ_TRANSLUCENT; */
	/* 	obj_buffer[67].attr1 = OBJ_X(ballX) | ATTR1_SIZE_8; */
	/* 	 */
	/* 	 */
	/* 	oam_copy(OAM, obj_buffer, 128); */
	/* } */
  
/* int checkCollision(u32 ax, u32 ay, u32 bx, u32 by, u32 bw, u32 bh){ */
/*   return !(ay+8 <= by || ay >= by+bh || ax >= bx+bw || ax+8 <= bx); */
/* } */


/* // Start tonclib snippet */
/* OBJATTR obj_buffer[128] ; */
/* OBJAFFINE *const  obj_aff_buffer = (OBJAFFINE*)obj_buffer; */
/*  */
/* void oam_copy(OBJATTR *dst, const OBJATTR *src, u32 count) { */
/*  */
/* // NOTE: while struct-copying is the Right Thing to do here, */
/* //	 there's a strange bug in DKP that sometimes makes it not work */
/* //	 If you see problems, just use the word-copy version. */
/* #if 1 */
/* 	while(count--) */
/* 		*dst++ = *src++; */
/* #else */
/* 	u32 *dstw= (u32*)dst, *srcw= (u32*)src; */
/* 	while(count--) */
/* 	{ */
/* 		*dstw++ = *srcw++; */
/* 		*dstw++ = *srcw++; */
/* 	} */
/* #endif */
/*  */
/* } */
/*  */
/* void init_oam(OBJATTR *obj, u32 count) { */
/* 	u32 nn = count; */
/* 	u32 *dst = (u32*)obj; */
/*  */
/* 	// Hide each object */
/* 	while (nn--) */
/* 	{ */
/* 		*dst++ = OBJ_DISABLE; */
/* 		*dst++ = 0; */
/* 	} */
/*  */
/* 	oam_copy(OAM, obj, count); */
/* } */
