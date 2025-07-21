const std = @import("std");
const exit = std.process.exit;
const print = std.debug.print;
const c_allocator = std.heap.c_allocator;

const core = @import("lexbor").core;
const html = @import("lexbor").html;
const tag = @import("lexbor").tag;

var allocator: std.mem.Allocator = undefined;

pub fn main() void {
    var arena = std.heap.ArenaAllocator.init(c_allocator);
    defer arena.deinit();

    allocator = arena.allocator();

    var status: core.Status = undefined;
    const data = "<div id=one-id class=silent ref='some &copy; a'>" ++
        "<option-one enabled>" ++
        "<option-two enabled='&#81'>" ++
        "</div>";

    print("HTML:\n{s}\n\n", .{data});
    print("Result:\n", .{});

    const tkz = html.tokenizer.create();
    defer _ = html.tokenizer.destroy(tkz);

    status = html.tokenizer.init(tkz);
    if (status != .ok) failed("Failed to create tokenizer object", .{});

    // Set callback for token
    html.tokenizer.callbackTokenDoneSet(tkz, tokenCallback, null);

    status = html.tokenizer.begin(tkz);
    if (status != .ok) failed("Failed to prepare tokenizer object for parsing", .{});

    status = html.tokenizer.chunk(tkz, data, data.len);
    if (status != .ok) failed("Failed to parse the html data", .{});

    status = html.tokenizer.end(tkz);
    if (status != .ok) failed("Failed to ending of parsing the html data", .{});
}

fn tokenCallback(tkz: ?*html.Tokenizer, token: ?*html.Token, ctx: ?*anyopaque) callconv(.C) ?*html.Token {
    _ = tkz;
    _ = ctx;

    var attr = token.?.attr_first;

    // Skip all #text or without attributes tokens
    if (token.?.tag_id == ._text or attr == null) {
        return token;
    }

    const tag_name = tag.nameById(token.?.tag_id, null) orelse
        failed("Failed to get token name", .{});

    print("\"{s}\" attributes:\n", .{tag_name});

    while (attr != null) {
        const name = html.token_attr.name(attr, null);

        if (name != null) {
            print("    Name: {s}; ", .{name.?});
        } else {
            // This can only happen for the DOCTYPE token.
            print("    Name: <NOT SET>; \n", .{});
        }

        if (attr.?.value != null) {
            const buf = std.fmt.allocPrint(allocator, "{s}\n", .{attr.?.value.?[0..attr.?.value_size]}) catch @panic("OOM");
            print("Value: {s}", .{buf});
        } else {
            print("Value: <NOT SET>\n", .{});
        }

        attr = attr.?.next;
    }

    return token;
}

pub fn failed(comptime fmt: []const u8, args: anytype) noreturn {
    print(fmt, args);
    exit(1);
}
