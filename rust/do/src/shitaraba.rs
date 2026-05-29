use regex::Regex;
use std::io::Write;
use std::process::{Command, ExitCode, Stdio};

const HELP_MSG: &str = "
Usage:
    do.exe shitaraba GENRE ID NUMBER";

fn convert_cp(code_point: &str) -> Result<String, String> {
    let cp_u32 = u32::from_str_radix(code_point, 10)
        .map_err(|_| "failed to 'u32::from_str_radix'".to_string())?;

    char::from_u32(cp_u32)
        .map(|c| c.to_string())
        .ok_or_else(|| "failed to 'char::from_u32'".to_string())
}

pub fn run(args: &[String]) -> ExitCode {
    if args.len() == 1 && (args[0] == "-h" || args[0] == "--help") {
        println!("{}", HELP_MSG);
        return ExitCode::SUCCESS;
    }
    if args.len() != 3 {
        eprintln!("{}", HELP_MSG);
        return ExitCode::FAILURE;
    }

    let (genre, id, number) = (&args[0], &args[1], &args[2]);

    let url = format!("https://jbbs.shitaraba.net/bbs/read.cgi/{genre}/{id}/{number}/l50");

    let output = match Command::new("cmd")
        .args([
            "/C",
            &format!("curl -sSL {url} | busybox64u iconv -f EUC-JP -t UTF-8"),
        ])
        .output()
    {
        Ok(out) => out,
        Err(_) => {
            eprintln!("failed to 'curl and busybox64u iconv'");
            return ExitCode::FAILURE;
        }
    };

    let re = Regex::new(r"<dt(?ms)\b.+?<b>(\w+?)</b>.+?：(.+?)</dt>.+?<dd>(.+?)</dd>")
        .expect("failed to compile main regex");
    let re_emoji = Regex::new(r"&#(\d+?);").expect("failed to compile emoji regex");

    let contents = match String::from_utf8(output.stdout) {
        Ok(contens) => contens,
        Err(_) => {
            eprintln!("failed to 'String::from_utf8'");
            return ExitCode::FAILURE;
        }
    };

    let mut dates = vec![];
    for (_, [name, date, post]) in re.captures_iter(&contents).map(|c| c.extract()) {
        let date = date.trim_ascii_end();
        let post = post
            .trim_ascii()
            .replace("<br>          <br>", "")
            .replace("<br>", "");

        let mut error_msg = None;
        let post = re_emoji.replace_all(&post, |caps: &regex::Captures| {
            if error_msg.is_some() {
                return "".to_string();
            }
            match convert_cp(&caps[1]) {
                Ok(emoji) => emoji,
                Err(e) => {
                    error_msg = Some(e);
                    "".to_string()
                }
            }
        });

        if let Some(e) = error_msg {
            eprintln!("{}", e);
            return ExitCode::FAILURE;
        }

        dates.push((name, date, post.into_owned()));
    }

    let mut child = match Command::new("less")
        .args(["-R", "--silent"])
        .stdin(Stdio::piped())
        .spawn()
    {
        Ok(c) => c,
        Err(_) => {
            eprintln!("failed to spawn 'less'");
            return ExitCode::FAILURE;
        }
    };

    if let Some(mut stdin) = child.stdin.take() {
        for (name, date, post) in dates {
            if let Err(_) = writeln!(
                stdin,
                "\x1b[36m{name}\x1b[0m: \x1b[32m{date}\x1b[0m\n{post}"
            ) {
                eprintln!("failed to write to less stdin");
                return ExitCode::FAILURE;
            }
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
