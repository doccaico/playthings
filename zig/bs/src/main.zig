const std = @import("std");

// https://hogehoge.tk/tool/number.html

var arena: std.heap.ArenaAllocator = undefined;

fn help(writer: anytype) !void {
    try writer.writeAll("Usage: bs.exe [256 or 0xff]\n");
    arena.deinit();
    std.process.exit(1);
}

fn fatal(writer: anytype, comptime format: []const u8, args: anytype) !void {
    try writer.print(format, args);
    arena.deinit();
    std.process.exit(1);
}

fn to_dec(input: []const u8) !u64 {
    return std.fmt.parseUnsigned(u64, input, 16);
}

fn to_hex(input: []const u8) !u64 {
    return std.fmt.parseUnsigned(u64, input, 10);
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();

    arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);

    if (args.len != 2) {
        try help(stderr);
    }

    if (std.mem.eql(u8, args[1], "--help") or std.mem.eql(u8, args[1], "-h")) {
        try help(stdout);
    }

    const arg = args[1];

    if (arg[0] == '0') {
        if (arg[1] == 'x' or arg[1] == 'X') {
            if (to_dec(arg[2..])) |dec| {
                try stdout.print("{d}\n", .{dec});
            } else |err| switch (err) {
                error.Overflow => try fatal(stderr, "overflow happend: {s}\n", .{arg}),
                error.InvalidCharacter => try fatal(stderr, "found invalid character: {s}\n", .{arg}),
            }
        }
    } else {
        if (to_hex(arg)) |hex| {
            try stdout.print("{x:0>16}", .{hex});
            try stdout.writeAll(" (");
            // zig fmt: off
            try stdout.print("{x:0>4}_{x:0>4}_{x:0>4}_{x:0>4}", .{
                hex >> 48,
                (hex & 0x0000FFFF00000000) >> 32,
                (hex & 0x00000000FFFF0000) >> 16,
                (hex & 0x000000000000FFFF)
            });
            // zig fmt: on
            try stdout.writeAll(")\n");
        } else |err| switch (err) {
            error.Overflow => try fatal(stderr, "overflow happend: {s}\n", .{arg}),
            error.InvalidCharacter => try fatal(stderr, "found invalid character: {s}\n", .{arg}),
        }
    }
}
