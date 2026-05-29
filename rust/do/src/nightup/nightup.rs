use ini::Ini;
use std::env;
use std::process::ExitCode;

mod zig;

const HELP_MSG: &str = "
Usage:
    do.exe nightup zig
    do.exe nightup odin
    do.exe nightup v
    do.exe nightup go";

pub fn run(args: &[String]) -> ExitCode {
    if args.len() == 1 && (args[0] == "-h" || args[0] == "--help") {
        println!("{}", HELP_MSG);
        return ExitCode::SUCCESS;
    }
    if args.len() != 1 {
        eprintln!("{}", HELP_MSG);
        return ExitCode::FAILURE;
    }

    let base_home = match env::home_dir() {
        Some(path) => path,
        None => {
            eprintln!("impossible to get your home dir");
            return ExitCode::FAILURE;
        }
    };

    let mut download_path = base_home.clone();
    download_path.push("Downloads");
    let download_dir = match download_path.into_os_string().into_string() {
        Ok(s) => s,
        Err(_) => {
            eprintln!("download path is not valid UTF-8");
            return ExitCode::FAILURE;
        }
    };

    let mut ini_path = base_home;
    ini_path.push(".nightup");

    let conf = match Ini::load_from_file_noescape(&ini_path) {
        Ok(ini) => ini,
        Err(_) => {
            eprintln!("failed to open: {}", ini_path.display());
            return ExitCode::FAILURE;
        }
    };

    let section = match conf.section(Some("Windows")) {
        Some(section) => section,
        None => {
            eprintln!(r#"nightup ini: not found section: "Windows""#);
            return ExitCode::FAILURE;
        }
    };

    match args[0].as_str() {
        "zig" => {
            let dist_dir = match section.get("zig") {
                Some(path) => path,
                None => {
                    eprintln!(r#"nightup ini: not found path: "zig""#);
                    return ExitCode::FAILURE;
                }
            };
            zig::run(dist_dir, &download_dir)
        }
        _ => {
            eprintln!("nightup: unknown command '{}'\n{}", args[0], HELP_MSG);
            ExitCode::FAILURE
        }
    }
}
