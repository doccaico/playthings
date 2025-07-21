const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const zeroInit = std.mem.zeroInit;

const lb = @import("lexbor");

test "init" {
    var mraw = lb.core.Mraw.create().?;
    const status = mraw.init(1024);

    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    _ = mraw.destroy(true);
}

test "init_null" {
    const status = lb.core.Mraw.init(null, 1024);
    try expectEqual(status, @intFromEnum(lb.core.Status.error_object_is_null));
}

test "init_stack" {
    var mraw: lb.core.Mraw = undefined;
    const status = mraw.init(1024);

    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    _ = mraw.destroy(false);
}

test "init_args" {
    var mraw = zeroInit(lb.core.Mraw, .{});
    var status: lb.core.status = undefined;

    status = mraw.init(0);
    try expectEqual(status, @intFromEnum(lb.core.Status.error_wrong_args));

    _ = mraw.destroy(false);
}

test "mraw_alloc" {
    var mraw = zeroInit(lb.core.Mraw, .{});
    _ = mraw.init(1024);

    const data = mraw.alloc(127);
    try expect(data != null);

    try expectEqual(lb.core.mrawDataSize(data), lb.core.memAlign(127));

    try expectEqual(mraw.mem.?.chunk_length, 1);
    try expectEqual(mraw.mem.?.chunk.?.length, lb.core.memAlign(127) + lb.core.MRAW_META_SIZE);

    try expectEqual(mraw.mem.?.chunk.?.size, lb.core.memAlign(1024) + lb.core.MRAW_META_SIZE);

    try expectEqual(mraw.cache.?.tree_length, 0);

    try expectEqual(mraw.mem.?.chunk, mraw.mem.?.chunk_first);

    _ = mraw.destroy(false);
}

test "mraw_alloc_eq" {
    var mraw = zeroInit(lb.core.Mraw, .{});
    _ = mraw.init(1024);

    const data = mraw.alloc(1024);
    try expect(data != null);

    try expectEqual(lb.core.mrawDataSize(data), 1024);

    try expectEqual(mraw.mem.?.chunk_length, 1);
    try expectEqual(mraw.mem.?.chunk.?.length, 1024 + lb.core.MRAW_META_SIZE);
    try expectEqual(mraw.mem.?.chunk.?.size, 1024 + lb.core.MRAW_META_SIZE);

    try expectEqual(mraw.cache.?.tree_length, 0);

    try expectEqual(mraw.mem.?.chunk, mraw.mem.?.chunk_first);

    _ = mraw.destroy(false);
}

test "mraw_alloc_overflow_if_len_0" {
    var mraw = zeroInit(lb.core.Mraw, .{});
    _ = mraw.init(1024);

    const data = mraw.alloc(1025);
    try expect(data != null);

    try expectEqual(lb.core.mrawDataSize(data), lb.core.memAlign(1025));

    try expectEqual(mraw.mem.?.chunk_length, 1);
    try expectEqual(mraw.mem.?.chunk.?.length, lb.core.memAlign(1025) + lb.core.MRAW_META_SIZE);

    try expectEqual(mraw.mem.?.chunk.?.size, lb.core.memAlign(1025) + lb.core.memAlign(1024) + (2 * lb.core.MRAW_META_SIZE));

    try expectEqual(mraw.cache.?.tree_length, 0);
    try expectEqual(mraw.mem.?.chunk, mraw.mem.?.chunk_first);

    _ = mraw.destroy(false);
}

test "mraw_alloc_overflow_if_len_not_0" {
    var mraw = zeroInit(lb.core.Mraw, .{});
    _ = mraw.init(1024);

    var data = mraw.alloc(13);
    try expect(data != null);
    try expectEqual(lb.core.mrawDataSize(data), lb.core.memAlign(13));

    data = mraw.alloc(1025);
    try expect(data != null);
    try expectEqual(lb.core.mrawDataSize(data), lb.core.memAlign(1025));

    try expectEqual(mraw.mem.?.chunk_first.?.length, 1024 + lb.core.MRAW_META_SIZE);
    try expectEqual(mraw.mem.?.chunk_first.?.size, 1024 + lb.core.MRAW_META_SIZE);

    try expectEqual(mraw.mem.?.chunk_length, 2);
    try expectEqual(mraw.mem.?.chunk.?.length, lb.core.memAlign(1025) + lb.core.MRAW_META_SIZE);

    try expectEqual(mraw.mem.?.chunk.?.size, lb.core.memAlign(1025) + lb.core.memAlign(1024) + (2 * lb.core.MRAW_META_SIZE));

    try expectEqual(mraw.cache.?.tree_length, 1);
    try expectEqual(mraw.cache.?.root.?.size, (lb.core.memAlign(1024) + lb.core.MRAW_META_SIZE) - (lb.core.memAlign(13) + lb.core.MRAW_META_SIZE) - lb.core.MRAW_META_SIZE);

    try expect(mraw.mem.?.chunk != mraw.mem.?.chunk_first);

    _ = mraw.destroy(false);
}

