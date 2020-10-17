## Build (cmake)

### Desktop

```
cd sokol_test
mkdir build
cd build
cmake ..
cmake --build .

# run
./sokol_test
```

### Web (wasm)

```
mkdir build
cd build
emcmake cmake -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=MinSizeRel ..
cmake --build .

# run
emrun sokol_test.html
```

### Build (gcc)

```
$ gcc -I./sokol sokol/sokol.c sokol_test.c -o sokol_test -lGL -lX11 -lXcursor -lXi -ldl
$ ./sokol_test
```

#### desktop.png
![desktop](https://github.com/doccaico/playthings/blob/main/c/sokol_test/img/desktop.png?raw=true)

#### web.png
![web](https://github.com/doccaico/playthings/blob/main/c/sokol_test/img/web.png?raw=true)

#### Links
- [floooh/sokol](https://github.com/floooh/sokol)
- [floooh/pacman.c](https://github.com/floooh/pacman.c)
