import os
import lexico

const Program = "trans"

proc toStringPosKind(kind: PosKind): string =
  case kind
  of posUnclass:
    "-"
  of posNoun:
    "noun"
  of posVerb:
    "verb"
  of posAdjective:
    "adj"
  of posAdverb:
    "adv"
  of posPronoun:
    "pron" 
  of posPreposition:
    "prep"
  of posTransverb:
    "trans. verb"
  of  posAuxverb:
    "aux verb"
  of posAbbreviation:
    "abbr"
  of posProperNoun:
    "proper noun"

proc help(code :int) =
  echo "Usage: " & Program & " Options word"
  echo ""
  echo "  Search for English words on https://www.lexico.com"
  echo ""
  echo "Options:"
  echo "  -uk         search out what it means in British English"
  echo "  -usa        search out what it means in American English"
  echo "  -h, --help  display this help and exit"
  quit(code)

when isMainModule:

  let argv = commandLineParams()
  var locale : Locale

  if argv.len == 1:
    case argv[0]
    of "-h", "--help":
      help(QuitSuccess)
    else:
      stderr.writeLine "unrecognized command line option '" & argv[0] & "'"
      help(QuitFailure)

  if argv.len != 2:
    help(QuitFailure)
  case argv[0]
  of "-uk":
    locale = Locale.uk
  of "-usa":
    locale = Locale.usa
  else:
    stderr.writeLine "unrecognized command line option '" & argv[0] & "'"
    help(QuitFailure)

  var key = ""
  # key= "horrible"
  # key= "ox"
  # key= "anarchy"
  # key= "autumn"
  # key = "I"
  # key = "he"
  # key = "punkk" # get suggest words
  # key = "yaass" # none
  # key = "anachy" # get suggest words
  # key = "ctteedfadfakje" # none
  # key= "chaoticc"
  # key= "chaos"
  key = argv[1]

  var lex = newLexico(key, Locale.usa)
  lex.search()

  for i, info in lex.info:
    echo "[", toStringPosKind(info.kind), "]"
    echo i+1, ". ", info.main.def
    for j, sub in info.sub:
      echo "  ", j+1, ". ",  sub.def
