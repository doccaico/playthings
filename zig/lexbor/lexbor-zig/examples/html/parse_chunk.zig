const std = @import("std");

const failed = @import("base.zig").failed;
const serializerCallback = @import("base.zig").serializerCallback;

const core = @import("lexbor").core;
const dom = @import("lexbor").dom;
const html = @import("lexbor").html;

pub fn main() void {
    var status: core.Status = undefined;
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

    // Initialization
    const parser = html.parser.create();
    defer _ = html.parser.destroy(parser);
    status = html.parser.init(parser);
    if (status != .ok) {
        failed("Failed to create HTML parser", .{});
    }

    // Parse chunks
    const doc = html.parser.parseChunkBegin(parser) orelse failed("Failed to create Document object", .{});
    defer _ = html.document.destroy(doc);

    for (input) |in| {
        status = html.parser.parseChunkProcess(parser, in, in.len);
        if (status != .ok) {
            failed("Failed to parse HTML chunk", .{});
        }
    }

    status = html.parser.parseChunkEnd(parser);
    if (status != .ok) {
        failed("Failed to parse HTML", .{});
    }

    // Serialization
    status = html.serialize.prettyTreeCb(dom.interface.node(doc), .undef, 0, serializerCallback, null);
    if (status != .ok) {
        failed("Failed to serialization HTML tree", .{});
    }
}
