## raylib-wasm (using [this binding](https://github.com/doccaico/raylib-nim))
[DEMO](https://doccaico.github.io/playthings/nim/raylib-wasm/)
### Version
```
2021/03/28: nim 1.4.4
```
### WASM
```
$ nim c -d:emscripten --passL:"~/local/lib/raylib-3.5.0-wasm/src/libraylib.a" main.nim
$ python3 wasm-server.py
$ Your-Browser http://localhost:8080/
```
### DESKTOP
```
$ nim c main.nim
$ ./main
```
