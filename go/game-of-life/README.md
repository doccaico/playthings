## Run

```sh
# linux
$ go run main.go main_linux.go

# windows
$ go run main.go main_windows.go
```

## Build

```sh
# linux(64bit)
$ GOOS=linux GOARCH=amd64 go build .

# windows(64bit)
$ GOOS=windows GOARCH=amd64 go build .
```
