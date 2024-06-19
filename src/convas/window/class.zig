const std = @import("std");
const builtin = @import("builtin");

const math = @import("../math.zig");
const convas = @import("../convas.zig");
const window = @import("window.zig");
const winapi = @import("../winapi/winapi.zig");
const gl = @import("../gl/gl.zig");
const event = @import("event.zig");

const utf16LeLiteral = convas.utf16LeLiteral;

pub const Error = error{
    RegisterWindowClassFail,
    UnregisterWindowClassFail,
};

pub const name = utf16LeLiteral("ConvasWindow");
var is_initialized = false;

pub fn init() !void {
    if (builtin.mode == .Debug or builtin.mode == .ReleaseSafe) {
        if (is_initialized) @panic("window_class.init() when window_class is already initialized");
    }

    const wclass = winapi.WNDCLASSW{
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hbrBackground = null,
        .hCursor = try winapi.LoadCursorW(null, winapi.Cursor.Arrow),
        .hIcon = null,
        .hInstance = convas.get().module_instance_handle,
        .lpfnWndProc = procedure,
        .lpszClassName = name,
        .lpszMenuName = null,
        .style = 0,
    };

    _ = try winapi.RegisterClassW(&wclass);

    is_initialized = true;
}

pub fn deinit() !void {
    if (builtin.mode == .Debug or builtin.mode == .ReleaseSafe) {
        if (!is_initialized) @panic("window_class.deinit() when window_class is already deinitialized");
    }

    try winapi.UnregisterClassW(name, convas.get().module_instance_handle);

    is_initialized = false;
}

fn procedure(window_handle: winapi.HWND, msg_type: winapi.WindowMessageType, wparam: winapi.WPARAM, lparam: winapi.LPARAM) callconv(winapi.WINAPI) winapi.LRESULT {
    if (window.instance) |*window_instance| {
        const possible_event = event.Event.fromWindowMessage(.{ .type = msg_type, .lparam = lparam, .wparam = wparam });
        if (possible_event) |e| window_instance.event_queue.append(e) catch {
            std.log.warn("Event queue overflow! Missed {} window message!", .{msg_type});
        };

        switch (msg_type) {
            //Handle mouse movement
            .MouseMove => window.onMouseMove(.{ winapi.extractXCoord(lparam), winapi.extractYCoord(lparam) }),

            //Handle window resize
            .Resize => window.onResize(.{ winapi.extractLowWord(lparam), winapi.extractHighWord(lparam) }),

            //Cache window focus state
            .SetFocus => window_instance.is_focused = true,
            .KillFocus => window_instance.is_focused = false,

            //When window is starting to destroy, deinitialize OpenGL context
            .Destroy => {
                window.instance = null;
            },

            //Omit default close behaviour
            .Close => {},

            else => return winapi.DefWindowProcW(window_handle, msg_type, wparam, lparam),
        }
    }

    return 0;
}

pub fn isInitialized() bool {
    return is_initialized;
}
