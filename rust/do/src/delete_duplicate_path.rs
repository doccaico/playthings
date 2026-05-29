use std::collections::HashSet;
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

    let mut set = HashSet::new();
    let mut path_vec = vec![];
    for path in paths.split(';').filter(|p| !p.is_empty()) {
        if set.insert(path) {
            path_vec.push(path);
        }
    }

    print!("{}", path_vec.join(";"));

    ExitCode::SUCCESS
}
