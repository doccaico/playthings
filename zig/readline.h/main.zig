const std = @import("std");
const c = @import("c.zig");

const prompt = "$ ";
const history_file = "readline_history";

pub fn main() void {

    _ = c.read_history(history_file);
    std.debug.print("Exit: Ctrl + d\n", .{});

    while (true) {

        var input = c.readline(prompt);
        if (input == null) {
            std.debug.print("{s}\n", .{ "Bye!!" });
            break;
        } else {
            c.add_history(input);
            std.debug.print("{s}\n", .{input});
        }
        c.free(input);
    }
    _ = c.write_history(history_file);
}
