#!/bin/sh

# ./build.sh [--debug, --release]

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

BUILD_DIR="build"
SRC_DIR="src"

[[ ! -d "./$BUILD_DIR" ]] && mkdir $BUILD_DIR

[[ ! -e "$BUILD_DIR/liblexbor.dll" ]] && cp -u /ucrt64/bin/liblexbor.dll $BUILD_DIR/
[[ ! -e "$BUILD_DIR/libcurl-x64.dll" ]] && cp -u ./vendor/curl/bin/libcurl-x64.dll $BUILD_DIR/
[[ ! -e "$BUILD_DIR/curl-ca-bundle.crt" ]] && cp -u ./vendor/curl/bin/curl-ca-bundle.crt $BUILD_DIR/

EXE_NAME="verse-c.exe"

CINCLUDE="-I./vendor/curl/include"
LDFLAGS="-L./vendor//curl/lib"
LDLIBS="-lcurl -llexbor"
CFLAGS="${OPTIMIZATION} -Wall -Wextra -pedantic -Wno-unused-parameter -Wno-missing-field-initializers"

gcc $CFLAGS $CINCLUDE $LDFLAGS $SRC_DIR/main.c -o $BUILD_DIR/$EXE_NAME $LDLIBS
