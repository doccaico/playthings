#!/bin/bash

# gox - A dead simple, no frills Go cross compile tool
# https://github.com/mitchellh/gox

# Go言語のクロスコンパイル設定値 $GOOS, $GOARCH 一覧リスト
# https://qiita.com/suin/items/7ddfcbc708c8863ea76a

NAME="ttt_go"
OUTDIR="build"
OUTNAME=${OUTDIR}/${NAME}_{{.OS}}_{{.Arch}}

gox -output=$OUTNAME -osarch="windows/386"
gox -output=$OUTNAME -osarch="windows/amd64"

gox -output=$OUTNAME -osarch="darwin/386"
gox -output=$OUTNAME -osarch="darwin/amd64"

gox -output=$OUTNAME -osarch="linux/386"
gox -output=$OUTNAME -osarch="linux/amd64"
