const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

const lb = @import("lexbor");

fn test_for_push(bst: *lb.core.bst) !void {
    var entry: *lb.core.bst_entry = undefined;
    var pushed: ?*lb.core.bst_entry = undefined;

    try expect(bst.insert(&bst.root, 5, @as(*anyopaque, @ptrFromInt(5))) != null);
    try expect(bst.insert(&bst.root, 2, @as(*anyopaque, @ptrFromInt(2))) != null);
    try expect(bst.insert(&bst.root, 1, @as(*anyopaque, @ptrFromInt(1))) != null);
    try expect(bst.insert(&bst.root, 3, @as(*anyopaque, @ptrFromInt(3))) != null);
    try expect(bst.insert(&bst.root, 18, @as(*anyopaque, @ptrFromInt(18))) != null);

    pushed = bst.insert(&bst.root, 4, @as(*anyopaque, @ptrFromInt(4)));
    try expect(pushed != null);

    entry = bst.root.?.left.?.right.?.right.?;
    try expectEqual(entry, pushed);
}

test "init" {
    var bst = lb.core.bst.create().?;
    const status = bst.init(128);

    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    _ = bst.destroy(true);
}

test "init_null" {
    const status = lb.core.bst.init(null, 128);
    try expectEqual(status, @intFromEnum(lb.core.Status.error_object_is_null));
}

test "init_stack" {
    var bst: lb.core.bst = undefined;
    const status = bst.init(128);

    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    _ = bst.destroy(false);
}

test "init_args" {
    var bst: lb.core.bst = .{ .dobject = null, .root = null, .tree_length = 0 };
    var status: lb.core.status = undefined;

    status = bst.init(0);
    try expectEqual(status, @intFromEnum(lb.core.Status.error_wrong_args));

    _ = bst.destroy(false);
}

test "bst_insert" {
    var bst: lb.core.bst = undefined;
    var entry: *lb.core.bst_entry = undefined;

    try expectEqual(bst.init(128), @intFromEnum(lb.core.Status.ok));

    try test_for_push(&bst);
    entry = bst.root.?.left.?.right.?.right.?;

    try expectEqual(bst.root.?.size, 5);
    try expectEqual(bst.root.?.left.?.size, 2);
    try expectEqual(bst.root.?.left.?.left.?.size, 1);
    try expectEqual(bst.root.?.left.?.right.?.size, 3);
    try expectEqual(bst.root.?.left.?.right.?.right.?.size, 4);
    try expectEqual(bst.root.?.right.?.size, 18);

    try expectEqual(bst.tree_length, 6);

    _ = bst.destroy(false);
}

test "bst_search" {
    var bst: lb.core.bst = undefined;
    var entry: ?*lb.core.bst_entry = undefined;

    try expectEqual(bst.init(128), @intFromEnum(lb.core.Status.ok));

    try test_for_push(&bst);

    entry = bst.search(bst.root, 3);
    try expect(entry != null);
    try expectEqual(entry.?.size, 3);

    _ = bst.destroy(false);
}

test "bst_search_close" {
    var bst: lb.core.bst = undefined;
    var entry: ?*lb.core.bst_entry = undefined;

    try expectEqual(bst.init(128), @intFromEnum(lb.core.Status.ok));

    try test_for_push(&bst);

    entry = bst.search_close(bst.root, 6);
    try expect(entry != null);
    try expectEqual(entry.?.size, 18);

    entry = bst.search_close(bst.root, 0);
    try expect(entry != null);
    try expectEqual(entry.?.size, 1);

    entry = bst.search_close(bst.root, 19);
    try expectEqual(entry, null);

    _ = bst.destroy(false);
}