test "mraw_alloc_if_len_not_0" {
    var mraw = zeroInit(lb.core.Mraw, .{});
    _ = mraw.init(1024);

    var data = mraw.alloc(8);
    try expect(data != null);
    try expectEqual(lb.core.mrawDataSize(data), lb.core.memAlign(8));

    data = mraw.alloc(1016 - lb.core.MRAW_META_SIZE);
    try expect(data != null);
    try expectEqual(lb.core.mrawDataSize(data), 1016 - lb.core.MRAW_META_SIZE);

    try expectEqual(mraw.mem.?.chunk_length, 1);
    try expectEqual(mraw.mem.?.chunk.?.length, 1024 + lb.core.MRAW_META_SIZE);
    try expectEqual(mraw.mem.?.chunk.?.size, mraw.mem.?.chunk.?.length);

    try expectEqual(mraw.cache.?.tree_length, 0);
    try expectEqual(mraw.mem.?.chunk, mraw.mem.?.chunk_first);

    _ = mraw.destroy(false);
}

test "mraw_realloc" {
    var mraw = zeroInit(lb.core.Mraw, .{});
    _ = mraw.init(1024);

    const data: ?*u8 = @ptrCast(mraw.alloc(128));
    try expect(data != null);
    try expectEqual(lb.core.mrawDataSize(data), 128);

    const new_data: ?*u8 = @ptrCast(mraw.realloc(data, 256));
    try expect(new_data != null);
    try expectEqual(lb.core.mrawDataSize(new_data), 256);

    try expectEqual(data, new_data);

    try expectEqual(mraw.mem.?.chunk_length, 1);
    try expectEqual(mraw.mem.?.chunk.?.length, 256 + lb.core.MRAW_META_SIZE);
    try expectEqual(mraw.mem.?.chunk.?.size, 1024 + lb.core.MRAW_META_SIZE);

    try expectEqual(mraw.cache.?.tree_length, 0);
    try expectEqual(mraw.mem.?.chunk, mraw.mem.?.chunk_first);

    _ = mraw.destroy(false);
}

test "mraw_realloc_eq" {
    var mraw = zeroInit(lb.core.Mraw, .{});
    _ = mraw.init(1024);

    const data: ?*u8 = @ptrCast(mraw.alloc(128));
    try expect(data != null);
    try expectEqual(lb.core.mrawDataSize(data), 128);

    const new_data: ?*u8 = @ptrCast(mraw.realloc(data, 128));
    try expect(new_data != null);
    try expectEqual(lb.core.mrawDataSize(new_data), 128);

    try expectEqual(data, new_data);

    try expectEqual(mraw.mem.?.chunk_length, 1);
    try expectEqual(mraw.mem.?.chunk.?.length, 128 + lb.core.MRAW_META_SIZE);
    try expectEqual(mraw.mem.?.chunk.?.size, 1024 + lb.core.MRAW_META_SIZE);

    try expectEqual(mraw.cache.?.tree_length, 0);
    try expectEqual(mraw.mem.?.chunk, mraw.mem.?.chunk_first);

    _ = mraw.destroy(false);
}

