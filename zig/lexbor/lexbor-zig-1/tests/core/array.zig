const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

const core = @import("lexbor").core;

test "init" {
    const array = core.array.create();
    const status = core.array.init(array, 32);

    try expectEqual(status, .ok);

    _ = core.array.destroy(array, true);
}

test "init_null" {
    const status = core.array.init(null, 32);
    try expectEqual(status, .error_object_is_null);
}

test "init_stack" {
    var array: core.Array = undefined;
    const status = core.array.init(&array, 32);

    try expectEqual(status, .ok);

    _ = core.array.destroy(&array, false);
}

test "clean" {
    var array: core.Array = undefined;
    _ = core.array.init(&array, 32);

    _ = core.array.push(&array, @as(*anyopaque, @ptrFromInt(1)));
    try expectEqual(core.array.length(&array), 1);

    core.array.clean(&array);
    try expectEqual(core.array.length(&array), 0);

    _ = core.array.destroy(&array, false);
}

test "push" {
    var array: core.Array = undefined;
    _ = core.array.init(&array, 32);

    try expectEqual(core.array.length(&array), 0);

    _ = core.array.push(&array, @as(*anyopaque, @ptrFromInt(1)));

    try expectEqual(core.array.length(&array), 1);
    try expectEqual(core.array.get(&array, 0), @as(*anyopaque, @ptrFromInt(1)));

    _ = core.array.destroy(&array, false);
}

test "push_null" {
    var array: core.Array = undefined;
    _ = core.array.init(&array, 32);

    _ = core.array.push(&array, null);

    try expectEqual(core.array.length(&array), 1);
    try expectEqual(core.array.get(&array, 0), null);

    _ = core.array.destroy(&array, false);
}

test "pop" {
    var array: core.Array = undefined;
    _ = core.array.init(&array, 32);

    _ = core.array.push(&array, @as(*anyopaque, @ptrFromInt(123)));

    try expectEqual(core.array.pop(&array), @as(*anyopaque, @ptrFromInt(123)));
    try expectEqual(core.array.length(&array), 0);

    _ = core.array.destroy(&array, false);
}

test "pop_if_empty" {
    var array: core.Array = undefined;
    _ = core.array.init(&array, 32);

    try expectEqual(core.array.length(&array), 0);
    try expectEqual(core.array.pop(&array), null);
    try expectEqual(core.array.length(&array), 0);

    _ = core.array.destroy(&array, false);
}

test "get" {
    var array: core.Array = undefined;
    _ = core.array.init(&array, 32);

    try expectEqual(core.array.get(&array, 1), null);
    try expectEqual(core.array.get(&array, 0), null);

    _ = core.array.push(&array, @as(*anyopaque, @ptrFromInt(123)));

    try expectEqual(core.array.get(&array, 0), @as(*anyopaque, @ptrFromInt(123)));
    try expectEqual(core.array.get(&array, 1), null);
    try expectEqual(core.array.get(&array, 1000), null);

    _ = core.array.destroy(&array, false);
}

test "set" {
    var array: core.Array = undefined;
    _ = core.array.init(&array, 32);

    _ = core.array.push(&array, @as(*anyopaque, @ptrFromInt(123)));

    try expectEqual(core.array.set(&array, 0, @as(*anyopaque, @ptrFromInt(456))), .ok);
    try expectEqual(core.array.get(&array, 0), @as(*anyopaque, @ptrFromInt(456)));

    try expectEqual(core.array.length(&array), 1);

    _ = core.array.destroy(&array, false);
}

test "set_not_exists" {
    var array: core.Array = undefined;
    _ = core.array.init(&array, 32);

    try expectEqual(core.array.set(&array, 10, @as(*anyopaque, @ptrFromInt(123))), .ok);
    try expectEqual(core.array.get(&array, 10), @as(*anyopaque, @ptrFromInt(123)));

    for (0..10) |i| {
        try expectEqual(core.array.get(&array, i), null);
    }

    try expectEqual(core.array.length(&array), 11);

    _ = core.array.destroy(&array, false);
}

test "insert" {
    var status: core.Status = undefined;
    var array: core.Array = undefined;
    _ = core.array.init(&array, 32);

    status = core.array.insert(&array, 0, @as(*anyopaque, @ptrFromInt(456)));
    try expectEqual(status, .ok);

    try expectEqual(core.array.get(&array, 0), @as(*anyopaque, @ptrFromInt(456)));

    try expectEqual(core.array.length(&array), 1);
    try expectEqual(core.array.size(&array), 32);

    _ = core.array.destroy(&array, false);
}

test "insert_end" {
    var status: core.Status = undefined;
    var array: core.Array = undefined;
    _ = core.array.init(&array, 32);

    status = core.array.insert(&array, 32, @as(*anyopaque, @ptrFromInt(457)));
    try expectEqual(status, .ok);

    try expectEqual(core.array.get(&array, 32), @as(*anyopaque, @ptrFromInt(457)));

    try expectEqual(core.array.length(&array), 33);
    try expect(core.array.size(&array) != 32);
    _ = core.array.destroy(&array, false);
}

