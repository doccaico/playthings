const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

const lb = @import("lexbor");

test "init" {
    var array = lb.core.array.create().?;
    const status = array.init(32);

    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    _ = array.destroy(true);
}

test "init_null" {
    const status = lb.core.array.init(null, 32);
    try expectEqual(status, @intFromEnum(lb.core.Status.error_object_is_null));
}

test "init_stack" {
    var array: lb.core.array = undefined;
    const status = array.init(32);

    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    _ = array.destroy(false);
}

test "clean" {
    var array: lb.core.array = undefined;
    _ = array.init(32);

    _ = array.push(@as(*anyopaque, @ptrFromInt(1)));
    try expectEqual(array.length, 1);

    array.clean();
    try expectEqual(array.length, 0);

    _ = array.destroy(false);
}

test "push" {
    var array: lb.core.array = undefined;
    _ = array.init(32);

    try expectEqual(array.length, 0);

    _ = array.push(@as(*anyopaque, @ptrFromInt(1)));

    try expectEqual(array.length, 1);
    try expectEqual(array.get(0), @as(*anyopaque, @ptrFromInt(1)));

    _ = array.destroy(false);
}

test "push_null" {
    var array: lb.core.array = undefined;
    _ = array.init(32);

    _ = array.push(null);

    try expectEqual(array.length, 1);
    try expectEqual(array.get(0), null);

    _ = array.destroy(false);
}

test "pop" {
    var array: lb.core.array = undefined;
    _ = array.init(32);

    _ = array.push(@as(*anyopaque, @ptrFromInt(123)));

    try expectEqual(array.pop(), @as(*anyopaque, @ptrFromInt(123)));
    try expectEqual(array.length, 0);

    _ = array.destroy(false);
}

test "pop_if_empty" {
    var array: lb.core.array = undefined;
    _ = array.init(32);

    try expectEqual(array.length, 0);
    try expectEqual(array.pop(), null);
    try expectEqual(array.length, 0);

    _ = array.destroy(false);
}

test "get" {
    var array: lb.core.array = undefined;
    _ = array.init(32);

    try expectEqual(array.get(1), null);
    try expectEqual(array.get(0), null);

    _ = array.push(@as(*anyopaque, @ptrFromInt(123)));

    try expectEqual(array.get(0), @as(*anyopaque, @ptrFromInt(123)));
    try expectEqual(array.get(1), null);
    try expectEqual(array.get(1000), null);

    _ = array.destroy(false);
}

test "set" {
    var array: lb.core.array = undefined;
    _ = array.init(32);

    _ = array.push(@as(*anyopaque, @ptrFromInt(123)));

    try expectEqual(array.set(0, @as(*anyopaque, @ptrFromInt(456))), @intFromEnum(lb.core.Status.ok));
    try expectEqual(array.get(0), @as(*anyopaque, @ptrFromInt(456)));

    try expectEqual(array.length, 1);

    _ = array.destroy(false);
}

test "set_not_exists" {
    var array: lb.core.array = undefined;
    _ = array.init(32);

    try expectEqual(array.set(10, @as(*anyopaque, @ptrFromInt(123))), @intFromEnum(lb.core.Status.ok));
    try expectEqual(array.get(10), @as(*anyopaque, @ptrFromInt(123)));

    for (0..10) |i| {
        try expectEqual(array.get(i), null);
    }

    try expectEqual(array.length, 11);

    _ = array.destroy(false);
}

test "insert" {
    var status: lb.core.status = undefined;
    var array: lb.core.array = undefined;
    _ = array.init(32);

    status = array.insert(0, @as(*anyopaque, @ptrFromInt(456)));
    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    try expectEqual(array.get(0), @as(*anyopaque, @ptrFromInt(456)));

    try expectEqual(array.length, 1);
    try expectEqual(array.size, 32);

    _ = array.destroy(false);
}

test "insert_end" {
    var status: lb.core.status = undefined;
    var array: lb.core.array = undefined;
    _ = array.init(32);

    status = array.insert(32, @as(*anyopaque, @ptrFromInt(457)));
    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    try expectEqual(array.get(32), @as(*anyopaque, @ptrFromInt(457)));

    try expectEqual(array.length, 33);
    try expect(array.size != 32);

    _ = array.destroy(false);
}

