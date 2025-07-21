const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const zeroInit = std.mem.zeroInit;

const lb = @import("lexbor");

test "init" {
    var incoming = lb.core.In.create().?;
    const status = incoming.init(1024);

    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    _ = incoming.destroy(true);
}

test "init_null" {
    const status = lb.core.In.init(null, 1024);
    try expectEqual(status, @intFromEnum(lb.core.Status.error_object_is_null));
}

test "init_stack" {
    var incoming: lb.core.In = undefined;
    const status = incoming.init(1024);

    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    _ = incoming.destroy(false);
}

test "init_args" {
    var incoming = zeroInit(lb.core.In, .{});
    const status = incoming.init(0);

    try expectEqual(status, @intFromEnum(lb.core.Status.error_wrong_args));

    _ = incoming.destroy(false);
}

test "node_make" {
    var incoming: lb.core.In = undefined;
    var node: ?*lb.core.InNode = undefined;

    const data = "some";
    const data_len = data.len;

    try expectEqual(incoming.init(1024), @intFromEnum(lb.core.Status.ok));

    node = incoming.nodeMake(null, &data[0], data_len);
    try expect(node != null);

    try expectEqual(node.?.offset, 0);

    try expectEqual(&node.?.begin.?[0], &data[0]);
    try expectEqual(@intFromPtr(node.?.end.?), @intFromPtr(&data[0]) + data_len);

    try expectEqual(node.?.next, null);
    try expectEqual(node.?.prev, null);

    try expectEqual(node.?.incoming, &incoming);

    _ = incoming.destroy(false);
}

test "node_make_arg_null" {
    var incoming: lb.core.In = undefined;
    var node: ?*lb.core.InNode = undefined;

    const data = "some";
    const data_len = data.len;

    try expectEqual(incoming.init(1024), @intFromEnum(lb.core.Status.ok));

    node = incoming.nodeMake(null, null, data_len);
    try expect(node != null);

    try expectEqual(node.?.offset, 0);

    try expectEqual(node.?.begin, null);
    try expect(node.?.end != null);

    try expectEqual(node.?.next, null);
    try expectEqual(node.?.prev, null);

    try expectEqual(node.?.incoming, &incoming);

    _ = incoming.destroy(false);
}

test "node_make_arg_null_0" {
    var incoming: lb.core.In = undefined;
    var node: ?*lb.core.InNode = undefined;

    try expectEqual(incoming.init(1024), @intFromEnum(lb.core.Status.ok));

    node = incoming.nodeMake(null, null, 0);
    try expect(node != null);

    try expectEqual(node.?.offset, 0);

    try expectEqual(node.?.begin, null);
    try expectEqual(node.?.end, null);

    try expectEqual(node.?.next, null);
    try expectEqual(node.?.prev, null);

    try expectEqual(node.?.incoming, &incoming);

    _ = incoming.destroy(false);
}

test "node_make_arg_data_0" {
    var incoming: lb.core.In = undefined;
    var node: ?*lb.core.InNode = undefined;

    const data = "some";

    try expectEqual(incoming.init(1024), @intFromEnum(lb.core.Status.ok));

    node = incoming.nodeMake(null, &data[0], 0);
    try expect(node != null);

    try expectEqual(node.?.offset, 0);

    try expectEqual(node.?.begin, data);
    try expectEqual(node.?.end, data);

    try expectEqual(node.?.next, null);
    try expectEqual(node.?.prev, null);

    try expectEqual(node.?.incoming, &incoming);

    _ = incoming.destroy(false);
}

test "node_clean" {
    var incoming: lb.core.In = undefined;
    var node: ?*lb.core.InNode = undefined;

    const data = "some";
    const data_len = data.len;

    try expectEqual(incoming.init(1024), @intFromEnum(lb.core.Status.ok));

    node = incoming.nodeMake(null, &data[0], data_len);
    try expect(node != null);

    node.?.clean();

    try expectEqual(node.?.offset, 0);
    try expectEqual(node.?.begin, null);
    try expectEqual(node.?.end, null);
    try expectEqual(node.?.next, null);
    try expectEqual(node.?.prev, null);

    try expectEqual(node.?.incoming, &incoming);

    _ = incoming.destroy(false);
}

