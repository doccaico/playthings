const std = @import("std");
const ArrayList = std.ArrayList;
const L = unicode.utf8ToUtf16LeStringLiteral;
const StringArrayHashMap = std.StringArrayHashMap;
const fs = std.fs;
const heap = std.heap;
const mem = std.mem;
const unicode = std.unicode;

var arena: std.heap.ArenaAllocator = undefined;

extern "kernel32" fn GetEnvironmentVariableW(
    lpName: ?[*:0]const u16,
    lpBuffer: ?[*:0]u16,
    nSize: u32,
) callconv(.winapi) u32;

const MaxLength = 32767;

pub fn main() !void {
    var stdout_file = fs.File.stdout().writer(&.{});
    const stdout = &stdout_file.interface;

    arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const memory = try allocator.allocSentinel(u16, MaxLength, 0);

    var hash = StringArrayHashMap(void).init(allocator);

    const path_len = GetEnvironmentVariableW(L("PATH"), memory, MaxLength);

    var it = mem.splitScalar(
        u16,
        memory[0..path_len],
        ';',
    );
    while (it.next()) |item| {
        if (item.len != 0) {
            const utf8 = try unicode.utf16LeToUtf8Alloc(allocator, item);
            try hash.put(utf8, {});
        }
    }

    var list = ArrayList([]const u8).init(allocator);
    for (hash.keys()) |key| {
        try list.append(key);
    }

    const new_path = try mem.join(allocator, ";", list.items);
    try stdout.print("{s}", .{new_path});
}
