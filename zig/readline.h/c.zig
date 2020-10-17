pub usingnamespace @cImport({
    @cInclude("readline/readline.h");
    @cInclude("readline/history.h");
});

pub extern fn free(ptr: ?*anyopaque) void;
