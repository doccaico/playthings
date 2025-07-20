const std = @import("std");
const fmt = std.fmt;
const fs = std.fs;
const heap = std.heap;
const mem = std.mem;
const process = std.process;

var arena: std.heap.ArenaAllocator = undefined;

fn help(writer: anytype, appname: []const u8) !noreturn {
    try writer.print("Usage: {s} [256 or 0xff]\n", .{appname});
    arena.deinit();
    process.exit(1);
}

pub fn main() !void {
    var stdout_file = fs.File.stdout().writer(&.{});
    const stdout = &stdout_file.interface;
    var stderr_file = fs.File.stderr().writer(&.{});
    const stderr = &stderr_file.interface;

    arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try process.argsAlloc(allocator);

    if (args.len != 2) {
        try help(stderr, args[0]);
    }

    if (mem.eql(u8, args[1], "--help") or mem.eql(u8, args[1], "-h")) {
        try help(stdout, args[0]);
    }

    const numStr = args[1];
    const parsed = try fmt.parseUnsigned(u64, numStr, 0);
    var buf: [128]u8 = undefined;
    // Bin
    {
        var count: i32 = 1;
        var list = std.ArrayList(u8).init(allocator);
        for (try fmt.bufPrint(&buf, "{b:064}", .{parsed})) |val| {
            try list.append(val);
            if (count == 4) {
                try list.append('_');
                count = 1;
            } else {
                count += 1;
            }
        }
        _ = list.pop(); // remove '_'
        const result = try fmt.bufPrint(&buf, "[Bin] {s}\n", .{list.items});
        try stdout.print("{s}", .{result});
    }
    // Oct
    {
        var count: i32 = 1;
        var list = std.ArrayList(u8).init(allocator);
        for (try fmt.bufPrint(&buf, "{o:064}", .{parsed})) |val| {
            try list.append(val);
            if (count == 4) {
                try list.append('_');
                count = 1;
            } else {
                count += 1;
            }
        }
        _ = list.pop(); // remove '_'
        const result = try fmt.bufPrint(&buf, "[Oct] {s}\n", .{list.items});
        try stdout.print("{s}", .{result});
    }
    // Hex
    {
        var count: i32 = 1;
        var list = std.ArrayList(u8).init(allocator);
        for (try fmt.bufPrint(&buf, "{x:064}", .{parsed})) |val| {
            try list.append(val);
            if (count == 4) {
                try list.append('_');
                count = 1;
            } else {
                count += 1;
            }
        }
        _ = list.pop(); // remove '_'
        const result = try fmt.bufPrint(&buf, "[Hex] {s}\n", .{list.items});
        try stdout.print("{s}", .{result});
    }
    // Dec
    {
        var count: i32 = 1;
        const slice = try fmt.bufPrint(&buf, "{d}", .{parsed});
        var list = std.ArrayList(u8).init(allocator);
        if (slice.len >= 4) {
            var it = mem.reverseIterator(slice);
            while (it.next()) |val| {
                try list.append(val);
                if (count == 3) {
                    try list.append(',');
                    count = 1;
                } else {
                    count += 1;
                }
            }
            if (list.items[list.items.len - 1] == ',') {
                _ = list.pop();
            }
            mem.reverse(u8, list.items);
        } else {
            try list.appendSlice(slice);
        }

        for (0..79 - list.items.len) |_| {
            try list.insert(0, ' ');
        }
        const result = try fmt.bufPrint(&buf, "[Dec] {s}\n", .{list.items});
        try stdout.print("{s}", .{result});
    }
    // Dec'
    {
        const slice = try fmt.bufPrint(&buf, "{d}", .{parsed});
        var list = std.ArrayList(u8).init(allocator);

        for (0..78 - slice.len) |_| {
            try list.append(' ');
        }
        try list.appendSlice(slice);
        const result = try fmt.bufPrint(&buf, "[Dec'] {s}\n", .{list.items});
        try stdout.print("{s}", .{result});
    }
}
