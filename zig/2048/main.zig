const std = @import("std");
const c = @import("c.zig");

const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

const help =
    \\ArrowKey(Top, Down, Right, Left)
    \\Exit(Ctrl+c, q)
;

const wait = 200000;

const Key = enum {
    up,
    down,
    right,
    left,
};

var isMoved: bool = false;
var score: u32 = 0;
var rand: *std.rand.Random = undefined;
var board: [4][4]u32 = [_][4]u32{
    [_]u32{ 0, 0, 0, 0 },
    [_]u32{ 0, 0, 0, 0 },
    [_]u32{ 0, 0, 0, 0 },
    [_]u32{ 0, 0, 0, 0 },
};

fn printBoard() !void {
    try stdout.print("---------------------\n", .{});
    for (board) |row| {
        for (row) |n| {
            if (n != 0) {
                try stdout.print("|{:4}", .{n});
            } else {
                try stdout.print("|{s}", .{"    "});
            }
        }
        try stdout.print("|\n---------------------\n", .{});
    }
}

inline fn isSpace(pos: u8) bool {
    return board[pos / 4][pos % 4] == 0;
}

fn getSpacePos() u8 {
    while (true) {
        const pos = rand.intRangeAtMost(u8, 0, 15);
        if (isSpace(pos)) return pos;
    }
}

fn putNumber(n: u32) void {
    const boardPos = getSpacePos();
    const y = boardPos / 4;
    const x = boardPos % 4;
    board[y][x] = n;
}

fn toMerge(row: []u32) void {
    var i: usize = 0;
    while (i < 3) : (i += 1) {
        var j: usize = i + 1;
        inner: while (j < 4) : (j += 1) {
            if (row[j] != 0 and row[i] != row[j]) {
                break :inner;
            }
            if (row[i] == row[j]) {
                row[i] = row[i] * 2;
                score += row[i];
                row[j] = 0;
                break :inner;
            }
        }
    }
}

fn toLeft(row: []u32) void {
    var tmp = [_]u32{ 0, 0, 0, 0 };
    var zeroIndex: usize = 0;
    var i: usize = 0;
    while (i < 4) : (i += 1) {
        if (row[i] != 0) {
            tmp[zeroIndex] = row[i];
            zeroIndex += 1;
        }
    }

    std.mem.copy(u32, row, &tmp);
}

fn slide() void {
    var tmp = [_]u32{ 0, 0, 0, 0 };
    var i: usize = 0;
    while (i < 4) : (i += 1) {
        std.mem.copy(u32, &tmp, &board[i]);
        toMerge(&board[i]);
        toLeft(&board[i]);
        if (!std.mem.eql(u32, &tmp, &board[i])) {
            isMoved = true;
        }
    }
}

fn rotate() void {
    var n: usize = 4;
    var tmp: u32 = undefined;

    var i: usize = 0;
    while (i < n / 2) : (i += 1) {
        var j: usize = i;
        while (j < n - i - 1) : (j += 1) {
            tmp = board[i][j];
            board[i][j] = board[j][n - i - 1];
            board[j][n - i - 1] = board[n - i - 1][n - j - 1];
            board[n - i - 1][n - j - 1] = board[n - j - 1][i];
            board[n - j - 1][i] = tmp;
        }
    }
}

fn pressed(key: Key) void {
    switch (key) {
        .up => {
            rotate();
            slide();
            rotate();
            rotate();
            rotate();
        },
        .down => {
            rotate();
            rotate();
            rotate();
            slide();
            rotate();
        },
        .right => {
            rotate();
            rotate();
            slide();
            rotate();
            rotate();
        },
        .left => {
            slide();
        },
    }
}

fn spaceExists() bool {
    for (board) |row| {
        for (row) |n| {
            if (n == 0) return true;
        }
    }
    return false;
}

fn isGameFinished() bool {
    for (board) |row| {
        for (row) |n| {
            if (n == 2048) return true;
        }
    }
    return false;
}

fn isGameOver() !bool {
    var i: usize = 0;
    var gameover: bool = true;
    var skip: bool = false;
    while (i < 4) : (i += 1) {
        var j: usize = 0;
        if (!skip) {
            for (board) |row| {
                while (j < 3) : (j += 1) {
                    if (row[j] == row[j + 1]) {
                        gameover = false;
                        skip = true;
                    }
                }
            }
        }
        rotate();
    }
    try stdout.print("gameover: {any}\n", .{gameover});
    return gameover;
}

