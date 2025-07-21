const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

const core = @import("lexbor").core;

pub const testStruct = struct {
    data: *allowzero c_char,
    len: usize,
};

test "init" {
    const array = core.array_obj.create();
    const status = core.array_obj.init(array, 32, @sizeOf(testStruct));

    try expectEqual(status, .ok);

    _ = core.array_obj.destroy(array, true);
}

test "init_null" {
    const status = core.array_obj.init(null, 32, @sizeOf(testStruct));
    try expectEqual(status, .error_object_is_null);
}

test "init_stack" {
    var status: core.Status = undefined;
    var array: core.ArrayObj = undefined;

    status = core.array_obj.init(&array, 32, @sizeOf(testStruct));
    try expectEqual(status, .ok);

    _ = core.array_obj.destroy(&array, false);
}

test "clean" {
    var array: core.ArrayObj = undefined;
    _ = core.array_obj.init(&array, 32, @sizeOf(testStruct));

    _ = core.array_obj.push(&array);
    try expectEqual(core.array_obj.length(&array), 1);

    core.array_obj.clean(&array);
    try expectEqual(core.array_obj.length(&array), 0);

    _ = core.array_obj.destroy(&array, false);
}

test "push" {
    var array: core.ArrayObj = undefined;
    _ = core.array_obj.init(&array, 32, @sizeOf(testStruct));

    try expectEqual(core.array_obj.length(&array), 0);

    const entry = core.array_obj.push(&array);
    try expect(entry != null);

    try expectEqual(core.array_obj.length(&array), 1);
    try expectEqual(core.array_obj.get(&array, 0), entry);

    _ = core.array_obj.destroy(&array, false);
}

test "pop" {
    var array: core.ArrayObj = undefined;
    _ = core.array_obj.init(&array, 32, @sizeOf(testStruct));

    const entry = core.array_obj.push(&array);
    try expect(entry != null);

    try expectEqual(core.array_obj.pop(&array), entry);
    try expectEqual(core.array_obj.length(&array), 0);

    _ = core.array_obj.destroy(&array, false);
}

test "pop_if_empty" {
    var array: core.ArrayObj = undefined;
    _ = core.array_obj.init(&array, 32, @sizeOf(testStruct));

    try expectEqual(core.array_obj.length(&array), 0);
    try expectEqual(core.array_obj.pop(&array), null);
    try expectEqual(core.array_obj.length(&array), 0);

    _ = core.array_obj.destroy(&array, false);
}

test "get" {
    var array: core.ArrayObj = undefined;
    _ = core.array_obj.init(&array, 32, @sizeOf(testStruct));

    try expectEqual(core.array_obj.get(&array, 1), null);
    try expectEqual(core.array_obj.get(&array, 0), null);

    const entry = core.array_obj.push(&array);
    try expect(entry != null);

    try expectEqual(core.array_obj.get(&array, 0), entry);
    try expectEqual(core.array_obj.get(&array, 1), null);
    try expectEqual(core.array_obj.get(&array, 1000), null);

    _ = core.array_obj.destroy(&array, false);
}

