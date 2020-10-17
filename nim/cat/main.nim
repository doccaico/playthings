import os, strutils

import parseopta

var fileNames: seq[string]
var lineNo: uint = 1

var
  # -A, --show-all (-vET)

  # -b, --number-nonblank (overrides -n)
  optNumber_nonblank = false

  # -e (-vE)

  # -E, --show-ends
  optShow_ends = false

  # -n, --number
  optNumber = false

  # -s, --squeeze-blank
  optSqueeze_blank = false

  # -t (-vT)

  # -T, --show-tabs
  optShow_tabs = false

  # -v, --show-nonprinting
  optShow_nonprinting = false

  # --help
  optHelp = false

  # --version
  optVersion = false

proc dupCount(str :string): int =
  var i = 0
  while i < str.len:
      if str[i] == '\n':
        inc result
      else:
        break
      inc i

proc ctrlc() {.noconv.} = quit(130)

proc readStdin() =
  while true:
    try:
      var line = readLine(stdin)
      echo line
    except EOFError:
      break

proc parseOpts() =
  var p = initOptParser(
    cmdline = commandLineParams(),
    shortNoVal = {'A', 'b', 'E', 'n', 's', 'T', 'v', 'e', 't'},
    longNoVal = (@["show-all", "number-nonblank", "number-blank", "show-ends",
        "number", "squeeze-blank", "show-tabs", "show-nonprinting", "help", "version"]))

  while true:

    p.next()

    case p.kind
    of cmdEnd:
      break
    of cmdArgument:
      fileNames.add(p.key)
    of cmdShortOption, cmdLongOption:
      case p.key
      of "A", "show-all":
        optShow_nonprinting = true
        optShow_ends = true
        optShow_tabs = true
      of "b", "number-blank":
        optNumber_nonblank = true
      of "e":
        optShow_nonprinting = true
        optShow_ends = true
      of "E", "show-ends":
        optShow_ends = true
      of "n", "number":
        optNumber = true
      of "s", "squeeze-blank":
        optSqueeze_blank = true
      of "t":
        optShow_nonprinting = true
        optShow_tabs = true
      of "T", "show-tabs":
        optShow_tabs = true
      of "v", "show-nonprinting":
        optShow_nonprinting = true
      of "help":
        optHelp = true
      of "version":
        optVersion = true
      else:
        echo "Invalid option: ", p.key
        quit(1)

    if optNumber_nonblank:
      optNumber = false

proc cat(buf: string, size: int) =

  var skip = 0

  if optNumber:
    stdout.write align($lineNo, 6)
    stdout.write '\t'
    inc lineNo

  if optNumber_nonblank:
    if size > 0 and buf[0] != '\n':
      stdout.write align($lineNo, 6)
      stdout.write '\t'
      inc lineNo

  for i, ch in buf:

    if skip != 0:
      dec skip
      continue

    # -v, --show-nonprinting
    if optShow_nonprinting:
      if ch.ord >= 32:
        if ch.ord < 127:
          stdout.write ch
        elif ch.ord == 127:
          stdout.write '^'
          stdout.write '?'
        else:
          stdout.write 'M'
          stdout.write '-'
          if ch.ord >= 128 + 32:
            if ch.ord < 128 + 127:
              stdout.write chr(ch.ord - 128)
            else:
              stdout.write '^'
              stdout.write '?'
          else:
            stdout.write '^'
            stdout.write chr(ch.ord - 128 + 64)
        continue
      elif ch == '\t' and not optShow_tabs:
        stdout.write '\t'
        continue
      elif ch != '\n':
        stdout.write '^'
        stdout.write chr(ch.ord + 64)
        continue

    # -T, --show-tabs
    if optShow_tabs:
      if ch == '\t':
        stdout.write '^'
        stdout.write chr(ch.ord + 64)
        continue

    if ch == '\n':

      # -E
      if optShow_ends:
        stdout.write '$'

      # -s, --squeeze-blank
      if optSqueeze_blank:
        if i != size - 1:
          skip = dupCount(buf[i+1..<buf.len])
          # first line
          if i == 0 and skip > 0:
            skip = 1
            if optNumber or optNumber_nonblank:
              stdout.write '\n'
              stdout.write align($lineNo, 6)
              stdout.write '\t'
              inc lineNo
              continue
          else:
            if skip != 0:
              dec skip
              if skip > 0:
                if optNumber:
                  stdout.write '\n'
                  stdout.write align($lineNo, 6)
                  stdout.write '\t'
                  inc lineNo
                  continue

      # -n, --number, or -b, --number-nonblank
      if skip == 0:
        if optNumber or optNumber_nonblank:
          if i != size - 1:
            if optNumber or buf[i+1] != '\n':
              stdout.write '\n'
              stdout.write align($lineNo, 6)
              stdout.write '\t'
              inc lineNo
              continue

    # stdout.write "@"
    stdout.write ch
proc run() =
  var f: File

  # pipe / terminal
  # import terminal
  # if not isatty(stdin):

  for fileName in fileNames:
    if fileName == "-":
      echo "> fun: readStdin()"
    elif existsFile(fileName):
      if open(f, fileName):
        try:
          let bufSize = getFileInfo(f).size
          if bufSize == 0:
            quit(0)
          var buf = newString(bufSize)
          let getSize = readChars(f, buf, 0, bufSize)
          cat(buf, getSize)
        except:
          echo "Unknown exception!"
          # reraise the unknown exception:
          raise
        finally:
          close(f)
    elif existsDir(fileName):
      echo "cat: ", fileName, ": Is a directory"
    else:
      echo "cat: ", filename, ": No such file or directory"
      # quit(1)


proc main() =
  setControlCHook(ctrlc)
  parseOpts()
  run()

when isMainModule:
  main()
