const std = @import("std");
const exit = std.process.exit;
const print = std.debug.print;

const core = @import("lexbor").core;
const html = @import("lexbor").html;
const tag = @import("lexbor").tag;

pub fn main() void {
    var status: core.Status = undefined;
    const data = "<div>Hi<span> my </span>friend</div>! " ++
        "&#x54;&#x72;&#x79;&#x20;&#x65;&#x6e;&#x74;" ++
        "&#x69;&#x74;&#x69;&#x65;&#x73;&excl;";

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

    print("\n", .{});
}

fn tokenCallback(tkz: ?*html.Tokenizer, token: ?*html.Token, ctx: ?*anyopaque) callconv(.C) ?*html.Token {
    _ = tkz;
    _ = ctx;

    // Skip all not #text tokens
    if (token.?.tag_id != ._text) return token;

    print("{s}\n", .{token.?.text_start.?[0 .. token.?.text_end.? - token.?.text_start.?]});

    return token;
}

pub fn failed(comptime fmt: []const u8, args: anytype) noreturn {
    print(fmt, args);
    exit(1);
}