test "bst_search_close_more" {
    var bst: lb.core.bst = undefined;
    var entry: ?*lb.core.bst_entry = undefined;

    try expectEqual(bst.init(128), @intFromEnum(lb.core.Status.ok));

    try expect(bst.insert(&bst.root, 76, @as(*anyopaque, @ptrFromInt(76))) != null);
    try expect(bst.insert(&bst.root, 5, @as(*anyopaque, @ptrFromInt(5))) != null);
    try expect(bst.insert(&bst.root, 2, @as(*anyopaque, @ptrFromInt(2))) != null);
    try expect(bst.insert(&bst.root, 3, @as(*anyopaque, @ptrFromInt(3))) != null);
    try expect(bst.insert(&bst.root, 36, @as(*anyopaque, @ptrFromInt(36))) != null);
    try expect(bst.insert(&bst.root, 30, @as(*anyopaque, @ptrFromInt(30))) != null);
    try expect(bst.insert(&bst.root, 8, @as(*anyopaque, @ptrFromInt(8))) != null);
    try expect(bst.insert(&bst.root, 18, @as(*anyopaque, @ptrFromInt(18))) != null);
    try expect(bst.insert(&bst.root, 21, @as(*anyopaque, @ptrFromInt(21))) != null);
    try expect(bst.insert(&bst.root, 33, @as(*anyopaque, @ptrFromInt(33))) != null);
    try expect(bst.insert(&bst.root, 31, @as(*anyopaque, @ptrFromInt(31))) != null);
    try expect(bst.insert(&bst.root, 58, @as(*anyopaque, @ptrFromInt(58))) != null);
    try expect(bst.insert(&bst.root, 63, @as(*anyopaque, @ptrFromInt(63))) != null);
    try expect(bst.insert(&bst.root, 77, @as(*anyopaque, @ptrFromInt(77))) != null);
    try expect(bst.insert(&bst.root, 84, @as(*anyopaque, @ptrFromInt(84))) != null);

    entry = bst.search_close(bst.root, 1);
    try expect(entry != null);
    try expectEqual(entry.?.size, 2);

    entry = bst.search_close(bst.root, 29);
    try expect(entry != null);
    try expectEqual(entry.?.size, 30);

    entry = bst.search_close(bst.root, 9);
    try expect(entry != null);
    try expectEqual(entry.?.size, 18);

    entry = bst.search_close(bst.root, 32);
    try expect(entry != null);
    try expectEqual(entry.?.size, 33);

    entry = bst.search_close(bst.root, 50);
    try expect(entry != null);
    try expectEqual(entry.?.size, 58);

    entry = bst.search_close(bst.root, 80);
    try expect(entry != null);
    try expectEqual(entry.?.size, 84);

    entry = bst.search_close(bst.root, 100);
    try expectEqual(entry, null);

    _ = bst.destroy(false);
}

test "bst_remove" {
    var bst: lb.core.bst = undefined;
    var value: ?*anyopaque = undefined;
    try expectEqual(bst.init(128), @intFromEnum(lb.core.Status.ok));

    try test_for_push(&bst);

    value = bst.remove(&bst.root, 1);
    try expect(value != null);

    try expectEqual(bst.root.?.size, 5);
    try expectEqual(bst.root.?.left.?.size, 2);
    try expectEqual(bst.root.?.left.?.right.?.size, 3);
    try expectEqual(bst.root.?.left.?.right.?.right.?.size, 4);
    try expectEqual(bst.root.?.right.?.size, 18);

    try expectEqual(bst.root.?.left.?.left, null);

    _ = bst.destroy(false);
}

test "bst_remove_one_child" {
    var bst: lb.core.bst = undefined;
    var value: ?*anyopaque = undefined;
    try expectEqual(bst.init(128), @intFromEnum(lb.core.Status.ok));

    try test_for_push(&bst);

    value = bst.remove(&bst.root, 3);
    try expect(value != null);

    try expectEqual(bst.root.?.size, 5);
    try expectEqual(bst.root.?.left.?.size, 2);
    try expectEqual(bst.root.?.left.?.left.?.size, 1);
    try expectEqual(bst.root.?.left.?.right.?.size, 4);
    try expectEqual(bst.root.?.right.?.size, 18);

    _ = bst.destroy(false);
}

