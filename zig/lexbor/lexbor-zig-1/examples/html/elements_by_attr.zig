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
        "<div class=\"green best grep\"></div>" ++
        "<a href=\"http://some.link/\">ref</a>" ++
        "<div class=\"red c++ best\"></div>";
    var status: core.Status = undefined;

    print("HTML:\n", .{});
    print("{s}\n", .{input});

    const doc = parse(input, input.len);
    defer _ = html.document.destroy(doc);

    const body = dom.interface.element(doc.body);

    const collection = dom.collection.make(&doc.dom_document, 128) orelse failed("Failed to create Collection object", .{});
    defer _ = dom.collection.destroy(collection, true);

    // Full match
    status = dom.elements.byAttr(body, collection, "class", 5, "red c++ best", 12, true);
    if (status != .ok) failed("Failed to get elements by name", .{});

    print("\nFull match by 'red c++ best':\n", .{});
    print_collection_elements(collection);

    // From begin
    status = dom.elements.byAttrBegin(body, collection, "href", 4, "http", 4, true);
    if (status != .ok) failed("Failed to get elements by name", .{});

    print("\nFrom begin by 'http':\n", .{});
    print_collection_elements(collection);

    // From end
    status = dom.elements.byAttrEnd(body, collection, "class", 5, "grep", 4, true);
    if (status != .ok) failed("Failed to get elements by name", .{});

    print("\nFrom end by 'grep':\n", .{});
    print_collection_elements(collection);

    // Contain
    status = dom.elements.byAttrContain(body, collection, "class", 5, "c++ b", 5, true);
    if (status != .ok) failed("Failed to get elements by name", .{});

    print("\nContain by 'c++ b':\n", .{});
    print_collection_elements(collection);
}

fn print_collection_elements(collection: ?*dom.Collection) void {
    for (0..dom.collection.length(collection)) |i| {
        const element = dom.collection.element(collection, i);
        serializeNode(dom.interface.node(element));
    }
    dom.collection.clean(collection);
}
