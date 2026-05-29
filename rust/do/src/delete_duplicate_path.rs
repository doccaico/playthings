use std::env;
use std::process::ExitCode;

pub fn run() -> ExitCode {
    let paths = match env::var("PATH") {
        Ok(value) => value,
        Err(err) => {
            eprintln!("couldn't interpret PATH: {}", err);
            return ExitCode::FAILURE;
        }
    };

    let result: String = paths.split(';').filter(|p| !p.is_empty()).collect();
    print!("{}", result);

    ExitCode::SUCCESS
}
