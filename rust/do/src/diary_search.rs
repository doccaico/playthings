use std::process::{Command, ExitCode};

const HELP_MSG: &str = "
Usage:
    do.exe diary_search WORD";

pub fn run(args: &[String]) -> ExitCode {
    if args.len() == 2 && (args[1] == "-h" || args[1] == "--help") {
        println!("{}", HELP_MSG);
        return ExitCode::SUCCESS;
    }
    if args[2] != 2 {
        eprintln!("{}", HELP_MSG);
        return ExitCode::FAILURE;
    }

    const DIARY_DIR: &str = r"C:\Users\doccaico\Dropbox\diary";
    const RG_OPT: &str = "--color always --heading --line-number --ignore-case --sort=path";
    const LESS_OPT: &str = "-R --silent";

    let keyword = &args[1];

    Command::new("cmd")
        .args([
            "/C",
            &format!("rg {RG_OPT} {keyword} {DIARY_DIR} | less {LESS_OPT}"),
        ])
        .status()
        .expect("failed to 'rg and less' process");

    ExitCode::SUCCESS
}