test "insert_overflow" {
    var status: core.Status = undefined;
    var array: core.Array = undefined;
    _ = core.array.init(&array, 32);

    status = core.array.insert(&array, 33, @as(*anyopaque, @ptrFromInt(458)));
    try expectEqual(status, .ok);

    try expectEqual(core.array.get(&array, 33), @as(*anyopaque, @ptrFromInt(458)));

    try expectEqual(core.array.length(&array), 34);
    try expect(core.array.size(&array) != 32);

    _ = core.array.destroy(&array, false);
}

test "insert_to" {
    var status: core.Status = undefined;
    var array: core.Array = undefined;
    _ = core.array.init(&array, 32);

    try expectEqual(core.array.push(&array, @as(*anyopaque, @ptrFromInt(1))), .ok);
    try expectEqual(core.array.push(&array, @as(*anyopaque, @ptrFromInt(2))), .ok);
    try expectEqual(core.array.push(&array, @as(*anyopaque, @ptrFromInt(3))), .ok);
    try expectEqual(core.array.push(&array, @as(*anyopaque, @ptrFromInt(4))), .ok);
    try expectEqual(core.array.push(&array, @as(*anyopaque, @ptrFromInt(5))), .ok);
    try expectEqual(core.array.push(&array, @as(*anyopaque, @ptrFromInt(6))), .ok);
    try expectEqual(core.array.push(&array, @as(*anyopaque, @ptrFromInt(7))), .ok);
    try expectEqual(core.array.push(&array, @as(*anyopaque, @ptrFromInt(8))), .ok);
    try expectEqual(core.array.push(&array, @as(*anyopaque, @ptrFromInt(9))), .ok);

    status = core.array.insert(&array, 4, @as(*anyopaque, @ptrFromInt(459)));
    try expectEqual(status, .ok);

    try expectEqual(core.array.get(&array, 0), @as(*anyopaque, @ptrFromInt(1)));
    try expectEqual(core.array.get(&array, 1), @as(*anyopaque, @ptrFromInt(2)));
    try expectEqual(core.array.get(&array, 2), @as(*anyopaque, @ptrFromInt(3)));
    try expectEqual(core.array.get(&array, 3), @as(*anyopaque, @ptrFromInt(4)));
    try expectEqual(core.array.get(&array, 4), @as(*anyopaque, @ptrFromInt(459)));
    try expectEqual(core.array.get(&array, 5), @as(*anyopaque, @ptrFromInt(5)));
    try expectEqual(core.array.get(&array, 6), @as(*anyopaque, @ptrFromInt(6)));
    try expectEqual(core.array.get(&array, 7), @as(*anyopaque, @ptrFromInt(7)));
    try expectEqual(core.array.get(&array, 8), @as(*anyopaque, @ptrFromInt(8)));
    try expectEqual(core.array.get(&array, 9), @as(*anyopaque, @ptrFromInt(9)));

    try expectEqual(core.array.length(&array), 10);

    _ = core.array.destroy(&array, false);
}

test "insert_to_end" {
    var status: core.Status = undefined;
    var array: core.Array = undefined;
    _ = core.array.init(&array, 9);

    try expectEqual(core.array.push(&array, @as(*anyopaque, @ptrFromInt(1))), .ok);
    try expectEqual(core.array.push(&array, @as(*anyopaque, @ptrFromInt(2))), .ok);
    try expectEqual(core.array.push(&array, @as(*anyopaque, @ptrFromInt(3))), .ok);
    try expectEqual(core.array.push(&array, @as(*anyopaque, @ptrFromInt(4))), .ok);
    try expectEqual(core.array.push(&array, @as(*anyopaque, @ptrFromInt(5))), .ok);
    try expectEqual(core.array.push(&array, @as(*anyopaque, @ptrFromInt(6))), .ok);
    try expectEqual(core.array.push(&array, @as(*anyopaque, @ptrFromInt(7))), .ok);
    try expectEqual(core.array.push(&array, @as(*anyopaque, @ptrFromInt(8))), .ok);
    try expectEqual(core.array.push(&array, @as(*anyopaque, @ptrFromInt(9))), .ok);

    try expectEqual(core.array.length(&array), 9);
    try expectEqual(core.array.size(&array), 9);

    status = core.array.insert(&array, 4, @as(*anyopaque, @ptrFromInt(459)));
    try expectEqual(status, .ok);

    try expectEqual(core.array.get(&array, 0), @as(*anyopaque, @ptrFromInt(1)));
    try expectEqual(core.array.get(&array, 1), @as(*anyopaque, @ptrFromInt(2)));
    try expectEqual(core.array.get(&array, 2), @as(*anyopaque, @ptrFromInt(3)));
    try expectEqual(core.array.get(&array, 3), @as(*anyopaque, @ptrFromInt(4)));
    try expectEqual(core.array.get(&array, 4), @as(*anyopaque, @ptrFromInt(459)));
    try expectEqual(core.array.get(&array, 5), @as(*anyopaque, @ptrFromInt(5)));
    try expectEqual(core.array.get(&array, 6), @as(*anyopaque, @ptrFromInt(6)));
    try expectEqual(core.array.get(&array, 7), @as(*anyopaque, @ptrFromInt(7)));
    try expectEqual(core.array.get(&array, 8), @as(*anyopaque, @ptrFromInt(8)));
    try expectEqual(core.array.get(&array, 9), @as(*anyopaque, @ptrFromInt(9)));

    try expectEqual(core.array.length(&array), 10);
    try expect(core.array.length(&array) != 9);

    _ = core.array.destroy(&array, false);
}

