## regex.h
### Version
```
2021/03/02: nim 1.4.4
```
### Build and Run
```
$ nim r --gc:orc main.nim
64
"0" matches characters 0 - 1
"0." matches characters 0 - 1
"0.0" matches characters 0 - 3
"10.1" matches characters 0 - 4
"-10.1" matches characters 0 - 5
"a" does not match
"a.1" matches characters 2 - 3
"0.a" matches characters 0 - 1
"0.1a" matches characters 0 - 3
"hello" does not match
```
[Regular expressions using regex.h](https://www.codeproject.com/Questions/275223/Regular-expressions-using-regex-h#ctl00_ctl00_MC_AMC_Answers_ctl01_A_Title)