test "mraw_realloc_tail_0" {
    var mraw = zeroInit(lb.core.Mraw, .{});
    _ = mraw.init(1024);

    const data: ?*u8 = @ptrCast(mraw.alloc(128));
    try expect(data != null);
    try expectEqual(lb.core.mrawDataSize(data), 128);

    const new_data: ?*u8 = @ptrCast(mraw.realloc(data, 0));
    try expectEqual(new_data, null);

    try expectEqual(mraw.mem.?.chunk_length, 1);
    try expectEqual(mraw.mem.?.chunk.?.length, 0);
    try expectEqual(mraw.mem.?.chunk.?.size, 1024 + lb.core.MRAW_META_SIZE);

    try expectEqual(mraw.cache.?.tree_length, 0);
    try expectEqual(mraw.mem.?.chunk, mraw.mem.?.chunk_first);

    _ = mraw.destroy(false);
}

test "mraw_realloc_tail_n" {
    var mraw = zeroInit(lb.core.Mraw, .{});
    _ = mraw.init(1024);

    var data: ?*u8 = @ptrCast(mraw.alloc(128));
    try expect(data != null);
    try expectEqual(lb.core.mrawDataSize(data), 128);

    data = @ptrCast(mraw.alloc(128));
    try expect(data != null);
    try expectEqual(lb.core.mrawDataSize(data), 128);

    const new_data: ?*u8 = @ptrCast(mraw.realloc(data, 1024));
    try expect(new_data != null);
    try expectEqual(lb.core.mrawDataSize(new_data), 1024);

    try expect(data != new_data);

    try expectEqual(mraw.mem.?.chunk_length, 2);
    try expectEqual(mraw.mem.?.chunk.?.length, 1024 + lb.core.MRAW_META_SIZE);
    try expectEqual(mraw.mem.?.chunk.?.size, 1024 + lb.core.MRAW_META_SIZE);

    try expectEqual(mraw.cache.?.tree_length, 1);
    try expectEqual(mraw.cache.?.root.?.size, (lb.core.memAlign(1024) + lb.core.MRAW_META_SIZE) - (lb.core.memAlign(128) + lb.core.MRAW_META_SIZE) - lb.core.MRAW_META_SIZE);

    try expect(mraw.mem.?.chunk != mraw.mem.?.chunk_first);

    _ = mraw.destroy(false);
}

test "mraw_realloc_tail_less" {
    var mraw = zeroInit(lb.core.Mraw, .{});
    _ = mraw.init(1024);

    const data: ?*u8 = @ptrCast(mraw.alloc(128));
    try expect(data != null);
    try expectEqual(lb.core.mrawDataSize(data), 128);

    const new_data: ?*u8 = @ptrCast(mraw.realloc(data, 16));
    try expect(data != null);
    try expectEqual(lb.core.mrawDataSize(new_data), 16);

    try expectEqual(data, new_data);

    try expectEqual(mraw.mem.?.chunk_length, 1);
    try expectEqual(mraw.mem.?.chunk.?.length, 16 + lb.core.MRAW_META_SIZE);
    try expectEqual(mraw.mem.?.chunk.?.size, 1024 + lb.core.MRAW_META_SIZE);

    try expectEqual(mraw.cache.?.tree_length, 0);
    try expectEqual(mraw.mem.?.chunk, mraw.mem.?.chunk_first);

    _ = mraw.destroy(false);
}

test "mraw_realloc_tail_great" {
    var mraw = zeroInit(lb.core.Mraw, .{});
    _ = mraw.init(1024);

    const data: ?*u8 = @ptrCast(mraw.alloc(128));
    try expect(data != null);
    try expectEqual(lb.core.mrawDataSize(data), 128);

    const new_data: ?*u8 = @ptrCast(mraw.realloc(data, 2046));
    try expect(data != null);
    try expectEqual(lb.core.mrawDataSize(new_data), lb.core.memAlign(2046));

    try expectEqual(mraw.mem.?.chunk_length, 1);
    try expectEqual(mraw.mem.?.chunk.?.length, lb.core.memAlign(2046) + lb.core.MRAW_META_SIZE);
    try expectEqual(mraw.mem.?.chunk.?.size, lb.core.memAlign(2046) + 1024 + (2 * lb.core.MRAW_META_SIZE));

    try expectEqual(mraw.cache.?.tree_length, 0);
    try expectEqual(mraw.mem.?.chunk, mraw.mem.?.chunk_first);

    _ = mraw.destroy(false);
}

