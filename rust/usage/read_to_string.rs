use std::fs::File;
use std::io::Read;

fn main() {
    let mut file = File::open("numbers.txt").unwrap();
    let mut contents = String::new();
    file.read_to_string(&mut contents).unwrap();

    let total: u32 = contents
        .lines()
        .map(|a| a.parse::<u32>().unwrap())
        .sum();

    println!("{}", total);
}

// use std::fs;
//
// fn main() {
//
//     let total: u32 = fs::read_to_string("numbers.txt").unwrap()
//         .lines()
//         .map(|a| a.parse::<u32>().unwrap())
//         .sum();
//
//     println!("{}", total);
// }
