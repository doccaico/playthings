const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const zeroInit = std.mem.zeroInit;

const lb = @import("lexbor");

fn testMakeMraw(mraw: ?*?*lb.core.Mraw) !void {
    mraw.?.* = lb.core.Mraw.create();
    try expectEqual(lb.core.Mraw.init(mraw.?.*, 1024), @intFromEnum(lb.core.Status.ok));
}

fn testDestroyMraw(mraw: ?*?*lb.core.Mraw) void {
    mraw.?.* = lb.core.Mraw.destroy(mraw.?.*, true);
}

test "init" {
    var mraw: ?*lb.core.Mraw = undefined;
    try testMakeMraw(&mraw);

    var str = lb.core.Str.create().?;
    const value = str.init(mraw, 128);

    expect(value != null);

    _ = str.destroy(mraw, true);
    testDestroyMraw(&mraw);
}

// test "init_null" {
//     const status = lb.core.Mraw.init(null, 1024);
//     try expectEqual(status, @intFromEnum(lb.core.Status.error_object_is_null));
// }
//
// test "init_stack" {
//     var mraw: lb.core.Mraw = undefined;
//     const status = mraw.init(1024);
//
//     try expectEqual(status, @intFromEnum(lb.core.Status.ok));
//
//     _ = mraw.destroy(false);
// }
//
// test "init_args" {
//     var mraw = zeroInit(lb.core.Mraw, .{});
//     var status: lb.core.status = undefined;
//
//     status = mraw.init(0);
//     try expectEqual(status, @intFromEnum(lb.core.Status.error_wrong_args));
//
//     _ = mraw.destroy(false);
// }
