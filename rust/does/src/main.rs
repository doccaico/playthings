use std::env;
use std::process::ExitCode;

mod diary_search;
mod gitup;

const HELP_MSG: &str = "
Usage:
    do.exe KIND
KIND:
    diary_search                日記を検索
    gitup                       GithubにPush
    shitaraba                   Shitarabaを閲覧
    delete_duplicate_path       環境変数PATHの重複を解消して表示
    verse                       聖書(新共同訳)を表示
    wiki                        ランダムWIKIのリストを表示";

fn main() -> ExitCode {
    let args: Vec<String> = env::args().collect();

    if args.len() == 1 {
        eprintln!("{}", HELP_MSG);
        return ExitCode::FAILURE;
    }
    if args[1] == "-h" || args[1] == "--help" {
        println!("{}", HELP_MSG);
        return ExitCode::SUCCESS;
    }

    match args[1].as_str() {
        "diary_search" => diary_search::run(&args[1..]),
        "gitup" => gitup::run(&args[1..]),
        _ => ExitCode::FAILURE,
    }
}
