const std = @import("std");
pub const win = @import("win.zig");
pub const console = @import("console.zig");
pub const input = @import("input.zig");
pub const log = std.log;

const InitError = error{
    ConvasAlreadyInitialized,
    RegisterWindowClassFail,
};

const DeinitError = error{
    ConvasNotInitialized,
    UnregisterWindowClassFail,
} || console.DeinitError;

var hInstance: ?win.HINSTANCE = null;

pub fn isInitialized() bool {
    return hInstance != null;
}

pub fn init() InitError!void {
    log.debug("convas.init()", .{});
    if (isInitialized()) return InitError.ConvasAlreadyInitialized;

    hInstance = @ptrCast(win.GetModuleHandleW(null));

    try registerWindowClass();
}

pub fn deinit() DeinitError!void {
    log.debug("convas.deinit()", .{});
    if (!isInitialized()) return DeinitError.ConvasNotInitialized;

    if (console.isInitialized()) try console.deinit();

    try unregisterWindowClass();

    hInstance = null;
}

fn registerWindowClass() InitError!void {
    var class: win.WNDCLASSW = std.mem.zeroes(win.WNDCLASSW);

    class.lpfnWndProc = consoleWindowProc;
    class.hInstance = hInstance.?;
    class.lpszClassName = console.window_classname;

    if (win.RegisterClassW(&class) == 0) return InitError.RegisterWindowClassFail;
}

fn unregisterWindowClass() DeinitError!void {
    if (win.UnregisterClassW(console.window_classname, hInstance.?) == 0) return DeinitError.UnregisterWindowClassFail;
}

fn consoleWindowProc(hwnd: win.HWND, msg: win.UINT, wparam: win.WPARAM, lparam: win.LPARAM) callconv(win.WINAPI) win.LRESULT {
    return win.DefWindowProcW(hwnd, msg, wparam, lparam);
}

pub fn getHInstance() ?win.HINSTANCE {
    return hInstance;
}

pub fn getLastWinError() win.DWORD {
    return win.GetLastError();
}
