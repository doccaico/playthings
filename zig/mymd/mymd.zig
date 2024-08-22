// Date: 2024/08/22
// Zig version: 0.14.0-dev.1224+16d74809d
// Build: zig build-exe -Doptimize=ReleaseFast mymd.zig

// Windowsでしかテストしていません

const std = @import("std");
const fs = std.fs;
const io = std.io;
const math = std.math;
const mem = std.mem;
const process = std.process;


var arena: std.heap.ArenaAllocator = undefined;


fn help(writer: anytype) !void {
    try writer.writeAll("Usage: mymd hoge.md\n");
    arena.deinit();
    process.exit(1);
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

    const cwd = fs.cwd();

    // {{ . }} の前の部分を出力する
    const md = try cwd.readFileAlloc(allocator, "mymd.tmpl.html", math.maxInt(usize));
    const pos = mem.indexOf(u8, md, "{{ . }}") orelse return error.templFileIsWeird;
    try stdout.print("{s}\n", .{md[0..pos]});


    // markdownの変換
    const file = try cwd.openFile(args[1], .{});
    defer file.close();
    var buf: [1024*2]u8 = undefined;
    var fbs = io.fixedBufferStream(&buf);
    while (true): (fbs.reset()) {
        file.reader().streamUntilDelimiter(fbs.writer(), '\n', buf.len) catch |err| switch(err) {
            error.EndOfStream => break,
            else => return err,
        };

        const output = fbs.getWritten();

        const line = blk: {
            if (output.len == 0) break :blk null;
            if (mem.startsWith(u8, output, "##### ")) {
                break :blk try mem.concat(allocator, u8,  &[_][]const u8{"<h5>", output[6..] ,"</h5>"});
            } else if (mem.startsWith(u8, output, "###### ")) {
                break :blk try mem.concat(allocator, u8,  &[_][]const u8{"<h6>", output[7..] ,"</h6>"});
            } else {
                break :blk try mem.concat(allocator, u8,  &[_][]const u8{"<p>", output[0..] ,"</p>"});
            }
        };
        if (line) |s| {
            try stdout.print("{s}\n", .{s});
        }
    }

    // {{ . }} から後の部分を出力する
    try stdout.print("{s}\n", .{md[pos+7..]});
}
