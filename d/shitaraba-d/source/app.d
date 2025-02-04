import std.array: appender;
import std.format : format;
import std.net.curl : HTTP;
import std.range : popFront, zip;
import std.stdio : writeln;
import std.string : strip;
import std.windows.charset : fromMBSz;

import parserino;

// EUC-JP -> UTF-8
// https://dlang-jp.github.io/Cookbook/cookbook--network_example.html

void help() {
    writeln("A program to read shitaraba (https://jbbs.shitaraba.net/).
            Usage: shitaraba-d [genre] [id] [number]
            Exsample: shitaraba-d sports 12345 456789012");
}

int main(string[] args)
{
    if (args.length != 1 && (args[1] == "-h" || args[1] == "--help")) {
        help();
        return 0;
    }
    if (args.length != 4) {
        help();
        return 1;
    }

    auto genre = args[1];
    auto id = args[2];
    auto number = args[3];

    auto client = HTTP();
    auto contents = appender!(char[])();
    client.url = format("https://jbbs.shitaraba.net/bbs/read.cgi/%s/%s/%s/l50", genre, id, number);
    client.onReceive = (void[] buf)
    {
        contents ~= cast(byte[])buf;
        return buf.length;
    };
    client.perform();
    auto buf = contents.data;

    auto utf8Contents = fromMBSz(cast(immutable char*)buf.ptr, 20_932);

    // Parse the html
    Document doc = Document(utf8Contents);

    auto dt_text = doc.byTagName("dt");
    dt_text.popFront();

    auto dd_text = doc.byTagName("dd");
    dd_text.popFront();

    foreach(t; zip(dt_text, dd_text)) {
        writeln("[", t[0].innerText.strip, "]");
        writeln(t[1].innerText.strip);
        writeln();
    }

    return 0;
}
