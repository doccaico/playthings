const std = @import("std");
const print = std.debug.print;

const failed = @import("base.zig").failed;
const serialize = @import("base.zig").serialize;
const serializeNode = @import("base.zig").serializeNode;
const parse = @import("base.zig").parse;

const core = @import("lexbor").core;
const dom = @import("lexbor").dom;
const html = @import("lexbor").html;
const tag = @import("lexbor").tag;

pub fn main() void {
    const input = "";
    var tag_name_len: usize = undefined;

    // Parse
    const doc = parse(input, input.len);
    defer _ = html.document.destroy(doc);

    const body = html.document.bodyElement(doc);

    var cur: tag.IdEnum = .a;
    const last: tag.IdEnum = ._last_entry;

    while (@intFromEnum(cur) < @intFromEnum(last)) : (cur = @enumFromInt(@intFromEnum(cur) + 1)) {
        const tag_name = tag.nameById(cur, &tag_name_len) orelse failed("Failed to get tag name by id", .{});

        const element = dom.document.createElement(&doc.dom_document, tag_name, tag_name_len, null) orelse
            failed("Failed to create element for tag \"{s}\"", .{tag_name});

        if (html.tag.isVoid(cur)) {
            print("Create element by tag name \"{s}\"\n", .{tag_name});
        } else {
            print("Create element by tag name \"{s}\" and append text node\n", .{tag_name});

            const text = dom.document.createTextNode(&doc.dom_document, tag_name, tag_name_len) orelse
                failed("Failed to create text node for \"{s}\"", .{tag_name});

            dom.node.insertChild(dom.interface.node(element), dom.interface.node(text));
        }
        serializeNode(dom.interface.node(element));
        dom.node.insertChild(dom.interface.node(body), dom.interface.node(element));
    }
    // Print Result
    serialize(dom.interface.node(doc));
}
