// Original: tinytetris https://github.com/taylorconor/tinytetris

const std = @import("std");
const c = @import("c.zig");

var x: i32 = 431424;
var y: i32 = 598356;
var r: i32 = 427089;
var px: i32 = 247872;
var py: i32 = 799248;
var pr: i32 = undefined;
var cc: i32 = 348480;
var p: i32 = 615696;
var tick: i32 = undefined;
var board: [20][10]i32 = undefined;
var block = [7][4]i32{
    [_]i32{ 431424, 598356, 431424, 598356 },
    [_]i32{ 427089, 615696, 427089, 615696 },
    [_]i32{ 348480, 348480, 348480, 348480 },
    [_]i32{ 599636, 431376, 598336, 432192 },
    [_]i32{ 411985, 610832, 415808, 595540 },
    [_]i32{ 247872, 799248, 247872, 799248 },
    [_]i32{ 614928, 399424, 615744, 428369 },
};
var score: i32 = 0;

fn NUM(xx: i32, yy: i32) i32 {
    return 3 & block[@intCast(usize, p)][@intCast(usize, xx)] >> @intCast(u5, yy);
}

fn new_piece() void {
    y = 0;
    py = 0;

    p = @rem(c.rand(), 7);

    pr = @rem(c.rand(), 4);
    r = pr;
    px = @rem(c.rand(), (10 - NUM(r, 16)));
    x = px;
}

fn frame() void {
    var i: usize = 0;
    while (i < 20) : (i += 1) {
        _ = c.move(@intCast(c_int, 1 + i), 1);
        var j: usize = 0;
        while (j < 10) : (j += 1) {
            if (board[i][j] != 0) {
                _ = c.attron(262176 | board[i][j] << 8);
            }
            _ = c.printw("  ");
            _ = c.attroff(262176 | board[i][j] << 8);
        }
    }
    _ = c.move(21, 1);
    _ = c.printw("Score: %d", score);
    _ = c.refresh();
}

fn set_piece(xx: i32, yy: i32, rr: i32, vv: i32) void {
    var i: i32 = 0;
    while (i < 8) : (i += 2) {
        board[@intCast(usize, NUM(rr, i * 2) + yy)][@intCast(usize, NUM(rr, (i * 2) + 2) + xx)] = vv;
    }
}

fn update_piece() void {
    set_piece(px, py, pr, 0);
    px = x;
    py = y;
    pr = r;
    set_piece(px, py, pr, p + 1);
}

fn remove_line() void {
    var row: usize = @intCast(usize, y);
    while (row <= y + NUM(r, 18)) : (row += 1) {
        cc = 1;
        var i: usize = 0;
        while (i < 10) : (i += 1) {
            cc *= board[row][i];
        }
        if (cc == 0) {
            continue;
        }
        var ii: usize = row - 1;
        while (ii > 0) : (ii -= 1) {
            _ = c.memcpy(&board[ii + 1][0], &board[ii][0], 40);
        }
        _ = c.memset(&board[0][0], 0, 10);
        score += 1;
    }
}

fn check_hit(xx: i32, yy: i32, rr: i32) i32 {
    if (yy + NUM(rr, 18) > 19) {
        return 1;
    }
    set_piece(px, py, pr, 0);
    cc = 0;
    var i: i32 = 0;
    while (i < 8) : (i += 2) {
        if (board[@intCast(usize, yy + NUM(rr, i * 2))][@intCast(usize, xx + NUM(rr, (i * 2) + 2))] != 0) {
            cc += 1;
        }
    }
    set_piece(px, py, pr, p + 1);
    return cc;
}

fn do_tick() i32 {
    tick += 1;
    if (tick > 30) {
        tick = 0;
        if (check_hit(x, y + 1, r) != 0) {
            if (y == 0) {
                return 0;
            }
            remove_line();
            new_piece();
        } else {
            y += 1;
            update_piece();
        }
    }
    return 1;
}

fn runloop() void {
    while (do_tick() != 0) {
        _ = c.usleep(10000);
        cc = c.getch();
        if (cc == 'a' and x > 0 and check_hit(x - 1, y, r) == 0) {
            x -= 1;
        }
        if (cc == 'd' and x + NUM(r, 16) < 9 and check_hit(x + 1, y, r) == 0) {
            x += 1;
        }
        if (cc == 's') {
            while (check_hit(x, y + 1, r) == 0) {
                y += 1;
                update_piece();
            }
            remove_line();
            new_piece();
        }
        if (cc == 'w') {
            r += 1;
            r = @rem(r, 4);
            while (x + NUM(r, 16) > 9) {
                x -= 1;
            }
            if (check_hit(x, y, r) != 0) {
                x = px;
                r = pr;
            }
        }
        if (cc == 'q') {
            return;
        }
        update_piece();
        frame();
    }
}

pub fn main() !void {
    c.srand(@intCast(u32, c.time(0)));
    _ = c.initscr();
    _ = c.start_color();

    var i: usize = 1;
    while (i < 8) : (i += 1) {
        _ = c.init_pair(@intCast(c_short, i), @intCast(c_short, i), 0);
    }
    new_piece();
    _ = c.resizeterm(22, 22);
    _ = c.noecho();
    c.timeout(0);
    _ = c.curs_set(0);
    _ = c.box(c.stdscr, 0, 0);
    runloop();
    _ = c.endwin();
}
