# Cat in Nim

Still very buggy --)

## build
```
$ nim c -d:release --hints:off --checks:off main.nim
```

## test
```
# do a test
$ ./t a

# do all tests
$ for i in a b c d e f ; do ./t $i ; done
```

## update test
```
$ python3 test_creator.py >> t
```

## see
[Checking stdin for content](https://www.reddit.com/r/nim/comments/8jki3k/checking_stdin_for_content/)
