import std.algorithm : filter, map, each;
import std.ascii : isDigit;
import std.conv : to, parse;
import std.format : format;
import std.net.curl : get;
import std.stdio : writeln;
import std.string : strip;

import parserino;

void help() {
    writeln("A program to read bible.
            Usage: verse [Chapter] [Page]
            Exsample: verse GEN 1");
}

string alignNumber(string text)
{
    auto c0 = text[0], c1 = text[1], c2 = text[2];

    if (isDigit(c0)) {
        if (isDigit(c1)) {
            if (isDigit(c2)) {
                return format("%c%c%c: %s", c0, c1, c2, text[3 .. $]);
            }
            return format("%c%c: %s", c0, c1, text[2 .. $]);
        } else {
            return format("%c: %s", c0, text[1 .. $]);
        }
    } else {
        return text;
    }
}

int main(string[] args)
{
    if (args.length != 1 && (args[1] == "-h" || args[1] == "--help")) {
        help();
        return 0;
    }
    if (args.length != 3) {
        help();
        return 1;
    }

    const BASE_URL = "https://www.bible.com/ja/bible/1819";

    auto rootURL = args[1];
    auto page = parse!int(args[2]);

    auto URL = format("%s/%s.%d", BASE_URL, rootURL, page);

    // Get the html of a bible page
    auto data = URL.get.to!string;

    // Parse the html
    Document doc = Document(data);

    auto div_text = doc.byTagName("div")
        .filter!(x => x.getAttribute("data-usfm") == format("%s.%d", rootURL, page)).front;

    div_text.byTagName("span")
        .filter!(x => x.hasAttribute("data-usfm"))
        .filter!(x => x.innerText.strip.length != 0)
        .map!(x => alignNumber(x.innerText))
        .each!(x => writeln(x));

    return 0;
}
