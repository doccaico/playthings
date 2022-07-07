// 2022/07/07

#[derive(PartialEq)]
enum CharKind {
    Space,
    Word,
}

fn wc(text :&str) -> u64 {

    let mut count: u64 = 0;
    let mut current_pos = CharKind::Space;

    for c in text.chars() {
        match c {
            ' ' | '\n' => {
                current_pos = CharKind::Space;
            },
            _ => {
                if current_pos == CharKind::Space {
                    current_pos = CharKind::Word;
                    count += 1;
                }
            }
        }
    }
    count
}

fn main() {
    assert_eq!(wc("aa bb cc"), 3);
    assert_eq!(wc("  aa bb cc"), 3);
    assert_eq!(wc("aa bb cc  "), 3);
    assert_eq!(wc("  aa  bb   cc  "), 3);
    assert_eq!(wc("  aa"), 1);
    assert_eq!(wc("  "), 0);
    assert_eq!(wc(""), 0);
}
