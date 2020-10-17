use rand::seq::SliceRandom;
use rand::thread_rng;

use std::thread;
use std::time;

// 2022/07/06
// cargo build --release
// 287K

struct Cgol {
    board: Vec<Vec<bool>>,
    col: usize,
    row: usize,
    ratio: f64,
}

impl Cgol {

    fn new(col: usize, row: usize, ratio: f64) -> Self {

        let mut g = Cgol {
            board: vec![vec![false; col + 2]; row + 2],
            col: col + 2,
            row: row + 2,
            ratio: ratio,
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

        let mut neighbors = vec![vec![0; self.col]; self.row];

        self.count_neighbors(&mut neighbors);

        for row in 1..self.row - 1 {
            for col in 1..self.col - 1 {
                if neighbors[row][col] == 2 {
                    // do nothing
                } else if neighbors[row][col] == 3{
                    self.board[row][col] = true
                } else {
                    self.board[row][col] = false
                }
            }
        }
    }

    fn count_neighbors(&self, neighbors: &mut Vec<Vec<i32>>) {
        for row in 1..self.row - 1 {
            for col in 1..self.col - 1 {
                // top-left
                let count = self.board[row-1][col-1] as i32 +
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

                neighbors[row][col] = count;
            }
        }
    }

}

fn main() {

    const WIDTH: usize =  50 + 2;
    const HEIGHT: usize = 30 + 2;
    const RATIO: f64 = 0.25;

    let mut g = Cgol::new(WIDTH, HEIGHT, RATIO);

    g.randomize();

    let ten_millis = time::Duration::from_millis(100);

    loop {
        g.clear();
        g.render();
        g.update();
        // g.info();
        thread::sleep(ten_millis);
    }
}
