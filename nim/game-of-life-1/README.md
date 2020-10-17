## Test
```
$ nimble test
```

## Run
```
$ nimble run lifegame_nim
```

## Build
```
$ nimble build -d:release
```

## Cross-Compiling For Windows on Linux
```
# install mingw64
$ sudo apt install apt install mingw-w64

# 32bit
$ nimble build -d:mingw --cpu:i386 -d:release --checks:off

# 64bit
$ nimble build -d:mingw --cpu:amd64 -d:release --checks:off
```
![image](https://user-images.githubusercontent.com/48589065/80030961-f50f6d80-8523-11ea-8cdc-402c33a4adad.png)
