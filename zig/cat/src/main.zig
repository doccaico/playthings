const std = @import("std");
const builtin = @import("builtin");
const clap = @import("clap");

// zig version: 0.12.0-dev.1733+648f592db
// test: cmd.exe and powershell.exe
// https://gist.github.com/doccaico/b503c562698bf77dbbee56fd47806f66

var bflag = false;
var nflag = false;
var tflag = false;

fn catStdin(allocator: std.mem.Allocator, stdin: anytype, stdout: anytype, input: *std.ArrayList(u8)) !void {
    const DELIMITER = if (builtin.os.tag == .windows) '\r' else '\n';

    var number: u64 = 1;

    while (true) {
        stdin.streamUntilDelimiter(input.writer(), DELIMITER, null) catch |err| switch (err) {
            error.EndOfStream => break, // Ctrl+c で終了
            else => unreachable,
        };

        // LF(0x0A)を削除 (windowsのみ)
        const line = if (builtin.os.tag == .windows)
            std.mem.trimLeft(u8, input.items, "\n")
        else
            input;

        const new_line = if (tflag)
            try std.mem.replaceOwned(u8, allocator, line, "\t", "^I")
        else
            line;

        if ((bflag and new_line.len != 0) or nflag) {
            try stdout.print("{:6}\t{s}\n", .{ number, new_line });
            number += 1;
        } else {
            try stdout.print("{s}\n", .{new_line});
        }

        input.clearRetainingCapacity();
    }
}

fn catFile(allocator: std.mem.Allocator, file: anytype, stdout: anytype, input: *std.ArrayList(u8), n: u64) !u64 {
    var number = n;

    while (true) {
        file.streamUntilDelimiter(input.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => unreachable,
        };

        const new_line = if (tflag)
            try std.mem.replaceOwned(u8, allocator, input.items, "\t", "^I")
        else
            input.items;

        if ((bflag and new_line.len != 0) or nflag) {
            try stdout.print("{:6}\t{s}\n", .{ number, new_line });
            number += 1;
        } else {
            try stdout.print("{s}\n", .{new_line});
        }

        input.clearRetainingCapacity();
    }

    return number;
}

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();

    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = general_purpose_allocator.allocator();

    var input = std.ArrayList(u8).init(gpa);
    defer input.deinit();

    const args = try std.process.argsAlloc(gpa);
    defer std.process.argsFree(gpa, args);

    const params = comptime clap.parseParamsComptime(
        \\-h, --help               Display this help and exit.
        \\-b, --number-nonblank    number nonempty output lines, overrides -n
        \\-n, --number             number all output lines
        \\-T, --show-tabs          display TAB characters as ^I
        \\<str>...                 file(s)
        \\
    );
    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = &diag,
    }) catch |err| {
        // Report useful error and exit
        diag.report(std.io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    if (res.args.help != 0)
        return clap.help(stderr, clap.Help, &params, .{});
    if (res.args.@"number-nonblank" != 0)
        bflag = true;
    if (res.args.number != 0)
        nflag = true;
    if (res.args.@"show-tabs" != 0)
        tflag = true;

    if (bflag and nflag)
        nflag = false;

    var n: u64 = 1;

    if (res.positionals.len == 0) {
        try catStdin(gpa, stdin, stdout, &input);
    } else {
        for (res.positionals) |path| {
            const file = std.fs.cwd().openFile(path, .{ .mode = .read_only }) catch |err| switch (err) {
                error.FileNotFound => {
                    try stderr.print("{s}: {s}: No such file or directory\n", .{ args[0], path });
                    continue;
                },
                error.IsDir => {
                    try stderr.print("{s}: {s}: Is a directory\n", .{ args[0], path });
                    continue;
                },
                else => {
                    try stderr.print("{s}: {s}: An error occured: {}\n", .{ args[0], path, err });
                    continue;
                },
            };
            defer file.close();
            n = try catFile(gpa, file.reader(), stdout, &input, n);
        }
    }
}
