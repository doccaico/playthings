import std/strutils

proc main() =
  var f : File = open("numbers.txt", FileMode.fmRead)
  defer: close(f)

  var total = 0
  while f.endOfFile == false:
    total += f.readLine().parseInt

  echo "total = ", $total

when isMainModule:
  main()
