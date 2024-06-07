const std = @import("std");

const math = @import("math.zig");
const convas = @import("convas.zig");
const convas_data = @import("data.zig");
const window = @import("window/window.zig");
const window_data = @import("window/data.zig");
const winapi = @import("winapi.zig");
const gl = @import("gl.zig");

const utf16LeLiteral = convas.utf16LeLiteral;

pub const Error = error{
    ConvasWindowClassAlreadyInitialized,
    ConvasWindowClassNotInitialized,
    RegisterWindowClassFail,
    UnregisterWindowClassFail,
};

pub const name = utf16LeLiteral("ConvasWindow");

pub fn init() !void {
    const wclass = winapi.WNDCLASSW{
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hbrBackground = null,
        .hCursor = winapi.LoadCursorW(null, winapi.Cursor.Arrow),
        .hIcon = null,
        .hInstance = convas_data.get().module_instance_handle,
        .lpfnWndProc = procedure,
        .lpszClassName = name,
        .lpszMenuName = null,
        .style = 0,
    };

    if (winapi.RegisterClassW(&wclass) == 0) return Error.RegisterWindowClassFail;
}

pub fn deinit() !void {
    if (winapi.UnregisterClassW(name, convas_data.get().module_instance_handle) == winapi.FALSE) return Error.UnregisterWindowClassFail;
}

fn procedure(hwnd: winapi.HWND, msg: winapi.WindowMessageType, wparam: winapi.WPARAM, lparam: winapi.LPARAM) callconv(winapi.WINAPI) winapi.LRESULT {
    if (window_data.instance) |*window_instance| {
        window_instance.event_queue.append(window.event.Event.fromWindowMessage(msg, wparam, lparam)) catch {};

        switch (msg) {
            .MouseMove => window_data._onMouseMove(.{ winapi.extractXCoord(lparam), winapi.extractYCoord(lparam) }),
            .Resize => window_data._onResize(.{ winapi.extractLowWord(lparam), winapi.extractHighWord(lparam) }),
            .SetFocus => window_instance.is_focused = true,
            .KillFocus => window_instance.is_focused = false,
            .Destroy => window.deinit() catch {},
            .Close => {},
            else => return winapi.DefWindowProcW(hwnd, msg, wparam, lparam),
        }
    }

    return 0;
}
