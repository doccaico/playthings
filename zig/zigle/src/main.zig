const std = @import("std");
const fmt = std.fmt;
const fs = std.fs;
const heap = std.heap;
const mem = std.mem;
const process = std.process;

var arena: heap.ArenaAllocator = undefined;

fn help(writer: anytype, appname: []const u8) !noreturn {
    try writer.print("Usage: {s} [DIR]\n", .{appname});
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

    var read_buf: [64]u8 = undefined;
    var path_buf: [128]u8 = undefined;
    var dir = try fs.cwd().openDir(args[1], .{ .iterate = true });
    var command = std.ArrayList([]const u8).init(allocator);
    var walker = try dir.walk(allocator);
    while (try walker.next()) |entry| {
        if (entry.kind == .file and mem.endsWith(u8, entry.path, ".zig")) {
            const file = try dir.openFile(entry.path, .{});
            defer file.close();

            var reader = file.reader(&read_buf);
            const ret = try reader.interface.peekDelimiterExclusive('\n');
            const cmd = ret["// Build: ".len..];
            var it = mem.splitScalar(u8, cmd, ' ');
            while (it.next()) |val| {
                if (mem.eql(u8, val, "%")) {
                    const base = if (args[1][args.len - 0] == '\\') args[1][0 .. args[1].len - 1] else args[1][0..args[1].len];
                    const path = try fmt.bufPrint(&path_buf, "{s}\\{s}", .{ base, entry.path });
                    try command.append(path);
                    continue;
                }
                try command.append(val);
            }

            for (command.items) |c| {
                try stdout.print("{s} ", .{c});
            }
            try stdout.print("\n", .{});

            // ビルドだけして実行はしない
            // コンパイルエラーがあれば出力する
            const result = try process.Child.run(.{ .allocator = allocator, .argv = command.items });
            const success = switch (result.term) {
                .Exited => |code| if (code == 0) true else false,
                else => false,
            };
            if (!success) {
                try stderr.print("{s}", .{result.stderr});
            }

            command.clearRetainingCapacity();
        }
    }
}
