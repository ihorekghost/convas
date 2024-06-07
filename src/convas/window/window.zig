//!Provides functions for creating, managing and destroying a window. This module is a "singleton", meaning there can be only one window at a time.
//!Every function except init(), pollEvents(), getEvent(), deinit() will panic if window is not initialized.

const std = @import("std");

pub const event = @import("event.zig");
const winapi = @import("../winapi.zig");
const math = @import("../math.zig");
const screen = @import("../screen/screen.zig");
const window_class = @import("../window_class.zig");
const convas_data = @import("../data.zig");
const gl = @import("../gl.zig");
const data = @import("data.zig");

pub const Options = @import("WindowOptions.zig");

pub const Visibility = winapi.WindowVisibility;

const Self = @This();

pub const Error = error{
    ConvasWindowAlreadyInitialized,
    ConvasWindowNotInitialized,
};

pub const WinapiError = error{
    CreateWindowExWFail,
    GetDCFail,
    wglCreateContextFail,
    wglMakeCurrentFail,
    wglDeleteContextFail,
    DestroyWindowFail,
};

//TODO: Replace "errdefer deinit()..." with manual WINAPI deinitialization. After CreateWindowEx: errdefer DestroyWindow(), after gl.createContext(): errdefer gl.deleteContext(), etc.
pub fn init(options: Options) !void {
    data.instance = data{ .size_glyphs = options.size_glyphs, .event_queue = try std.BoundedArray(event.Event, 256).init(0) };

    const window = &data.instance.?;

    const absolute_pos: math.Vec2(i32) = try screen.normalizedToScreen(options.pos);
    const absolute_size: math.Vec2(i32) = try screen.normalizedToScreen(options.size);

    window.handle = winapi.CreateWindowExW(
        0,
        window_class.name,
        options.title,
        winapi.WindowStyle.OverlappedWindow,
        absolute_pos[0],
        absolute_pos[1],
        absolute_size[0],
        absolute_size[1],
        null,
        null,
        convas_data.get().module_instance_handle,
        null,
    ) orelse return WinapiError.CreateWindowExWFail;

    errdefer deinit() catch unreachable;

    window.dc = winapi.GetDC(window.handle) orelse return WinapiError.GetDCFail;

    const pixel_format_descriptor = winapi.PIXELFORMATDESCRIPTOR{
        .nSize = @sizeOf(winapi.PIXELFORMATDESCRIPTOR),
        .nVersion = 1,
        .dwFlags = winapi.PIXELFORMATDESCRIPTOR.Flags.DoubleBuffer | winapi.PIXELFORMATDESCRIPTOR.Flags.DrawToWindow | winapi.PIXELFORMATDESCRIPTOR.Flags.SupportOpenGL, //Flags
        .iPixelType = winapi.PIXELFORMATDESCRIPTOR.PixelType.Rgba, // The kind of framebuffer. RGBA or palette.
        .cColorBits = 32, // Colordepth of the framebuffer.
        .cRedBits = 0,
        .cRedShift = 0,
        .cGreenBits = 0,
        .cGreenShift = 0,
        .cBlueBits = 0,
        .cBlueShift = 0,
        .cAlphaBits = 0,
        .cAlphaShift = 0,
        .cAccumBits = 0,
        .cAccumRedBits = 0,
        .cAccumGreenBits = 0,
        .cAccumBlueBits = 0,
        .cAccumAlphaBits = 0,
        .cDepthBits = 24, // Number of bits for the depthbuffer
        .cStencilBits = 8, // Number of bits for the stencilbuffer
        .cAuxBuffers = 0, // Number of Aux buffers in the framebuffer.
        .iLayerType = 0,
        .bReserved = 0,
        .dwLayerMask = 0,
        .dwVisibleMask = 0,
        .dwDamageMask = 0,
    };

    const pixel_format = winapi.ChoosePixelFormat(window.dc, &pixel_format_descriptor);

    _ = winapi.SetPixelFormat(window.dc, pixel_format, &pixel_format_descriptor);

    window.gl_context = gl.createContext(window.dc) orelse return WinapiError.wglCreateContextFail;

    if (gl.selectContext(window.dc, window.gl_context) == winapi.FALSE) return WinapiError.wglMakeCurrentFail;

    gl.ortho(0.0, 1.0, 1.0, 0.0, 1.0, -1.0);
}

pub fn deinit() !void {
    var err: ?(Error || WinapiError) = null;
    const window = data.get();

    if (gl.selectContext(null, null) == winapi.FALSE) err = WinapiError.wglMakeCurrentFail;
    if (gl.deleteContext(window.gl_context) == winapi.FALSE and err == null) err = WinapiError.wglDeleteContextFail;
    if (winapi.DestroyWindow(window.handle) == winapi.FALSE and err == null) err = WinapiError.DestroyWindowFail;

    data.instance = null;

    if (err != null) return err.?;
}

pub fn setVisibility(visibility: Visibility) void {
    const window = data.get();

    _ = winapi.ShowWindow(window.handle, visibility);
}

pub fn show() void {
    setVisibility(.Show);
}

pub fn hide() void {
    setVisibility(.Hide);
}

pub fn isValid() bool {
    return data.instance != null;
}

pub fn isFocused() bool {
    return data.get().is_focused;
}

pub fn getEvent() ?event.Event {
    if (data.instance) |*window| {
        return window.event_queue.popOrNull();
    }

    return null;
}

pub fn pollEvents() bool {
    if (data.instance) |window| {
        var msg = std.mem.zeroes(winapi.MSG);

        while (winapi.PeekMessageW(&msg, window.handle, 0, 0, winapi.PeekMessageAction.Remove) == winapi.TRUE) {
            _ = winapi.TranslateMessage(&msg);
            _ = winapi.DispatchMessageW(&msg);
        }

        return true;
    }

    return false;
}

pub fn update() void {
    // If minimized, do nothing

    const window = data.get();

    gl.clearColor(1.0, 1.0, 1.0, 0.0);
    gl.clear(gl.AttributeMask.ColorBufferBit);

    gl.begin(gl.BeginMode.Triangles);

    gl.color3f(0.5, 0.0, 0.5);

    gl.vertex2f(0.25, 0.75);
    gl.vertex2f(0.75, 0.75);
    gl.vertex2f(0.5, 0.25);

    gl.end();

    gl.flush();

    _ = gl.swapBuffers(window.dc);
}

pub fn getMousePos() math.Vec2(f32) {
    return data.get().mouse_pos;
}
