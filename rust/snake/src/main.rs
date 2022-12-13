extern crate ncurses;

use ncurses::*;
use rand::rngs::ThreadRng;
use rand::Rng;
use std::thread::sleep;
use std::time::Duration;

const SNAKE: &str = "o";
const FOOD: &str = "x";
const DELAY: u64 = 30;
const RETRY: u64 = 2000;
const TIMEOUT: i32 = 10;
const EAT_POINT: i32 = 5;

#[derive(PartialEq)]
enum Direction {
    LEFT,
    RIGHT,
    UP,
    DOWN,
}

#[derive(Clone, Copy)]
struct Point {
    x: i32,
    y: i32,
}

struct Snake {
    max_y: i32,
    max_x: i32,
    next_x: i32,
    next_y: i32,
    tail_length: i32,
    game_over: bool,
    score: i32,
    current_dir: Direction,
    snake_parts: [Point; 255],
    food: Point,
    rng: ThreadRng,
}

impl Snake {
    fn draw_screen(&self) {
        // Clears the screen - put all draw functions after this
        clear();

        // Print game over if gameOver is true
        if self.game_over {
            mvprintw(self.max_y / 2, self.max_x / 2, "Game Over!");
        }

        // Draw the snake to the screen
        let mut i: usize = 0;
        while i < self.tail_length as usize {
            mvprintw(self.snake_parts[i].y, self.snake_parts[i].x, SNAKE);
            i += 1
        }

        // Draw the current food
        mvprintw(self.food.y, self.food.x, FOOD);

        // Draw the score
        mvprintw(
            1,
            2,
            &format!(
                "Score: {} Food y:{} x:{}",
                self.score, self.food.y, self.food.x
            ),
        );

        // ncurses refresh
        refresh();

        // Delay between movements
        sleep(Duration::from_millis(DELAY));
    }

    fn shift_snake(&mut self) {
        let tmp: Point = self.snake_parts[(self.tail_length as usize) - 1];

        let mut i: usize = (self.tail_length as usize) - 1;
        while i > 0 {
            self.snake_parts[i] = self.snake_parts[i - 1];
            i -= 1;
        }
        self.snake_parts[0] = tmp;
    }

    fn create_food(&mut self) {
        self.food.x = self.rng.gen_range(0..(self.max_x - 20)) + 10;
        self.food.y = self.rng.gen_range(0..(self.max_y - 10)) + 5;
    }

    fn curses_init() {
        initscr(); // Initialize the window
        noecho(); // Don't echo keypresses
        keypad(stdscr(), true);
        cbreak();
        timeout(TIMEOUT);
        curs_set(CURSOR_VISIBILITY::CURSOR_INVISIBLE); // Don't display a cursor
    }

    fn new() -> Self {
        let mut s = Self {
            max_y: getmaxy(stdscr()),
            max_x: getmaxx(stdscr()),
            next_x: 0,
            next_y: 0,
            tail_length: 5,
            game_over: false,
            score: 0,
            current_dir: Direction::RIGHT,
            snake_parts: [Point { x: 0, y: 0 }; 255],
            food: Point { x: 0, y: 0 },
            rng: rand::thread_rng(),
        };

        clear();

        let mut i: i32 = s.tail_length;
        let mut j: usize = 0;
        while i >= 0 {
            let curr_point = Point {
                x: i,
                y: s.max_y % 2,
            };
            s.snake_parts[j] = curr_point;
            i -= 1;
            j += 1;
        }

        s.create_food();

        refresh();

        s
    }
}

fn main() {
    Snake::curses_init();
    let mut g: Snake = Snake::new();

    loop {
        getmaxy(stdscr());
        getmaxx(stdscr());

        if g.game_over {
            sleep(Duration::from_millis(RETRY));
            g = Snake::new();
        }

        let ch: i32 = getch();

        if ch == KEY_RIGHT
            && (g.current_dir != Direction::RIGHT && g.current_dir != Direction::LEFT)
        {
            g.current_dir = Direction::RIGHT;
        } else if ch == KEY_LEFT
            && (g.current_dir != Direction::LEFT && g.current_dir != Direction::RIGHT)
        {
            g.current_dir = Direction::LEFT;
        } else if ch == KEY_DOWN
            && (g.current_dir != Direction::DOWN && g.current_dir != Direction::UP)
        {
            g.current_dir = Direction::DOWN;
        } else if ch == KEY_UP
            && (g.current_dir != Direction::UP && g.current_dir != Direction::DOWN)
        {
            g.current_dir = Direction::UP;
        } else if ch == ('q' as i32) {
            break;
        }

        // Movement
        g.next_x = g.snake_parts[0].x;
        g.next_y = g.snake_parts[0].y;

        if g.current_dir == Direction::RIGHT {
            g.next_x += 1;
        } else if g.current_dir == Direction::LEFT {
            g.next_x -= 1;
        } else if g.current_dir == Direction::UP {
            g.next_y -= 1;
        } else if g.current_dir == Direction::DOWN {
            g.next_y += 1;
        }

        if g.next_x == g.food.x && g.next_y == g.food.y {
            let tail = Point {
                x: g.next_x,
                y: g.next_y,
            };

            g.snake_parts[g.tail_length as usize] = tail;

            if g.tail_length < 255 {
                g.tail_length += 1;
            } else {
                // If we have exhausted the array then just reset the tail length but let the player keep building their score :)
                g.tail_length = 5;
            }

            g.score += EAT_POINT;
            g.create_food();
        } else {
            // Draw the snake to the screen
            let mut i: usize = 0;
            while i < g.tail_length as usize {
                if g.next_x == g.snake_parts[i].x && g.next_y == g.snake_parts[i].y {
                    g.game_over = true;
                    break;
                }
                i += 1;
            }

            // We are going to set the tail as the new head
            g.snake_parts[(g.tail_length as usize) - 1].x = g.next_x;
            g.snake_parts[(g.tail_length as usize) - 1].y = g.next_y;
        }

        // Shift all the snake parts
        g.shift_snake();

        // Game Over if the player hits the screen edges
        if (g.next_x >= g.max_x || g.next_x < 0) || (g.next_y >= g.max_y || g.next_y < 0) {
            g.game_over = true;
        }

        // Draw the screen
        g.draw_screen();
    }

    /* Terminate ncurses. */
    endwin();
}
