use rand::seq::SliceRandom;
use rand::thread_rng;

use std::thread;
use std::time;

// 2022/07/07
// $ cargo build --release
// $ ls -l ./target/release/cgol2
// 293280
// $ ls -lh ./target/release/cgol2
// 287K

struct Cgol {
    board: Vec<Vec<bool>>,
    neighbors: Vec<Vec<i32>>,
    col: usize,
    row: usize,
    ratio: f64,
    delay: time::Duration,
}

impl Cgol {

    fn new(col: usize, row: usize, ratio: f64, delay: u64) -> Self {

        let mut g = Cgol {
            board: vec![vec![false; col + 2]; row + 2],
            neighbors: vec![vec![0; col + 2]; row + 2],
            col: col + 2,
            row: row + 2,
            ratio: ratio,
            delay: time::Duration::from_millis(delay),
        };

        for row in g.board[1..g.row - 1].iter_mut() {
            for (j, col) in row[1..g.col - 1].iter_mut().enumerate() {
                if j < (( (g.col-2) as f64) * g.ratio) as usize {
                    *col = true;
                }
            }
        }
        g
    }

    fn randomize(&mut self) {

        let mut rng = thread_rng();

        for row in self.board[1..self.row - 1].iter_mut() {
            row[1..self.col - 1].shuffle(&mut rng);
        }
    }

    fn clear(&self) {
        print!("{esc}[2J{esc}[1;1H", esc = 27 as char);
    }

    fn render(&self) {
        for row in self.board[1..self.row - 1].iter() {
            for col in row[1..self.col - 1].iter() {
                let mark = if *col { '*' } else { ' ' };
                print!("{}", mark);
            }
            println!();
        }
    }

    fn update(&mut self) {

        self.count_neighbors();

        for row in 1..self.row - 1 {
            for col in 1..self.col - 1 {
                if self.neighbors[row][col] == 2 {
                    // do nothing
                } else if self.neighbors[row][col] == 3{
                    self.board[row][col] = true
                } else {
                    self.board[row][col] = false
                }
            }
        }
    }

    fn count_neighbors(&mut self) {
        for row in 1..self.row - 1 {
            for col in 1..self.col - 1 {
                let count =
                    // top-left
                    self.board[row-1][col-1] as i32 +
                    // top-middle
                    self.board[row-1][col] as i32 +
                    // top-right
                    self.board[row-1][col+1] as i32 +
                    // left
                    self.board[row][col-1] as i32 +
                    // right
                    self.board[row][col+1] as i32 +
                    // bottom-left
                    self.board[row+1][col-1] as i32 +
                    // bottom-middle
                    self.board[row+1][col] as i32 +
                    // bottom-right
                    self.board[row+1][col+1] as i32;

                self.neighbors[row][col] = count;
            }
        }
    }

    fn sleep(&self) {
        thread::sleep(self.delay);
    }
}

fn main() {

    const WIDTH: usize =  50;
    const HEIGHT: usize = 30;
    const RATIO: f64 = 0.25;
    const DELAY: u64 = (1000.0 * 0.075) as u64;

    let mut g = Cgol::new(WIDTH, HEIGHT, RATIO, DELAY);

    g.randomize();

    loop {
        g.clear();
        g.render();
        g.update();
        g.sleep();
    }
}
