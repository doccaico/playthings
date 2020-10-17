// gcc -Wall -O2 main.c -lraylib -ldl -lpthread -lm -lX11 -o snake_customized && ./snake_customized

// On Windows (msys2 mingw64)                                                                                                      
// gcc snake_customized.c -o snake_customized -O2 -s -static -Wl,--subsystem,windows -lraylib -lgdi32 -lwinmm && ./snake_customized

#include "raylib.h"

#define TITLE "Snake"
#define FPS 60
#define SQUARE_SIZE 15
#define WALL_SIZE SQUARE_SIZE
#define SCREEN_WIDTH  300
#define SCREEN_HEIGHT 300
#define FONT_SIZE 17

// you win when you eat a food 'MAX_SNAKE_LEN' times
#define MAX_SNAKE_LEN 10

typedef struct Snake {
    Vector2 pos;
    Vector2 speed;
} Snake;

typedef struct Food {
    Vector2 pos;
    bool active;
} Food;

typedef struct Game {
    Snake snake[MAX_SNAKE_LEN];
    Food food;
    Vector2 snake_pos[MAX_SNAKE_LEN];
    int snake_len;
    int frames_counter;
    bool game_win;
    bool game_over;
    bool allow_move;
    Color background_color;
    Color wall_color;
    Color head_color;
    Color body_color;
    Color food_color;
    Color font_color;
    Color win_text_color;
    Color lose_text_color;
} Game;

void init(Game *g) {

    g->frames_counter = 0;
    g->snake_len = 1;
    g->game_win = false;
    g->game_over = false;
    g->allow_move = false;
    g->food.active = false;

    for (int i = 0; i < MAX_SNAKE_LEN; i++) {
        // snake's starting position
        g->snake[i].pos.x = WALL_SIZE;
        g->snake[i].pos.y = WALL_SIZE;

        // snake go right when the game is started
        g->snake[i].speed.x = SQUARE_SIZE;
        g->snake[i].speed.y = 0;
    }
    for (int i = 0; i < MAX_SNAKE_LEN; i++) {
        g->snake_pos[i].x = 0.0;
        g->snake_pos[i].y = 0.0;
    }

    // https://www.raylib.com/cheatsheet/cheatsheet.html#colors
    g->background_color = WHITE;
    g->wall_color = BLACK;
    g->head_color = DARKBLUE;
    g->body_color = BLUE;
    g->food_color = RED;
    g->win_text_color = BLUE;
    g->lose_text_color = GRAY;
}

