const std = @import("std");
const L = std.unicode.utf8ToUtf16LeStringLiteral;

const win = @import("win32api.zig");

// Use wide API for zigwin32
pub const UNICODE = true;

fn wndProc(hWnd: win.HWND, msg: win.UINT, wParam: win.WPARAM, lParam: win.LPARAM) callconv(win.WINAPI) win.LRESULT {
    switch (msg) {
        win.WM_DESTROY => {
            win.PostQuitMessage(0);
            return 0;
        },
        else => {
            return win.DefWindowProcW(hWnd, msg, wParam, lParam);
        },
    }

    return 0;
}

pub export fn wWinMain(hInstance: win.HINSTANCE, hPrevInstance: ?win.HINSTANCE, pCmdLine: ?win.LPWSTR, nCmdShow: win.INT) callconv(win.WINAPI) win.INT {
    _ = hPrevInstance;
    _ = pCmdLine;
    _ = nCmdShow;

    var msg: win.MSG = undefined;

    // zig fmt: off
    var winc: win.WNDCLASSEXW = .{
        .cbSize = @sizeOf(win.WNDCLASSEXW),
        .hIconSm = null,
        .style = .{
            .VREDRAW = 1,
            .HREDRAW = 1,
        },
        .lpfnWndProc = wndProc,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hInstance = hInstance,
        .hIcon = win.LoadIconW(null, win.IDI_APPLICATION),
        .hCursor = win.LoadCursorW(null, win.IDC_ARROW),
        .hbrBackground = win.GetStockObject(win.WHITE_BRUSH),
        .lpszMenuName = null,
        .lpszClassName = L("Window") };
    // zig fmt: on

    if (win.RegisterClassExW(&winc) == 0) {
        return -1;
    }

    // zig fmt: off
    const hwnd = win.CreateWindowExW(
        .{},
        L("Window"),
        L("Window's title"),
        .{
            .TABSTOP = 1,
            .GROUP = 1,
            .SYSMENU = 1,
            .THICKFRAME = 1,
            .VISIBLE = 1,
        },
        200,
        200,
        500,
        500,
        null,
        null,
        hInstance,
        null
    );
    // zig fmt: on

    if (hwnd == null) {
        return -1;
    }

    while (win.GetMessageW(&msg, null, 0, 0) != 0) {
        _ = win.DispatchMessageW(&msg);
    }

    // _ = win.MessageBoxW(null, L("Title"), L("Message"), win.MB_OK);

    return @intCast(msg.wParam);
}
