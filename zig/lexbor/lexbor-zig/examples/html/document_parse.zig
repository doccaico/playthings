const std = @import("std");
const print = std.debug.print;

const failed = @import("base.zig").failed;
const serialize = @import("base.zig").serialize;

const core = @import("lexbor").core;
const dom = @import("lexbor").dom;
const html = @import("lexbor").html;

pub fn main() void {
    const input = "<div><p>blah-blah-blah</div>";

    // Initialization
    const doc = html.document.create() orelse failed("Failed to create HTML Document", .{});
    defer _ = html.document.destroy(doc);

    // Parse HTML
    const status = html.document.parse(doc, input, input.len);
    if (status != .ok) failed("Failed to parse HTML", .{});

    // Print Incoming Data
    print("HTML:\n", .{});
    print("{s}\n", .{input});

    // Print Result
    print("\nHTML Tree:\n", .{});
    serialize(dom.interface.node(doc));
}
