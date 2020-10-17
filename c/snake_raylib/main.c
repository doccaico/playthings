// gcc -Wall -O2 main.c -lraylib -ldl -lpthread -lm -lX11 -o snake && ./snake

#include <stdio.h>

#include "raylib.h"

#define TITLE "Snake"
#define FPS 60
#define SNAKE_LENGTH 10
#define SQUARE_SIZE 15
#define SCREEN_WIDTH  300
#define SCREEN_HEIGHT 300
#define FONT_SIZE 17

// color https://www.raylib.com/cheatsheet/cheatsheet.html#colors
#define BACKGROUND_COLOR WHITE
#define HEAD_COLOR DARKBLUE
#define BODY_COLOR BLUE
#define FRUIT_COLOR RED
#define FONT_COLOR GRAY

typedef struct Snake {
    Vector2 pos;
    Vector2 size;
    Vector2 speed;
    Color   color;
} Snake;

typedef struct Food {
    Vector2 pos;
    Vector2 size;
    bool active;
    Color color;
} Food;

typedef struct Game {
    int screen_width;
    int screen_height;
    int frames_counter;
    bool game_over;
    bool game_pause;
    Food fruit;
    Snake snake[SNAKE_LENGTH];
    Vector2 snake_pos[SNAKE_LENGTH];
    bool allow_move;
    Vector2 offset;
    int counter_tail;
} Game;

void init(Game *g) {
    g->screen_width = SCREEN_WIDTH;
    g->screen_height = SCREEN_HEIGHT;

    g->frames_counter = 0;
    g->game_over = false;
    g->game_pause = false;

    g->counter_tail = 1;
    g->allow_move = false;

    g->offset.x = g->screen_width % SQUARE_SIZE;
    g->offset.y = g->screen_height % SQUARE_SIZE;

    for (int i = 0; i < SNAKE_LENGTH; i++) {
        g->snake[i].pos.x = g->offset.x/2;
        g->snake[i].pos.y = g->offset.y/2;
        g->snake[i].size.x = SQUARE_SIZE;
        g->snake[i].size.y = SQUARE_SIZE;
        g->snake[i].speed.x = SQUARE_SIZE;
        g->snake[i].speed.y = 0;
        if (i == 0) {
            // snake's head
            g->snake[i].color = HEAD_COLOR;
        } else {
            // snake's body
            g->snake[i].color = BODY_COLOR;
        }
    }
    for (int i = 0; i < SNAKE_LENGTH; i++) {
        g->snake_pos[i].x = 0.0;
        g->snake_pos[i].y = 0.0;
    }

    // fruit
    g->fruit.size = (Vector2){SQUARE_SIZE, SQUARE_SIZE};
    g->fruit.color = FRUIT_COLOR;
    g->fruit.active = false;
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
        for (int i = 0; i < g->counter_tail; i++) {
            g->snake_pos[i] = g->snake[i].pos;
        }
        if (g->frames_counter%5 == 0) {
            for (int i = 0; i < g->counter_tail; i++) {
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
        if (((g->snake[0].pos.x) > (g->screen_width - g->offset.x)) ||
                ((g->snake[0].pos.y) > (g->screen_height - g->offset.y)) ||
                (g->snake[0].pos.x < 0) ||
                (g->snake[0].pos.y < 0)) {
            g->game_over = true;
        }

        // collision with yourself
        for (int i = 1; i < g->counter_tail; i++) {
            if (g->snake[0].pos.x == g->snake[i].pos.x && g->snake[0].pos.y == g->snake[i].pos.y) {
                g->game_over = true;
            }
        }

        if (!g->fruit.active) {
            g->fruit.active = true;
            g->fruit.pos.x = GetRandomValue(0, (g->screen_width/SQUARE_SIZE) - 1) * SQUARE_SIZE+g->offset.x / 2;
            g->fruit.pos.y = GetRandomValue(0, (g->screen_height/SQUARE_SIZE) - 1) * SQUARE_SIZE+g->offset.y / 2;

            for (int i = 0; i < g->counter_tail; i++) {
                while (g->fruit.pos.x == g->snake[i].pos.x && g->fruit.pos.y == g->snake[i].pos.y) {
                    g->fruit.pos.x = GetRandomValue(0, (g->screen_width / SQUARE_SIZE) - 1) * SQUARE_SIZE;
                    g->fruit.pos.y = GetRandomValue(0, (g->screen_width / SQUARE_SIZE) - 1) * SQUARE_SIZE;
                    i = 0;
                }
            }
        }

        // collision
        if (CheckCollisionRecs(
                    (Rectangle){g->snake[0].pos.x, g->snake[0].pos.y, g->snake[0].size.x, g->snake[0].size.y},
                    (Rectangle){g->fruit.pos.x, g->fruit.pos.y, g->fruit.size.x, g->fruit.size.y})
           ) {
            g->snake[g->counter_tail].pos = g->snake_pos[g->counter_tail-1];
            g->counter_tail += 1;
            g->fruit.active = false;
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

    if (!g->game_over) {
        // Draw snake
        for (int i = 0; i < g->counter_tail; i++) {
            DrawRectangleV(g->snake[i].pos, g->snake[i].size, g->snake[i].color);
        }
        // Draw fruit to pick
        DrawRectangleV(g->fruit.pos, g->fruit.size, g->fruit.color);
    } else {
        const char *text = "PRESS [ENTER] TO PLAY AGAIN";
        const int pos_x = GetScreenWidth() / 2 - MeasureText(text, FONT_SIZE) / 2;
        const int pos_y = GetScreenHeight() / 2 - 50;
        DrawText(text, pos_x, pos_y, FONT_SIZE, FONT_COLOR);
    }
}

int main(void) {

    Game g;
    init(&g);

    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, TITLE);

    SetTargetFPS(FPS);

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        update(&g);

        // Draw
        BeginDrawing();
        ClearBackground(BACKGROUND_COLOR);
        draw(&g);
        EndDrawing();
    }

    CloseWindow();

    return 0;
}
