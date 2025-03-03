#!/bin/sh

# ./build.sh [debug, release]

help_and_exit () {
    if [ $# -lt 1 ]; then
        echo "need a parameter [--debug, --release]"
        exit 0
    fi
}

if [ $# -lt 1 ]; then
    help_and_exit
fi

if [ $1 = "--debug" ]; then
    OPTIMIZATION=""
elif [ $1 = "--release" ]; then 
    OPTIMIZATION="-O3 -s"
else
    echo "unknown parameter: $1"
    help_and_exit
fi

[[ ! -e "./liblexbor.dll" ]] && cp -u /ucrt64/bin/liblexbor.dll .
[[ ! -e "./libcurl-x64.dll" ]] && cp -u ./bin/curl/libcurl-x64.dll .
[[ ! -e "./curl-ca-bundle.crt" ]] && cp -u ./bin/curl/curl-ca-bundle.crt .

EXE_NAME="verse-c.exe"

CINCLUDE="-I./lib/curl/include"
LDFLAGS="-L./lib/curl/lib"
LDLIBS="-lcurl -llexbor"
CFLAGS="${OPTIMIZATION} -Wall -Wextra -pedantic -Wno-unused-parameter -Wno-missing-field-initializers"

gcc $CFLAGS $CINCLUDE $LDFLAGS main.c -o $EXE_NAME $LDLIBS