test "mraw_realloc_n" {
    var mraw = zeroInit(lb.core.Mraw, .{});
    _ = mraw.init(1024);

    const one: ?*u8 = @ptrCast(mraw.alloc(128));
    try expect(one != null);
    try expectEqual(lb.core.mrawDataSize(one), 128);

    const two: ?*u8 = @ptrCast(mraw.alloc(13));
    try expect(two != null);
    try expectEqual(lb.core.mrawDataSize(two), lb.core.memAlign(13));

    const three: ?*u8 = @ptrCast(mraw.realloc(one, 256));
    try expect(three != null);
    try expectEqual(lb.core.mrawDataSize(three), 256);

    try expect(one != three);

    try expectEqual(mraw.mem.?.chunk_length, 1);
    try expectEqual(mraw.mem.?.chunk.?.length, 128 + lb.core.MRAW_META_SIZE + lb.core.memAlign(13) + lb.core.MRAW_META_SIZE + 256 + lb.core.MRAW_META_SIZE);

    try expectEqual(mraw.mem.?.chunk.?.size, 1024 + lb.core.MRAW_META_SIZE);

    try expectEqual(mraw.cache.?.tree_length, 1);
    try expectEqual(mraw.mem.?.chunk, mraw.mem.?.chunk_first);

    try expect(mraw.cache.?.root != null);
    try expectEqual(mraw.cache.?.root.?.size, 128);

    _ = mraw.destroy(false);
}

test "mraw_realloc_n_0" {
    var mraw = zeroInit(lb.core.Mraw, .{});
    _ = mraw.init(1024);

    const one: ?*u8 = @ptrCast(mraw.alloc(128));
    try expect(one != null);
    try expectEqual(lb.core.mrawDataSize(one), 128);

    const two: ?*u8 = @ptrCast(mraw.alloc(13));
    try expect(two != null);
    try expectEqual(lb.core.mrawDataSize(two), lb.core.memAlign(13));

    const three: ?*u8 = @ptrCast(mraw.realloc(one, 0));
    try expectEqual(three, null);

    try expectEqual(mraw.mem.?.chunk_length, 1);
    try expectEqual(mraw.mem.?.chunk.?.length, 128 + lb.core.MRAW_META_SIZE + lb.core.memAlign(13) + lb.core.MRAW_META_SIZE);

    try expectEqual(mraw.mem.?.chunk.?.size, 1024 + lb.core.MRAW_META_SIZE);

    try expectEqual(mraw.cache.?.tree_length, 1);
    try expectEqual(mraw.mem.?.chunk, mraw.mem.?.chunk_first);

    try expect(mraw.cache.?.root != null);
    try expectEqual(mraw.cache.?.root.?.size, 128);

    _ = mraw.destroy(false);
}

test "mraw_realloc_n_less" {
    var mraw = zeroInit(lb.core.Mraw, .{});
    _ = mraw.init(1024);

    const one: ?*u8 = @ptrCast(mraw.alloc(128));
    try expect(one != null);
    try expectEqual(lb.core.mrawDataSize(one), 128);

    const two: ?*u8 = @ptrCast(mraw.alloc(256));
    try expect(two != null);
    try expectEqual(lb.core.mrawDataSize(two), lb.core.memAlign(256));

    const three: ?*u8 = @ptrCast(mraw.realloc(one, 51));
    try expect(three != null);
    try expectEqual(lb.core.mrawDataSize(three), lb.core.memAlign(51));

    try expectEqual(one, three);

    try expectEqual(mraw.cache.?.tree_length, 1);
    try expect(mraw.cache.?.root != null);

    try expectEqual(mraw.cache.?.root.?.size, (128 + lb.core.MRAW_META_SIZE) - (lb.core.memAlign(51) + lb.core.MRAW_META_SIZE) - lb.core.MRAW_META_SIZE);

    try expectEqual(mraw.mem.?.chunk_length, 1);
    try expectEqual(mraw.mem.?.chunk.?.size, 1024 + lb.core.MRAW_META_SIZE);
    try expectEqual(mraw.mem.?.chunk.?.length, 128 + lb.core.MRAW_META_SIZE + 256 + lb.core.MRAW_META_SIZE);

    try expectEqual(mraw.mem.?.chunk, mraw.mem.?.chunk_first);

    _ = mraw.destroy(false);
}

