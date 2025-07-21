const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const zeroInit = std.mem.zeroInit;

const core = @import("lexbor").core;

pub const AvlTestCtx = struct {
    remove: usize,
    result: ?*usize,
    p: ?*usize,
};

fn avlCb(avl: ?*core.Avl, root: ?*?*core.avl.Node, node: ?*core.avl.Node, ctx: ?*anyopaque) callconv(.C) core.StatusType {
    const t = ctx;

    @as(*AvlTestCtx, @ptrCast(@alignCast(t.?))).p.?.* = node.?.type;

    const pointer_address = @intFromPtr(@as(*AvlTestCtx, @ptrCast(@alignCast(t.?))).p.?);

    @as(*AvlTestCtx, @ptrCast(@alignCast(t.?))).p.? = @ptrFromInt(pointer_address + @sizeOf(usize));

    if (node.?.type == @as(*AvlTestCtx, @ptrCast(@alignCast(t.?))).remove) {
        core.avl.removeByNode(avl, root, node);
    }

    return @intFromEnum(core.Status.ok);
}

test "init" {
    const avl = core.avl.create();
    const status = core.avl.init(avl, 1024, 0);

    try expectEqual(status, .ok);

    _ = core.avl.destroy(avl, true);
}

test "init_null" {
    const status = core.avl.init(null, 1024, 0);
    try expectEqual(status, .error_object_is_null);
}

test "init_stack" {
    var avl: core.Avl = undefined;
    const status = core.avl.init(&avl, 1024, 0);

    try expectEqual(status, .ok);

    _ = core.avl.destroy(&avl, false);
}

test "init_args" {
    var avl = zeroInit(core.Avl, .{});
    const status = core.avl.init(&avl, 0, 0);

    try expectEqual(status, .error_wrong_args);

    _ = core.avl.destroy(&avl, false);
}

test "node_make" {
    var avl: core.Avl = undefined;
    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    const node = core.avl.nodeMake(&avl, 1, &avl);

    try expect(node != null);

    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expectEqual(node.?.parent, null);
    try expectEqual(node.?.height, 0);
    try expectEqual(node.?.type, 1);
    try expectEqual(node.?.value.?, @as(*anyopaque, @ptrCast(&avl)));

    _ = core.avl.destroy(&avl, false);
}

test "node_clean" {
    var avl: core.Avl = undefined;
    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    const node = core.avl.nodeMake(&avl, 1, &avl);

    try expect(node != null);

    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expectEqual(node.?.parent, null);
    try expectEqual(node.?.height, 0);
    try expectEqual(node.?.type, 1);
    try expectEqual(node.?.value, @as(*anyopaque, @ptrCast(&avl)));

    core.avl.nodeClean(node);

    try expectEqual(node.?.left, null);
    try expectEqual(node.?.right, null);
    try expectEqual(node.?.parent, null);
    try expectEqual(node.?.height, 0);
    try expectEqual(node.?.type, 0);
    try expectEqual(node.?.value, null);

    _ = core.avl.destroy(&avl, false);
}

test "node_destroy" {
    const avl = core.avl.create();
    _ = core.avl.init(avl, 1024, 0);

    var node = core.avl.nodeMake(avl, 1, avl);

    try expect(node != null);

    try expectEqual(core.avl.nodeDestroy(avl, node, true), null);

    node = core.avl.nodeMake(avl, 1, avl);
    try expect(node != null);

    try expectEqual(core.avl.nodeDestroy(avl, node, false), node);
    try expectEqual(core.avl.nodeDestroy(avl, null, false), null);

    _ = core.avl.destroy(avl, true);
}

