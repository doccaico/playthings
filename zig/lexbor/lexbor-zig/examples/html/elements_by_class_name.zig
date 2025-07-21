const std = @import("std");
const print = std.debug.print;

const failed = @import("base.zig").failed;
const parse = @import("base.zig").parse;
const serializeNode = @import("base.zig").serializeNode;

const core = @import("lexbor").core;
const dom = @import("lexbor").dom;
const html = @import("lexbor").html;

pub fn main() void {
    const input =
        "<div class=\"best blue some\"><span></div>" ++
        "<div class=\"red pref_best grep\"></div>" ++
        "<div class=\"red best grep\"></div>" ++
        "<div class=\"red c++ best\"></div>";

    const doc = parse(input, input.len);
    defer _ = html.document.destroy(doc);

    const collection = dom.collection.make(&doc.dom_document, 128) orelse failed("Failed to create Collection object", .{});
    defer _ = dom.collection.destroy(collection, true);

    const status = dom.elements.byClassName(dom.interface.element(doc.body), collection, "best", 4);
    if (status != .ok) failed("Failed to get elements by name", .{});

    print("HTML:\n", .{});
    print("{s}\n", .{input});
    print("\nFind all 'div' elements by class name 'best'.\n", .{});
    print("Elements found:\n", .{});

    for (0..dom.collection.length(collection)) |i| {
        const element = dom.collection.element(collection, i);
        serializeNode(dom.interface.node(element));
    }
}
