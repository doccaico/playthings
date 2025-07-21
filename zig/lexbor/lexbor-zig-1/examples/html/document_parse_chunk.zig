const std = @import("std");
const print = std.debug.print;

const failed = @import("base.zig").failed;
const serialize = @import("base.zig").serialize;

const core = @import("lexbor").core;
const dom = @import("lexbor").dom;
const html = @import("lexbor").html;

pub fn main() void {
    const input = [_][]const u8{
        "<!DOCT",
        "YPE htm",
        "l>",
        "<html><head>",
        "<ti",
        "tle>HTML chun",
        "ks parsing</",
        "title>",
        "</head><bod",
        "y><div cla",
        "ss=",
        "\"bestof",
        "class",
        "\">",
        "good for me",
        "</div>",
    };
    var status: core.Status = undefined;

    // Initialization
    const doc = html.document.create() orelse failed("Failed to create HTML Document", .{});
    defer _ = html.document.destroy(doc);

    // Parse HTML
    status = html.document.parseChunkBegin(doc);
    if (status != .ok) failed("Failed to parse HTML", .{});

    print("Incoming HTML chunks:\n", .{});

    for (input) |in| {
        print("{s}\n", .{in});

        status = html.document.parseChunk(doc, in, in.len);

        if (status != .ok) failed("Failed to parse HTML chunk", .{});
    }

    status = html.document.parseChunkEnd(doc);
    if (status != .ok) failed("Failed to parse HTML", .{});

    // Print Result
    print("\nHTML Tree:\n", .{});
    serialize(dom.interface.node(doc));
}
