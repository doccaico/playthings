// Build: zig build-exe -O ReleaseFast --strip src/main.zig
// Run: zig build run -- -w 70 -h 40 -m "*" -s 0.07 -c 25
// Version: 0.10.0-dev.3475+b3d463c9e
// Date: 2022/08/09

const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const os = std.os;

const Cgol = struct {
    gpa: *std.mem.Allocator,
    board: [][]u8,
    subboard: [][]u8,
    width: u32,
    height: u32,
    mark: u8,
    sleep: u64,
    cells: u32,
    child_process: std.ChildProcess,
    buf: []u8,

    const clear_cmd = [_][]const u8{
        "printf", "\\33c\\e[3J\\33c",
    };

    fn init(gpa: *std.mem.Allocator, width: u32, height: u32, mark: u8, sleep: f64, cells: u32) !Cgol {
        var child_process = std.ChildProcess.init(&clear_cmd, gpa.*);

        var board = try gpa.alloc([]u8, height + 2);
        for (board) |*col| {
            col.* = try gpa.alloc(u8, width + 2);
            // zero clear
            for (col.*) |*v| {
                v.* = 0;
            }
        }

        var subboard = try gpa.alloc([]u8, height + 2);
        for (subboard) |*col| {
            col.* = try gpa.alloc(u8, width + 2);
        }

        // plus newlines('\n')
        var buf = try gpa.alloc(u8, height * width + height);

        return Cgol{
            .board = board,
            .subboard = subboard,
            .gpa = gpa,
            .width = width,
            .height = height,
            .mark = mark,
            .sleep = @floatToInt(u64, 1_000_000_000 * sleep),
            .cells = cells,
            .child_process = child_process,
            .buf = buf,
        };
    }

    fn deinit(self: *Cgol) void {
        for (self.board) |*col| {
            self.gpa.free(col.*);
        }
        self.gpa.free(self.board);

        for (self.subboard) |*col| {
            self.gpa.free(col.*);
        }
        self.gpa.free(self.subboard);

        self.gpa.free(self.buf);
    }

    fn initBoard(self: *Cgol) !void {
        var prng = std.rand.DefaultPrng.init(blk: {
            var seed: u64 = undefined;
            try os.getrandom(std.mem.asBytes(&seed));
            break :blk seed;
        });

        const random = prng.random();

        var y: usize = 1;
        var x: usize = 1;
        while (y < self.height + 1) : (y += 1) {
            while (x < self.cells + 1) : (x += 1) {
                self.board[y][x] = 1;
            }
            random.shuffle(u8, self.board[y][1..self.width]);
            x = 1;
        }
    }

    fn printBoard(self: *Cgol) !void {
        const stdout = std.io.getStdOut().writer();

        var mark: u8 = undefined;
        var y: usize = 1;
        var x: usize = 1;
        var i: usize = 0;

        while (y < self.height + 1) : (y += 1) {
            while (x < self.width + 1) : (x += 1) {
                mark = if (self.board[y][x] == 1) self.mark else ' ';
                self.buf[i] = mark;
                i += 1;
            }
            self.buf[i] = '\n';
            i += 1;
            x = 1;
        }
        try stdout.writeAll(self.buf);
    }

    fn clear(self: *Cgol) !void {
        _ = try self.child_process.spawnAndWait();
    }

    fn wait(self: *Cgol) void {
        std.time.sleep(self.sleep);
    }

    fn nextGeneration(self: *Cgol) void {
        var y: usize = 1;
        var x: usize = 1;
        while (y < self.height + 1) : (y += 1) {
            while (x < self.width + 1) : (x += 1) {
                self.subboard[y][x] = self.countNeighbors(y, x);
            }
            x = 1;
        }

        x = 1;
        y = 1;
        while (y < self.height + 1) : (y += 1) {
            while (x < self.width + 1) : (x += 1) {
                switch (self.subboard[y][x]) {
                    2 => {},
                    3 => self.board[y][x] = 1,
                    else => self.board[y][x] = 0,
                }
            }
            x = 1;
        }
    }

    fn countNeighbors(self: *Cgol, y: usize, x: usize) u8 {
        // top-left
        return self.board[y - 1][x - 1] +
            // top-middle
            self.board[y - 1][x] +
            // top-right
            self.board[y - 1][x + 1] +
            // left
            self.board[y][x - 1] +
            // right
            self.board[y][x + 1] +
            // bottom-left
            self.board[y + 1][x - 1] +
            // bottom-middle
            self.board[y + 1][x] +
            // bottom-right
            self.board[y + 1][x + 1];
    }
};

fn help() void {
    std.debug.print("Usage: zig build run -- -w 70 -h 40 -m \"*\" -s 0.07 -c 25\n", .{});
    os.exit(0);
}

pub fn main() !void {
    if (os.argv.len == 1 or os.argv.len != 11) {
        help();
    }

    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = general_purpose_allocator.deinit();
    var gpa = general_purpose_allocator.allocator();

    var arg_iter = try std.process.argsWithAllocator(gpa);
    defer arg_iter.deinit();

    _ = arg_iter.next();

    var width: u32 = undefined;
    var height: u32 = undefined;
    var mark: u8 = undefined;
    var sleep: f64 = undefined;
    var cells: u32 = undefined;

    var in: i32 = 0;

    if (mem.eql(u8, "-w", arg_iter.next().?)) {
        width = try fmt.parseUnsigned(u32, arg_iter.next().?, 10);
        in += 1;
    }
    if (mem.eql(u8, "-h", arg_iter.next().?)) {
        height = try fmt.parseUnsigned(u32, arg_iter.next().?, 10);
        in += 1;
    }
    if (mem.eql(u8, "-m", arg_iter.next().?)) {
        mark = arg_iter.next().?[0];
        in += 1;
    }
    if (mem.eql(u8, "-s", arg_iter.next().?)) {
        sleep = try fmt.parseFloat(f64, arg_iter.next().?);
        in += 1;
    }
    if (mem.eql(u8, "-c", arg_iter.next().?)) {
        cells = try fmt.parseUnsigned(u32, arg_iter.next().?, 10);
        in += 1;
    }
    if (in != 5) {
        help();
    }

    // std.debug.print("width: {}\n", .{width});
    // std.debug.print("height: {}\n", .{height});
    // std.debug.print("mark: {c}\n", .{mark});
    // std.debug.print("sleep: {d}\n", .{sleep});
    // std.debug.print("cells: {d}\n", .{cells});

    var g: Cgol = try Cgol.init(&gpa, width, height, mark, sleep, cells);
    defer g.deinit();

    try g.initBoard();

    while (true) {
        try g.clear();
        try g.printBoard();
        g.nextGeneration();
        g.wait();
    }
}
