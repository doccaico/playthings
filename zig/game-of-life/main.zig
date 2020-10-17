// How to build: zig build-exe -O ReleaseFast --strip main.zig
// 2021/07/06: 0.10.0-dev.2849+93ac87c1b

const std = @import("std");

const width = 60;
const height = 30;
// the number live cells in width
const live_cells = 20;
// for clear the screen
const clear_cmd = [_][]const u8{
    "printf", "\\33c\\e[3J\\33c",
};
// 0.07 sec
const wait: u64 = 1000000000 * 0.07;

var board: [height + 2][width + 2]u8 = undefined;

fn initBoard() !void {
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });

    const random = prng.random();

    var y: usize = 1;
    var x: usize = 1;
    while (y < height + 1) : (y += 1) {
        while (x < live_cells + 1) : (x += 1) {
            board[y][x] = 1;
        }
        random.shuffle(u8, board[y][1..width]);
        x = 1;
    }
}

fn printBoard() !void {
    const stdout = std.io.getStdOut().writer();

    var ch: u8 = undefined;
    var y: usize = 1;
    var x: usize = 1;
    while (y < height + 1) : (y += 1) {
        while (x < width + 1) : (x += 1) {
            ch = if (board[y][x] == 1) '*' else ' ';
            try stdout.writeByte(ch);
        }
        try stdout.writeByte('\n');
        x = 1;
    }
}

fn clear(cp: *std.ChildProcess) !void {
    try cp.spawn();
    _ = try cp.wait();
}

fn nextGeneration() void {
    var neighbors: [height + 2][width + 2]u8 = undefined;

    var y: usize = 1;
    var x: usize = 1;
    while (y < height + 1) : (y += 1) {
        while (x < width + 1) : (x += 1) {
            neighbors[y][x] = countNeighbors(y, x);
        }
        x = 1;
    }

    x = 1;
    y = 1;
    while (y < height + 1) : (y += 1) {
        while (x < width + 1) : (x += 1) {
            switch (neighbors[y][x]) {
                2 => {},
                3 => board[y][x] = 1,
                else => board[y][x] = 0,
            }
        }
        x = 1;
    }
}

fn countNeighbors(y: u64, x: u64) callconv(.Inline) u8 {
    // top-left
    return board[y - 1][x - 1] +
        // top-middle
        board[y - 1][x] +
        // top-right
        board[y - 1][x + 1] +
        // left
        board[y][x - 1] +
        // right
        board[y][x + 1] +
        // bottom-left
        board[y + 1][x - 1] +
        // bottom-middle
        board[y + 1][x] +
        // bottom-right
        board[y + 1][x + 1];
}

pub fn main() !void {
    var child_process = std.ChildProcess.init(&clear_cmd, std.heap.page_allocator);

    try initBoard();
    try printBoard();

    while (true) {
        try clear(&child_process);
        try printBoard();
        nextGeneration();
        std.time.sleep(wait);
    }
}
