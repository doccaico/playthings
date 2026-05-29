use std::path::Path;
use std::process::{Command, ExitCode};

const HELP_MSG: &str = r"
Usage:
    do.exe gitup DIR MESSAGE
    do.exe gitup     MESSAGE";

pub fn run(args: &[String]) -> ExitCode {
    if args.len() == 1 || args.len() > 3 {
        eprintln!("{}", HELP_MSG);
        return ExitCode::FAILURE;
    }
    if args[1] == "-h" || args[1] == "--help" {
        println!("{}", HELP_MSG);
        return ExitCode::SUCCESS;
    }

    let (dir_path, commig_msg) = {
        if args.len() == 3 {
            let path = Path::new(&args[1]);
            if !path.is_dir() {
                eprintln!("Does not exist: {}", args[1]);
                return ExitCode::FAILURE;
            }
            (&args[1], &args[2])
        } else {
            (&".".to_string(), &args[1])
        }
    };

    let output = Command::new("git")
        .current_dir(dir_path)
        .args(["status", "--porcelain"])
        .output()
        .expect("failed to 'git status --porcelain' process");

    if "".as_bytes() == output.stdout.trim_ascii_end() {
        eprintln!("There is no need to update");
        return ExitCode::SUCCESS;
    }

    Command::new("git")
        .current_dir(dir_path)
        .args(["add", "."])
        .status()
        .expect("failed to 'git add .' process");

    Command::new("git")
        .current_dir(dir_path)
        .args(["commit", "-m", commig_msg])
        .status()
        .unwrap_or_else(|_| panic!("failed to 'git commit \"{}\"' process", commig_msg));

    let output = Command::new("git")
        .current_dir(dir_path)
        .arg("push")
        .output()
        .expect("failed to 'git push' process");

    println!("{}", String::from_utf8_lossy(&output.stdout));

    ExitCode::SUCCESS
}