void update(Game *g) {

    if (!g->game_over) {

        // input
        if (IsKeyDown(KEY_RIGHT) && g->snake[0].speed.x == 0 && g->allow_move) {
            g->snake[0].speed.x = SQUARE_SIZE;
            g->snake[0].speed.y = 0;
            g->allow_move = false;
        }
        if (IsKeyDown(KEY_LEFT) && g->snake[0].speed.x == 0 && g->allow_move)  {
            g->snake[0].speed.x = -SQUARE_SIZE;
            g->snake[0].speed.y = 0;
            g->allow_move = false;
        }
        if (IsKeyDown(KEY_UP) && g->snake[0].speed.y == 0 && g->allow_move)    {
            g->snake[0].speed.x = 0;
            g->snake[0].speed.y = -SQUARE_SIZE;
            g->allow_move = false;
        }
        if (IsKeyDown(KEY_DOWN) && g->snake[0].speed.y == 0 && g->allow_move) {
            g->snake[0].speed.x = 0;
            g->snake[0].speed.y = SQUARE_SIZE;
            g->allow_move = false;
        }

        // movement
        for (int i = 0; i < g->snake_len; i++) {
            g->snake_pos[i] = g->snake[i].pos;
        }
        if (g->frames_counter%5 == 0) {
            for (int i = 0; i < g->snake_len; i++) {
                if (i == 0) {
                    g->snake[0].pos.x += g->snake[0].speed.x;
                    g->snake[0].pos.y += g->snake[0].speed.y;
                    g->allow_move = true;
                } else {
                    g->snake[i].pos = g->snake_pos[i-1];
                }
            }
        }

        // wall behaviour
        if (((g->snake[0].pos.x) >= (SCREEN_WIDTH - WALL_SIZE)) ||
                ((g->snake[0].pos.y) >= (SCREEN_HEIGHT - WALL_SIZE)) ||
                (g->snake[0].pos.x < WALL_SIZE) ||
                (g->snake[0].pos.y < WALL_SIZE)) {
            g->game_over = true;
        }

        // collision with yourself
        for (int i = 1; i < g->snake_len; i++) {
            if (g->snake[0].pos.x == g->snake[i].pos.x && g->snake[0].pos.y == g->snake[i].pos.y) {
                g->game_over = true;
            }
        }

        // set the position of food
        if (!g->food.active) {
            g->food.pos.x = GetRandomValue(1, (SCREEN_WIDTH / SQUARE_SIZE) - 2) * SQUARE_SIZE;
            g->food.pos.y = GetRandomValue(1, (SCREEN_HEIGHT / SQUARE_SIZE) - 2) * SQUARE_SIZE;

            for (int i = 0; i < g->snake_len; i++) {
                while (g->food.pos.x == g->snake[i].pos.x && g->food.pos.y == g->snake[i].pos.y) {
                    g->food.pos.x = GetRandomValue(1, (SCREEN_WIDTH / SQUARE_SIZE) - 2) * SQUARE_SIZE;
                    g->food.pos.y = GetRandomValue(1, (SCREEN_WIDTH / SQUARE_SIZE) - 2) * SQUARE_SIZE;
                    i = 0;
                }
            }

            g->food.active = true;
        }

        // collision with food
        if (CheckCollisionRecs(
                    (Rectangle){g->snake[0].pos.x, g->snake[0].pos.y, SQUARE_SIZE, SQUARE_SIZE},
                    (Rectangle){g->food.pos.x, g->food.pos.y, SQUARE_SIZE, SQUARE_SIZE})
           ) {

            // win
            if (g->snake_len  == MAX_SNAKE_LEN) {
                g->game_win = true;
                g->game_over = true;
            } else {
                g->snake[g->snake_len].pos = g->snake_pos[g->snake_len-1];
                g->snake_len += 1;
                g->food.active = false;
            }
        }

        g->frames_counter++;

    } else {

        if (IsKeyDown(KEY_ENTER)) {
            init(g);
            g->game_over = false;
        }
    }
}

void draw(Game *g) {

    if (g->game_win) {
        const char *text = "YOU WIN.\nPRESS [ENTER] TO PLAY AGAIN";
        const int x = GetScreenWidth() / 2 - MeasureText(text, FONT_SIZE) / 2;
        const int y = GetScreenHeight() / 2 - 50;
        DrawText(text, x, y, FONT_SIZE, g->win_text_color);

    } else if (!g->game_over) {
        const Vector2 size = {SQUARE_SIZE, SQUARE_SIZE};
        // draw wall
        for (int i = 0; i < (SCREEN_WIDTH / SQUARE_SIZE); i++) {
            const Vector2 top = {i * SQUARE_SIZE, 0};
            const Vector2 bottom = {i * SQUARE_SIZE, SCREEN_HEIGHT - SQUARE_SIZE};
            DrawRectangleV(top,    size, g->wall_color);
            DrawRectangleV(bottom, size, g->wall_color);
        }
        for (int i = 0; i < (SCREEN_HEIGHT / SQUARE_SIZE); i++) {
            const Vector2 left = {0, i * SQUARE_SIZE};
            const Vector2 right = {SCREEN_WIDTH - SQUARE_SIZE, i * SQUARE_SIZE};
            DrawRectangleV(left,  size, g->wall_color);
            DrawRectangleV(right, size, g->wall_color);
        }
        // draw snake
        DrawRectangleV(g->snake[0].pos, size, g->head_color);
        for (int i = 1; i < g->snake_len; i++) {
            DrawRectangleV(g->snake[i].pos, size, g->body_color);
        }
        // draw food to pick
        DrawRectangleV(g->food.pos, size, g->food_color);
    } else  {
        const char *text = "YOU LOSE.\nPRESS [ENTER] TO PLAY AGAIN";
        const int x = GetScreenWidth() / 2 - MeasureText(text, FONT_SIZE) / 2;
        const int y = GetScreenHeight() / 2 - 50;
        DrawText(text, x, y, FONT_SIZE, g->lose_text_color);
    }
}

int main(void) {

    Game g;
    init(&g);

    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, TITLE);
    SetTargetFPS(FPS);

    // main game loop
    while (!WindowShouldClose())    // detect window close button or ESC key
    {
        // update
        update(&g);

        // draw
        BeginDrawing();
        ClearBackground(g.background_color);
        draw(&g);
        EndDrawing();
    }

    CloseWindow();

    return 0;
}
