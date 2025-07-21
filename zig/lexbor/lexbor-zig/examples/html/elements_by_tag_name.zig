const std = @import("std");
const print = std.debug.print;

const failed = @import("base.zig").failed;
const parse = @import("base.zig").parse;
const serializeNode = @import("base.zig").serializeNode;

const core = @import("lexbor").core;
const dom = @import("lexbor").dom;
const html = @import("lexbor").html;

pub fn main() void {
    const input = "<div a=b><span></div><div x=z></div>";

    const doc = parse(input, input.len);
    defer _ = html.document.destroy(doc);

    const collection = dom.collection.make(&doc.dom_document, 128) orelse failed("Failed to create Collection object", .{});
    defer _ = dom.collection.destroy(collection, true);

    const status = dom.elements.byTagName(dom.interface.element(doc.body), collection, "div", 3);
    if (status != .ok) failed("Failed to get elements by name", .{});

    print("HTML:\n", .{});
    print("{s}\n", .{input});
    print("\nFind all 'div' elements by tag name 'div'.\n", .{});
    print("Elements found:\n", .{});

    for (0..dom.collection.length(collection)) |i| {
        const element = dom.collection.element(collection, i);
        serializeNode(dom.interface.node(element));
    }
}
