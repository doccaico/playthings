// How to build: zig build-exe main.zig -O ReleaseFast --single-threaded --strip
// 2021/03/02/: 0.8.0-dev.1371+bee7db77f

const std = @import("std");

const width = 50;
const height = 20;
// the number live cells in width
const live_cells = 20;
// for clear the screen
const clear_cmd = [_][]const u8{
    "printf", "\\33c\\e[3J\\33c",
};
// 0.1 sec
const wait: u64 = 1000000000 * 0.1;

var board: [height + 2][width + 2]u8 = undefined;

fn initBoard() !void {
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });

    var y: usize = 1;
    var x: usize = 1;
    while (y < height + 1) : (y += 1) {
        while (x < live_cells + 1) : (x += 1) {
            board[y][x] = 1;
        }
        prng.random.shuffle(u8, board[y][1..width]);
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
    _ = try cp.spawnAndWait();
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
    const child_process = try std.ChildProcess.init(&clear_cmd, std.heap.page_allocator);
    defer child_process.deinit();

    try initBoard();
    try printBoard();

    while (true) {
        try clear(child_process);
        try printBoard();
        nextGeneration();
        std.time.sleep(wait);
    }
}
