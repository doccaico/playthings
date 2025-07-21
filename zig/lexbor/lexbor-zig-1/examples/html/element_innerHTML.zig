const std = @import("std");
const print = std.debug.print;

const failed = @import("base.zig").failed;
const parse = @import("base.zig").parse;
const serialize = @import("base.zig").serialize;

const dom = @import("lexbor").dom;
const html = @import("lexbor").html;

pub fn main() void {
    const input = "<div><span>blah-blah-blah</div>";
    const inner = "<ul><li>1<li>2<li>3</ul>";

    // Parse
    const doc = parse(input, input.len);
    defer _ = html.document.destroy(doc);

    // Print Incoming Data
    print("HTML:\n", .{});
    print("{s}\n", .{input});
    print("\nTree after parse:", .{});
    serialize(dom.interface.node(doc));

    // Get BODY element
    const body = html.document.bodyElement(doc);

    print("\nHTML for innerHTML:\n", .{});
    print("{s}\n", .{inner});

    _ = html.element.innerHtmlSet(html.interface.element(body), inner, inner.len) orelse failed("Failed to parse innerHTML", .{});

    // Print Result
    print("\nTree after innerHTML set:\n", .{});
    serialize(dom.interface.node(doc));
}
