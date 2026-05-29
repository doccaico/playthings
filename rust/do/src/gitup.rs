use std::path::Path;
use std::process::{Command, ExitCode};

const HELP_MSG: &str = r"
Usage:
    do.exe gitup DIR MESSAGE
    do.exe gitup     MESSAGE";

pub fn run(args: &[String]) -> ExitCode {
    if args.is_empty() || args.len() > 2 {
        eprintln!("{}", HELP_MSG);
        return ExitCode::FAILURE;
    }
    if args[0] == "-h" || args[0] == "--help" {
        println!("{}", HELP_MSG);
        return ExitCode::SUCCESS;
    }

    let (dir_path, commig_msg): (&str, &str) = {
        if args.len() == 2 {
            let path = Path::new(&args[0]);
            if !path.is_dir() {
                eprintln!("Does not exist: {}", args[0]);
                return ExitCode::FAILURE;
            }
            (&args[0], &args[1])
        } else {
            (".", &args[0])
        }
    };

    let output = match Command::new("git")
        .current_dir(dir_path)
        .args(["status", "--porcelain"])
        .output()
    {
        Ok(out) => out,
        Err(_) => {
            eprintln!("'git' command not found");
            return ExitCode::FAILURE;
        }
    };

    if !output.status.success() {
        eprintln!("'{}' is not a git repository (or git error)", dir_path);
        return ExitCode::FAILURE;
    }

    if output.stdout.trim_ascii_end().is_empty() {
        println!("There is no need to update");
        return ExitCode::SUCCESS;
    }

    let add_status = Command::new("git")
        .current_dir(dir_path)
        .args(["add", "."])
        .status()
        .unwrap();

    if !add_status.success() {
        println!("failed to execute 'git add'");
        return ExitCode::FAILURE;
    }

    let commit_status = Command::new("git")
        .current_dir(dir_path)
        .args(["commit", "-m", commig_msg])
        .status()
        .expect("failed to execute 'git commit'");

    if !commit_status.success() {
        println!("'git commit' failed");
        return ExitCode::FAILURE;
    }

    let push_status = Command::new("git")
        .current_dir(dir_path)
        .arg("push")
        .status()
        .expect("failed to execute 'git push'");

    if push_status.success() {
        ExitCode::SUCCESS
    } else {
        eprintln!("git push failed");
        ExitCode::FAILURE
    }
}