fn test_for_three(avl: *core.Avl, root: ?*core.avl.Node) !void {
    var node: ?*core.avl.Node = undefined;

    try expect(root != null);
    try expectEqual(root.?.type, 2);

    // 1
    node = core.avl.search(avl, root, 1);
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
    var avl: core.Avl = undefined;
    var root: ?*core.avl.Node = null;

    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    _ = core.avl.insert(&avl, &root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = core.avl.insert(&avl, &root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = core.avl.insert(&avl, &root, 3, @as(*anyopaque, @ptrFromInt(3)));

    try test_for_three(&avl, root);

    _ = core.avl.destroy(&avl, false);
}

test "three_3_1" {
    var avl: core.Avl = undefined;
    var root: ?*core.avl.Node = null;

    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    _ = core.avl.insert(&avl, &root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = core.avl.insert(&avl, &root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = core.avl.insert(&avl, &root, 1, @as(*anyopaque, @ptrFromInt(1)));

    try test_for_three(&avl, root);

    _ = core.avl.destroy(&avl, false);
}

test "three_3_2" {
    var avl: core.Avl = undefined;
    var root: ?*core.avl.Node = null;

    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    _ = core.avl.insert(&avl, &root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = core.avl.insert(&avl, &root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = core.avl.insert(&avl, &root, 3, @as(*anyopaque, @ptrFromInt(3)));

    try test_for_three(&avl, root);

    _ = core.avl.destroy(&avl, false);
}

test "three_3_3" {
    var avl: core.Avl = undefined;
    var root: ?*core.avl.Node = null;

    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    _ = core.avl.insert(&avl, &root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = core.avl.insert(&avl, &root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = core.avl.insert(&avl, &root, 1, @as(*anyopaque, @ptrFromInt(1)));

    try test_for_three(&avl, root);

    _ = core.avl.destroy(&avl, false);
}

test "three_3_4" {
    var avl: core.Avl = undefined;
    var root: ?*core.avl.Node = null;

    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    _ = core.avl.insert(&avl, &root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = core.avl.insert(&avl, &root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = core.avl.insert(&avl, &root, 2, @as(*anyopaque, @ptrFromInt(2)));

    try test_for_three(&avl, root);

    _ = core.avl.destroy(&avl, false);
}

test "three_3_5" {
    var avl: core.Avl = undefined;
    var root: ?*core.avl.Node = null;

    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    _ = core.avl.insert(&avl, &root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = core.avl.insert(&avl, &root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = core.avl.insert(&avl, &root, 2, @as(*anyopaque, @ptrFromInt(2)));

    try test_for_three(&avl, root);

    _ = core.avl.destroy(&avl, false);
}

test "tree_4" {
    var avl: core.Avl = undefined;
    var root: ?*core.avl.Node = null;
    var node: ?*core.avl.Node = undefined;

    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    _ = core.avl.insert(&avl, &root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = core.avl.insert(&avl, &root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = core.avl.insert(&avl, &root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = core.avl.insert(&avl, &root, 4, @as(*anyopaque, @ptrFromInt(4)));

    // 1
    node = core.avl.search(&avl, root, 1);
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

    _ = core.avl.destroy(&avl, false);
}

test "tree_5" {
    var avl: core.Avl = undefined;
    var root: ?*core.avl.Node = null;
    var node: ?*core.avl.Node = undefined;

    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    _ = core.avl.insert(&avl, &root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = core.avl.insert(&avl, &root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = core.avl.insert(&avl, &root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = core.avl.insert(&avl, &root, 4, @as(*anyopaque, @ptrFromInt(4)));
    _ = core.avl.insert(&avl, &root, 5, @as(*anyopaque, @ptrFromInt(5)));

    // 1
    node = core.avl.search(&avl, root, 1);
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

    _ = core.avl.destroy(&avl, false);
}

test "delete_1L" {
    var avl: core.Avl = undefined;
    var root: ?*core.avl.Node = null;
    var node: ?*core.avl.Node = undefined;

    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    _ = core.avl.insert(&avl, &root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = core.avl.insert(&avl, &root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = core.avl.insert(&avl, &root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = core.avl.insert(&avl, &root, 4, @as(*anyopaque, @ptrFromInt(4)));

    try expect(root != null);

    try expect(core.avl.remove(&avl, &root, 1) != null);
    try expect(root != null);

    // 2
    node = core.avl.search(&avl, root, 2);
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

    _ = core.avl.destroy(&avl, false);
}

test "delete_1R" {
    var avl: core.Avl = undefined;
    var root: ?*core.avl.Node = null;
    var node: ?*core.avl.Node = undefined;

    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    _ = core.avl.insert(&avl, &root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = core.avl.insert(&avl, &root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = core.avl.insert(&avl, &root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = core.avl.insert(&avl, &root, 4, @as(*anyopaque, @ptrFromInt(4)));

    try expect(root != null);

    try expect(core.avl.remove(&avl, &root, 4) != null);
    try expect(root != null);

    // 1
    node = core.avl.search(&avl, root, 1);
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

    _ = core.avl.destroy(&avl, false);
}

test "delete_2L" {
    var avl: core.Avl = undefined;
    var root: ?*core.avl.Node = null;
    var node: ?*core.avl.Node = undefined;

    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    _ = core.avl.insert(&avl, &root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = core.avl.insert(&avl, &root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = core.avl.insert(&avl, &root, 4, @as(*anyopaque, @ptrFromInt(4)));
    _ = core.avl.insert(&avl, &root, 3, @as(*anyopaque, @ptrFromInt(3)));

    try expect(root != null);

    try expect(core.avl.remove(&avl, &root, 1) != null);
    try expect(root != null);

    // 2
    node = core.avl.search(&avl, root, 2);
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

    _ = core.avl.destroy(&avl, false);
}

test "delete_2R" {
    var avl: core.Avl = undefined;
    var root: ?*core.avl.Node = null;
    var node: ?*core.avl.Node = undefined;

    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    _ = core.avl.insert(&avl, &root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = core.avl.insert(&avl, &root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = core.avl.insert(&avl, &root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = core.avl.insert(&avl, &root, 4, @as(*anyopaque, @ptrFromInt(4)));

    try expect(root != null);

    try expect(core.avl.remove(&avl, &root, 4) != null);
    try expect(root != null);

    // 1
    node = core.avl.search(&avl, root, 1);
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

    _ = core.avl.destroy(&avl, false);
}

test "delete_sub_1L" {
    var avl: core.Avl = undefined;
    var root: ?*core.avl.Node = null;
    var node: ?*core.avl.Node = undefined;

    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    _ = core.avl.insert(&avl, &root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = core.avl.insert(&avl, &root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = core.avl.insert(&avl, &root, 5, @as(*anyopaque, @ptrFromInt(5)));
    _ = core.avl.insert(&avl, &root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = core.avl.insert(&avl, &root, 4, @as(*anyopaque, @ptrFromInt(4)));
    _ = core.avl.insert(&avl, &root, 6, @as(*anyopaque, @ptrFromInt(6)));
    _ = core.avl.insert(&avl, &root, 7, @as(*anyopaque, @ptrFromInt(7)));

    try expect(root != null);

    try expect(core.avl.remove(&avl, &root, 1) != null);
    try expect(root != null);

    // 2
    node = core.avl.search(&avl, root, 2);
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

    _ = core.avl.destroy(&avl, false);
}

test "delete_sub_1R" {
    var avl: core.Avl = undefined;
    var root: ?*core.avl.Node = null;
    var node: ?*core.avl.Node = undefined;

    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    _ = core.avl.insert(&avl, &root, 5, @as(*anyopaque, @ptrFromInt(5)));
    _ = core.avl.insert(&avl, &root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = core.avl.insert(&avl, &root, 6, @as(*anyopaque, @ptrFromInt(6)));
    _ = core.avl.insert(&avl, &root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = core.avl.insert(&avl, &root, 4, @as(*anyopaque, @ptrFromInt(4)));
    _ = core.avl.insert(&avl, &root, 7, @as(*anyopaque, @ptrFromInt(7)));
    _ = core.avl.insert(&avl, &root, 1, @as(*anyopaque, @ptrFromInt(1)));

    try expect(root != null);

    try expect(core.avl.remove(&avl, &root, 7) != null);
    try expect(root != null);

    // 1
    node = core.avl.search(&avl, root, 1);
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

    _ = core.avl.destroy(&avl, false);
}

test "delete_10_0" {
    var avl: core.Avl = undefined;
    var root: ?*core.avl.Node = null;
    var node: ?*core.avl.Node = undefined;

    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    _ = core.avl.insert(&avl, &root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = core.avl.insert(&avl, &root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = core.avl.insert(&avl, &root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = core.avl.insert(&avl, &root, 4, @as(*anyopaque, @ptrFromInt(4)));
    _ = core.avl.insert(&avl, &root, 5, @as(*anyopaque, @ptrFromInt(5)));
    _ = core.avl.insert(&avl, &root, 6, @as(*anyopaque, @ptrFromInt(6)));
    _ = core.avl.insert(&avl, &root, 7, @as(*anyopaque, @ptrFromInt(7)));
    _ = core.avl.insert(&avl, &root, 8, @as(*anyopaque, @ptrFromInt(8)));
    _ = core.avl.insert(&avl, &root, 9, @as(*anyopaque, @ptrFromInt(9)));
    _ = core.avl.insert(&avl, &root, 10, @as(*anyopaque, @ptrFromInt(10)));

    try expect(root != null);

    try expect(core.avl.remove(&avl, &root, 8) != null);
    try expect(root != null);

    // 4
    node = core.avl.search(&avl, root, 4);
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

    _ = core.avl.destroy(&avl, false);
}

test "delete_10_1" {
    var avl: core.Avl = undefined;
    var root: ?*core.avl.Node = null;
    var node: ?*core.avl.Node = undefined;

    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    _ = core.avl.insert(&avl, &root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = core.avl.insert(&avl, &root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = core.avl.insert(&avl, &root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = core.avl.insert(&avl, &root, 4, @as(*anyopaque, @ptrFromInt(4)));
    _ = core.avl.insert(&avl, &root, 5, @as(*anyopaque, @ptrFromInt(5)));
    _ = core.avl.insert(&avl, &root, 6, @as(*anyopaque, @ptrFromInt(6)));
    _ = core.avl.insert(&avl, &root, 7, @as(*anyopaque, @ptrFromInt(7)));
    _ = core.avl.insert(&avl, &root, 8, @as(*anyopaque, @ptrFromInt(8)));
    _ = core.avl.insert(&avl, &root, 9, @as(*anyopaque, @ptrFromInt(9)));
    _ = core.avl.insert(&avl, &root, 10, @as(*anyopaque, @ptrFromInt(10)));

    try expect(root != null);

    try expect(core.avl.remove(&avl, &root, 8) != null);
    try expect(root != null);
    try expect(core.avl.remove(&avl, &root, 5) != null);
    try expect(root != null);

    // 4
    node = core.avl.search(&avl, root, 4);
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

    _ = core.avl.destroy(&avl, false);
}

test "delete_10_2" {
    var avl: core.Avl = undefined;
    var root: ?*core.avl.Node = null;
    var node: ?*core.avl.Node = undefined;

    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    _ = core.avl.insert(&avl, &root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = core.avl.insert(&avl, &root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = core.avl.insert(&avl, &root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = core.avl.insert(&avl, &root, 4, @as(*anyopaque, @ptrFromInt(4)));
    _ = core.avl.insert(&avl, &root, 5, @as(*anyopaque, @ptrFromInt(5)));
    _ = core.avl.insert(&avl, &root, 6, @as(*anyopaque, @ptrFromInt(6)));
    _ = core.avl.insert(&avl, &root, 7, @as(*anyopaque, @ptrFromInt(7)));
    _ = core.avl.insert(&avl, &root, 8, @as(*anyopaque, @ptrFromInt(8)));
    _ = core.avl.insert(&avl, &root, 9, @as(*anyopaque, @ptrFromInt(9)));
    _ = core.avl.insert(&avl, &root, 10, @as(*anyopaque, @ptrFromInt(10)));

    try expect(root != null);

    try expect(core.avl.remove(&avl, &root, 8) != null);
    try expect(root != null);
    try expect(core.avl.remove(&avl, &root, 6) != null);
    try expect(root != null);

    // 4
    node = core.avl.search(&avl, root, 4);
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

    _ = core.avl.destroy(&avl, false);
}

test "delete_10_3" {
    var avl: core.Avl = undefined;
    var root: ?*core.avl.Node = null;
    var node: ?*core.avl.Node = undefined;

    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    _ = core.avl.insert(&avl, &root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = core.avl.insert(&avl, &root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = core.avl.insert(&avl, &root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = core.avl.insert(&avl, &root, 4, @as(*anyopaque, @ptrFromInt(4)));
    _ = core.avl.insert(&avl, &root, 5, @as(*anyopaque, @ptrFromInt(5)));
    _ = core.avl.insert(&avl, &root, 6, @as(*anyopaque, @ptrFromInt(6)));
    _ = core.avl.insert(&avl, &root, 7, @as(*anyopaque, @ptrFromInt(7)));
    _ = core.avl.insert(&avl, &root, 8, @as(*anyopaque, @ptrFromInt(8)));
    _ = core.avl.insert(&avl, &root, 9, @as(*anyopaque, @ptrFromInt(9)));
    _ = core.avl.insert(&avl, &root, 10, @as(*anyopaque, @ptrFromInt(10)));

    try expect(root != null);

    try expect(core.avl.remove(&avl, &root, 9) != null);
    try expect(root != null);

    // 4
    node = core.avl.search(&avl, root, 4);
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

    _ = core.avl.destroy(&avl, false);
}

test "delete_10_4" {
    var avl: core.Avl = undefined;
    var root: ?*core.avl.Node = null;
    var node: ?*core.avl.Node = undefined;

    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    _ = core.avl.insert(&avl, &root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = core.avl.insert(&avl, &root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = core.avl.insert(&avl, &root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = core.avl.insert(&avl, &root, 4, @as(*anyopaque, @ptrFromInt(4)));
    _ = core.avl.insert(&avl, &root, 5, @as(*anyopaque, @ptrFromInt(5)));
    _ = core.avl.insert(&avl, &root, 6, @as(*anyopaque, @ptrFromInt(6)));
    _ = core.avl.insert(&avl, &root, 7, @as(*anyopaque, @ptrFromInt(7)));
    _ = core.avl.insert(&avl, &root, 8, @as(*anyopaque, @ptrFromInt(8)));
    _ = core.avl.insert(&avl, &root, 9, @as(*anyopaque, @ptrFromInt(9)));
    _ = core.avl.insert(&avl, &root, 10, @as(*anyopaque, @ptrFromInt(10)));

    try expect(root != null);

    try expect(core.avl.remove(&avl, &root, 4) != null);
    try expect(root != null);

    // 3
    node = core.avl.search(&avl, root, 3);
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

    _ = core.avl.destroy(&avl, false);
}

test "delete_10_5" {
    var avl: core.Avl = undefined;
    var root: ?*core.avl.Node = null;
    var node: ?*core.avl.Node = undefined;

    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    _ = core.avl.insert(&avl, &root, 1, @as(*anyopaque, @ptrFromInt(1)));
    _ = core.avl.insert(&avl, &root, 2, @as(*anyopaque, @ptrFromInt(2)));
    _ = core.avl.insert(&avl, &root, 3, @as(*anyopaque, @ptrFromInt(3)));
    _ = core.avl.insert(&avl, &root, 4, @as(*anyopaque, @ptrFromInt(4)));
    _ = core.avl.insert(&avl, &root, 5, @as(*anyopaque, @ptrFromInt(5)));
    _ = core.avl.insert(&avl, &root, 6, @as(*anyopaque, @ptrFromInt(6)));
    _ = core.avl.insert(&avl, &root, 7, @as(*anyopaque, @ptrFromInt(7)));
    _ = core.avl.insert(&avl, &root, 8, @as(*anyopaque, @ptrFromInt(8)));
    _ = core.avl.insert(&avl, &root, 9, @as(*anyopaque, @ptrFromInt(9)));
    _ = core.avl.insert(&avl, &root, 10, @as(*anyopaque, @ptrFromInt(10)));

    try expect(root != null);

    try expect(core.avl.remove(&avl, &root, 6) != null);
    try expect(root != null);

    // 4
    node = core.avl.search(&avl, root, 4);
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

    _ = core.avl.destroy(&avl, false);
}

test "clean" {
    var avl: core.Avl = undefined;
    _ = core.avl.init(&avl, 1024, 0);

    core.avl.clean(&avl);

    _ = core.avl.destroy(&avl, false);
}

test "destroy" {
    var avl = core.avl.create();
    _ = core.avl.init(avl, 1024, 0);

    try expectEqual(core.avl.destroy(avl, true), null);

    avl = core.avl.create();
    _ = core.avl.init(avl, 1021, 0);

    try expectEqual(core.avl.destroy(avl, false), avl);
    try expectEqual(core.avl.destroy(avl, true), null);
    try expectEqual(core.avl.destroy(null, false), null);
}

test "destroy_stack" {
    var avl: core.Avl = undefined;
    _ = core.avl.init(&avl, 1024, 0);

    try expectEqual(core.avl.destroy(&avl, false), &avl);
}

test "foreach_4" {
    var p: *usize = undefined;
    var avl: core.Avl = undefined;
    var t: AvlTestCtx = undefined;
    var root: ?*core.avl.Node = null;

    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    var i: usize = 5;
    while (i > 1) : (i -= 1) {
        _ = core.avl.insert(&avl, &root, i, null);
    }

    t.result = @ptrCast(@alignCast(core.malloc(10 * @sizeOf(usize))));
    try expect(t.result != null);

    t.remove = 4;
    t.p = t.result;

    _ = core.avl.foreach(&avl, &root, avlCb, &t);

    p = t.result.?;

    i = 2;
    while (i < 6) : (i += 1) {
        try expect(p != t.p);
        try expectEqual(i, p.*);
        p = @ptrFromInt(@intFromPtr(p) + @sizeOf(usize));
    }

    core.free(t.result);
    _ = core.avl.destroy(&avl, false);
}

test "foreach_6" {
    var p: *usize = undefined;
    var avl: core.Avl = undefined;
    var t: AvlTestCtx = undefined;
    var root: ?*core.avl.Node = null;

    try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

    for (5..9) |i| {
        _ = core.avl.insert(&avl, &root, i, null);
    }

    t.result = @ptrCast(@alignCast(core.malloc(10 * @sizeOf(usize))));
    try expect(t.result != null);

    t.remove = 6;
    t.p = t.result;

    _ = core.avl.foreach(&avl, &root, avlCb, &t);

    p = t.result.?;

    for (5..9) |i| {
        try expect(p != t.p);
        try expectEqual(i, p.*);
        p = @ptrFromInt(@intFromPtr(p) + @sizeOf(usize));
    }

    core.free(t.result);
    _ = core.avl.destroy(&avl, false);
}

test "foreach_10" {
    var p: *usize = undefined;
    var avl: core.Avl = undefined;
    var t: AvlTestCtx = undefined;
    var root: ?*core.avl.Node = undefined;

    const total: usize = 101;

    t.result = @ptrCast(@alignCast(core.malloc(total * @sizeOf(usize))));
    try expect(t.result != null);

    for (1..total) |r| {
        try expectEqual(core.avl.init(&avl, 1024, 0), .ok);

        root = null;

        for (1..total) |i| {
            _ = core.avl.insert(&avl, &root, i, null);
        }

        t.remove = r;
        t.p = t.result;

        _ = core.avl.foreach(&avl, &root, avlCb, &t);

        p = t.result.?;

        for (1..total) |i| {
            try expect(p != t.p);

            try expectEqual(i, p.*);

            p = @ptrFromInt(@intFromPtr(p) + @sizeOf(usize));
        }

        _ = core.avl.destroy(&avl, false);
    }

    core.free(t.result);
}
