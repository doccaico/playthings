const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const zeroInit = std.mem.zeroInit;

const lb = @import("lexbor");

pub const AvlTestCtx = struct {
    remove: usize,
    result: ?*usize,
    p: ?*usize,
};

fn avl_cb(avl: ?*lb.core.Avl, root: ?*?*lb.core.AvlNode, node: ?*lb.core.AvlNode, ctx: ?*anyopaque) callconv(.C) lb.core.status {
    const t = ctx;

    @as(*AvlTestCtx, @ptrCast(@alignCast(t.?))).p.?.* = node.?.type;

    const pointer_address = @intFromPtr(@as(*AvlTestCtx, @ptrCast(@alignCast(t.?))).p.?);

    @as(*AvlTestCtx, @ptrCast(@alignCast(t.?))).p.? = @ptrFromInt(pointer_address + @sizeOf(usize));

    if (node.?.type == @as(*AvlTestCtx, @ptrCast(@alignCast(t.?))).remove) {
        avl.?.removeByNode(root, node);
    }

    return @intFromEnum(lb.core.Status.ok);
}

test "init" {
    var avl = lb.core.Avl.create().?;
    const status = avl.init(1024, 0);

    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    _ = avl.destroy(true);
}

test "init_null" {
    const status = lb.core.Avl.init(null, 1024, 0);
    try expectEqual(status, @intFromEnum(lb.core.Status.error_object_is_null));
}

test "init_stack" {
    var avl: lb.core.Avl = undefined;
    const status = avl.init(1024, 0);

    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    _ = avl.destroy(false);
}

test "init_args" {
    var avl = zeroInit(lb.core.Avl, .{});
    const status = avl.init(0, 0);

    try expectEqual(status, @intFromEnum(lb.core.Status.error_wrong_args));

    _ = avl.destroy(false);
}

test "node_make" {
    var avl: lb.core.Avl = undefined;
    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    const node = avl.nodeMake(1, &avl);

    try expect(node != null);

    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expectEqual(node.?.parent, null);
    try expectEqual(node.?.height, 0);
    try expectEqual(node.?.type, 1);
    try expectEqual(node.?.value.?, @as(*anyopaque, @ptrCast(&avl)));

    _ = avl.destroy(false);
}

test "node_clean" {
    var avl: lb.core.Avl = undefined;
    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    var node = avl.nodeMake(1, &avl);

    try expect(node != null);

    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expectEqual(node.?.parent, null);
    try expectEqual(node.?.height, 0);
    try expectEqual(node.?.type, 1);
    try expectEqual(node.?.value, @as(*anyopaque, @ptrCast(&avl)));

    node.?.clean();

    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expectEqual(node.?.parent, null);
    try expectEqual(node.?.height, 0);
    try expectEqual(node.?.type, 0);
    try expectEqual(node.?.value, null);

    _ = avl.destroy(false);
}

test "node_destroy" {
    var avl = lb.core.Avl.create().?;
    _ = avl.init(1024, 0);

    var node = avl.nodeMake(1, avl);

    try expect(node != null);

    try expectEqual(avl.nodeDestroy(node, true), null);

    node = avl.nodeMake(1, avl);
    try expect(node != null);

    try expectEqual(avl.nodeDestroy(node, false), node);
    try expectEqual(avl.nodeDestroy(null, false), null);

    _ = avl.destroy(true);
}

fn test_for_three(avl: *lb.core.Avl, root: ?*lb.core.AvlNode) !void {
    var node: ?*lb.core.AvlNode = undefined;

    try expect(root != null);
    try expectEqual(root.?.type, 2);

    // 1
    node = avl.search(root, 1);
    try expect(node != null);

    try expectEqual(node.?.type, 1);
    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 2);

    // 2
    node = node.?.parent;
    try expect(node != null);

    try expectEqual(node.?.type, 2);

    try expect(node.?.left != null);
    try expectEqual(node.?.left.?.type, 1);

    try expect(node.?.right != null);
    try expectEqual(node.?.right.?.type, 3);

    try expectEqual(node.?.parent, null);

    // 3
    node = node.?.right;
    try expect(node != null);

    try expectEqual(node.?.type, 3);
    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 2);
}

