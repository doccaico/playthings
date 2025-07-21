const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const zeroInit = std.mem.zeroInit;

const core = @import("lexbor").core;

fn test_for_push(bst: *core.Bst) !void {
    var entry: *core.bst.Entry = undefined;
    var pushed: ?*core.bst.Entry = undefined;

    try expect(core.bst.insert(bst, &bst.root, 5, @as(*anyopaque, @ptrFromInt(5))) != null);
    try expect(core.bst.insert(bst, &bst.root, 2, @as(*anyopaque, @ptrFromInt(2))) != null);
    try expect(core.bst.insert(bst, &bst.root, 1, @as(*anyopaque, @ptrFromInt(1))) != null);
    try expect(core.bst.insert(bst, &bst.root, 3, @as(*anyopaque, @ptrFromInt(3))) != null);
    try expect(core.bst.insert(bst, &bst.root, 18, @as(*anyopaque, @ptrFromInt(18))) != null);

    pushed = core.bst.insert(bst, &bst.root, 4, @as(*anyopaque, @ptrFromInt(4)));
    try expect(pushed != null);

    entry = bst.root.?.left.?.right.?.right.?;
    try expectEqual(entry, pushed);
}

test "init" {
    const bst = core.bst.create();
    const status = core.bst.init(bst, 128);

    try expectEqual(status, .ok);

    _ = core.bst.destroy(bst, true);
}

test "init_null" {
    const status = core.bst.init(null, 128);
    try expectEqual(status, .error_object_is_null);
}

test "init_stack" {
    var bst: core.Bst = undefined;
    const status = core.bst.init(&bst, 128);

    try expectEqual(status, .ok);

    _ = core.bst.destroy(&bst, false);
}

test "init_args" {
    var bst = zeroInit(core.Bst, .{});
    var status: core.Status = undefined;

    status = core.bst.init(&bst, 0);
    try expectEqual(status, .error_wrong_args);

    _ = core.bst.destroy(&bst, false);
}

test "bst_insert" {
    var bst: core.Bst = undefined;
    var entry: *core.bst.Entry = undefined;

    try expectEqual(core.bst.init(&bst, 128), .ok);

    try test_for_push(&bst);
    entry = bst.root.?.left.?.right.?.right.?;

    try expectEqual(bst.root.?.size, 5);
    try expectEqual(bst.root.?.left.?.size, 2);
    try expectEqual(bst.root.?.left.?.left.?.size, 1);
    try expectEqual(bst.root.?.left.?.right.?.size, 3);
    try expectEqual(bst.root.?.left.?.right.?.right.?.size, 4);
    try expectEqual(bst.root.?.right.?.size, 18);

    try expectEqual(bst.tree_length, 6);

    _ = core.bst.destroy(&bst, false);
}

test "bst_search" {
    var bst: core.Bst = undefined;
    var entry: ?*core.bst.Entry = undefined;

    try expectEqual(core.bst.init(&bst, 128), .ok);

    try test_for_push(&bst);

    entry = core.bst.search(&bst, bst.root, 3);
    try expect(entry != null);
    try expectEqual(entry.?.size, 3);

    _ = core.bst.destroy(&bst, false);
}

