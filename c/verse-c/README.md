### verse-c
A program to read bible.

#### Usage
```
# Usage: verse-c [Chapter] [Page]
#   Exsample: verse-c GEN 1
```

#### Build Requirements
- UCRT64([MSYS2](https://www.msys2.org/))
- gcc and lexbor
```sh
$ pacman -S mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-lexbor
```

#### Build
```sh
# on Debug mode
$ ./build --debug

# on Release mode
$ ./build --release
```

#### Run
```sh
$ ./build/verse-c.exe GEN 1
```
