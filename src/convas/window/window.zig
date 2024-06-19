//!Provides functions for creating, managing and destroying a window. This module is a "singleton", meaning there can be only one window at a time.
//!Every function except init(), pollEvents(), getEvent(), deinit() will panic if window is not initialized.

const std = @import("std");
const builtin = @import("builtin");

const winapi = @import("../winapi/winapi.zig");
const math = @import("../math.zig");
const screen = @import("../screen.zig");
const window_class = @import("class.zig");
const convas = @import("../convas.zig");
const gl = @import("../gl/gl.zig");

pub const event = @import("event.zig");
pub const canvas = @import("canvas/canvas.zig");
pub const Options = @import("Options.zig");

pub const Visibility = winapi.WindowVisibility;

pub const Error = error{
    ConvasWindowAlreadyInitialized,
    ConvasWindowNotInitialized,
};

//Handle to the window
handle: winapi.HWND = undefined,

//Indicates if the window is focused or not
is_focused: bool = false,

//Position of mouse cursor relative to window's upper-left corner, in pixels
mouse_pos: math.Vec2(i16) = math.Vec2(i16){ 0, 0 },

//Event queue
event_queue: std.BoundedArray(event.Event, 256),

///**For private use.**
pub var instance: ?@This() = null;

///Intialize a window. **There can only be one window at a time.**
///You can handle events using *window.updateEvents()*, *window.getEvents()*, *window.clearEvents()* methods.
///**The window must be initialized before using any of its methods, except window.isInitialized().**
pub fn init(options: Options) !void {
    if (builtin.mode == .Debug or builtin.mode == .ReleaseSafe) {
        if (isInitialized()) @panic("window.init() when already initialized");
    }

    instance = @This(){ .event_queue = try std.BoundedArray(event.Event, 256).init(0) };

    const window = &instance.?;

    window.handle = try winapi.CreateWindowExW(
        0,
        window_class.name,
        options.title,
        winapi.WindowStyle.OverlappedWindow,
        options.pos[0],
        options.pos[1],
        options.size[0],
        options.size[1],
        null,
        null,
        convas.get().module_instance_handle,
        null,
    );
}

///Deinitialize the window. **After this, every window's method call will panic.**
pub fn deinit() !void {
    if (builtin.mode == .Debug or builtin.mode == .ReleaseSafe) {
        if (!isInitialized()) @panic("window.deinit() when already deinitialized");
    }

    const window = get();

    try winapi.DestroyWindow(window.handle);
}

///Show or hide the window depending on *visibility* parameter.
pub fn setVisibility(visibility: Visibility) void {
    const window = get();

    _ = winapi.ShowWindow(window.handle, visibility);
}

///Show the window.
pub fn show() void {
    setVisibility(.Show);
}

///Hide the window.
pub fn hide() void {
    setVisibility(.Hide);
}

pub fn isInitialized() bool {
    return instance != null;
}

pub fn isFocused() bool {
    return get().is_focused;
}

///Get a slice that represents all the events in the event queue.
pub fn getEvents() []const event.Event {
    const window = get();

    return window.event_queue.constSlice();
}

///Fetch events and add them to the queue.
pub fn updateEvents() void {
    const window = get();

    var msg = std.mem.zeroes(winapi.MSG);

    while (winapi.PeekMessageW(&msg, window.handle, 0, 0, winapi.PeekMessageAction.Remove) == winapi.TRUE) {
        _ = winapi.TranslateMessage(&msg);
        _ = winapi.DispatchMessageW(&msg);
    }
}

///Clear the event queue.
pub fn clearEvents() void {
    const window = get();

    window.event_queue.resize(0) catch unreachable;
}

///**For private use.** Get an instance of the window.
pub fn get() *@This() {
    //If building in Debug or ReleaseSafe modes, check for uninitialized window in runtime.
    if (builtin.mode == .Debug or builtin.mode == .ReleaseSafe) {
        if (!isInitialized()) @panic("window is used after deinit()");
    }

    return &instance.?;
}

///**For private use.**
pub fn onMouseMove(pos: math.Vec2(i16)) void {
    const window = get();

    window.mouse_pos = pos;
}

///**For private use.**
pub fn onResize(new_size: math.Vec2(u16)) void {
    if (canvas.instance) |*canvas_instance| {
        canvas_instance.rect = math.fixed_aspect_ratio_scale(
            new_size,
            @as(f32, @floatFromInt(canvas_instance.size_glyphs[0])) / @as(f32, @floatFromInt(canvas_instance.size_glyphs[1])) * canvas_instance.glyph_aspect,
        );

        gl.viewport(canvas_instance.rect.pos[0], canvas_instance.rect.pos[1], canvas_instance.rect.size[0], canvas_instance.rect.size[1]);
    }
}
