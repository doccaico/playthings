const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectEqualStrings = std.testing.expectEqualStrings;
const zeroInit = std.mem.zeroInit;

const core = @import("lexbor").core;

test "init" {
    const bst_map = core.bst_map.create();
    const status = core.bst_map.init(bst_map, 128);

    try expectEqual(status, .ok);

    _ = core.bst_map.destroy(bst_map, true);
}

test "init_null" {
    const status = core.bst_map.init(null, 128);
    try expectEqual(status, .error_object_is_null);
}

test "init_stack" {
    var bst_map: core.BstMap = undefined;
    const status = core.bst_map.init(&bst_map, 128);

    try expectEqual(status, .ok);

    _ = core.bst_map.destroy(&bst_map, false);
}

test "init_args" {
    var bst_map = zeroInit(core.BstMap, .{});
    var status: core.Status = undefined;

    status = core.bst_map.init(&bst_map, 0);
    try expectEqual(status, .error_wrong_args);

    _ = core.bst_map.destroy(&bst_map, false);
}

test "bst_map_insert" {
    var bst_map: core.BstMap = undefined;
    var entry: ?*core.bst_map.Entry = undefined;

    var scope: ?*core.bst.Entry = null;

    const key = "test";
    const key_len = key.len;

    try expectEqual(core.bst_map.init(&bst_map, 128), .ok);

    entry = core.bst_map.insert(&bst_map, &scope, key, key_len, @as(*anyopaque, @ptrFromInt(1)));

    try expect(entry != null);
    try expect(scope != null);

    try expectEqualStrings(entry.?.str.data.?[0..key_len], key);
    try expectEqual(entry.?.str.length, key_len);
    try expectEqual(entry.?.value, @as(*anyopaque, @ptrFromInt(1)));

    _ = core.bst_map.destroy(&bst_map, false);
}

test "bst_map_search" {
    var bst_map: core.BstMap = undefined;
    var entry: ?*core.bst_map.Entry = undefined;

    var scope: ?*core.bst.Entry = null;

    const key = "test";
    const key_len = key.len;

    const col_key = "test1";
    const col_key_len = key.len;

    try expectEqual(core.bst_map.init(&bst_map, 128), .ok);

    entry = core.bst_map.insert(&bst_map, &scope, key, key_len, @as(*anyopaque, @ptrFromInt(1)));

    try expect(entry != null);

    entry = core.bst_map.insert(&bst_map, &scope, col_key, col_key_len, @as(*anyopaque, @ptrFromInt(2)));

    try expect(entry != null);

    entry = core.bst_map.search(&bst_map, scope, key, key_len);
    try expect(entry != null);

    try expectEqualStrings(entry.?.str.data.?[0..key_len], key);
    try expectEqual(entry.?.str.length, key_len);
    try expectEqual(entry.?.value, @as(*anyopaque, @ptrFromInt(1)));

    _ = core.bst_map.destroy(&bst_map, false);
}

test "bst_map_remove" {
    var value: ?*anyopaque = undefined;
    var bst_map: core.BstMap = undefined;
    var entry: ?*core.bst_map.Entry = undefined;

    var scope: ?*core.bst.Entry = null;

    const key = "test";
    const key_len = key.len;

    const col_key = "test1";
    const col_key_len = key.len;

    try expectEqual(core.bst_map.init(&bst_map, 128), .ok);

    entry = core.bst_map.insert(&bst_map, &scope, key, key_len, @as(*anyopaque, @ptrFromInt(1)));

    try expect(entry != null);

    entry = core.bst_map.insert(&bst_map, &scope, col_key, col_key_len, @as(*anyopaque, @ptrFromInt(2)));

    try expect(entry != null);

    value = core.bst_map.remove(&bst_map, &scope, key, key_len);

    try expectEqual(value.?, @as(*anyopaque, @ptrFromInt(1)));
    try expect(scope != null);

    _ = core.bst_map.destroy(&bst_map, false);
}

test "clean" {
    var bst_map: core.BstMap = undefined;
    var entry: ?*core.bst_map.Entry = undefined;
    var scope: ?*core.bst.Entry = null;

    const key = "test";
    const key_len = key.len;

    try expectEqual(core.bst_map.init(&bst_map, 128), .ok);

    entry = core.bst_map.insert(&bst_map, &scope, key, key_len, @as(*anyopaque, @ptrFromInt(1)));

    try expect(entry != null);

    core.bst_map.clean(&bst_map);

    _ = core.bst_map.destroy(&bst_map, false);
}

test "destroy" {
    var bst_map = core.bst_map.create();
    try expectEqual(core.bst_map.init(bst_map, 128), .ok);

    try expectEqual(core.bst_map.destroy(bst_map, true), null);

    bst_map = core.bst_map.create();
    try expectEqual(core.bst_map.init(bst_map, 128), .ok);

    try expectEqual(core.bst_map.destroy(bst_map, false), bst_map);
    try expectEqual(core.bst_map.destroy(bst_map, true), null);
    try expectEqual(core.bst_map.destroy(null, false), null);
}

test "destroy_stack" {
    var bst_map: core.BstMap = undefined;
    try expectEqual(core.bst_map.init(&bst_map, 128), .ok);

    try expectEqual(core.bst_map.destroy(&bst_map, false), &bst_map);
}