test "three_3_0" {
    var avl: lb.core.Avl = undefined;
    var root: ?*lb.core.AvlNode = null;

    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    _ = avl.insert(&root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = avl.insert(&root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = avl.insert(&root, 3, @as(*anyopaque, @ptrFromInt(3)));

    try test_for_three(&avl, root);

    _ = avl.destroy(false);
}

test "three_3_1" {
    var avl: lb.core.Avl = undefined;
    var root: ?*lb.core.AvlNode = null;

    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    _ = avl.insert(&root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = avl.insert(&root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = avl.insert(&root, 1, @as(*anyopaque, @ptrFromInt(1)));

    try test_for_three(&avl, root);

    _ = avl.destroy(false);
}

test "three_3_2" {
    var avl: lb.core.Avl = undefined;
    var root: ?*lb.core.AvlNode = null;

    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    _ = avl.insert(&root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = avl.insert(&root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = avl.insert(&root, 3, @as(*anyopaque, @ptrFromInt(3)));

    try test_for_three(&avl, root);

    _ = avl.destroy(false);
}

test "three_3_3" {
    var avl: lb.core.Avl = undefined;
    var root: ?*lb.core.AvlNode = null;

    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    _ = avl.insert(&root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = avl.insert(&root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = avl.insert(&root, 1, @as(*anyopaque, @ptrFromInt(1)));

    try test_for_three(&avl, root);

    _ = avl.destroy(false);
}

test "three_3_4" {
    var avl: lb.core.Avl = undefined;
    var root: ?*lb.core.AvlNode = null;

    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    _ = avl.insert(&root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = avl.insert(&root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = avl.insert(&root, 2, @as(*anyopaque, @ptrFromInt(2)));

    try test_for_three(&avl, root);

    _ = avl.destroy(false);
}

test "three_3_5" {
    var avl: lb.core.Avl = undefined;
    var root: ?*lb.core.AvlNode = null;

    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    _ = avl.insert(&root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = avl.insert(&root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = avl.insert(&root, 2, @as(*anyopaque, @ptrFromInt(2)));

    try test_for_three(&avl, root);

    _ = avl.destroy(false);
}

test "tree_4" {
    var avl: lb.core.Avl = undefined;
    var root: ?*lb.core.AvlNode = null;
    var node: ?*lb.core.AvlNode = undefined;

    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    _ = avl.insert(&root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = avl.insert(&root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = avl.insert(&root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = avl.insert(&root, 4, @as(*anyopaque, @ptrFromInt(4)));

    // 1
    node = avl.search(root, 1);
    try expect(node != null);

    try expectEqual(node.?.type, 1);
    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 2);

    // 2
    node = node.?.parent;
    try expect(node != null);

    try expectEqual(node.?.type, 2);

    try expect(node.?.left != null);
    try expectEqual(node.?.left.?.type, 1);

    try expect(node.?.right != null);
    try expectEqual(node.?.right.?.type, 3);

    try expectEqual(node.?.parent, null);

    // 3
    node = node.?.right;
    try expect(node != null);

    try expectEqual(node.?.type, 3);
    try expectEqual(node.?.left, null);

    try expect(node.?.right != null);
    try expectEqual(node.?.right.?.type, 4);

    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 2);

    // 4
    node = node.?.right;
    try expect(node != null);

    try expectEqual(node.?.type, 4);
    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 3);

    _ = avl.destroy(false);
}

test "tree_5" {
    var avl: lb.core.Avl = undefined;
    var root: ?*lb.core.AvlNode = null;
    var node: ?*lb.core.AvlNode = undefined;

    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    _ = avl.insert(&root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = avl.insert(&root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = avl.insert(&root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = avl.insert(&root, 4, @as(*anyopaque, @ptrFromInt(4)));
    _ = avl.insert(&root, 5, @as(*anyopaque, @ptrFromInt(5)));

    // 1
    node = avl.search(root, 1);
    try expect(node != null);

    try expectEqual(node.?.type, 1);
    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 2);

    // 2
    node = node.?.parent;
    try expect(node != null);

    try expectEqual(node.?.type, 2);

    try expect(node.?.left != null);
    try expectEqual(node.?.left.?.type, 1);

    try expect(node.?.right != null);
    try expectEqual(node.?.right.?.type, 4);

    try expectEqual(node.?.parent, null);

    // 4
    node = node.?.right;
    try expect(node != null);

    try expectEqual(node.?.type, 4);

    try expect(node.?.left != null);
    try expectEqual(node.?.left.?.type, 3);

    try expect(node.?.right != null);
    try expectEqual(node.?.right.?.type, 5);

    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 2);

    // 3
    node = node.?.left;
    try expect(node != null);

    try expectEqual(node.?.type, 3);
    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 4);

    // 5
    node = node.?.parent.?.right;
    try expect(node != null);

    try expectEqual(node.?.type, 5);
    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 4);

    _ = avl.destroy(false);
}

test "delete_1L" {
    var avl: lb.core.Avl = undefined;
    var root: ?*lb.core.AvlNode = null;
    var node: ?*lb.core.AvlNode = undefined;

    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    _ = avl.insert(&root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = avl.insert(&root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = avl.insert(&root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = avl.insert(&root, 4, @as(*anyopaque, @ptrFromInt(4)));

    try expect(root != null);

    try expect(avl.remove(&root, 1) != null);
    try expect(root != null);

    // 2
    node = avl.search(root, 2);
    try expect(node != null);

    try expectEqual(node.?.type, 2);
    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 3);

    // 3
    node = node.?.parent;
    try expect(node != null);

    try expectEqual(node.?.type, 3);

    try expect(node.?.left != null);
    try expectEqual(node.?.left.?.type, 2);

    try expect(node.?.right != null);
    try expectEqual(node.?.right.?.type, 4);

    try expectEqual(node.?.parent, null);

    // 4
    node = node.?.right;
    try expect(node != null);

    try expectEqual(node.?.type, 4);
    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 3);

    _ = avl.destroy(false);
}

test "delete_1R" {
    var avl: lb.core.Avl = undefined;
    var root: ?*lb.core.AvlNode = null;
    var node: ?*lb.core.AvlNode = undefined;

    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    _ = avl.insert(&root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = avl.insert(&root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = avl.insert(&root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = avl.insert(&root, 4, @as(*anyopaque, @ptrFromInt(4)));

    try expect(root != null);

    try expect(avl.remove(&root, 4) != null);
    try expect(root != null);

    // 1
    node = avl.search(root, 1);
    try expect(node != null);

    try expectEqual(node.?.type, 1);
    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 2);

    // 2
    node = node.?.parent;
    try expect(node != null);

    try expectEqual(node.?.type, 2);

    try expect(node.?.left != null);
    try expectEqual(node.?.left.?.type, 1);

    try expect(node.?.right != null);
    try expectEqual(node.?.right.?.type, 3);

    try expectEqual(node.?.parent, null);

    // 3
    node = node.?.right;
    try expect(node != null);

    try expectEqual(node.?.type, 3);
    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 2);

    _ = avl.destroy(false);
}

test "delete_2L" {
    var avl: lb.core.Avl = undefined;
    var root: ?*lb.core.AvlNode = null;
    var node: ?*lb.core.AvlNode = undefined;

    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    _ = avl.insert(&root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = avl.insert(&root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = avl.insert(&root, 4, @as(*anyopaque, @ptrFromInt(4)));
    _ = avl.insert(&root, 3, @as(*anyopaque, @ptrFromInt(3)));

    try expect(root != null);

    try expect(avl.remove(&root, 1) != null);
    try expect(root != null);

    // 2
    node = avl.search(root, 2);
    try expect(node != null);

    try expectEqual(node.?.type, 2);
    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 3);

    // 3
    node = node.?.parent;
    try expect(node != null);

    try expectEqual(node.?.type, 3);

    try expect(node.?.left != null);
    try expectEqual(node.?.left.?.type, 2);

    try expect(node.?.right != null);
    try expectEqual(node.?.right.?.type, 4);

    try expectEqual(node.?.parent, null);

    // 4
    node = node.?.right;
    try expect(node != null);

    try expectEqual(node.?.type, 4);
    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 3);

    _ = avl.destroy(false);
}

test "delete_2R" {
    var avl: lb.core.Avl = undefined;
    var root: ?*lb.core.AvlNode = null;
    var node: ?*lb.core.AvlNode = undefined;

    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    _ = avl.insert(&root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = avl.insert(&root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = avl.insert(&root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = avl.insert(&root, 4, @as(*anyopaque, @ptrFromInt(4)));

    try expect(root != null);

    try expect(avl.remove(&root, 4) != null);
    try expect(root != null);

    // 1
    node = avl.search(root, 1);
    try expect(node != null);

    try expectEqual(node.?.type, 1);
    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 2);

    // 2
    node = node.?.parent;
    try expect(node != null);

    try expectEqual(node.?.type, 2);

    try expect(node.?.left != null);
    try expectEqual(node.?.left.?.type, 1);

    try expect(node.?.right != null);
    try expectEqual(node.?.right.?.type, 3);

    try expectEqual(node.?.parent, null);

    // 3
    node = node.?.right;
    try expect(node != null);

    try expectEqual(node.?.type, 3);
    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 2);

    _ = avl.destroy(false);
}

test "delete_sub_1L" {
    var avl: lb.core.Avl = undefined;
    var root: ?*lb.core.AvlNode = null;
    var node: ?*lb.core.AvlNode = undefined;

    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    _ = avl.insert(&root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = avl.insert(&root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = avl.insert(&root, 5, @as(*anyopaque, @ptrFromInt(5)));
    _ = avl.insert(&root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = avl.insert(&root, 4, @as(*anyopaque, @ptrFromInt(4)));
    _ = avl.insert(&root, 6, @as(*anyopaque, @ptrFromInt(6)));
    _ = avl.insert(&root, 7, @as(*anyopaque, @ptrFromInt(7)));

    try expect(root != null);

    try expect(avl.remove(&root, 1) != null);
    try expect(root != null);

    // 2
    node = avl.search(root, 2);
    try expect(node != null);

    try expectEqual(node.?.type, 2);
    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 3);

    // 3
    node = node.?.parent;
    try expect(node != null);

    try expectEqual(node.?.type, 3);

    try expect(node.?.left != null);
    try expectEqual(node.?.left.?.type, 2);

    try expect(node.?.right != null);
    try expectEqual(node.?.right.?.type, 4);

    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 5);

    // 4
    node = node.?.right;
    try expect(node != null);

    try expectEqual(node.?.type, 4);
    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 3);

    // 5
    node = node.?.parent.?.parent;
    try expect(node != null);

    try expectEqual(node.?.type, 5);

    try expect(node.?.left != null);
    try expectEqual(node.?.left.?.type, 3);

    try expect(node.?.right != null);
    try expectEqual(node.?.right.?.type, 6);

    try expectEqual(node.?.parent, null);

    // 6
    node = node.?.right;
    try expect(node != null);

    try expectEqual(node.?.type, 6);
    try expectEqual(node.?.left, null);

    try expect(node.?.right != null);
    try expectEqual(node.?.right.?.type, 7);

    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 5);

    // 7
    node = node.?.right;
    try expect(node != null);

    try expectEqual(node.?.type, 7);
    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 6);

    _ = avl.destroy(false);
}

test "delete_sub_1R" {
    var avl: lb.core.Avl = undefined;
    var root: ?*lb.core.AvlNode = null;
    var node: ?*lb.core.AvlNode = undefined;

    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    _ = avl.insert(&root, 5, @as(*anyopaque, @ptrFromInt(5)));
    _ = avl.insert(&root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = avl.insert(&root, 6, @as(*anyopaque, @ptrFromInt(6)));
    _ = avl.insert(&root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = avl.insert(&root, 4, @as(*anyopaque, @ptrFromInt(4)));
    _ = avl.insert(&root, 7, @as(*anyopaque, @ptrFromInt(7)));
    _ = avl.insert(&root, 1, @as(*anyopaque, @ptrFromInt(1)));

    try expect(root != null);

    try expect(avl.remove(&root, 7) != null);
    try expect(root != null);

    // 1
    node = avl.search(root, 1);
    try expect(node != null);

    try expectEqual(node.?.type, 1);
    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 2);

    // 2
    node = node.?.parent;
    try expect(node != null);

    try expectEqual(node.?.type, 2);

    try expect(node.?.left != null);
    try expectEqual(node.?.left.?.type, 1);

    try expectEqual(node.?.right, null);

    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 3);

    // 3
    node = node.?.parent;
    try expect(node != null);

    try expectEqual(node.?.type, 3);

    try expect(node.?.left != null);
    try expectEqual(node.?.left.?.type, 2);

    try expect(node.?.right != null);
    try expectEqual(node.?.right.?.type, 5);

    try expectEqual(node.?.parent, null);

    // 5
    node = node.?.right;
    try expect(node != null);

    try expectEqual(node.?.type, 5);

    try expect(node.?.left != null);
    try expectEqual(node.?.left.?.type, 4);

    try expect(node.?.right != null);
    try expectEqual(node.?.right.?.type, 6);

    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 3);

    // 4
    node = node.?.left;
    try expect(node != null);

    try expectEqual(node.?.type, 4);
    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 5);

    // 6
    node = node.?.parent.?.right;
    try expect(node != null);

    try expectEqual(node.?.type, 6);
    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expect(node.?.parent != null);
    try expectEqual(node.?.parent.?.type, 5);

    _ = avl.destroy(false);
}

test "delete_10_0" {
    var avl: lb.core.Avl = undefined;
    var root: ?*lb.core.AvlNode = null;
    var node: ?*lb.core.AvlNode = undefined;

    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    _ = avl.insert(&root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = avl.insert(&root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = avl.insert(&root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = avl.insert(&root, 4, @as(*anyopaque, @ptrFromInt(4)));
    _ = avl.insert(&root, 5, @as(*anyopaque, @ptrFromInt(5)));
    _ = avl.insert(&root, 6, @as(*anyopaque, @ptrFromInt(6)));
    _ = avl.insert(&root, 7, @as(*anyopaque, @ptrFromInt(7)));
    _ = avl.insert(&root, 8, @as(*anyopaque, @ptrFromInt(8)));
    _ = avl.insert(&root, 9, @as(*anyopaque, @ptrFromInt(9)));
    _ = avl.insert(&root, 10, @as(*anyopaque, @ptrFromInt(10)));

    try expect(root != null);

    try expect(avl.remove(&root, 8) != null);
    try expect(root != null);

    // 4
    node = avl.search(root, 4);
    try expect(node != null);

    try expectEqual(node.?.type, 4);

    try expect(node.?.left != null);
    try expect(node.?.right != null);
    try expectEqual(node.?.parent, null);

    try expectEqual(node.?.left.?.type, 2);
    try expectEqual(node.?.left.?.left.?.type, 1);
    try expectEqual(node.?.left.?.right.?.type, 3);

    try expectEqual(node.?.right.?.type, 7);
    try expectEqual(node.?.right.?.left.?.type, 6);
    try expectEqual(node.?.right.?.right.?.type, 9);
    try expectEqual(node.?.right.?.left.?.left.?.type, 5);
    try expectEqual(node.?.right.?.right.?.right.?.type, 10);

    _ = avl.destroy(false);
}

test "delete_10_1" {
    var avl: lb.core.Avl = undefined;
    var root: ?*lb.core.AvlNode = null;
    var node: ?*lb.core.AvlNode = undefined;

    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    _ = avl.insert(&root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = avl.insert(&root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = avl.insert(&root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = avl.insert(&root, 4, @as(*anyopaque, @ptrFromInt(4)));
    _ = avl.insert(&root, 5, @as(*anyopaque, @ptrFromInt(5)));
    _ = avl.insert(&root, 6, @as(*anyopaque, @ptrFromInt(6)));
    _ = avl.insert(&root, 7, @as(*anyopaque, @ptrFromInt(7)));
    _ = avl.insert(&root, 8, @as(*anyopaque, @ptrFromInt(8)));
    _ = avl.insert(&root, 9, @as(*anyopaque, @ptrFromInt(9)));
    _ = avl.insert(&root, 10, @as(*anyopaque, @ptrFromInt(10)));

    try expect(root != null);

    try expect(avl.remove(&root, 8) != null);
    try expect(root != null);
    try expect(avl.remove(&root, 5) != null);
    try expect(root != null);

    // 4
    node = avl.search(root, 4);
    try expect(node != null);

    try expectEqual(node.?.type, 4);

    try expect(node.?.left != null);
    try expect(node.?.right != null);
    try expectEqual(node.?.parent, null);

    try expectEqual(node.?.left.?.type, 2);
    try expectEqual(node.?.left.?.left.?.type, 1);
    try expectEqual(node.?.left.?.right.?.type, 3);

    try expectEqual(node.?.right.?.type, 7);
    try expectEqual(node.?.right.?.left.?.type, 6);
    try expectEqual(node.?.right.?.right.?.type, 9);
    try expectEqual(node.?.right.?.right.?.right.?.type, 10);

    _ = avl.destroy(false);
}

test "delete_10_2" {
    var avl: lb.core.Avl = undefined;
    var root: ?*lb.core.AvlNode = null;
    var node: ?*lb.core.AvlNode = undefined;

    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    _ = avl.insert(&root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = avl.insert(&root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = avl.insert(&root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = avl.insert(&root, 4, @as(*anyopaque, @ptrFromInt(4)));
    _ = avl.insert(&root, 5, @as(*anyopaque, @ptrFromInt(5)));
    _ = avl.insert(&root, 6, @as(*anyopaque, @ptrFromInt(6)));
    _ = avl.insert(&root, 7, @as(*anyopaque, @ptrFromInt(7)));
    _ = avl.insert(&root, 8, @as(*anyopaque, @ptrFromInt(8)));
    _ = avl.insert(&root, 9, @as(*anyopaque, @ptrFromInt(9)));
    _ = avl.insert(&root, 10, @as(*anyopaque, @ptrFromInt(10)));

    try expect(root != null);

    try expect(avl.remove(&root, 8) != null);
    try expect(root != null);
    try expect(avl.remove(&root, 6) != null);
    try expect(root != null);

    // 4
    node = avl.search(root, 4);
    try expect(node != null);

    try expectEqual(node.?.type, 4);

    try expect(node.?.left != null);
    try expect(node.?.right != null);
    try expectEqual(node.?.parent, null);

    try expectEqual(node.?.left.?.type, 2);
    try expectEqual(node.?.left.?.left.?.type, 1);
    try expectEqual(node.?.left.?.right.?.type, 3);

    try expectEqual(node.?.right.?.type, 7);
    try expectEqual(node.?.right.?.left.?.type, 5);
    try expectEqual(node.?.right.?.right.?.type, 9);
    try expectEqual(node.?.right.?.right.?.right.?.type, 10);

    _ = avl.destroy(false);
}

test "delete_10_3" {
    var avl: lb.core.Avl = undefined;
    var root: ?*lb.core.AvlNode = null;
    var node: ?*lb.core.AvlNode = undefined;

    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    _ = avl.insert(&root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = avl.insert(&root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = avl.insert(&root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = avl.insert(&root, 4, @as(*anyopaque, @ptrFromInt(4)));
    _ = avl.insert(&root, 5, @as(*anyopaque, @ptrFromInt(5)));
    _ = avl.insert(&root, 6, @as(*anyopaque, @ptrFromInt(6)));
    _ = avl.insert(&root, 7, @as(*anyopaque, @ptrFromInt(7)));
    _ = avl.insert(&root, 8, @as(*anyopaque, @ptrFromInt(8)));
    _ = avl.insert(&root, 9, @as(*anyopaque, @ptrFromInt(9)));
    _ = avl.insert(&root, 10, @as(*anyopaque, @ptrFromInt(10)));

    try expect(root != null);

    try expect(avl.remove(&root, 9) != null);
    try expect(root != null);

    // 4
    node = avl.search(root, 4);
    try expect(node != null);

    try expectEqual(node.?.type, 4);

    try expect(node.?.left != null);
    try expect(node.?.right != null);
    try expectEqual(node.?.parent, null);

    try expectEqual(node.?.left.?.type, 2);
    try expectEqual(node.?.left.?.left.?.type, 1);
    try expectEqual(node.?.left.?.right.?.type, 3);

    try expectEqual(node.?.right.?.type, 8);
    try expectEqual(node.?.right.?.left.?.type, 6);
    try expectEqual(node.?.right.?.right.?.type, 10);
    try expectEqual(node.?.right.?.left.?.left.?.type, 5);
    try expectEqual(node.?.right.?.left.?.right.?.type, 7);

    _ = avl.destroy(false);
}

test "delete_10_4" {
    var avl: lb.core.Avl = undefined;
    var root: ?*lb.core.AvlNode = null;
    var node: ?*lb.core.AvlNode = undefined;

    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    _ = avl.insert(&root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = avl.insert(&root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = avl.insert(&root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = avl.insert(&root, 4, @as(*anyopaque, @ptrFromInt(4)));
    _ = avl.insert(&root, 5, @as(*anyopaque, @ptrFromInt(5)));
    _ = avl.insert(&root, 6, @as(*anyopaque, @ptrFromInt(6)));
    _ = avl.insert(&root, 7, @as(*anyopaque, @ptrFromInt(7)));
    _ = avl.insert(&root, 8, @as(*anyopaque, @ptrFromInt(8)));
    _ = avl.insert(&root, 9, @as(*anyopaque, @ptrFromInt(9)));
    _ = avl.insert(&root, 10, @as(*anyopaque, @ptrFromInt(10)));

    try expect(root != null);

    try expect(avl.remove(&root, 4) != null);
    try expect(root != null);

    // 3
    node = avl.search(root, 3);
    try expect(node != null);

    try expectEqual(node.?.type, 3);

    try expect(node.?.left != null);
    try expect(node.?.right != null);
    try expectEqual(node.?.parent, null);

    try expectEqual(node.?.left.?.type, 2);
    try expectEqual(node.?.left.?.left.?.type, 1);

    try expectEqual(node.?.right.?.type, 8);
    try expectEqual(node.?.right.?.left.?.type, 6);
    try expectEqual(node.?.right.?.right.?.type, 9);
    try expectEqual(node.?.right.?.left.?.left.?.type, 5);
    try expectEqual(node.?.right.?.left.?.right.?.type, 7);
    try expectEqual(node.?.right.?.right.?.right.?.type, 10);

    _ = avl.destroy(false);
}

test "delete_10_5" {
    var avl: lb.core.Avl = undefined;
    var root: ?*lb.core.AvlNode = null;
    var node: ?*lb.core.AvlNode = undefined;

    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    _ = avl.insert(&root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = avl.insert(&root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = avl.insert(&root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = avl.insert(&root, 4, @as(*anyopaque, @ptrFromInt(4)));
    _ = avl.insert(&root, 5, @as(*anyopaque, @ptrFromInt(5)));
    _ = avl.insert(&root, 6, @as(*anyopaque, @ptrFromInt(6)));
    _ = avl.insert(&root, 7, @as(*anyopaque, @ptrFromInt(7)));
    _ = avl.insert(&root, 8, @as(*anyopaque, @ptrFromInt(8)));
    _ = avl.insert(&root, 9, @as(*anyopaque, @ptrFromInt(9)));
    _ = avl.insert(&root, 10, @as(*anyopaque, @ptrFromInt(10)));

    try expect(root != null);

    try expect(avl.remove(&root, 6) != null);
    try expect(root != null);

    // 4
    node = avl.search(root, 4);
    try expect(node != null);

    try expectEqual(node.?.type, 4);

    try expect(node.?.left != null);
    try expect(node.?.right != null);
    try expectEqual(node.?.parent, null);

    try expectEqual(node.?.left.?.type, 2);
    try expectEqual(node.?.left.?.left.?.type, 1);
    try expectEqual(node.?.left.?.right.?.type, 3);

    try expectEqual(node.?.right.?.type, 8);
    try expectEqual(node.?.right.?.left.?.type, 5);
    try expectEqual(node.?.right.?.right.?.type, 9);
    try expectEqual(node.?.right.?.left.?.right.?.type, 7);
    try expectEqual(node.?.right.?.right.?.right.?.type, 10);

    _ = avl.destroy(false);
}

test "clean" {
    var avl: lb.core.Avl = undefined;
    _ = avl.init(1024, 0);

    avl.clean();

    _ = avl.destroy(false);
}

test "destroy" {
    var avl = lb.core.Avl.create().?;
    _ = avl.init(1024, 0);

    try expectEqual(avl.destroy(true), null);

    avl = lb.core.Avl.create().?;
    _ = avl.init(1021, 0);

    try expectEqual(avl.destroy(false), avl);
    try expectEqual(avl.destroy(true), null);
    try expectEqual(lb.core.Avl.destroy(null, false), null);
}

test "destroy_stack" {
    var avl: lb.core.Avl = undefined;
    _ = avl.init(1024, 0);

    try expectEqual(avl.destroy(false), &avl);
}

test "foreach_4" {
    var p: *usize = undefined;
    var avl: lb.core.Avl = undefined;
    var t: AvlTestCtx = undefined;
    var root: ?*lb.core.AvlNode = null;

    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    var i: usize = 5;
    while (i > 1) : (i -= 1) {
        _ = avl.insert(&root, i, null);
    }

    t.result = @ptrCast(@alignCast(lb.core.memoryMalloc(10 * @sizeOf(usize))));
    try expect(t.result != null);

    t.remove = 4;
    t.p = t.result;

    _ = avl.foreach(&root, avl_cb, &t);

    p = t.result.?;

    i = 2;
    while (i < 6) : (i += 1) {
        try expect(p != t.p);
        try expectEqual(i, p.*);
        p = @ptrFromInt(@intFromPtr(p) + @sizeOf(usize));
    }

    lb.core.memoryFree(t.result);
    _ = avl.destroy(false);
}

test "foreach_6" {
    var p: *usize = undefined;
    var avl: lb.core.Avl = undefined;
    var t: AvlTestCtx = undefined;
    var root: ?*lb.core.AvlNode = null;

    try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

    for (5..9) |i| {
        _ = avl.insert(&root, i, null);
    }

    t.result = @ptrCast(@alignCast(lb.core.memoryMalloc(10 * @sizeOf(usize))));
    try expect(t.result != null);

    t.remove = 6;
    t.p = t.result;

    _ = avl.foreach(&root, avl_cb, &t);

    p = t.result.?;

    for (5..9) |i| {
        try expect(p != t.p);
        try expectEqual(i, p.*);
        p = @ptrFromInt(@intFromPtr(p) + @sizeOf(usize));
    }

    lb.core.memoryFree(t.result);
    _ = avl.destroy(false);
}

test "foreach_10" {
    var p: *usize = undefined;
    var avl: lb.core.Avl = undefined;
    var t: AvlTestCtx = undefined;
    var root: ?*lb.core.AvlNode = undefined;

    const total: usize = 101;

    t.result = @ptrCast(@alignCast(lb.core.memoryMalloc(total * @sizeOf(usize))));
    try expect(t.result != null);

    for (1..total) |r| {
        try expectEqual(avl.init(1024, 0), @intFromEnum(lb.core.Status.ok));

        root = null;

        for (1..total) |i| {
            _ = avl.insert(&root, i, null);
        }

        t.remove = r;
        t.p = t.result;

        _ = avl.foreach(&root, avl_cb, &t);

        p = t.result.?;

        for (1..total) |i| {
            try expect(p != t.p);

            try expectEqual(i, p.*);

            p = @ptrFromInt(@intFromPtr(p) + @sizeOf(usize));
        }

        _ = avl.destroy(false);
    }

    lb.core.memoryFree(t.result);
}