test "delete" {
    var array: core.Array = undefined;
    _ = core.array.init(&array, 32);

    for (0..10) |i| {
        _ = core.array.push(&array, @as(?*anyopaque, @ptrFromInt(i)));
    }

    try expectEqual(core.array.length(&array), 10);

    core.array.delete(&array, 10, 100);
    try expectEqual(core.array.length(&array), 10);

    core.array.delete(&array, 100, 1);
    try expectEqual(core.array.length(&array), 10);

    core.array.delete(&array, 100, 0);
    try expectEqual(core.array.length(&array), 10);

    for (0..10) |i| {
        try expectEqual(core.array.get(&array, i), @as(?*anyopaque, @ptrFromInt(i)));
    }

    core.array.delete(&array, 4, 4);
    try expectEqual(core.array.length(&array), 6);

    core.array.delete(&array, 4, 0);
    try expectEqual(core.array.length(&array), 6);

    core.array.delete(&array, 0, 0);
    try expectEqual(core.array.length(&array), 6);

    try expectEqual(core.array.get(&array, 0), @as(?*anyopaque, @ptrFromInt(0)));
    try expectEqual(core.array.get(&array, 1), @as(*anyopaque, @ptrFromInt(1)));
    try expectEqual(core.array.get(&array, 2), @as(*anyopaque, @ptrFromInt(2)));
    try expectEqual(core.array.get(&array, 3), @as(*anyopaque, @ptrFromInt(3)));
    try expectEqual(core.array.get(&array, 4), @as(*anyopaque, @ptrFromInt(8)));
    try expectEqual(core.array.get(&array, 5), @as(*anyopaque, @ptrFromInt(9)));

    core.array.delete(&array, 0, 1);
    try expectEqual(core.array.length(&array), 5);

    try expectEqual(core.array.get(&array, 0), @as(*anyopaque, @ptrFromInt(1)));
    try expectEqual(core.array.get(&array, 1), @as(*anyopaque, @ptrFromInt(2)));
    try expectEqual(core.array.get(&array, 2), @as(*anyopaque, @ptrFromInt(3)));
    try expectEqual(core.array.get(&array, 3), @as(*anyopaque, @ptrFromInt(8)));
    try expectEqual(core.array.get(&array, 4), @as(*anyopaque, @ptrFromInt(9)));

    core.array.delete(&array, 1, 1000);
    try expectEqual(core.array.length(&array), 1);

    try expectEqual(core.array.get(&array, 0), @as(*anyopaque, @ptrFromInt(1)));

    _ = core.array.destroy(&array, false);
}

test "delete_if_empty" {
    var array: core.Array = undefined;
    _ = core.array.init(&array, 32);

    core.array.delete(&array, 0, 0);
    try expectEqual(core.array.length(&array), 0);

    core.array.delete(&array, 1, 0);
    try expectEqual(core.array.length(&array), 0);

    core.array.delete(&array, 1, 1);
    try expectEqual(core.array.length(&array), 0);

    core.array.delete(&array, 100, 1);
    try expectEqual(core.array.length(&array), 0);

    core.array.delete(&array, 10, 100);
    try expectEqual(core.array.length(&array), 0);

    _ = core.array.destroy(&array, false);
}

test "expand" {
    var array: core.Array = undefined;
    _ = core.array.init(&array, 32);

    try expect(core.array.expand(&array, 128) != null);
    try expectEqual(core.array.size(&array), 128);

    _ = core.array.destroy(&array, false);
}

test "destroy" {
    var array = core.array.create();
    _ = core.array.init(array, 32);

    try expectEqual(core.array.destroy(array, true), null);

    array = core.array.create();
    _ = core.array.init(array, 32);

    try expectEqual(core.array.destroy(array, false), array);
    try expectEqual(core.array.destroy(array, true), null);
    try expectEqual(core.array.destroy(null, false), null);
}

test "destroy_stack" {
    var array: core.Array = undefined;
    _ = core.array.init(&array, 32);

    try expectEqual(core.array.destroy(&array, false), &array);
}
