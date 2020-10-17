テキストファイル内の平仮名、片仮名を変換 (UTF-8 限定)

## ビルド
```
$ ./run build
```

## 使い方
```
$ ./canacon txt/in.txt > txt/out.txt
or $ ./canacon < txt/in.txt > txt/out.txt
or $ cat txt/in.txt | ./canacon > txt/out.txt
```
## 変換マップをカスタマイズ
[pattern1.h](pattern1.h) を編集してincludeしてビルド
```
#include "original_pattern.h"
#include "convkana.h"
```

## 変換前
<img src="https://github.com/doccaico/playthings/blob/main/c/canacon/screenshot/a.png?raw=true" width="400" height="300">

## 変換後
<img src="https://github.com/doccaico/playthings/blob/main/c/canacon/screenshot/b.png?raw=true" width="400" height="300">
