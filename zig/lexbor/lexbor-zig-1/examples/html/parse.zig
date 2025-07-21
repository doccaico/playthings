const std = @import("std");
const print = std.debug.print;

const failed = @import("base.zig").failed;
const serializerCallback = @import("base.zig").serializerCallback;

const core = @import("lexbor").core;
const dom = @import("lexbor").dom;
const html = @import("lexbor").html;

pub fn main() void {
    var status: core.Status = undefined;
    const html_one = "<div><p>First</div>";
    const html_two = "<div><p>Second</div>";

    // Initialization
    const parser = html.parser.create();
    status = html.parser.init(parser);
    if (status != .ok) {
        failed("Failed to create HTML parser", .{});
    }

    // Parse
    const doc_one = html.parse(parser, html_one, html_one.len) orelse failed("Failed to create Document object", .{});
    defer _ = html.document.destroy(doc_one);

    const doc_two = html.parse(parser, html_two, html_two.len) orelse failed("Failed to create Document object", .{});
    defer _ = html.document.destroy(doc_two);

    // Destroy parser
    _ = html.parser.destroy(parser);

    // Serialization
    print("First Document:\n", .{});
    status = html.serialize.prettyTreeCb(dom.interface.node(doc_one), .undef, 0, serializerCallback, null);
    if (status != .ok) {
        failed("Failed to serialization HTML tree", .{});
    }

    print("\nSecond Document:\n", .{});
    status = html.serialize.prettyTreeCb(dom.interface.node(doc_two), .undef, 0, serializerCallback, null);
    if (status != .ok) {
        failed("Failed to serialization HTML tree", .{});
    }
}
