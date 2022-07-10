import
  std/os,
  std/osproc,
  std/strutils

proc createCommand(line: string): (string, seq[string]) =
  let cmds = splitWhitespace(line)
  let cmd = cmds[0]
  let args = cmds[1..^1]
  (cmd, args)

if isMainModule:

  while true:
    stdout.write ">  "
    let line = readline(stdin).strip()

    if line == "": continue

    let (cmd, args) = createCommand(line)

    # builtin command
    case cmd
    of "cd":
      if args.len == 0:
        setCurrentDir(getHomeDir())
      elif args.len == 1:
        setCurrentDir(args[0])
      else:
        stderr.writeline "cd: too many arguments"
      continue
    of "help":
      stdout.write "This is a help message"
    of "exit":
      quit(0)
    else: discard


    var output: string
    try:
      output = execProcess(cmd, args=args, options={poStdErrToStdOut, poUsePath})
    except:
      echo getCurrentExceptionMsg()
      continue

    stdout.write output