test "insert_overflow" {
    var status: lb.core.status = undefined;
    var array: lb.core.array = undefined;
    _ = array.init(32);

    status = array.insert(33, @as(*anyopaque, @ptrFromInt(458)));
    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    try expectEqual(array.get(33), @as(*anyopaque, @ptrFromInt(458)));

    try expectEqual(array.length, 34);
    try expect(array.size != 32);

    _ = array.destroy(false);
}

test "insert_to" {
    var status: lb.core.status = undefined;
    var array: lb.core.array = undefined;
    _ = array.init(32);

    try expectEqual(array.push(@as(*anyopaque, @ptrFromInt(1))), @intFromEnum(lb.core.Status.ok));
    try expectEqual(array.push(@as(*anyopaque, @ptrFromInt(2))), @intFromEnum(lb.core.Status.ok));
    try expectEqual(array.push(@as(*anyopaque, @ptrFromInt(3))), @intFromEnum(lb.core.Status.ok));
    try expectEqual(array.push(@as(*anyopaque, @ptrFromInt(4))), @intFromEnum(lb.core.Status.ok));
    try expectEqual(array.push(@as(*anyopaque, @ptrFromInt(5))), @intFromEnum(lb.core.Status.ok));
    try expectEqual(array.push(@as(*anyopaque, @ptrFromInt(6))), @intFromEnum(lb.core.Status.ok));
    try expectEqual(array.push(@as(*anyopaque, @ptrFromInt(7))), @intFromEnum(lb.core.Status.ok));
    try expectEqual(array.push(@as(*anyopaque, @ptrFromInt(8))), @intFromEnum(lb.core.Status.ok));
    try expectEqual(array.push(@as(*anyopaque, @ptrFromInt(9))), @intFromEnum(lb.core.Status.ok));

    status = array.insert(4, @as(*anyopaque, @ptrFromInt(459)));
    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    try expectEqual(array.get(0), @as(*anyopaque, @ptrFromInt(1)));
    try expectEqual(array.get(1), @as(*anyopaque, @ptrFromInt(2)));
    try expectEqual(array.get(2), @as(*anyopaque, @ptrFromInt(3)));
    try expectEqual(array.get(3), @as(*anyopaque, @ptrFromInt(4)));
    try expectEqual(array.get(4), @as(*anyopaque, @ptrFromInt(459)));
    try expectEqual(array.get(5), @as(*anyopaque, @ptrFromInt(5)));
    try expectEqual(array.get(6), @as(*anyopaque, @ptrFromInt(6)));
    try expectEqual(array.get(7), @as(*anyopaque, @ptrFromInt(7)));
    try expectEqual(array.get(8), @as(*anyopaque, @ptrFromInt(8)));
    try expectEqual(array.get(9), @as(*anyopaque, @ptrFromInt(9)));

    try expectEqual(array.length, 10);

    _ = array.destroy(false);
}

test "insert_to_end" {
    var status: lb.core.status = undefined;
    var array: lb.core.array = undefined;
    _ = array.init(9);

    try expectEqual(array.push(@as(*anyopaque, @ptrFromInt(1))), @intFromEnum(lb.core.Status.ok));
    try expectEqual(array.push(@as(*anyopaque, @ptrFromInt(2))), @intFromEnum(lb.core.Status.ok));
    try expectEqual(array.push(@as(*anyopaque, @ptrFromInt(3))), @intFromEnum(lb.core.Status.ok));
    try expectEqual(array.push(@as(*anyopaque, @ptrFromInt(4))), @intFromEnum(lb.core.Status.ok));
    try expectEqual(array.push(@as(*anyopaque, @ptrFromInt(5))), @intFromEnum(lb.core.Status.ok));
    try expectEqual(array.push(@as(*anyopaque, @ptrFromInt(6))), @intFromEnum(lb.core.Status.ok));
    try expectEqual(array.push(@as(*anyopaque, @ptrFromInt(7))), @intFromEnum(lb.core.Status.ok));
    try expectEqual(array.push(@as(*anyopaque, @ptrFromInt(8))), @intFromEnum(lb.core.Status.ok));
    try expectEqual(array.push(@as(*anyopaque, @ptrFromInt(9))), @intFromEnum(lb.core.Status.ok));

    try expectEqual(array.length, 9);
    try expectEqual(array.size, 9);

    status = array.insert(4, @as(*anyopaque, @ptrFromInt(459)));
    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    try expectEqual(array.get(0), @as(*anyopaque, @ptrFromInt(1)));
    try expectEqual(array.get(1), @as(*anyopaque, @ptrFromInt(2)));
    try expectEqual(array.get(2), @as(*anyopaque, @ptrFromInt(3)));
    try expectEqual(array.get(3), @as(*anyopaque, @ptrFromInt(4)));
    try expectEqual(array.get(4), @as(*anyopaque, @ptrFromInt(459)));
    try expectEqual(array.get(5), @as(*anyopaque, @ptrFromInt(5)));
    try expectEqual(array.get(6), @as(*anyopaque, @ptrFromInt(6)));
    try expectEqual(array.get(7), @as(*anyopaque, @ptrFromInt(7)));
    try expectEqual(array.get(8), @as(*anyopaque, @ptrFromInt(8)));
    try expectEqual(array.get(9), @as(*anyopaque, @ptrFromInt(9)));

    try expectEqual(array.length, 10);
    try expect(array.length != 9);

    _ = array.destroy(false);
}