test "bst_remove_two_child" {
    var bst: lb.core.bst = undefined;
    var value: ?*anyopaque = undefined;
    try expectEqual(bst.init(128), @intFromEnum(lb.core.Status.ok));

    try expect(bst.insert(&bst.root, 5, @as(*anyopaque, @ptrFromInt(5))) != null);
    try expect(bst.insert(&bst.root, 2, @as(*anyopaque, @ptrFromInt(2))) != null);
    try expect(bst.insert(&bst.root, 1, @as(*anyopaque, @ptrFromInt(1))) != null);
    try expect(bst.insert(&bst.root, 3, @as(*anyopaque, @ptrFromInt(3))) != null);
    try expect(bst.insert(&bst.root, 4, @as(*anyopaque, @ptrFromInt(4))) != null);
    try expect(bst.insert(&bst.root, 12, @as(*anyopaque, @ptrFromInt(12))) != null);
    try expect(bst.insert(&bst.root, 9, @as(*anyopaque, @ptrFromInt(9))) != null);
    try expect(bst.insert(&bst.root, 21, @as(*anyopaque, @ptrFromInt(21))) != null);
    try expect(bst.insert(&bst.root, 19, @as(*anyopaque, @ptrFromInt(19))) != null);
    try expect(bst.insert(&bst.root, 25, @as(*anyopaque, @ptrFromInt(25))) != null);

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

    value = bst.remove(&bst.root, 12);
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

    _ = bst.destroy(false);
}

test "bst_remove_root_two_child" {
    var bst: lb.core.bst = undefined;
    var value: ?*anyopaque = undefined;
    try expectEqual(bst.init(128), @intFromEnum(lb.core.Status.ok));

    try expect(bst.insert(&bst.root, 20, @as(*anyopaque, @ptrFromInt(20))) != null);
    try expect(bst.insert(&bst.root, 10, @as(*anyopaque, @ptrFromInt(10))) != null);
    try expect(bst.insert(&bst.root, 5, @as(*anyopaque, @ptrFromInt(5))) != null);

    try expectEqual(bst.root.?.size, 20);
    try expectEqual(bst.root.?.parent, null);

    value = bst.remove(&bst.root, 20);
    try expect(value != null);

    try expectEqual(bst.root.?.size, 10);
    try expectEqual(bst.root.?.parent, null);

    _ = bst.destroy(false);
}

test "bst_remove_close" {
    var bst: lb.core.bst = undefined;
    var value: ?*anyopaque = undefined;
    try expectEqual(bst.init(128), @intFromEnum(lb.core.Status.ok));

    try test_for_push(&bst);

    value = bst.remove_close(&bst.root, 7, null);
    try expect(value != null);

    try expectEqual(bst.root.?.size, 5);
    try expectEqual(bst.root.?.left.?.size, 2);
    try expectEqual(bst.root.?.left.?.left.?.size, 1);
    try expectEqual(bst.root.?.left.?.right.?.size, 3);
    try expectEqual(bst.root.?.left.?.right.?.right.?.size, 4);

    try expectEqual(bst.root.?.right, null);

    _ = bst.destroy(false);
}

test "clean" {
    var bst: lb.core.bst = undefined;
    try expectEqual(bst.init(128), @intFromEnum(lb.core.Status.ok));

    const entry = bst.insert(&bst.root, 100, null);
    try expect(entry != null);
    try expectEqual(bst.tree_length, 1);

    bst.clean();
    try expectEqual(bst.tree_length, 0);

    _ = bst.destroy(false);
}

test "destroy" {
    var bst = lb.core.array.create().?;
    try expectEqual(bst.init(128), @intFromEnum(lb.core.Status.ok));

    try expectEqual(bst.destroy(true), null);

    bst = lb.core.array.create().?;
    try expectEqual(bst.init(128), @intFromEnum(lb.core.Status.ok));

    try expectEqual(bst.destroy(false), bst);
    try expectEqual(bst.destroy(true), null);
    try expectEqual(lb.core.bst.destroy(null, false), null);
}

test "destroy_stack" {
    var bst: lb.core.bst = undefined;
    try expectEqual(bst.init(128), @intFromEnum(lb.core.Status.ok));

    try expectEqual(bst.destroy(false), &bst);
}
