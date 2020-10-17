# Cat in Rust ([plan9 version](https://github.com/0intro/plan9/blob/main/sys/src/cmd/cat.c))

## Build and Run
```
$ cargo build --release

$ ./target/release/cat_plan9
or
$ printf "Grape\nApple\nBanana\n" | ./target/release/cat_plan9
or
$ ./target/release/cat_plan9 FILE1 FILE2 ...
```
