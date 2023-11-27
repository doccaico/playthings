const std = @import("std");
const c = @import("c.zig");

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO | c.SDL_INIT_EVENTS) < 0) {
        c.SDL_LogError(c.SDL_LOG_CATEGORY_APPLICATION, "SDL_Init() failed: %s\n", c.SDL_GetError());
        return;
    }
    defer c.SDL_Quit();

    // _ = c.TTF_Init();
    // defer c.TTF_Quit();

    const window = c.SDL_CreateWindow(
        "SDL2 Native Demo",
        c.SDL_WINDOWPOS_CENTERED,
        c.SDL_WINDOWPOS_CENTERED,
        800,
        600,
        c.SDL_WINDOW_SHOWN,
    ) orelse {
        c.SDL_LogError(c.SDL_LOG_CATEGORY_APPLICATION, "SDL_CreateWindow() failed: %s\n", c.SDL_GetError());
        return;
    };

    defer _ = c.SDL_DestroyWindow(window);

    mainLoop: while (true) {
        // const start = c.SDL_GetPerformanceCounter();

        var ev: c.SDL_Event = undefined;

        while (c.SDL_PollEvent(&ev) != 0) {
            switch (ev.type) {
                c.SDL_QUIT => break :mainLoop,
                c.SDL_KEYDOWN => {
                    if (c.SDL_SCANCODE_ESCAPE == ev.key.keysym.scancode)
                        break :mainLoop;
                },
                else => {},
            }
        }

        // const end = c.SDL_GetPerformanceCounter();

        // const elapsedMS: f64 =
        //     @as(f64, @floatFromInt(end - start)) / @as(f64, @floatFromInt(c.SDL_GetPerformanceFrequency())) * 1000.0;
        // std.debug.print("{d}\n", .{@as(i32, @intFromFloat(@floor(33.333 - elapsedMS)))});

        // c.SDL_Delay(@floatToInt(u32, @floor(16.666 - elapsedMS))); // 60 FPS (1000 / 60 = 16.666...)
        // c.SDL_Delay(@intFromFloat(@floor(33.333 - elapsedMS))); // 30 FPS (1000/ 30 = 33.333...)

        c.SDL_Delay(33); // 30 FPS
        // c.SDL_Delay(17); // 60 FPS
    }
}
