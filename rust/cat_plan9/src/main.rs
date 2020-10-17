use std::fs::File;
use std::io::Read;
use std::path::Path;

fn cat(file: &mut File, path: &Path) {
    let mut x = String::new();
    match file.read_to_string(&mut x) {
        Err(error) => panic!("couldn't read {}: {}", path.display(), error),
        Ok(_) => print!("{}", x)
    }
}

fn cat_stdin() {
    loop {
        let mut x = String::new();
        match std::io::stdin().read_line(&mut x) {
            Err(error) => panic!("couldn't read stdin: {}", error),
            Ok(_) => {
                if x == "" {
                    break;
                }
                print!("{}", x)
            }
        }
    }
}

fn main() {

    let args: Vec<String> = std::env::args().collect();
    let argc = args.len();

    if argc == 1 {
        cat_stdin();
    } else {
        for i in 1..argc {
            let path = Path::new(&args[i]);
            {
                let mut file = match File::open(&path) {
                    Err(error) => panic!("couldn't open {}: {}", path.display(), error),
                    Ok(file) => file
                };
                cat(&mut file, &path);
            }
        }
    }
}
