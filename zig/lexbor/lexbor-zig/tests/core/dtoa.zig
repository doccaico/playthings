const std = @import("std");
const expectEqualStrings = std.testing.expectEqualStrings;

const core = @import("lexbor").core;

test "dtoa" {
    const num: f64 = 9.23;
    var buf: [16]u8 = undefined;

    const len = core.dtoa(num, &buf, buf.len);

    try expectEqualStrings(buf[0..len], "9.23");
}