test "delete" {
    var array: lb.core.array = undefined;
    _ = array.init(32);

    for (0..10) |i| {
        _ = array.push(@as(?*anyopaque, @ptrFromInt(i)));
    }

    try expectEqual(array.length, 10);

    array.delete(10, 100);
    try expectEqual(array.length, 10);

    array.delete(100, 1);
    try expectEqual(array.length, 10);

    array.delete(100, 0);
    try expectEqual(array.length, 10);

    for (0..10) |i| {
        try expectEqual(array.get(i), @as(?*anyopaque, @ptrFromInt(i)));
    }

    array.delete(4, 4);
    try expectEqual(array.length, 6);

    array.delete(4, 0);
    try expectEqual(array.length, 6);

    array.delete(0, 0);
    try expectEqual(array.length, 6);

    try expectEqual(array.get(0), @as(?*anyopaque, @ptrFromInt(0)));
    try expectEqual(array.get(1), @as(*anyopaque, @ptrFromInt(1)));
    try expectEqual(array.get(2), @as(*anyopaque, @ptrFromInt(2)));
    try expectEqual(array.get(3), @as(*anyopaque, @ptrFromInt(3)));
    try expectEqual(array.get(4), @as(*anyopaque, @ptrFromInt(8)));
    try expectEqual(array.get(5), @as(*anyopaque, @ptrFromInt(9)));

    array.delete(0, 1);
    try expectEqual(array.length, 5);

    try expectEqual(array.get(0), @as(*anyopaque, @ptrFromInt(1)));
    try expectEqual(array.get(1), @as(*anyopaque, @ptrFromInt(2)));
    try expectEqual(array.get(2), @as(*anyopaque, @ptrFromInt(3)));
    try expectEqual(array.get(3), @as(*anyopaque, @ptrFromInt(8)));
    try expectEqual(array.get(4), @as(*anyopaque, @ptrFromInt(9)));

    array.delete(1, 1000);
    try expectEqual(array.length, 1);

    try expectEqual(array.get(0), @as(*anyopaque, @ptrFromInt(1)));

    _ = array.destroy(false);
}

test "delete_if_empty" {
    var array: lb.core.array = undefined;
    _ = array.init(32);

    array.delete(0, 0);
    try expectEqual(array.length, 0);

    array.delete(1, 0);
    try expectEqual(array.length, 0);

    array.delete(1, 1);
    try expectEqual(array.length, 0);

    array.delete(100, 1);
    try expectEqual(array.length, 0);

    array.delete(10, 100);
    try expectEqual(array.length, 0);

    _ = array.destroy(false);
}

test "expand" {
    var array: lb.core.array = undefined;
    _ = array.init(32);

    try expect(array.expand(128) != null);
    try expectEqual(array.size, 128);

    _ = array.destroy(false);
}

test "destroy" {
    var array = lb.core.array.create().?;
    _ = array.init(32);

    try expectEqual(array.destroy(true), null);

    array = lb.core.array.create().?;
    _ = array.init(32);

    try expectEqual(array.destroy(false), array);
    try expectEqual(array.destroy(true), null);
    try expectEqual(lb.core.array.destroy(null, false), null);
}

test "destroy_stack" {
    var array: lb.core.array = undefined;
    _ = array.init(32);

    try expectEqual(array.destroy(false), &array);
}
