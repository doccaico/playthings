const std = @import("std");
const print = std.debug.print;

const failed = @import("base.zig").failed;
const serialize = @import("base.zig").serialize;

const core = @import("lexbor").core;
const dom = @import("lexbor").dom;
const html = @import("lexbor").html;

pub fn main() void {
    const input = "<head><title>  Oh,    my...   </title></head>";
    var status: core.Status = undefined;

    // Initialization
    const doc = html.document.create() orelse failed("Failed to create HTML Document", .{});
    defer _ = html.document.destroy(doc);

    // Parse HTML
    status = html.document.parse(doc, input, input.len);
    if (status != .ok) failed("Failed to parse HTML", .{});

    // Print HTML tree
    print("HTML Tree:\n", .{});
    serialize(dom.interface.node(doc));

    // Get title
    if (html.document.getTitle(doc)) |title| {
        print("\nTitle: {s}", .{title});
    } else {
        print("\nTitle is empty", .{});
    }

    // Get raw title
    if (html.document.getRawTitle(doc)) |raw_title| {
        print("\nRaw title: {s}", .{raw_title});
    } else {
        print("\nRaw title is empty", .{});
    }

    const new_title = "We change title";
    print("\nChange title to: {s}", .{new_title});

    // Set new title
    status = html.document.setTitle(doc, new_title, new_title.len);
    if (status != .ok) failed("Failed to change HTML title", .{});

    // Get new title
    if (html.document.getTitle(doc)) |title| {
        print("\nNew title: {s}", .{title});
    } else {
        print("\nNew title is empty", .{});
    }

    // Print HTML tree
    print("\n\nHTML Tree after change title:\n", .{});
    serialize(dom.interface.node(doc));
}
