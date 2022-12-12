// Original: ncurses-snake https://github.com/Sheep42/ncurses-snake

const std = @import("std");
const c = @import("c.zig");

const DELAY = 30000;
const TIMEOUT = 10;

const DirectionType = enum { LEFT, RIGHT, UP, DOWN };

const Point = struct {
    x: i32,
    y: i32,
};

var x: i32 = 0;
var y: i32 = 0;
var maxY: i32 = 0;
var maxX: i32 = 0;
var nextX: i32 = 0;
var nextY: i32 = 0;

var tailLength: i32 = undefined;
var gameOver: bool = undefined;
var score: i32 = undefined;
var currentDir: DirectionType = undefined;
var snakeParts: [255]Point = undefined;
var food: Point = undefined;

fn create_food() void {
    // Food.x is a random int between 10 and maxX - 10
    food.x = @rem(c.rand(), (maxX - 20)) + 10;
    // it's not works
    // food.x = random.intRangeAtMost(i32, 0, ((maxX - 20) - 1) + 10);
    // food.x = random.intRangeAtMost(i32, 0, maxX - 20) - 1 + 10;

    // Food.y is a random int between 5 and maxY - 5
    food.y = @rem(c.rand(), (maxY - 10)) + 5;
    // it's not works
    // food.y = random.intRangeAtMost(i32, 0, ((maxY - 10) - 1) + 5);
    // food.y = random.intRangeAtMost(i32, 0, maxY - 10) - 1 + 5;
}

fn draw_part(drawPoint: Point) void {
    _ = c.mvprintw(drawPoint.y, drawPoint.x, "o");
}

fn curses_init() void {
    _ = c.initscr(); // Initialize the window
    _ = c.noecho(); // Don't echo keypresses
    _ = c.keypad(c.stdscr, true);
    _ = c.cbreak();
    _ = c.timeout(TIMEOUT);
    _ = c.curs_set(0); // Don't display a cursor

    // Global var stdscr is created by the call to initscr()
    maxY = c.getmaxy(c.stdscr);
    maxX = c.getmaxx(c.stdscr);
}

fn init() !void {
    c.srand(@intCast(u32, c.time(0)));

    currentDir = .RIGHT;
    tailLength = 5;
    gameOver = false;
    score = 0;

    _ = c.clear(); // Clears the screen

    // Set the initial snake coords
    var i: i32 = tailLength;
    var j: usize = 0;
    while (i >= 0) : ({
        i -= 1;
        j += 1;
    }) {
        var currPoint = Point{
            .x = i,
            .y = @divTrunc(maxY, 2), // Start mid screen on the y axis
        };

        snakeParts[j] = currPoint;
    }

    create_food();

    _ = c.refresh();
}

fn shift_snake() void {
    const tmp: Point = snakeParts[@intCast(usize, tailLength) - 1];

    var i: usize = @intCast(usize, tailLength) - 1;
    while (i > 0) : (i -= 1) {
        snakeParts[i] = snakeParts[i - 1];
    }
    snakeParts[0] = tmp;
}

fn draw_screen() void {
    // Clears the screen - put all draw functions after this
    _ = c.clear();

    // Print game over if gameOver is true
    if (gameOver) {
        _ = c.mvprintw(@divTrunc(maxY, 2), @divTrunc(maxX, 2), "Game Over!");
    }

    // Draw the snake to the screen
    var i: usize = 0;
    while (i < tailLength) : (i += 1) {
        draw_part(snakeParts[i]);
    }

    // Draw the current food
    draw_part(food);

    // Draw the score
    _ = c.mvprintw(1, 2, "Score: %i Food y:%i x:%i", score, food.y, food.x);

    // ncurses refresh
    _ = c.refresh();

    // Delay between movements
    _ = c.usleep(DELAY);
}

pub fn main() !void {
    curses_init();
    try init();

    var ch: i32 = undefined;
    while (true) {
        // Global var stdscr is created by the call to initscr()
        // This tells us the max size of the terminal window at any given moment
        maxY = c.getmaxy(c.stdscr);
        maxX = c.getmaxx(c.stdscr);

        if (gameOver) {
            _ = c.sleep(2);
            try init();
        }

        // Input Handler
        ch = c.getch();

        if (ch == c.KEY_RIGHT and (currentDir != .RIGHT and currentDir != .LEFT)) {
            currentDir = .RIGHT;
        } else if (ch == c.KEY_LEFT and (currentDir != .RIGHT and currentDir != .LEFT)) {
            currentDir = .LEFT;
        } else if (ch == c.KEY_DOWN and (currentDir != .UP and currentDir != .DOWN)) {
            currentDir = .DOWN;
        } else if (ch == c.KEY_UP and (currentDir != .UP and currentDir != .DOWN)) {
            currentDir = .UP;
        }

        // Movement
        nextX = snakeParts[0].x;
        nextY = snakeParts[0].y;

        if (currentDir == .RIGHT) {
            nextX += 1;
        } else if (currentDir == .LEFT) {
            nextX -= 1;
        } else if (currentDir == .UP) {
            nextY -= 1;
        } else if (currentDir == .DOWN) {
            nextY += 1;
        }

        if (nextX == food.x and nextY == food.y) {
            const tail = Point{
                .x = nextX,
                .y = nextY,
            };

            snakeParts[@intCast(usize, tailLength)] = tail;

            if (tailLength < 255) {
                tailLength += 1;
            } else {
                // If we have exhausted the array then just reset the tail length but let the player keep building their score :)
                tailLength = 5;
            }

            score += 5;
            create_food();
        } else {
            // Draw the snake to the screen
            var i: usize = 0;
            while (i < tailLength) : (i += 1) {
                if (nextX == snakeParts[i].x and nextY == snakeParts[i].y) {
                    gameOver = true;
                    break;
                }
            }

            // We are going to set the tail as the new head
            snakeParts[@intCast(usize, tailLength) - 1].x = nextX;
            snakeParts[@intCast(usize, tailLength) - 1].y = nextY;
        }

        // Shift all the snake parts
        shift_snake();

        // Game Over if the player hits the screen edges
        if ((nextX >= maxX or nextX < 0) or (nextY >= maxY or nextY < 0)) {
            gameOver = true;
        }

        // Draw the screen
        draw_screen();
    }

    _ = c.endwin(); // Restore normal terminal behavior
    _ = c.nocbreak();
}