test "bst_search_close" {
    var bst: core.Bst = undefined;
    var entry: ?*core.bst.Entry = undefined;

    try expectEqual(core.bst.init(&bst, 128), .ok);

    try test_for_push(&bst);

    entry = core.bst.searchClose(&bst, bst.root, 6);
    try expect(entry != null);
    try expectEqual(entry.?.size, 18);

    entry = core.bst.searchClose(&bst, bst.root, 0);
    try expect(entry != null);
    try expectEqual(entry.?.size, 1);

    entry = core.bst.searchClose(&bst, bst.root, 19);
    try expectEqual(entry, null);

    _ = core.bst.destroy(&bst, false);
}
//
test "bst_search_close_more" {
    var bst: core.Bst = undefined;
    var entry: ?*core.bst.Entry = undefined;

    try expectEqual(core.bst.init(&bst, 128), .ok);

    try expect(core.bst.insert(&bst, &bst.root, 76, @as(*anyopaque, @ptrFromInt(76))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 5, @as(*anyopaque, @ptrFromInt(5))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 2, @as(*anyopaque, @ptrFromInt(2))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 3, @as(*anyopaque, @ptrFromInt(3))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 36, @as(*anyopaque, @ptrFromInt(36))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 30, @as(*anyopaque, @ptrFromInt(30))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 8, @as(*anyopaque, @ptrFromInt(8))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 18, @as(*anyopaque, @ptrFromInt(18))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 21, @as(*anyopaque, @ptrFromInt(21))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 33, @as(*anyopaque, @ptrFromInt(33))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 31, @as(*anyopaque, @ptrFromInt(31))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 58, @as(*anyopaque, @ptrFromInt(58))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 63, @as(*anyopaque, @ptrFromInt(63))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 77, @as(*anyopaque, @ptrFromInt(77))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 84, @as(*anyopaque, @ptrFromInt(84))) != null);

    entry = core.bst.searchClose(&bst, bst.root, 1);
    try expect(entry != null);
    try expectEqual(entry.?.size, 2);

    entry = core.bst.searchClose(&bst, bst.root, 29);
    try expect(entry != null);
    try expectEqual(entry.?.size, 30);

    entry = core.bst.searchClose(&bst, bst.root, 9);
    try expect(entry != null);
    try expectEqual(entry.?.size, 18);

    entry = core.bst.searchClose(&bst, bst.root, 32);
    try expect(entry != null);
    try expectEqual(entry.?.size, 33);

    entry = core.bst.searchClose(&bst, bst.root, 50);
    try expect(entry != null);
    try expectEqual(entry.?.size, 58);

    entry = core.bst.searchClose(&bst, bst.root, 80);
    try expect(entry != null);
    try expectEqual(entry.?.size, 84);

    entry = core.bst.searchClose(&bst, bst.root, 100);
    try expectEqual(entry, null);

    _ = core.bst.destroy(&bst, false);
}

test "bst_remove" {
    var bst: core.Bst = undefined;
    var value: ?*anyopaque = undefined;
    try expectEqual(core.bst.init(&bst, 128), .ok);

    try test_for_push(&bst);

    value = core.bst.remove(&bst, &bst.root, 1);
    try expect(value != null);

    try expectEqual(bst.root.?.size, 5);
    try expectEqual(bst.root.?.left.?.size, 2);
    try expectEqual(bst.root.?.left.?.right.?.size, 3);
    try expectEqual(bst.root.?.left.?.right.?.right.?.size, 4);
    try expectEqual(bst.root.?.right.?.size, 18);

    try expectEqual(bst.root.?.left.?.left, null);

    _ = core.bst.destroy(&bst, false);
}

test "bst_remove_one_child" {
    var bst: core.Bst = undefined;
    var value: ?*anyopaque = undefined;
    try expectEqual(core.bst.init(&bst, 128), .ok);

    try test_for_push(&bst);

    value = core.bst.remove(&bst, &bst.root, 3);
    try expect(value != null);

    try expectEqual(bst.root.?.size, 5);
    try expectEqual(bst.root.?.left.?.size, 2);
    try expectEqual(bst.root.?.left.?.left.?.size, 1);
    try expectEqual(bst.root.?.left.?.right.?.size, 4);
    try expectEqual(bst.root.?.right.?.size, 18);

    _ = core.bst.destroy(&bst, false);
}

