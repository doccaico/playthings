### cmd-wrapper for me (. .;)

```
Usage: cmd-wrapper.exe [cmd] args
  cmd:
    cp: copy a file or directory
    mv: move a file or directory
    rm: remove a file or directory
```

### Build

```cmd
;; Debug Build

odin build main.odin -file -out:cmd-wrapper.exe [-debug]

;; Release Build

odin build main.odin -file -out:cmd-wrapper.exe -o:speed -no-bounds-check
```
