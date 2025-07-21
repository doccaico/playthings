const std = @import("std");
const print = std.debug.print;

const failed = @import("base.zig").failed;
const parse = @import("base.zig").parse;
const serialize = @import("base.zig").serialize;
const serializeNode = @import("base.zig").serializeNode;

const core = @import("lexbor").core;
const dom = @import("lexbor").dom;
const html = @import("lexbor").html;

pub fn main() void {
    const input = "<div id=my-best-id></div>";
    const name = "my-name";
    var element: ?*dom.Element = undefined;
    var status: core.Status = undefined;

    // Parse
    const doc = parse(input, input.len);
    defer _ = html.document.destroy(doc);

    // Print Incoming Data
    print("HTML:\n", .{});
    print("{s}\n\n", .{input});
    print("Tree after parse:\n", .{});
    serialize(dom.interface.node(doc));

    const collection = dom.collection.make(&doc.dom_document, 16) orelse failed("Failed to create collection", .{});
    defer _ = dom.collection.destroy(collection, true);

    // Get BODY element (root for search)
    const body = html.document.bodyElement(doc);
    element = dom.interface.element(body);

    // Find DIV eleemnt
    status = dom.elements.byTagName(element, collection, "div", 3);

    if (status != .ok or dom.collection.length(collection) == 0) {
        failed("Failed to find DIV element", .{});
    }

    // Append new attribute
    element = dom.collection.element(collection, 0);

    var attr: ?*dom.Attr = dom.element.setAttribute(element, name, name.len, "oh God", 6) orelse failed("Failed to create and append new attribute", .{});

    // Print Result
    print("\nTree after append attribute to DIV element:\n", .{});
    serialize(dom.interface.node(doc));

    // Check exist
    const is_exist = dom.element.hasAttribute(element, name, name.len);

    if (is_exist) {
        print("\nElement has attribute \"{s}\": true", .{name});
    } else {
        print("\nElement has attribute \"{s}\": false", .{name});
    }

    // Get value by qualified name
    var value_len: usize = undefined;
    const value = dom.element.getAttribute(element, name, name.len, &value_len) orelse failed("Failed to get attribute value by qualified name", .{});

    print("\nGet attribute value by qualified name \"{s}\": {s}\n", .{ name, value });

    // Iterator
    print("\nGet element attributes by iterator:\n", .{});
    attr = dom.element.firstAttribute(element);
    var tmp_len: usize = undefined;
    while (attr != null) {
        var tmp = dom.attr.qualifiedName(attr, &tmp_len);
        print("Name: {s}", .{tmp.?});

        tmp = dom.attr.value(attr, &tmp_len);
        if (tmp != null) {
            print("; Value: {s}\n", .{tmp.?});
        } else {
            print("\n", .{});
        }

        attr = dom.element.nextAttribute(attr);
    }

    // Change value
    print("\nChange attribute value:\n", .{});
    print("Element before attribute \"{s}\" change: ", .{name});
    serializeNode(dom.interface.node(element));

    attr = dom.element.attrByName(element, name, name.len);
    status = dom.attr.setValue(attr, "new value", 9);
    if (status != .ok) failed("Failed to change attribute value", .{});

    print("Element after attribute \"{s}\" change: ", .{name});
    serializeNode(dom.interface.node(element));

    // Remove new attribute by name
    _ = dom.element.removeAttribute(element, name, name.len);

    // Print Result
    print("\nTree after remove attribute form DIV element:", .{});
    serialize(dom.interface.node(doc));
}
