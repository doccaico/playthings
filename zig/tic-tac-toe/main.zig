const std = @import("std");
const fmt = std.fmt;
const os = std.os;

const winpatterns_x = 8;
const winpatterns_y = 3;
const board_x = 9;
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

const winpatterns = [winpatterns_x][winpatterns_y]u8{
    .{ 0, 1, 2 },
    .{ 3, 4, 5 },
    .{ 6, 7, 8 },
    .{ 0, 3, 6 },
    .{ 1, 4, 7 },
    .{ 2, 5, 8 },
    .{ 0, 4, 8 },
    .{ 2, 4, 6 },
};

var board: [board_x]u8 = [_]u8{' '} ** board_x;

fn displayBoard() !void {
    try stdout.print("|-----|-----|-----|\n", .{});
    try stdout.print("|  {c}  |  {c}  |  {c}  |\n", .{ board[0], board[1], board[2] });
    try stdout.print("|-----|-----|-----|\n", .{});
    try stdout.print("|  {c}  |  {c}  |  {c}  |\n", .{ board[3], board[4], board[5] });
    try stdout.print("|-----|-----|-----|\n", .{});
    try stdout.print("|  {c}  |  {c}  |  {c}  |\n", .{ board[6], board[7], board[8] });
    try stdout.print("|-----|-----|-----|\n", .{});
}

fn scanChar(msg: []const u8) !u8 {
    while (true) {
        try stdout.print("{s}", .{msg});
        var ch = stdin.readByte() catch os.exit(0);
        if (stdin.readByte() catch os.exit(0) == '\n') {
            return ch;
        }
        while (stdin.readByte() catch os.exit(0) != '\n') {}
    }
}

fn selectPlayer() !u8 {
    while (true) {
        var ch = try scanChar("Choose the first player (X or O): ");
        if (ch == 'X' or 'O' == ch) {
            return ch;
        }
    }
}

fn scanNumber(player: u8) !u8 {
    const bufSize = comptime "[{c}'s turn] Enter a number (0..8): ".len - 2;
    var buf: [bufSize]u8 = undefined;
    var msg = try fmt.bufPrint(&buf, "[{c}'s turn] Enter a number (0..8): ", .{player});

    while (true) {
        var ch = try scanChar(msg);
        if (ch < '0' or '8' < ch) {
            continue;
        }
        return try fmt.charToDigit(ch, 10);
    }
}

fn existsWinner() bool {
    var i: usize = 0;
    while (i < winpatterns_x) : (i += 1) {
        const a = winpatterns[i][0];
        const b = winpatterns[i][1];
        const c = winpatterns[i][2];
        if (board[a] != ' ' and board[a] == board[b] and board[a] == board[c]) {
            return true;
        }
    }
    return false;
}

fn switchPlayer(player: u8) u8 {
    if (player == 'X') {
        return 'O';
    } else {
        return 'X';
    }
}

pub fn main() !void {
    try stdout.print("Thank you for playing this game.\n", .{});

    var player = try selectPlayer();

    while (true) {
        try displayBoard();
        var pos = try scanNumber(player);

        if (board[pos] != ' ') {
            try stdout.print("It is already placed: {}\n", .{pos});
            continue;
        }

        board[pos] = player;

        if (existsWinner()) {
            try displayBoard();
            try stdout.print("Congratulations, {c} won.\nBye.\n", .{player});
            break;
        }
        player = switchPlayer(player);
    }
}
