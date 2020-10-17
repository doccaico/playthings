# Usage

* testする場合は下記のコマンドが必要(要curl)

```
mkdir -p test && curl -L https://raw.githubusercontent.com/bvdberg/ctest/master/ctest.h -o test/ctest.h
```

* デフォルトでコンパイラの出力を抑制している(V=0)。表示するには make V=1
* 依存関係をdepend.mkから読み込むので、make dependすること(ファイルが増えた場合も)
 
## build
```
make
```

## make all test files
```
make test
```

## make a test
```
make test_****
```

## excute all tests
```
make testrun
```
## clean
```
make clean 
```

## 変数の表示方法
```
$(info $$SRC = $(SRC))
```
