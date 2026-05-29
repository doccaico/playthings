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

    let mut result = String::new();
    for path in paths.split(';') {
        if "" != path {
            result.push_str(path);
        }
    }

    print!("{}", result);

    ExitCode::SUCCESS
}