test "delete" {
    var entry: *testStruct = undefined;
    var array: core.ArrayObj = undefined;

    _ = core.array_obj.init(&array, 32, @sizeOf(testStruct));

    for (0..10) |i| {
        entry = @ptrCast(@alignCast(core.array_obj.push(&array)));
        entry.data = @ptrFromInt(i);
        entry.len = i;
    }

    try expectEqual(core.array_obj.length(&array), 10);

    core.array_obj.delete(&array, 10, 100);
    try expectEqual(core.array_obj.length(&array), 10);

    core.array_obj.delete(&array, 100, 1);
    try expectEqual(core.array_obj.length(&array), 10);

    core.array_obj.delete(&array, 100, 0);
    try expectEqual(core.array_obj.length(&array), 10);

    for (0..10) |i| {
        entry = @ptrCast(@alignCast(core.array_obj.get(&array, i)));
        try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(i)));
        try expectEqual(entry.len, i);
    }

    core.array_obj.delete(&array, 4, 4);
    try expectEqual(core.array_obj.length(&array), 6);

    core.array_obj.delete(&array, 4, 0);
    try expectEqual(core.array_obj.length(&array), 6);

    core.array_obj.delete(&array, 0, 0);
    try expectEqual(core.array_obj.length(&array), 6);

    entry = @ptrCast(@alignCast(core.array_obj.get(&array, 0)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(0)));
    try expectEqual(entry.len, 0);

    entry = @ptrCast(@alignCast(core.array_obj.get(&array, 1)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(1)));
    try expectEqual(entry.len, 1);

    entry = @ptrCast(@alignCast(core.array_obj.get(&array, 2)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(2)));
    try expectEqual(entry.len, 2);

    entry = @ptrCast(@alignCast(core.array_obj.get(&array, 3)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(3)));
    try expectEqual(entry.len, 3);

    entry = @ptrCast(@alignCast(core.array_obj.get(&array, 4)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(8)));
    try expectEqual(entry.len, 8);

    entry = @ptrCast(@alignCast(core.array_obj.get(&array, 5)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(9)));
    try expectEqual(entry.len, 9);

    core.array_obj.delete(&array, 0, 1);
    try expectEqual(core.array_obj.length(&array), 5);

    entry = @ptrCast(@alignCast(core.array_obj.get(&array, 0)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(1)));
    try expectEqual(entry.len, 1);

    entry = @ptrCast(@alignCast(core.array_obj.get(&array, 1)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(2)));
    try expectEqual(entry.len, 2);

    entry = @ptrCast(@alignCast(core.array_obj.get(&array, 2)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(3)));
    try expectEqual(entry.len, 3);

    entry = @ptrCast(@alignCast(core.array_obj.get(&array, 3)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(8)));
    try expectEqual(entry.len, 8);

    entry = @ptrCast(@alignCast(core.array_obj.get(&array, 4)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(9)));
    try expectEqual(entry.len, 9);

    core.array_obj.delete(&array, 1, 1000);
    try expectEqual(core.array_obj.length(&array), 1);

    entry = @ptrCast(@alignCast(core.array_obj.get(&array, 0)));
    try expectEqual(entry.data, @as(*allowzero c_char, @ptrFromInt(1)));
    try expectEqual(entry.len, 1);

    _ = core.array_obj.destroy(&array, false);
}

test "delete_if_empty" {
    var array: core.ArrayObj = undefined;
    _ = core.array_obj.init(&array, 32, @sizeOf(testStruct));

    core.array_obj.delete(&array, 0, 0);
    try expectEqual(core.array_obj.length(&array), 0);

    core.array_obj.delete(&array, 1, 0);
    try expectEqual(core.array_obj.length(&array), 0);

    core.array_obj.delete(&array, 1, 1);
    try expectEqual(core.array_obj.length(&array), 0);

    core.array_obj.delete(&array, 100, 1);
    try expectEqual(core.array_obj.length(&array), 0);

    core.array_obj.delete(&array, 10, 100);
    try expectEqual(core.array_obj.length(&array), 0);

    _ = core.array_obj.destroy(&array, false);
}

test "expand" {
    var array: core.ArrayObj = undefined;
    _ = core.array_obj.init(&array, 32, @sizeOf(testStruct));

    try expect(core.array_obj.expand(&array, 128) != null);
    try expectEqual(core.array_obj.size(&array), 128);

    _ = core.array_obj.destroy(&array, false);
}

test "destroy" {
    var array = core.array_obj.create();
    _ = core.array_obj.init(array, 32, @sizeOf(testStruct));

    try expectEqual(core.array_obj.destroy(array, true), null);

    array = core.array_obj.create();
    _ = core.array_obj.init(array, 32, @sizeOf(testStruct));

    try expectEqual(core.array_obj.destroy(array, false), array);
    try expectEqual(core.array_obj.destroy(array, true), null);
    try expectEqual(core.array_obj.destroy(null, false), null);
}

test "destroy_stack" {
    var array: core.ArrayObj = undefined;
    _ = core.array_obj.init(&array, 32, @sizeOf(testStruct));

    try expectEqual(core.array_obj.destroy(&array, false), &array);
}

// adding my test cases

test "erase" {
    var array: core.ArrayObj = undefined;
    _ = core.array_obj.init(&array, 32, @sizeOf(testStruct));

    const e0 = core.array_obj.push(
        &array,
    );
    try expectEqual(core.array_obj.get(&array, 0), e0);

    const e1 = core.array_obj.push(&array);
    try expectEqual(core.array_obj.get(&array, 1), e1);

    core.array_obj.erase(&array);

    try expectEqual(core.array_obj.get(&array, 0), null);
    try expectEqual(core.array_obj.get(&array, 1), null);

    _ = core.array_obj.destroy(&array, false);
}
