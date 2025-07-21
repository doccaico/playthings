const std = @import("std");
const expectEqual = std.testing.expectEqual;
const expectEqualStrings = std.testing.expectEqualStrings;

const core = @import("lexbor").core;

test "floatToData" {
    const num: f64 = 9.23;
    var buf: [16]u8 = undefined;

    const len = core.conv.floatToData(num, &buf, buf.len);

    try expectEqualStrings(buf[0..len], "9.23");
}

test "longToData" {
    const num: c_long = 923;
    var buf: [16]u8 = undefined;

    const len = core.conv.longToData(num, &buf, buf.len);

    try expectEqualStrings(buf[0..len], "923");
}

test "int64ToData" {
    const num: i64 = 923;
    var buf: [16]u8 = undefined;

    const len = core.conv.int64ToData(num, &buf, buf.len);

    try expectEqualStrings(buf[0..len], "923");
}

test "dataToDouble" {
    const data = "9.23";
    try expectEqual(core.conv.dataToDouble(data, data.len), 9.23);
}

test "dataToUlong" {
    const data = "923";
    try expectEqual(core.conv.dataToUlong(data, data.len), 923);
}

test "dataToLong" {
    const data = "923";
    try expectEqual(core.conv.dataToLong(data, data.len), 923);
}

test "dataToUint" {
    const data = "923";
    try expectEqual(core.conv.dataToUint(data, data.len), 923);
}

test "decToHex" {
    const num: u32 = 923;
    var buf: [16]u8 = undefined;

    const len = core.conv.decToHex(num, &buf, buf.len);

    try expectEqualStrings(buf[0..len], "39b");
}

test "doubleToLong" {
    const num: f64 = 9.23;
    try expectEqual(core.conv.doubleToLong(num), 9);
}
