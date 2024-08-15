#!/bin/sh

function USAGE () {
    echo "Usage: $0 [debug, release] FILE"
    exit 0
}

if [ $# -lt 1 ]; then
    USAGE
fi

if [ $1 = "debug" ]; then
    OPTIMIZATION="-O0"
elif [ $1 = "release" ]; then 
    OPTIMIZATION="-O2"
else
    USAGE
fi

# clear

C_FLAGS="-std=c99 ${OPTIMIZATION} -Wall -Wextra -pedantic -Wno-unused-parameter -Wno-missing-field-initializers"

COMPILER='gcc'

COMMAND="${COMPILER} ${C_FLAGS} $2 -o `basename $2 .c`.exe"

ESC=$(printf '\033')
S='[Compile]'
echo ${ESC}[36m${S}${ESC}[m ${COMMAND}

${COMMAND}
