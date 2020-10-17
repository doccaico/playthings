import htmlparser
import httpClient
import sequtils
import strtabs
import strutils
import strutils
import sugar
import terminal
import xmltree


type
  Locale* = enum
    uk = "//"
    usa = "/en/"

  # kind of part of speech
  PosKind* = enum
    posUnclass, # for 'I'
    posNoun, posVerb, posAdjective, posAdverb, posPronoun, posPreposition,
        posTransverb, posAuxverb, posAbbreviation, posProperNoun

type
  Info* = object
    def*: string

  Definition* = object
    kind*: PosKind
    main*: Info
    sub*: seq[Info]

  Lexico* = object
    locale: Locale
    url: string
    redirectUrl: string
    word: string
    info*: seq[Definition]
    suggestWords: seq[string]


proc newLexico*(word: string, locale: Locale): Lexico  =
  result = Lexico(
    word: word,
    locale: locale,
    url:  "https://www.lexico.com" & $locale & "definition/" & word
  )

proc newPosKind(val: string): PosKind =
  result = case val
  of "":
    posUnclass
  of "noun":
    posNoun
  of "verb":
    posVerb
  of "adjective":
    posAdjective
  of "adverb":
    posAdverb
  of "pronoun":
    posPronoun
  of "preposition":
    posPreposition
  of "transitive verb":
    posTransverb
  of "auxiliary verb":
    posAuxverb
  of "abbreviation":
    posAbbreviation
  of "proper noun":
    posProperNoun
  else:
    stderr.styledWrite(fgRed, "Error: ")
    quit("unknown enum value: " & "'" & val & "'")

proc setBases(html: XmlNode): seq[XmlNode] =
  let sections = html.findAll("section")
  result = newSeqOfCap[XmlNode](sections.len)
  for tag in sections:
    if tag.attrsLen > 0 and tag.attrs["class"] == "gramb":
      result.add(tag)
  assert result != @[]

proc setKind(lex: var Lexico, base: XmlNode) =
  for tag in base.findALL("span"):
    if tag.attrsLen > 0 and tag.attrs["class"] == "pos":
      let kind =
        if tag.len == 0: "" # for 'I'
        else: tag[0].text
      lex.info.add(
        Definition(
          kind: newPosKind(kind),
          main: Info(def: ""),
          sub: @[])
      )
  assert lex.info.len != 0

proc setDefinition(lex: var Lexico, base: XmlNode, count: int) =
  lex.setKind(base)
  for tag in base.findAll("ul"):
    if tag.attrsLen > 0 and tag.attrs["class"] == "semb":
      var i = 0
      for span in tag.findALL("span"):
        if span.attrsLen > 0 and span.attrs["class"] == "ind":
          if i == 0:
            lex.info[count].main.def = span[0].text
          else:
            lex.info[count].sub.add(Info(def: span[0].text))
          inc i
  assert lex.info[0].main.def != ""

proc setSuggestWords(lex: var Lexico, html :XmlNode) =
  let content = newHttpClient(maxRedirects = 0).request(lex.redirectUrl)
  let html = parseHtml(content.body)
  for tag in html.findAll("a"):
    if tag.attrs.contains("class") and tag.attrs["class"] == "no-transition":
      lex.suggestWords.add(tag[0].text)

proc search*(lex: var Lexico) =

  var content = newHttpClient(maxRedirects = 1).request(lex.url)
  let redirect = content.status.startsWith "302"

  if redirect:
    lex.redirectUrl = content.headers["location"]
    content = newHttpClient(maxRedirects = 0).request(lex.redirectUrl)
    lex.setSuggestWords(parseHtml(content.body))

    stdout.write "'" & lex.word & "' is not found"
    if lex.suggestWords != []:
      stdout.write "; did you mean "
      stdout.write map(lex.suggestWords, w => "'" & w & "'").join(" ")
      stdout.write "?"
    stdout.write "\n"
    quit(1)

  let html = parseHtml(content.body)

  var bases = setBases(html)

  for count, base in bases.pairs:
    lex.setDefinition(base, count)




