const std = @import("std");
const mem = std.mem;

fn lsb_pos(p: *const u8) *const u8 {
    var nloop: usize = 0;
    var cmd: [2]u8 = undefined;
    var ret = @intToPtr(*u8, @ptrToInt(p) - @sizeOf(u8) * 8);

    while (true) {
        cmd[0] = @intToPtr(*u8, @ptrToInt(ret) + @sizeOf(u8) * 3).*;
        cmd[1] = @intToPtr(*u8, @ptrToInt(ret) + @sizeOf(u8) * 7).*;

        if (mem.eql(u8, &cmd, "?!")) {
            nloop += 1;
        } else if (mem.eql(u8, &cmd, "!?")) {
            if (nloop != 0) {
                nloop -= 1;
            } else {
                return ret;
            }
        }
        ret = @intToPtr(*u8, @ptrToInt(ret) - @sizeOf(u8) * 8);
    }
}

fn rsb_pos(p: *const u8) *const u8 {
    var nloop: usize = 0;
    var cmd: [2]u8 = undefined;
    var ret = @intToPtr(*u8, @ptrToInt(p) + @sizeOf(u8) * 8);
    while (true) {
        cmd[0] = @intToPtr(*u8, @ptrToInt(ret) + @sizeOf(u8) * 3).*;
        cmd[1] = @intToPtr(*u8, @ptrToInt(ret) + @sizeOf(u8) * 7).*;

        if (mem.eql(u8, &cmd, "!?")) {
            nloop += 1;
        } else if (mem.eql(u8, &cmd, "?!")) {
            if (nloop != 0) {
                nloop -= 1;
            } else {
                return ret;
            }
        }
        ret = @intToPtr(*u8, @ptrToInt(ret) + @sizeOf(u8) * 8);
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var memory = [_]u8{0} ** 512;
    var ptr = &memory[512 / 2];

    // Hello World!
    const code = "Ook.Ook?Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook." ++
        "Ook.Ook.Ook.Ook.Ook!Ook?Ook?Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook." ++
        "Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook?Ook!Ook!Ook?Ook!Ook?Ook." ++
        "Ook!Ook.Ook.Ook?Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook." ++
        "Ook.Ook.Ook!Ook?Ook?Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook?" ++
        "Ook!Ook!Ook?Ook!Ook?Ook.Ook.Ook.Ook!Ook.Ook.Ook.Ook.Ook.Ook.Ook." ++
        "Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook!Ook.Ook!Ook.Ook.Ook.Ook.Ook." ++
        "Ook.Ook.Ook!Ook.Ook.Ook?Ook.Ook?Ook.Ook?Ook.Ook.Ook.Ook.Ook.Ook." ++
        "Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook!Ook?Ook?Ook.Ook.Ook." ++
        "Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook?Ook!Ook!Ook?Ook!Ook?Ook.Ook!Ook." ++
        "Ook.Ook?Ook.Ook?Ook.Ook?Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook." ++
        "Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook!Ook?Ook?Ook.Ook.Ook." ++
        "Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook.Ook." ++
        "Ook.Ook?Ook!Ook!Ook?Ook!Ook?Ook.Ook!Ook!Ook!Ook!Ook!Ook!Ook!Ook." ++
        "Ook?Ook.Ook?Ook.Ook?Ook.Ook?Ook.Ook!Ook.Ook.Ook.Ook.Ook.Ook.Ook." ++
        "Ook!Ook.Ook!Ook!Ook!Ook!Ook!Ook!Ook!Ook!Ook!Ook!Ook!Ook!Ook!Ook." ++
        "Ook!Ook!Ook!Ook!Ook!Ook!Ook!Ook!Ook!Ook!Ook!Ook!Ook!Ook!Ook!Ook!" ++
        "Ook!Ook.Ook.Ook?Ook.Ook?Ook.Ook.Ook!Ook.";

    var cmd: [2]u8 = undefined;
    var codePtr = &code[0];

    while (codePtr.* != 0) {
        cmd[0] = @intToPtr(*u8, @ptrToInt(codePtr) + @sizeOf(u8) * 3).*;
        cmd[1] = @intToPtr(*u8, @ptrToInt(codePtr) + @sizeOf(u8) * 7).*;

        if (mem.eql(u8, &cmd, ".?")) {
            // ptr++ (>)
            ptr = @intToPtr(*u8, @ptrToInt(ptr) + @sizeOf(u8));
        } else if (mem.eql(u8, &cmd, "?.")) {
            // ptr-- (<)
            ptr = @intToPtr(*u8, @ptrToInt(ptr) - @sizeOf(u8));
        } else if (mem.eql(u8, &cmd, "..")) {
            // (*ptr)++ (+)
            ptr.* += 1;
        } else if (mem.eql(u8, &cmd, "!!")) {
            // (*ptr)-- (-)
            ptr.* -= 1;
        } else if (mem.eql(u8, &cmd, "!?")) {
            // ([)
            if (ptr.* == 0) {
                codePtr = rsb_pos(codePtr);
            }
        } else if (mem.eql(u8, &cmd, "?!")) {
            // (])
            if (ptr.* != 0) {
                codePtr = lsb_pos(codePtr);
            }
        } else if (mem.eql(u8, &cmd, "!.")) {
            // (.)
            try stdout.writeByte(ptr.*);
        }
        codePtr = @intToPtr(*u8, @ptrToInt(codePtr) + @sizeOf(u8) * 8);
    }
}