test "node_destroy" {
    var incoming: lb.core.In = undefined;
    var node: ?*lb.core.InNode = undefined;

    const data = "some";
    const data_len = data.len;

    try expectEqual(incoming.init(1024), @intFromEnum(lb.core.Status.ok));

    node = incoming.nodeMake(null, &data[0], data_len);
    try expect(node != null);

    try expectEqual(incoming.nodeDestroy(node, true), null);

    node = incoming.nodeMake(null, &data[0], data_len);
    try expect(node != null);

    try expectEqual(incoming.nodeDestroy(node, false), node);
    try expectEqual(incoming.nodeDestroy(null, false), null);

    _ = incoming.destroy(false);
}

test "node_split" {
    var incoming: lb.core.In = undefined;
    var node: ?*lb.core.InNode = undefined;
    var new_node: ?*lb.core.InNode = undefined;

    const data = "some";
    const data_len = data.len;

    try expectEqual(incoming.init(1024), @intFromEnum(lb.core.Status.ok));

    node = incoming.nodeMake(null, &data[0], data_len);
    try expect(node != null);

    new_node = node.?.split(@ptrFromInt(@intFromPtr(&data[0]) + 2));

    // node
    try expectEqual(node.?.offset, 0);
    try expectEqual(node.?.begin, data);
    try expectEqual(@intFromPtr(node.?.end.?), @intFromPtr(&data[0]) + 2);
    try expectEqual(node.?.next, new_node);
    try expectEqual(node.?.prev, null);
    try expectEqual(node.?.incoming, &incoming);

    // new_node
    try expectEqual(new_node.?.offset, 2);
    try expectEqual(@intFromPtr(new_node.?.begin.?), @intFromPtr(&data[0]) + 2);
    try expectEqual(@intFromPtr(new_node.?.end.?), @intFromPtr(&data[0]) + data_len);
    try expectEqual(new_node.?.next, null);
    try expectEqual(new_node.?.prev, node);
    try expectEqual(new_node.?.incoming, &incoming);

    _ = incoming.destroy(false);
}

test "node_find" {
    var incoming: lb.core.In = undefined;
    var node: ?*lb.core.InNode = undefined;
    var found_node: ?*lb.core.InNode = undefined;

    const data = "some";
    const data_len = data.len;

    try expectEqual(incoming.init(1024), @intFromEnum(lb.core.Status.ok));

    node = incoming.nodeMake(null, &data[0], data_len);
    try expect(node != null);

    node = incoming.nodeMake(node, &"test"[0], 4);
    try expect(node != null);

    found_node = node.?.find(@ptrFromInt(@intFromPtr(&data[0]) + 2));

    try expectEqual(found_node.?.offset, 0);
    try expectEqual(found_node.?.begin, data);
    try expectEqual(@intFromPtr(found_node.?.end.?), @intFromPtr(&data[0]) + data_len);
    try expect(found_node.?.next != null);
    try expectEqual(found_node.?.prev, null);
    try expectEqual(found_node.?.incoming, &incoming);

    _ = incoming.destroy(false);
}

test "node_param" {
    var incoming: lb.core.In = undefined;
    var node: ?*lb.core.InNode = undefined;

    const data = "some";
    const data_len = data.len;

    try expectEqual(incoming.init(1024), @intFromEnum(lb.core.Status.ok));

    node = incoming.nodeMake(null, &data[0], data_len);
    try expect(node != null);

    try expectEqual(lb.core.inNodeOffset(node), 0);
    try expectEqual(lb.core.inNodeBegin(node).?, data);
    try expectEqual(lb.core.inNodeEnd(node).?, @as(?[*]const lb.core.char, @ptrFromInt(@intFromPtr(&data[0]) + data_len)));
    try expectEqual(lb.core.inNodeNext(node), null);
    try expectEqual(lb.core.inNodePrev(node), null);
    try expectEqual(lb.core.inNodeIn(node), &incoming);

    _ = incoming.destroy(false);
}

test "clean" {
    var incoming: lb.core.In = undefined;
    _ = incoming.init(1024);

    incoming.clean();

    _ = incoming.destroy(false);
}

test "destroy" {
    var incoming = lb.core.In.create();
    _ = incoming.?.init(1024);

    try expectEqual(incoming.?.destroy(true), null);

    incoming = lb.core.In.create();
    _ = incoming.?.init(1021);

    try expectEqual(incoming.?.destroy(false), incoming);
    try expectEqual(incoming.?.destroy(true), null);
    try expectEqual(lb.core.In.destroy(null, false), null);
}

test "destroy_stack" {
    var incoming: lb.core.In = undefined;
    _ = incoming.init(1023);

    try expectEqual(incoming.destroy(false), &incoming);
}
