import std.stdio : writeln;

import d2sqlite3;

void help() {
    writeln(`A program to read a Google Chrome History file.
            Usage: gh-d [path]
            Exsample: gh-d History`);
}

// https://www.mirandora.com/?p=697

int main(string[] args)
{
    if (args.length != 1 && (args[1] == "-h" || args[1] == "--help")) {
        help();
        return 0;
    }
    if (args.length != 2) {
        help();
        return 1;
    }

    // .cmd ファイルなどで、History ファイルをどこかにコピーして、それを path として渡す事。
    string filepath = args[1];

    auto db = Database(filepath);

    ResultRange results = db.execute("SELECT * FROM urls");

    foreach (Row row; results) {
        auto title = row["title"].as!string;
        auto url = row["url"].as!string;
        writeln(title, "\t", url);
    }

    return 0;
}
