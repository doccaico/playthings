const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

const lb = @import("lexbor");

pub const test_struct = struct {
    data: *allowzero c_char,
    len: usize,
};

test "init" {
    var array = lb.core.ArrayObj.create().?;
    const status = array.init(32, @sizeOf(test_struct));

    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    _ = array.destroy(true);
}

test "init_null" {
    const status = lb.core.ArrayObj.init(null, 32, @sizeOf(test_struct));
    try expectEqual(status, @intFromEnum(lb.core.Status.error_object_is_null));
}

test "init_stack" {
    var status: lb.core.status = undefined;
    var array: lb.core.ArrayObj = undefined;

    status = array.init(32, @sizeOf(test_struct));
    try expectEqual(status, @intFromEnum(lb.core.Status.ok));

    _ = array.destroy(false);
}

test "clean" {
    var array: lb.core.ArrayObj = undefined;
    _ = array.init(32, @sizeOf(test_struct));

    _ = array.push();
    try expectEqual(array.length, 1);

    array.clean();
    try expectEqual(array.length, 0);

    _ = array.destroy(false);
}

test "push" {
    var array: lb.core.ArrayObj = undefined;
    _ = array.init(32, @sizeOf(test_struct));

    try expectEqual(array.length, 0);

    const entry = array.push();
    try expect(entry != null);

    try expectEqual(array.length, 1);
    try expectEqual(lb.core.arrayObjGet(&array, 0), entry);

    _ = array.destroy(false);
}

test "pop" {
    var array: lb.core.ArrayObj = undefined;
    _ = array.init(32, @sizeOf(test_struct));

    const entry = array.push();
    try expect(entry != null);

    try expectEqual(array.pop(), entry);
    try expectEqual(array.length, 0);

    _ = array.destroy(false);
}

test "pop_if_empty" {
    var array: lb.core.ArrayObj = undefined;
    _ = array.init(32, @sizeOf(test_struct));

    try expectEqual(array.length, 0);
    try expectEqual(array.pop(), null);
    try expectEqual(array.length, 0);

    _ = array.destroy(false);
}

test "get" {
    var array: lb.core.ArrayObj = undefined;
    _ = array.init(32, @sizeOf(test_struct));

    try expectEqual(lb.core.arrayObjGet(&array, 1), null);
    try expectEqual(lb.core.arrayObjGet(&array, 0), null);

    const entry = array.push();
    try expect(entry != null);

    try expectEqual(lb.core.arrayObjGet(&array, 0), entry);
    try expectEqual(lb.core.arrayObjGet(&array, 1), null);
    try expectEqual(lb.core.arrayObjGet(&array, 1000), null);

    _ = array.destroy(false);
}

test "delete" {
    var entry: *test_struct = undefined;
    var array: lb.core.ArrayObj = undefined;

    _ = array.init(32, @sizeOf(test_struct));

    for (0..10) |i| {
        entry = @ptrCast(@alignCast(array.push()));
        entry.data = @ptrFromInt(i);
        entry.len = i;
    }

    try expectEqual(array.length, 10);

    array.delete(10, 100);
    try expectEqual(array.length, 10);

    array.delete(100, 1);
    try expectEqual(array.length, 10);

    array.delete(100, 0);
    try expectEqual(array.length, 10);

    for (0..10) |i| {
        entry = @ptrCast(@alignCast(lb.core.arrayObjGet(&array, i)));
        try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(i)));
        try expectEqual(entry.len, i);
    }

    array.delete(4, 4);
    try expectEqual(array.length, 6);

    array.delete(4, 0);
    try expectEqual(array.length, 6);

    array.delete(0, 0);
    try expectEqual(array.length, 6);

    entry = @ptrCast(@alignCast(lb.core.arrayObjGet(&array, 0)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(0)));
    try expectEqual(entry.len, 0);

    entry = @ptrCast(@alignCast(lb.core.arrayObjGet(&array, 1)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(1)));
    try expectEqual(entry.len, 1);

    entry = @ptrCast(@alignCast(lb.core.arrayObjGet(&array, 2)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(2)));
    try expectEqual(entry.len, 2);

    entry = @ptrCast(@alignCast(lb.core.arrayObjGet(&array, 3)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(3)));
    try expectEqual(entry.len, 3);

    entry = @ptrCast(@alignCast(lb.core.arrayObjGet(&array, 4)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(8)));
    try expectEqual(entry.len, 8);

    entry = @ptrCast(@alignCast(lb.core.arrayObjGet(&array, 5)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(9)));
    try expectEqual(entry.len, 9);

    array.delete(0, 1);
    try expectEqual(array.length, 5);

    entry = @ptrCast(@alignCast(lb.core.arrayObjGet(&array, 0)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(1)));
    try expectEqual(entry.len, 1);

    entry = @ptrCast(@alignCast(lb.core.arrayObjGet(&array, 1)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(2)));
    try expectEqual(entry.len, 2);

    entry = @ptrCast(@alignCast(lb.core.arrayObjGet(&array, 2)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(3)));
    try expectEqual(entry.len, 3);

    entry = @ptrCast(@alignCast(lb.core.arrayObjGet(&array, 3)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(8)));
    try expectEqual(entry.len, 8);

    entry = @ptrCast(@alignCast(lb.core.arrayObjGet(&array, 4)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(9)));
    try expectEqual(entry.len, 9);

    array.delete(1, 1000);
    try expectEqual(array.length, 1);

    entry = @ptrCast(@alignCast(lb.core.arrayObjGet(&array, 0)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(1)));
    try expectEqual(entry.len, 1);

    _ = array.destroy(false);
}

test "delete_if_empty" {
    var array: lb.core.ArrayObj = undefined;
    _ = array.init(32, @sizeOf(test_struct));

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
    var array: lb.core.ArrayObj = undefined;
    _ = array.init(32, @sizeOf(test_struct));

    try expect(array.expand(128) != null);
    try expectEqual(array.size, 128);

    _ = array.destroy(false);
}

test "destroy" {
    var array = lb.core.ArrayObj.create().?;
    _ = array.init(32, @sizeOf(test_struct));

    try expectEqual(array.destroy(true), null);

    array = lb.core.ArrayObj.create().?;
    _ = array.init(32, @sizeOf(test_struct));

    try expectEqual(array.destroy(false), array);
    try expectEqual(array.destroy(true), null);
    try expectEqual(lb.core.ArrayObj.destroy(null, false), null);
}

test "destroy_stack" {
    var array: lb.core.ArrayObj = undefined;
    _ = array.init(32, @sizeOf(test_struct));

    try expectEqual(lb.core.ArrayObj.destroy(&array, false), &array);
}

// adding my test cases

test "erase" {
    var array: lb.core.ArrayObj = undefined;
    _ = array.init(32, @sizeOf(test_struct));

    const e0 = array.push();
    try expectEqual(lb.core.arrayObjGet(&array, 0), e0);

    const e1 = array.push();
    try expectEqual(lb.core.arrayObjGet(&array, 1), e1);

    lb.core.arrayObjErase(&array);

    try expectEqual(lb.core.arrayObjGet(&array, 0), null);
    try expectEqual(lb.core.arrayObjGet(&array, 1), null);

    _ = array.destroy(false);
}