test "mraw_realloc_n_great" {
    var mraw = zeroInit(lb.core.Mraw, .{});
    var cache_entry: ?*lb.core.BstEntry = undefined;

    _ = mraw.init(1024);

    const one: ?*u8 = @ptrCast(mraw.alloc(128));
    try expect(one != null);
    try expectEqual(lb.core.mrawDataSize(one), 128);

    const two: ?*u8 = @ptrCast(mraw.alloc(256));
    try expect(two != null);
    try expectEqual(lb.core.mrawDataSize(two), lb.core.memAlign(256));

    const three: ?*u8 = @ptrCast(mraw.realloc(one, 1000));
    try expect(three != null);
    try expectEqual(lb.core.mrawDataSize(three), lb.core.memAlign(1000));

    try expect(one != three);

    try expectEqual(mraw.cache.?.tree_length, 2);
    try expect(mraw.cache.?.root != null);

    cache_entry = lb.core.Bst.search(mraw.cache, mraw.cache.?.root, 128);
    try expect(cache_entry != null);

    const size = (1024 + lb.core.MRAW_META_SIZE) - (128 + lb.core.MRAW_META_SIZE) - (256 + lb.core.MRAW_META_SIZE) - lb.core.MRAW_META_SIZE;

    cache_entry = lb.core.Bst.search(mraw.cache, mraw.cache.?.root, size);
    try expect(cache_entry != null);

    try expectEqual(mraw.mem.?.chunk_length, 2);
    try expectEqual(mraw.mem.?.chunk_first.?.size, 1024 + lb.core.MRAW_META_SIZE);
    try expectEqual(mraw.mem.?.chunk_first.?.length, 1024 + lb.core.MRAW_META_SIZE);

    try expectEqual(mraw.mem.?.chunk.?.size, 1024 + lb.core.MRAW_META_SIZE);
    try expectEqual(mraw.mem.?.chunk.?.length, 1000 + lb.core.MRAW_META_SIZE);

    try expect(mraw.mem.?.chunk != mraw.mem.?.chunk_first);

    try expectEqual(mraw.mem.?.chunk_first.?.next, mraw.mem.?.chunk);
    try expectEqual(mraw.mem.?.chunk.?.prev, mraw.mem.?.chunk_first);

    _ = mraw.destroy(false);
}

test "mraw_free" {
    var mraw = zeroInit(lb.core.Mraw, .{});
    var cache_entry: ?*lb.core.BstEntry = undefined;

    _ = mraw.init(1024);

    const data: ?*u8 = @ptrCast(mraw.calloc(23));
    try expect(data != null);

    _ = mraw.free(data);

    cache_entry = lb.core.Bst.search(mraw.cache, mraw.cache.?.root, lb.core.memAlign(23));
    try expect(cache_entry != null);

    cache_entry = lb.core.Bst.searchClose(mraw.cache, mraw.cache.?.root, 23);
    try expect(cache_entry != null);
    try expectEqual(cache_entry.?.size, lb.core.memAlign(23));

    _ = mraw.destroy(false);
}

test "mraw_calloc" {
    var mraw = zeroInit(lb.core.Mraw, .{});
    _ = mraw.init(1024);

    const data: ?[*]u8 = @ptrCast(mraw.calloc(1024));
    try expect(data != null);
    try expectEqual(lb.core.mrawDataSize(data), 1024);

    for (0..1024) |i| {
        try expectEqual(data.?[i], 0x00);
    }

    _ = mraw.destroy(false);
}

test "clean" {
    var mraw: lb.core.Mraw = undefined;
    _ = mraw.init(1024);

    mraw.clean();

    _ = mraw.destroy(false);
}

test "destroy" {
    var mraw = lb.core.Mraw.create().?;
    _ = mraw.init(1024);

    try expectEqual(mraw.destroy(true), null);

    mraw = lb.core.Mraw.create().?;
    _ = mraw.init(1021);

    try expectEqual(mraw.destroy(false), mraw);
    try expectEqual(mraw.destroy(true), null);
    try expectEqual(lb.core.Mraw.destroy(null, false), null);
}

test "destroy_stack" {
    var mraw: lb.core.Mraw = undefined;
    _ = mraw.init(1023);

    try expectEqual(mraw.destroy(false), &mraw);
}
