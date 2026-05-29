use regex::Regex;
use std::fs;
use std::path::Path;
use std::process::{Command, ExitCode};

pub fn run(dist_dir: &str, download_dir: &str) -> ExitCode {
    // index.jsonを取得する
    let output = match Command::new("curl")
        .args([
            "-sSL",
            "-A",
            "Mozilla/5.0",
            "https://ziglang.org/download/index.json",
        ])
        .output()
    {
        Ok(out) => out,
        Err(_) => {
            eprintln!("failed to 'curl'");
            return ExitCode::FAILURE;
        }
    };
    println!("Download (index.json) is done");

    let contents = match String::from_utf8(output.stdout) {
        Ok(contens) => contens,
        Err(_) => {
            eprintln!("failed to 'String::from_utf8'");
            return ExitCode::FAILURE;
        }
    };

    // ダウンロードURLを取得する
    let re_url =
        Regex::new(r#"(?ms)"master":\s*\{.*?"x86_64-windows":\s*\{.*?"tarball":\s*"([^"]+)""#)
            .expect("failed to compile zig.re_url (regex)");

    // 抽出できた URL を格納する変数
    let mut download_url = String::new();

    if let Some(caps) = re_url.captures(&contents) {
        if let Some(mat) = caps.get(1) {
            download_url = mat.as_str().to_string();
        }
    }

    if download_url.is_empty() {
        eprintln!("failed to find tarball URL for x86_64-windows master");
        return ExitCode::FAILURE;
    }
    println!("Download URL: {}", download_url);

    // URLからファイル名を抽出する (例: zig-windows-x86_64-0.14.0.zip)
    let file_name = match download_url.split('/').last() {
        Some(name) => name,
        None => {
            eprintln!("failed to parse filename from URL");
            return ExitCode::FAILURE;
        }
    };

    // 解凍後のディレクトリ名（.zip を除いた名前、後で移動処理に使うため残しておくと便利）
    let dir_name = file_name.strip_suffix(".zip").unwrap_or(file_name);

    // ZIPをダウンロードする
    // ZIPを確実に指定ディレクトリへダウンロードする
    // -O ではなく -o <ファイル名> を使うことでWindowsでも確実に保存される
    let output = match Command::new("curl")
        .current_dir(download_dir)
        .args(["-fsSL", "-A", "Mozilla/5.0", &download_url, "-o", file_name])
        .output()
    {
        Ok(out) => out,
        Err(_) => {
            eprintln!("failed to 'curl ZIP file'");
            return ExitCode::FAILURE;
        }
    };

    if !output.status.success() {
        eprintln!("curl failed with status: {:?}", output.status);
        return ExitCode::FAILURE;
    }

    println!("Download (ZIP) is done: {}", file_name);

    // 解凍する
    let output = match Command::new("7za")
        .current_dir(download_dir)
        .args(["x", "-aoa", file_name, "-bso0", "-bsp0"])
        .output()
    {
        Ok(out) => out,
        Err(_) => {
            eprintln!("failed to '7za'");
            return ExitCode::FAILURE;
        }
    };

    if !output.status.success() {
        eprintln!("7za failed with status: {:?}", output.status);
        return ExitCode::FAILURE;
    }

    println!("Extraction is done");

    //  配置（アップデートの適用）
    let extracted_path = Path::new(download_dir).join(dir_name);
    let target_path = Path::new(dist_dir);

    // 既存の古いインストールディレクトリがあれば削除
    if target_path.exists() {
        if let Err(e) = fs::remove_dir_all(target_path) {
            eprintln!("failed to remove old dist directory: {}", e);
            return ExitCode::FAILURE;
        }
    }
    println!(r#"Removed: "{}""#, target_path.display());

    // 解凍したフォルダを本来の配置先に移動（リネーム）
    if let Err(e) = fs::rename(&extracted_path, &target_path) {
        eprintln!("failed to move extracted directory to dist: {}", e);
        return ExitCode::FAILURE;
    }
    println!(
        r#"Moved: "{}" to "{}""#,
        extracted_path.display(),
        target_path.display()
    );

    // 後始末: ダウンロードしたZIPファイルを削除
    let zip_path = Path::new(download_dir).join(file_name);
    if let Err(e) = fs::remove_file(&zip_path) {
        eprintln!("failed to remove ZIP: {}", e);
        return ExitCode::FAILURE;
    }
    println!(r#"Removed: "{}""#, zip_path.display());

    println!(r#"Updated: "{}""#, dist_dir);

    ExitCode::SUCCESS
}
