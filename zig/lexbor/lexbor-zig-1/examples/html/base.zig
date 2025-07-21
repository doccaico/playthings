const std = @import("std");
const exit = std.process.exit;
const panic = std.debug.panic;
const print = std.debug.print;

const core = @import("lexbor").core;
const html = @import("lexbor").html;
const dom = @import("lexbor").dom;

pub fn failed(comptime fmt: []const u8, args: anytype) noreturn {
    print(fmt, args);
    exit(1);
}

pub fn parse(input: []const u8, input_len: usize) *html.Document {
    var status: core.Status = undefined;

    const parser = html.parser.create();
    if (parser == null) {
        panic("Failed to create", .{});
    }

    status = html.parser.init(parser);
    if (status != core.Status.ok) {
        panic("Failed to create HTML parser", .{});
    }

    const document = html.parser.parse(parser, input, input_len);
    if (parser == null) {
        panic("Failed to create Document object", .{});
    }

    _ = html.parser.destroy(parser);

    return document.?;
}

pub fn serialize(node: ?*dom.Node) void {
    const status = html.serialize.prettyTreeCb(node, html.serialize.Opt.undef, 0, serializerCallback, null);

    if (status != core.Status.ok) {
        panic("Failed to serialization HTML tree", .{});
    }
}

pub fn serializeNode(node: ?*dom.Node) void {
    const status = html.serialize.prettyCb(node, html.serialize.Opt.undef, 0, serializerCallback, null);

    if (status != core.Status.ok) {
        panic("Failed to serialization HTML tree", .{});
    }
}

pub fn serializerCallback(data: ?[*:0]const core.CharType, len: usize, ctx: ?*anyopaque) callconv(.C) core.StatusType {
    _ = ctx;
    _ = len;
    print("{s}", .{data.?});
    return @intFromEnum(core.Status.ok);
}
