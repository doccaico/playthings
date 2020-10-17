use std::{thread, time};

use rand::rngs::ThreadRng;
use rand::seq::SliceRandom;
use rand::thread_rng;

const WIDTH: usize =  30 + 2;
const HEIGHT: usize = 30 + 2;
const RATIO: f64 = 0.40;

// 2020/05/16
// I think this code is bad. It's messy.
// release
// 928.0 KB

fn init(board: &mut [[bool; WIDTH]; HEIGHT], rng: &mut ThreadRng) {
    for row in board[1..HEIGHT-1].iter_mut() {
        for (j, col) in row[1..WIDTH-1].iter_mut().enumerate() {
            if j < (( (WIDTH-2) as f64) * RATIO) as usize {
                *col = true;
            }
        }
    }
    for row in board[1..HEIGHT-1].iter_mut() {
        row[1..WIDTH-1].shuffle(rng);
    }
}

fn render(board: & [[bool; WIDTH]; HEIGHT]) {
    for row in board[1..HEIGHT-1].iter() {
        for col in row[1..WIDTH-1].iter() {
            let mark = if *col {
                '*'
            } else {
                ' '
            };
            print!("{} ", mark);
        }
        println!();
    }
}

#[allow(dead_code)]
fn info() {
    println!("Board Size: {}/w {}/h", WIDTH-2, HEIGHT-2);
    println!("Ratio: {}",  RATIO);
    println!("Initial Status: Lived {} Empty {}",
             (( (WIDTH-2) as f64) * RATIO) as usize * (HEIGHT-2),
             (WIDTH-2)*(HEIGHT-2));
}

fn clear() {
    print!("{esc}[2J{esc}[1;1H", esc = 27 as char);
}

fn update(board: &mut [[bool; WIDTH]; HEIGHT]) {
    let mut neighbors = [[0; WIDTH]; HEIGHT];

    count_neighbors(board, &mut neighbors);

    for row in 1..HEIGHT-1 {
        for col in 1..WIDTH-1 {
            if neighbors[row][col] == 2 {
                // do nothing
            } else if neighbors[row][col] == 3{
                board[row][col] = true
            } else {
                board[row][col] = false
            }
        }
    }
}

fn count_neighbors(board: &mut [[bool; WIDTH]; HEIGHT], neighbors: &mut [[i32; WIDTH]; HEIGHT]) {
    for row in 1..HEIGHT-1 {
        for col in 1..WIDTH-1 {
            // top-left
            let count = board[row-1][col-1] as i32 +
                // top-middle
                board[row-1][col] as i32 +
                // top-right
                board[row-1][col+1] as i32 +
                // left
                board[row][col-1] as i32 +
                // right
                board[row][col+1] as i32 +
                // bottom-left
                board[row+1][col-1] as i32 +
                // bottom-middle
                board[row+1][col] as i32 +
                // bottom-right
                board[row+1][col+1] as i32;

            neighbors[row][col] = count;
        }
    }
}

fn main() {

    let mut board = [[false; WIDTH]; HEIGHT];

    let mut rng = thread_rng();

    init(&mut board, &mut rng);

    let ten_millis = time::Duration::from_millis(100);

    loop {
        clear();
        render(&board);
        update(&mut board);
        info();
        thread::sleep(ten_millis);
    }
}
