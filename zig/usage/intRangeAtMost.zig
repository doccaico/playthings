const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });

    const rand = prng.random();

    var i: i32 = 0;
    while (i < 5) : (i += 1) {
        // In c: int val = rand() % 4
        // val = 0 .. 3
        const val = rand.intRangeAtMost(u8, 0, 4 - 1);
        try stdout.print("{d}\n", .{val});
    }
}

// #include <stdio.h>
// #include <stdlib.h>
// #include <time.h>
//
// int
// main(int argc, char** argv) {
//     (void) argc;
//     (void) argv;
//
//     srand(time(0));
//
//     for (int i = 0; i < 5; i++) {
//         int val = rand() % 4;
//         printf("%d\n", val);
//     }
//
//     return 0;
// }
