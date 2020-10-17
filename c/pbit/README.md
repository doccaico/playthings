## Usage

```
# 64bit

$ pbit -u 0xff
00000000 00000000 00000000 00000000 00000000 00000000 00000000 11111111
$ pbit -s -255
11111111 11111111 11111111 11111111 11111111 11111111 11111111 00000001
$ pbit -h
USAGE: pbit [OPTION] NUMBER
 -s	signed		-9223372036854775808 <= NUMBER >= 9223372036854775807
 -u	unsigned	0 <= NUMBER >= 18446744073709551615

 -h	display this help and exit

# 32bit

$ pbit -u 0xff
00000000 00000000 00000000 11111111
$ pbit -s -255
11111111 11111111 11111111 00000001
$ pbit -h
USAGE: pbit [OPTION] NUMBER
 -s	signed		-2147483648 <= NUMBER >= 2147483647
 -u	unsigned	0 <= NUMBER >= 4294967295

 -h	display this help and exit
```

## Input Support
```
(only '-s') Negative number (-1234567890)

Decimal numbers (1234567890)

Hexadecimal numbers (0x... 0X...)

Octal numbers (0o... 0O...)
```

## Build

```
# dev
$ make

# relese
$ make release
```