test "bst_remove_two_child" {
    var bst: core.Bst = undefined;
    var value: ?*anyopaque = undefined;
    try expectEqual(core.bst.init(&bst, 128), .ok);

    try expect(core.bst.insert(&bst, &bst.root, 5, @as(*anyopaque, @ptrFromInt(5))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 2, @as(*anyopaque, @ptrFromInt(2))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 1, @as(*anyopaque, @ptrFromInt(1))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 3, @as(*anyopaque, @ptrFromInt(3))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 4, @as(*anyopaque, @ptrFromInt(4))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 12, @as(*anyopaque, @ptrFromInt(12))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 9, @as(*anyopaque, @ptrFromInt(9))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 21, @as(*anyopaque, @ptrFromInt(21))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 19, @as(*anyopaque, @ptrFromInt(19))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 25, @as(*anyopaque, @ptrFromInt(25))) != null);

    try expectEqual(bst.root.?.size, 5);
    try expectEqual(bst.root.?.left.?.size, 2);
    try expectEqual(bst.root.?.left.?.left.?.size, 1);
    try expectEqual(bst.root.?.left.?.right.?.size, 3);
    try expectEqual(bst.root.?.left.?.right.?.right.?.size, 4);
    try expectEqual(bst.root.?.right.?.size, 12);
    try expectEqual(bst.root.?.right.?.left.?.size, 9);
    try expectEqual(bst.root.?.right.?.right.?.size, 21);
    try expectEqual(bst.root.?.right.?.right.?.left.?.size, 19);
    try expectEqual(bst.root.?.right.?.right.?.right.?.size, 25);

    value = core.bst.remove(&bst, &bst.root, 12);
    try expect(value != null);

    try expectEqual(bst.root.?.size, 5);
    try expectEqual(bst.root.?.left.?.size, 2);
    try expectEqual(bst.root.?.left.?.left.?.size, 1);
    try expectEqual(bst.root.?.left.?.right.?.size, 3);
    try expectEqual(bst.root.?.left.?.right.?.right.?.size, 4);
    try expectEqual(bst.root.?.right.?.size, 19);
    try expectEqual(bst.root.?.right.?.left.?.size, 9);
    try expectEqual(bst.root.?.right.?.right.?.size, 21);
    try expectEqual(bst.root.?.right.?.right.?.right.?.size, 25);

    try expectEqual(bst.root.?.right.?.right.?.left, null);

    _ = core.bst.destroy(&bst, false);
}

test "bst_remove_root_two_child" {
    var bst: core.Bst = undefined;
    var value: ?*anyopaque = undefined;
    try expectEqual(core.bst.init(&bst, 128), .ok);

    try expect(core.bst.insert(&bst, &bst.root, 20, @as(*anyopaque, @ptrFromInt(20))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 10, @as(*anyopaque, @ptrFromInt(10))) != null);
    try expect(core.bst.insert(&bst, &bst.root, 5, @as(*anyopaque, @ptrFromInt(5))) != null);

    try expectEqual(bst.root.?.size, 20);
    try expectEqual(bst.root.?.parent, null);

    value = core.bst.remove(&bst, &bst.root, 20);
    try expect(value != null);

    try expectEqual(bst.root.?.size, 10);
    try expectEqual(bst.root.?.parent, null);

    _ = core.bst.destroy(&bst, false);
}

test "bst_remove_close" {
    var bst: core.Bst = undefined;
    var value: ?*anyopaque = undefined;
    try expectEqual(core.bst.init(&bst, 128), .ok);

    try test_for_push(&bst);

    value = core.bst.removeClose(&bst, &bst.root, 7, null);
    try expect(value != null);

    try expectEqual(bst.root.?.size, 5);
    try expectEqual(bst.root.?.left.?.size, 2);
    try expectEqual(bst.root.?.left.?.left.?.size, 1);
    try expectEqual(bst.root.?.left.?.right.?.size, 3);
    try expectEqual(bst.root.?.left.?.right.?.right.?.size, 4);

    try expectEqual(bst.root.?.right, null);

    _ = core.bst.destroy(&bst, false);
}

test "clean" {
    var bst: core.Bst = undefined;
    try expectEqual(core.bst.init(&bst, 128), .ok);

    const entry = core.bst.insert(&bst, &bst.root, 100, null);
    try expect(entry != null);
    try expectEqual(bst.tree_length, 1);

    core.bst.clean(&bst);
    try expectEqual(bst.tree_length, 0);

    _ = core.bst.destroy(&bst, false);
}

test "destroy" {
    var bst = core.bst.create();
    try expectEqual(core.bst.init(bst, 128), .ok);

    try expectEqual(core.bst.destroy(bst, true), null);

    bst = core.bst.create();
    try expectEqual(core.bst.init(bst, 128), .ok);

    try expectEqual(core.bst.destroy(bst, false), bst);
    try expectEqual(core.bst.destroy(bst, true), null);
    try expectEqual(core.bst.destroy(null, false), null);
}

test "destroy_stack" {
    var bst: core.Bst = undefined;
    try expectEqual(core.bst.init(&bst, 128), .ok);

    try expectEqual(core.bst.destroy(&bst, false), &bst);
}
