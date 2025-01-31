use std::env;
use std::io;
use std::process;

use scraper::{Html, Selector};

const BASE_URL: &str = "https://www.bible.com/ja/bible/1819";

fn help(code: i32) {
    println!(
        r#"
A program to read bible.

    Usage: verse [Chapter] [Page]
    Exsample: verse GEN 50
        "#
    );
    process::exit(code);
}

fn main() {
    // 引数を処理する
    let args: Vec<String> = env::args().collect();
    if args[1] == "-h" || args[1] == "--help" {
        help(0);
    }
    if args.len() != 3 {
        help(1);
    }
    let root_url = &args[1];
    let max: i32 = args[2]
        .parse()
        .unwrap_or_else(|_| panic!(r#""{}" not an integer"#, args[2]));

    // 標準入力からページ(数値)を読み取る
    let mut input_line = String::new();
    let mut page: i32;
    loop {
        println!("読みたいページを入力してください。 (1 .. {max})");
        io::stdin()
            .read_line(&mut input_line)
            .expect("Failed to read line");
        page = input_line.trim().parse().expect("Input not an integer");
        if 1 <= page && page <= max {
            break;
        }
        input_line.clear();
    }

    // URLを生成し、スクライピングを開始する
    let url = format!("{}/{}.{}", BASE_URL, root_url, page);

    let resp = reqwest::blocking::get(&url).unwrap_or_else(|_| panic!("failed to get {}", url));
    if !resp.status().is_success() {
        panic!("status code is not success: {}", resp.status())
    }
    let text = resp
        .text()
        .expect("failed to convert text (shoud be utf-8 encoding)");

    let fragment = Html::parse_fragment(&text);
    let selector = Selector::parse(&format!(r#"div[data-usfm="{}.{}"]"#, root_url, page)).unwrap();
    let tag = fragment.select(&selector).next().unwrap();
    let text = tag.text().collect::<Vec<_>>().join("\n");

    println!("{text}");
}
