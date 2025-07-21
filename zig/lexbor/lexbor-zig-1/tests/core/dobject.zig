const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const zeroInit = std.mem.zeroInit;

const core = @import("lexbor").core;

pub const TestData = struct {
    a: usize,
    b: c_char,
    c: c_int,
};

test "init" {
    const dobj = core.dobject.create();
    const status = core.dobject.init(dobj, 128, @sizeOf(TestData));

    try expectEqual(status, .ok);

    _ = core.dobject.destroy(dobj, true);
}

test "init_stack" {
    var dobj: core.Dobject = undefined;
    const status = core.dobject.init(&dobj, 128, @sizeOf(TestData));

    try expectEqual(status, .ok);

    _ = core.dobject.destroy(&dobj, false);
}

test "init_args" {
    var dobj = zeroInit(core.Dobject, .{});
    var status: core.Status = undefined;

    status = core.dobject.init(&dobj, 0, @sizeOf(TestData));
    try expectEqual(status, .error_wrong_args);

    status = core.dobject.init(&dobj, 128, 0);
    try expectEqual(status, .error_wrong_args);

    status = core.dobject.init(&dobj, 0, 0);
    try expectEqual(status, .error_wrong_args);

    _ = core.dobject.destroy(&dobj, false);
}

test "obj_alloc" {
    var dobj: core.Dobject = undefined;
    _ = core.dobject.init(&dobj, 128, @sizeOf(TestData));

    const data = core.dobject.alloc(&dobj);

    try expect(data != null);
    try expectEqual(dobj.allocated, 1);

    _ = core.dobject.destroy(&dobj, false);
}

test "obj_calloc" {
    var dobj: core.Dobject = undefined;
    _ = core.dobject.init(&dobj, 128, @sizeOf(TestData));

    const data = core.dobject.calloc(&dobj);

    try expectEqual(@as(*TestData, @ptrCast(@alignCast(data.?))).a, 0);
    try expectEqual(@as(*TestData, @ptrCast(@alignCast(data.?))).b, 0x00);
    try expectEqual(@as(*TestData, @ptrCast(@alignCast(data.?))).c, 0);

    _ = core.dobject.destroy(&dobj, false);
}

test "obj_mem_chunk" {
    const count: usize = 128;

    var dobj: core.Dobject = undefined;
    _ = core.dobject.init(&dobj, count, @sizeOf(TestData));

    for (0..count) |_| {
        _ = core.dobject.alloc(&dobj);
    }

    try expectEqual(dobj.mem.?.chunk_length, 1);

    _ = core.dobject.destroy(&dobj, false);
}

test "obj_alloc_free_alloc" {
    var dobj: core.Dobject = undefined;
    _ = core.dobject.init(&dobj, 128, @sizeOf(TestData));

    var data = core.dobject.alloc(&dobj);

    @as(*TestData, @ptrCast(@alignCast(data.?))).a = 159753;
    @as(*TestData, @ptrCast(@alignCast(data.?))).b = 'L';
    @as(*TestData, @ptrCast(@alignCast(data.?))).c = 12;

    _ = core.dobject.free(&dobj, data);

    try expectEqual(dobj.allocated, 0);
    try expectEqual(core.dobject.cacheLength(&dobj), 1);

    data = core.dobject.alloc(&dobj);

    try expectEqual(@as(*TestData, @ptrCast(@alignCast(data.?))).a, 159753);
    try expectEqual(@as(*TestData, @ptrCast(@alignCast(data.?))).b, 'L');
    try expectEqual(@as(*TestData, @ptrCast(@alignCast(data.?))).c, 12);

    _ = core.dobject.destroy(&dobj, false);
}

test "obj_cache" {
    var dobj: core.Dobject = undefined;

    var data: [100]TestData = undefined;

    const data_size = data.len;

    _ = core.dobject.init(&dobj, 128, @sizeOf(TestData));

    for (0..data_size) |i| {
        data[i] = @as(*TestData, @ptrCast(@alignCast(core.dobject.alloc(&dobj).?))).*;
        try expectEqual(dobj.allocated, i + 1);
    }

    for (0..data_size) |i| {
        _ = core.dobject.free(&dobj, &data[i]);
        try expectEqual(core.dobject.cacheLength(&dobj), i + 1);
    }

    try expectEqual(dobj.allocated, 0);
    try expectEqual(core.dobject.cacheLength(&dobj), 100);

    _ = core.dobject.destroy(&dobj, false);
}

