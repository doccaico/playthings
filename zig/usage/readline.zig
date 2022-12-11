const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const path = "numbers.txt";
    var buf: [1024]u8 = undefined;

    const contents = try std.fs.cwd().readFile(path, &buf);
    // try stdout.print("{s}\n", .{contents});

    var it = std.mem.tokenize(u8, contents, "\n");
    var total: i32 = 0;
    while (it.next()) |line| {
        total += try std.fmt.parseInt(i32, line, 10);
        // try stdout.print("{s}\n", .{line});
    }
    try stdout.print("total = {}\n", .{total});
}