pub fn main() !void {
    var oldt: c.termios = undefined;
    var newt: c.termios = undefined;

    _ = c.tcgetattr(c.STDIN_FILENO, &oldt);
    newt = oldt;
    newt.c_lflag &= ~(@as(c_uint, c.ICANON) | @as(c_uint, c.ECHO));
    _ = c.tcsetattr(c.STDIN_FILENO, c.TCSANOW, &newt);

    // game init
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    rand = &prng.random();

    // set first two values (2 or 4)
    const two_four = [_]u8{ 2, 4 };
    putNumber(two_four[rand.intRangeAtMost(u8, 0, 1)]);
    putNumber(two_four[rand.intRangeAtMost(u8, 0, 1)]);

    // display how to play
    try stdout.print("{s}\n\n", .{help});
    try printBoard();

    mainLoop: while (true) {
        const ch1 = try stdin.readByte();
        if (ch1 == 'q') break;
        if (ch1 == 27) {
            const ch2 = try stdin.readByte();
            if (ch2 == 91) {
                const ch3 = try stdin.readByte();
                switch (ch3) {
                    65 => pressed(Key.up),
                    66 => pressed(Key.down),
                    67 => pressed(Key.right),
                    68 => pressed(Key.left),
                    else => {},
                }
            }
        }
        if (isMoved) {
            try printBoard();
            _ = c.usleep(wait);
            putNumber(2);
            try printBoard();
            try stdout.print("score: {d}\n", .{score});
            isMoved = false;
        }
        if (isGameFinished()) {
            try stdout.print("You Win.\n", .{});
            break :mainLoop;
        }
        if (!spaceExists() and try isGameOver()) {
            try stdout.print("You Lose.\n", .{});
            break :mainLoop;
        }
    }
    _ = c.tcsetattr(c.STDIN_FILENO, c.TCSANOW, &oldt);
}

test "toMerge" {
    const eql = std.mem.eql;
    const expect = std.testing.expect;

    var arr: [4]u32 = undefined;

    arr = [_]u32{ 0, 2, 0, 4 };
    toMerge(&arr);
    try expect(eql(u32, &arr, &[_]u32{ 0, 2, 0, 4 }));

    arr = [_]u32{ 2, 2, 4, 4 };
    toMerge(&arr);
    try expect(eql(u32, &arr, &[_]u32{ 4, 0, 8, 0 }));

    arr = [_]u32{ 8, 0, 2, 2 };
    toMerge(&arr);
    try expect(eql(u32, &arr, &[_]u32{ 8, 0, 4, 0 }));

    arr = [_]u32{ 2, 2, 2, 2 };
    toMerge(&arr);
    try expect(eql(u32, &arr, &[_]u32{ 4, 0, 4, 0 }));

    arr = [_]u32{ 4, 2, 0, 2 };
    toMerge(&arr);
    try expect(eql(u32, &arr, &[_]u32{ 4, 4, 0, 0 }));

    arr = [_]u32{ 2, 4, 2, 0 };
    toMerge(&arr);
    try expect(eql(u32, &arr, &[_]u32{ 2, 4, 2, 0 }));

    arr = [_]u32{ 2, 2, 16, 2 };
    toMerge(&arr);
    try expect(eql(u32, &arr, &[_]u32{ 4, 0, 16, 2 }));
}

test "toLeft" {
    const eql = std.mem.eql;
    const expect = std.testing.expect;

    var arr: [4]u32 = undefined;

    arr = [_]u32{ 0, 2, 0, 4 };
    toMerge(&arr);
    toLeft(&arr);
    try expect(eql(u32, &arr, &[_]u32{ 2, 4, 0, 0 }));

    arr = [_]u32{ 2, 2, 4, 4 };
    toMerge(&arr);
    toLeft(&arr);
    try expect(eql(u32, &arr, &[_]u32{ 4, 8, 0, 0 }));

    arr = [_]u32{ 8, 0, 2, 2 };
    toMerge(&arr);
    toLeft(&arr);
    try expect(eql(u32, &arr, &[_]u32{ 8, 4, 0, 0 }));

    arr = [_]u32{ 2, 2, 2, 2 };
    toMerge(&arr);
    toLeft(&arr);
    try expect(eql(u32, &arr, &[_]u32{ 4, 4, 0, 0 }));

    arr = [_]u32{ 4, 2, 0, 2 };
    toMerge(&arr);
    toLeft(&arr);
    try expect(eql(u32, &arr, &[_]u32{ 4, 4, 0, 0 }));

    arr = [_]u32{ 2, 4, 2, 0 };
    toMerge(&arr);
    toLeft(&arr);
    try expect(eql(u32, &arr, &[_]u32{ 2, 4, 2, 0 }));

    arr = [_]u32{ 2, 2, 16, 2 };
    toMerge(&arr);
    toLeft(&arr);
    try expect(eql(u32, &arr, &[_]u32{ 4, 16, 2, 0 }));
}
