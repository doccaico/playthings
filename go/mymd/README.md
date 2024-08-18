#### mymd
## Usage
現在いるディレクトリ内にmymd.tmpl.htmlがある状態で
```
$ mymd hoge.md
```
## Build
```
$ go build -ldflags="-s -w" -trimpath
```
