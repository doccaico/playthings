const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const zeroInit = std.mem.zeroInit;

const lb = @import("lexbor");

const HashEntry = struct {
    entry: lb.core.HashEntry,
    hash: lb.core.Hash,
    value: usize,
};

test "init" {
    var hash = lb.core.Hash.create().?;
    const status = hash.init(1024, @sizeOf(HashEntry));
    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    _ = hash.destroy(true);
}

test "init_null" {
    const status = lb.core.Hash.init(null, 1024, @sizeOf(HashEntry));
    try expectEqual(status, @intFromEnum(lb.core.Status.error_object_is_null));
}

test "init_stack" {
    var hash = zeroInit(lb.core.Hash, .{});
    const status = hash.init(1024, @sizeOf(HashEntry));
    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    _ = hash.destroy(false);
}

test "clean" {
    var hash: lb.core.Hash = undefined;
    const status = hash.init(1024, @sizeOf(HashEntry));
    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    hash.clean();

    _ = hash.destroy(false);
}

test "destroy" {
    var hash = lb.core.Hash.create().?;
    var status = hash.init(1024, @sizeOf(HashEntry));
    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    try expectEqual(hash.destroy(true), null);

    hash = lb.core.Hash.create().?;
    status = hash.init(1021, @sizeOf(HashEntry));
    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    try expectEqual(hash.destroy(false), hash);
    try expectEqual(hash.destroy(true), null);
    try expectEqual(lb.core.Hash.destroy(null, false), null);
}

test "destroy_stack" {
    var hash: lb.core.Hash = undefined;
    const status = hash.init(1024, @sizeOf(HashEntry));
    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    try expectEqual(hash.destroy(false), &hash);
}

test "insert_search_case" {
    var hash = zeroInit(lb.core.Hash, .{});
    const status = hash.init(1024, @sizeOf(HashEntry));
    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    var entry: ?*HashEntry = undefined;
    var entry_raw: ?*HashEntry = undefined;
    var entry_lo: ?*HashEntry = undefined;
    var entry_up: ?*HashEntry = undefined;

    // Raw
    entry_raw = @as(?*HashEntry, @ptrCast(@alignCast(hash.insert(lb.core.hashInsertRaw.*, &"KeY"[0], 3))));

    try expect(entry_raw != null);

    entry_raw.?.value = 1;

    // Lower
    entry_lo = @as(?*HashEntry, @ptrCast(@alignCast(hash.insert(lb.core.hashInsertLower.*, &"Key"[0], 3))));

    try expect(entry_lo != null);

    entry_lo.?.value = 2;

    // Upper
    entry_up = @as(?*HashEntry, @ptrCast(@alignCast(hash.insert(lb.core.hashInsertUpper.*, &"kEy"[0], 3))));

    try expect(entry_up != null);

    entry_up.?.value = 3;

    // Check
    // Raw
    entry = @as(?*HashEntry, @ptrCast(@alignCast(hash.search(lb.core.hashSearchRaw.*, &"KeY"[0], 3))));

    try expect(entry != null);
    try expectEqual(entry, entry_raw);

    entry = @as(?*HashEntry, @ptrCast(@alignCast(hash.search(lb.core.hashSearchRaw.*, &"key"[0], 3))));

    try expect(entry != null);
    try expectEqual(entry, entry_lo);

    entry = @as(?*HashEntry, @ptrCast(@alignCast(hash.search(lb.core.hashSearchRaw.*, &"KEY"[0], 3))));

    try expect(entry != null);
    try expectEqual(entry, entry_up);

    entry = @as(?*HashEntry, @ptrCast(@alignCast(hash.search(lb.core.hashSearchRaw.*, &"keY"[0], 3))));

    try expectEqual(entry, null);

    // Lower

    entry = @as(?*HashEntry, @ptrCast(@alignCast(hash.search(lb.core.hashSearchLower.*, &"KeY"[0], 3))));

    try expect(entry != null);
    try expectEqual(entry, entry_lo);

    // Upper

    entry = @as(?*HashEntry, @ptrCast(@alignCast(hash.search(lb.core.hashSearchUpper.*, &"kEy"[0], 3))));

    try expect(entry != null);
    try expectEqual(entry, entry_up);

    try expectEqual(lb.core.hashEntriesCount(&hash), 3);

    _ = hash.destroy(false);
}
