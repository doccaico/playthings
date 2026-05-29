use std::io::Write;
use std::process::{Command, ExitCode, Stdio};

pub fn view_help_msg(msg: &str) -> ExitCode {
    let mut child = match Command::new("less")
        .args(["-R", "-i", "--silent"])
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

    if let Some(mut stdin) = child.stdin.take() {
        if let Err(_) = write!(stdin, "{}", msg) {
            eprintln!("failed to write to less stdin");
            return ExitCode::FAILURE;
        }
    }

    match child.wait() {
        Ok(status) if status.success() => ExitCode::SUCCESS,
        _ => {
            eprintln!("less exited with an error");
            ExitCode::FAILURE
        }
    }
}
