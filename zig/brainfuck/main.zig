const std = @import("std");

fn lsb_pos(p: *const u8) *const u8 {
    var nloop: usize = 0;
    var ret = @intToPtr(*u8, @ptrToInt(p) - @sizeOf(u8));
    while (true) {
        switch (ret.*) {
            ']' => {
                nloop += 1;
            },
            '[' => {
                if (nloop != 0) {
                    nloop -= 1;
                } else {
                    return ret;
                }
            },
            else => {},
        }
        ret = @intToPtr(*u8, @ptrToInt(ret) - @sizeOf(u8));
    }
}

fn rsb_pos(p: *const u8) *const u8 {
    var nloop: usize = 0;
    var ret = @intToPtr(*u8, @ptrToInt(p) + @sizeOf(u8));
    while (true) {
        switch (ret.*) {
            '[' => {
                nloop += 1;
            },
            ']' => {
                if (nloop != 0) {
                    nloop -= 1;
                } else {
                    return ret;
                }
            },
            else => {},
        }
        ret = @intToPtr(*u8, @ptrToInt(ret) + @sizeOf(u8));
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var memory = [_]u8{0} ** 512;
    var ptr = &memory[512 / 2];

    // Hello World!
    const code =
        \\ ++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.
        \\ >---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.
    ;
    var codePtr = &code[0];

    while (codePtr.* != 0) {
        switch (codePtr.*) {
            '+' => {
                ptr.* += 1;
            },
            '-' => {
                ptr.* -= 1;
            },
            '>' => {
                ptr = @intToPtr(*u8, @ptrToInt(ptr) + @sizeOf(u8));
            },
            '<' => {
                ptr = @intToPtr(*u8, @ptrToInt(ptr) - @sizeOf(u8));
            },
            '[' => {
                if (ptr.* == 0) {
                    codePtr = rsb_pos(codePtr);
                }
            },
            ']' => {
                if (ptr.* != 0) {
                    codePtr = lsb_pos(codePtr);
                }
            },
            '.' => {
                try stdout.writeByte(ptr.*);
            },
            else => {},
        }
        codePtr = @intToPtr(*u8, @ptrToInt(codePtr) + @sizeOf(u8));
    }
}
