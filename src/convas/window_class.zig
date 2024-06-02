const convas = @import("convas.zig");
const window = @import("window.zig");
const winapi = @import("winapi.zig");
const gl = @import("gl.zig");

const utf16LeLiteral = convas.utf16LeLiteral;

pub const Error = error{
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
        .hInstance = try convas._getModuleInstanceHandle(),
        .lpfnWndProc = procedure,
        .lpszClassName = name,
        .lpszMenuName = null,
        .style = 0,
    };

    if (winapi.RegisterClassW(&wclass) == 0) return @This().Error.RegisterWindowClassFail;
}

pub fn deinit() void {
    _ = winapi.UnregisterClassW(name, convas._instance.?.module_instance_handle);
}

fn procedure(hwnd: winapi.HWND, msg: winapi.WindowMessageType, wparam: winapi.WPARAM, lparam: winapi.LPARAM) callconv(winapi.WINAPI) winapi.LRESULT {
    if (window._instance) |*window_instance| {
        window_instance.event_handler(window.Event.fromWindowMessage(msg, wparam, lparam));

        switch (msg) {
            .Resize => gl.viewport(0, 0, winapi.LOWORD(lparam), winapi.HIWORD(lparam)),
            .SetFocus => window_instance.is_focused = true,
            .KillFocus => window_instance.is_focused = false,
            .Destroy => window.deinit(),
            .Close => {},
            else => return winapi.DefWindowProcW(hwnd, msg, wparam, lparam),
        }
    }

    return 0;
}
