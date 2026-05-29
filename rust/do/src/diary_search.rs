use std::io::Write;
use std::process::{Command, ExitCode, Stdio};

const HELP_MSG: &str = "
Usage:
    do.exe diary_search WORD
    環境変数(DIARY_DIR)に日記が入っているディレクトリを設定すること";

pub fn run(args: &[String]) -> ExitCode {
    if args.len() == 1 && (args[0] == "-h" || args[0] == "--help") {
        println!("{}", HELP_MSG);
        return ExitCode::SUCCESS;
    }
    if args.len() != 1 {
        eprintln!("{}", HELP_MSG);
        return ExitCode::FAILURE;
    }

    let diary_dir = match std::env::var("DIARY_DIR") {
        Ok(dir) => dir,
        Err(_) => {
            eprintln!("not found 'DIARY_DIR' in env variable");
            return ExitCode::FAILURE;
        }
    };

    let output = match Command::new("rg")
        .args([
            "--color",
            "always",
            "--heading",
            "--line-number",
            "--ignore-case",
            "--sort=path",
            &args[0],
            &diary_dir,
        ])
        .output()
    {
        Ok(out) => out,
        Err(_) => {
            eprintln!("'rg' is not in PATH");
            return ExitCode::FAILURE;
        }
    };

    if output.stdout.is_empty() {
        println!("No matches found for '{}'.", &args[0]);
        return ExitCode::SUCCESS;
    }

    let mut child = match Command::new("less")
        .args(["-R", "--silent"])
        .stdin(Stdio::piped())
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .spawn()
    {
        Ok(c) => c,
        Err(_) => {
            eprintln!("failed to spawn 'less'");
            return ExitCode::FAILURE;
        }
    };

    if let Some(mut stdin) = child.stdin.take()
        && stdin.write_all(&output.stdout).is_err() {
            eprintln!("failed to write to less stdin");
            return ExitCode::FAILURE;
    }

    match child.wait() {
        Ok(status) if status.success() => ExitCode::SUCCESS,
        _ => {
            eprintln!("less exited with an error");
            ExitCode::FAILURE
        }
    }
}