test "absolute_position" {
    var data: *TestData = undefined;
    var dobj: core.Dobject = undefined;

    _ = core.dobject.init(&dobj, 128, @sizeOf(TestData));

    for (0..100) |i| {
        data = @as(*TestData, @ptrCast(@alignCast(core.dobject.alloc(&dobj).?)));

        data.a = i;
        data.b = @intCast(i);
        data.c = @intCast(i + 5);
    }

    data = @as(*TestData, @ptrCast(@alignCast(core.dobject.byAbsolutePosition(&dobj, 34).?)));

    try expectEqual(data.a, 34);
    try expectEqual(data.b, 34);
    try expectEqual(data.c, 39);

    _ = core.dobject.destroy(&dobj, false);
}

test "absolute_position_up" {
    var data: *TestData = undefined;
    var dobj: core.Dobject = undefined;

    _ = core.dobject.init(&dobj, 27, @sizeOf(TestData));

    for (0..213) |i| {
        data = @as(*TestData, @ptrCast(@alignCast(core.dobject.alloc(&dobj).?)));

        data.a = i;
        data.b = @truncate(@as(c_int, @intCast(i)));
        data.c = @intCast(i + 5);
    }

    data = @as(*TestData, @ptrCast(@alignCast(core.dobject.byAbsolutePosition(&dobj, 121).?)));

    try expectEqual(data.a, 121);
    try expectEqual(data.b, 121);
    try expectEqual(data.c, 126);

    _ = core.dobject.destroy(&dobj, false);
}

test "absolute_position_edge" {
    var data: *TestData = undefined;
    var dobj: core.Dobject = undefined;

    _ = core.dobject.init(&dobj, 128, @sizeOf(TestData));

    for (0..256) |i| {
        data = @as(*TestData, @ptrCast(@alignCast(core.dobject.alloc(&dobj).?)));

        data.a = i;
        data.b = @truncate(@as(c_int, @intCast(i)));
        data.c = @intCast(i + 5);
    }

    data = @as(*TestData, @ptrCast(@alignCast(core.dobject.byAbsolutePosition(&dobj, 128).?)));

    try expectEqual(data.a, 128);
    try expectEqual(data.b, @as(c_char, @truncate(@as(c_int, @intCast(128)))));
    try expectEqual(data.c, 133);

    _ = core.dobject.destroy(&dobj, false);
}

test "obj_free" {
    var dobj: core.Dobject = undefined;
    _ = core.dobject.init(&dobj, 128, @sizeOf(TestData));

    const data = @as(?*TestData, @ptrCast(@alignCast(core.dobject.alloc(&dobj).?)));
    _ = core.dobject.free(&dobj, data);

    try expectEqual(dobj.allocated, 0);
    try expectEqual(core.dobject.cacheLength(&dobj), 1);

    _ = core.dobject.destroy(&dobj, false);
}

test "clean" {
    var dobj: core.Dobject = undefined;
    _ = core.dobject.init(&dobj, 128, @sizeOf(TestData));

    const data = @as(?*TestData, @ptrCast(@alignCast(core.dobject.alloc(&dobj).?)));
    try expect(data != null);

    core.dobject.clean(&dobj);
    try expectEqual(dobj.allocated, 0);
    try expectEqual(core.dobject.cacheLength(&dobj), 0);

    _ = core.dobject.destroy(&dobj, false);
}

test "destroy" {
    var dobj = core.dobject.create();
    _ = core.dobject.init(dobj, 128, @sizeOf(TestData));

    try expectEqual(core.dobject.destroy(dobj, true), null);

    dobj = core.dobject.create();
    _ = core.dobject.init(dobj, 128, @sizeOf(TestData));

    try expectEqual(core.dobject.destroy(dobj, false), dobj);
    try expectEqual(core.dobject.destroy(dobj, true), null);
    try expectEqual(core.dobject.destroy(null, false), null);
}

test "destroy_stack" {
    const dobj = core.dobject.create();
    _ = core.dobject.init(dobj, 128, @sizeOf(TestData));

    try expectEqual(core.dobject.destroy(dobj, false), dobj);
}
