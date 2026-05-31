use std::io::Write;
use std::path::Path;
use std::process::{Command, ExitCode, Stdio};

const HELP_MSG: &str = "
Usage:
    do.exe diary_search [OPTION] 検索キーワード
OPTION:
    -h, --help                 ヘルプメッセージを表示
REQUIRED:
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

    let diary_dir_raw = std::env::var("DIARY_DIR").expect("not found 'DIARY_DIR' in env variable");
    let path = Path::new(&diary_dir_raw);
    if !path.is_dir() {
        panic!("'{}' does not exist or is a file", path.display());
    }

    let output = Command::new("rg")
        .args([
            "--color",
            "always",
            "--heading",
            "--line-number",
            "--ignore-case",
            "--sort=path",
            &args[0],
        ])
        .arg(path)
        .output()
        .expect("failed to run 'rg'");

    if output.stdout.is_empty() {
        println!("No matches found for '{}'.", &args[0]);
        return ExitCode::SUCCESS;
    }

    let mut child = Command::new("less")
        .args(["-R", "-i", "--silent"])
        .stdin(Stdio::piped())
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .spawn()
        .expect("failed to spawn 'less'");

    // `stdin` を `take()` で完全に外に切り出す
    let mut stdin = child.stdin.take().expect("failed to open stdin");

    // 切り出した `stdin` に書き込む
    if stdin.write_all(&output.stdout).is_err() {
        eprintln!("failed to write to less stdin");
        let _ = child.kill();
        let _ = child.wait();
        return ExitCode::FAILURE;
    }

    // 書き込みが完了したため、明示的に `stdin` を閉じて less に通知する
    drop(stdin);

    match child.wait() {
        Ok(status) if status.success() => ExitCode::SUCCESS,
        _ => {
            eprintln!("less exited with an error");
            ExitCode::FAILURE
        }
    }
}
