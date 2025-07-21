const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const zeroInit = std.mem.zeroInit;

const core = @import("lexbor").core;

const HashEntry = struct {
    entry: core.hash.Entry,
    hash: core.Hash,
    value: usize,
};

test "init" {
    const hash = core.hash.create();
    const status = core.hash.init(hash, 1024, @sizeOf(HashEntry));
    try expectEqual(status, .ok);

    _ = core.hash.destroy(hash, true);
}

test "init_null" {
    const status = core.hash.init(null, 1024, @sizeOf(HashEntry));
    try expectEqual(status, .error_object_is_null);
}

test "init_stack" {
    var hash = zeroInit(core.Hash, .{});
    const status = core.hash.init(&hash, 1024, @sizeOf(HashEntry));
    try expectEqual(status, .ok);

    _ = core.hash.destroy(&hash, false);
}

test "clean" {
    var hash: core.Hash = undefined;
    const status = core.hash.init(&hash, 1024, @sizeOf(HashEntry));
    try expectEqual(status, .ok);

    core.hash.clean(&hash);

    _ = core.hash.destroy(&hash, false);
}

test "destroy" {
    var hash = core.hash.create();
    var status = core.hash.init(hash, 1024, @sizeOf(HashEntry));
    try expectEqual(status, .ok);

    try expectEqual(core.hash.destroy(hash, true), null);

    hash = core.hash.create();
    status = core.hash.init(hash, 1021, @sizeOf(HashEntry));
    try expectEqual(status, .ok);

    try expectEqual(core.hash.destroy(hash, false), hash);
    try expectEqual(core.hash.destroy(hash, true), null);
    try expectEqual(core.hash.destroy(null, false), null);
}

test "destroy_stack" {
    var hash: core.Hash = undefined;
    const status = core.hash.init(&hash, 1024, @sizeOf(HashEntry));
    try expectEqual(status, .ok);

    try expectEqual(core.hash.destroy(&hash, false), &hash);
}

test "insert_search_case" {
    var hash = zeroInit(core.Hash, .{});
    const status = core.hash.init(&hash, 1024, @sizeOf(HashEntry));
    try expectEqual(status, .ok);

    var entry: ?*HashEntry = undefined;
    var entry_raw: ?*HashEntry = undefined;
    var entry_lo: ?*HashEntry = undefined;
    var entry_up: ?*HashEntry = undefined;

    // Raw
    entry_raw = @ptrCast(@alignCast(core.hash.insert(&hash, core.hash.insert_raw.*, "KeY", 3)));

    try expect(entry_raw != null);

    entry_raw.?.value = 1;

    // Lower
    entry_lo = @ptrCast(@alignCast(core.hash.insert(&hash, core.hash.insert_lower.*, "Key", 3)));

    try expect(entry_lo != null);

    entry_lo.?.value = 2;

    // Upper
    entry_up = @ptrCast(@alignCast(core.hash.insert(&hash, core.hash.insert_upper.*, "kEy", 3)));

    try expect(entry_up != null);

    entry_up.?.value = 3;

    // Check
    // Raw
    entry = @ptrCast(@alignCast(core.hash.search(&hash, core.hash.search_raw.*, "KeY", 3)));

    try expect(entry != null);
    try expectEqual(entry, entry_raw);

    entry = @ptrCast(@alignCast(core.hash.search(&hash, core.hash.search_raw.*, "key", 3)));

    try expect(entry != null);
    try expectEqual(entry, entry_lo);

    entry = @ptrCast(@alignCast(core.hash.search(&hash, core.hash.search_raw.*, "KEY", 3)));

    try expect(entry != null);
    try expectEqual(entry, entry_up);

    entry = @ptrCast(@alignCast(core.hash.search(&hash, core.hash.search_raw.*, "keY", 3)));

    try expectEqual(entry, null);

    // Lower

    entry = @ptrCast(@alignCast(core.hash.search(&hash, core.hash.search_lower.*, "KeY", 3)));

    try expect(entry != null);
    try expectEqual(entry, entry_lo);

    // Upper

    entry = @ptrCast(@alignCast(core.hash.search(&hash, core.hash.search_upper.*, "kEy", 3)));

    try expect(entry != null);
    try expectEqual(entry, entry_up);

    try expectEqual(core.hash.entriesCount(&hash), 3);

    _ = core.hash.destroy(&hash, false);
}
