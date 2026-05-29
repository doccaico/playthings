use regex::Regex;
use std::process::{Command, ExitCode};

const HELP_MSG: &str = "
Usage:
    do.exe shitaraba GENRE ID NUMBER";

pub fn run(args: &[String]) -> ExitCode {
    if args.len() == 1 || args.len() != 4 {
        eprintln!("{}", HELP_MSG);
        return ExitCode::FAILURE;
    }
    if args[1] == "-h" || args[1] == "--help" {
        println!("{}", HELP_MSG);
        return ExitCode::SUCCESS;
    }

    let (genre, id, number) = (&args[1], &args[2], &args[3]);

    let url = format!("https://jbbs.shitaraba.net/bbs/read.cgi/{genre}/{id}/{number}/l50");

    let output = Command::new("cmd")
        .args([
            "/C",
            &format!("curl {url} | busybox64u iconv -f EUC-JP -t UTF-8"),
        ])
        .output()
        .expect("failed to 'curl and busybox64u iconv' process");

    let re = match Regex::new(r"<dt(?ms)\b.+?<b>(\w+?)</b>.+?：(.+?)</dt>.+?<dd>(.+?)</dd>") {
        Ok(re) => re,
        Err(_) => {
            eprintln!(
                r#"failed to 'Regex::new("<dt(?ms)\b.+?<b>(\w+?)</b>.+?：(.+?)</dt>.+?<dd>(.+?)</dd>")'"#
            );
            return ExitCode::FAILURE;
        }
    };

    let re_emoji = match Regex::new(r"&#(\d+?);") {
        Ok(re) => re,
        Err(_) => {
            eprintln!(r#"failed to 'Regex::new("&#(\d+?);")'"#);
            return ExitCode::FAILURE;
        }
    };

    let contents = match String::from_utf8(output.stdout) {
        Ok(contens) => contens,
        Err(_) => {
            eprintln!("failed to 'String::from_utf8'");
            return ExitCode::FAILURE;
        }
    };

    let mut dates = vec![];
    let mut err_msg: &str = "";
    for (_, [name, date, post]) in re.captures_iter(&contents).map(|c| c.extract()) {
        let (new_name, new_date, new_post) = {
            let date = date.trim_ascii_end();
            let post = post
                .trim_ascii()
                .replace("<br>          <br>", "")
                .replace("<br>", "");
            let post = re_emoji
                .replace_all(&post, |caps: &regex::Captures| {
                    let code_point = match u32::from_str_radix(&caps[1], 10) {
                        Ok(cp) => cp,
                        Err(_) => {
                            err_msg = "failed to 'u32::from_str_radix'";
                            return String::new();
                        }
                    };
                    let emoji = match char::from_u32(code_point) {
                        Some(emoji) => emoji,
                        None => {
                            err_msg = "failed to 'char::from_u32'";
                            return String::new();
                        }
                    };
                    emoji.to_string()
                })
                .into_owned();
            (name, date, post)
        };
        dates.push((new_name, new_date, new_post));
    }

    if "" != err_msg {
        eprintln!("{}", err_msg);
        return ExitCode::FAILURE;
    }

    for v in dates {
        println!("{}", v.2);
    }

    // print!("{} ", String::from_utf8_lossy(&output.stdout));
    ExitCode::SUCCESS
}
