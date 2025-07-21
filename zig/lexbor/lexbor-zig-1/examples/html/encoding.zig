const std = @import("std");
const argsAlloc = std.process.argsAlloc;
const argsFree = std.process.argsFree;
const c_allocator = std.heap.c_allocator;
const exit = std.process.exit;
const print = std.debug.print;

const core = @import("lexbor").core;
const html = @import("lexbor").html;

fn failed(with_usage: bool, comptime fmt: []const u8, args: anytype) noreturn {
    print(fmt, args);

    if (with_usage) usage();

    exit(1);
}

fn usage() void {
    print("Usage:\n", .{});
    print("    zig build html-encoding -- <file-path-to-html>\n", .{});
}

pub fn main() !void {
    var len: usize = undefined;
    var em: html.Encoding = undefined;
    var status: core.Status = undefined;

    var arena = std.heap.ArenaAllocator.init(c_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const args = try argsAlloc(allocator);
    defer argsFree(allocator, args);

    if (args.len != 2) {
        usage();
        exit(0);
    }

    const content = core.fs.fileEasyRead(args[1], &len) orelse {
        failed(true, "Failed to read file: {s}\n", .{args[1]});
    };
    defer core.free(content.ptr);

    status = html.encoding.init(&em);
    defer _ = html.encoding.destroy(&em, false);
    if (status != .ok) {
        failed(false, "Failed to init html encoding\n", .{});
    }

    status = html.encoding.determine(&em, content, @ptrFromInt((@intFromPtr(content.ptr) + len)));
    if (status != .ok) {
        // delete all allocated memory
        _ = html.encoding.destroy(&em, false);
        core.free(content.ptr);
        argsFree(allocator, args);
        arena.deinit();

        failed(false, "Failed to determine encoding\n", .{});
    }

    const entry = html.encoding.metaEntry(&em, 0);
    if (entry != null) {
        print("{s}\n", .{entry.?.name.?[0 .. entry.?.end.? - entry.?.name.?]});
    } else {
        print("Encoding not found\n", .{});
    }
}
