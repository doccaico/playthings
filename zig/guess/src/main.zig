const std = @import("std");

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();
    const secret_number = rand.intRangeAtMost(u8, 1, 100);

    try stdout.print("Guess the number!\n", .{});
    // try stdout.print("The secret number is: {}\n", .{secret_number});

    var buffer: [32]u8 = undefined;
    while (true) {
        try stdout.print("Please input your guess.\n", .{});

        if (try stdin.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
            const guess: i32 = std.fmt.parseInt(i32, std.mem.trim(u8, line, " "), 10) catch |err| {
                switch (err) {
                    error.Overflow => {
                        try stdout.writeAll("Please enter a small positive number.\n");
                        continue;
                    },
                    error.InvalidCharacter => {
                        try stdout.writeAll("Please enter a valid number.\n");
                        continue;
                    },
                }
            };
            try stdout.print("You guessed: {}\n", .{guess});

            if (guess < secret_number) {
                try stdout.writeAll("Too Small!\n");
            } else if (guess > secret_number) {
                try stdout.writeAll("Too Big!\n");
            } else {
                try stdout.writeAll("You win!\n");
                break;
            }
        } else {
            break;
        }
    }
}
