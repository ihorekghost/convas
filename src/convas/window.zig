const std = @import("std");
const winapi = @import("winapi.zig");
const math = @import("math.zig");
const screen = @import("screen.zig");
const window_class = @import("window_class.zig");
const convas = @import("convas.zig");
const gl = @import("gl.zig");

pub const Options = @import("WindowOptions.zig");

pub const Visibility = winapi.WindowVisibility;

pub const Error = error{
    ConvasWindowAlreadyInitialized,
    ConvasWindowNotInitialized,
};

pub const WinapiError = error{
    CreateWindowExWFail,
    GetDCFail,
    wglCreateContextFail,
    wglMakeCurrentFail,
};

pub const MouseButtonEvent = @import("events/MouseButtonEvent.zig");
pub const KeyEvent = @import("events/KeyEvent.zig");

pub const EventType = enum {
    Unknown,
    Close,
    Destroy,
    MouseButton,
    MouseMove,
    Key,
};

pub const Event = union(EventType) {
    Unknown: void,
    Close: void,
    Destroy: void,
    MouseButton: MouseButtonEvent,
    MouseMove: @Vector(2, i16),
    Key: KeyEvent,

    pub fn fromWindowMessage(msg: winapi.WindowMessageType, wparam: winapi.WPARAM, lparam: winapi.LPARAM) @This() {
        return switch (msg) {
            .LMouseButtonUp => Event{ .MouseButton = .{ .button = .Left, .state = .Released } },
            .LMouseButtonDown => Event{ .MouseButton = .{ .button = .Left, .state = .Pressed } },
            .MMouseButtonUp => Event{ .MouseButton = .{ .button = .Middle, .state = .Released } },
            .MMouseButtonDown => Event{ .MouseButton = .{ .button = .Middle, .state = .Pressed } },
            .RMouseButtonUp => Event{ .MouseButton = .{ .button = .Right, .state = .Released } },
            .RMouseButtonDown => Event{ .MouseButton = .{ .button = .Right, .state = .Pressed } },
            .MouseMove => Event{ .MouseMove = math.Vec2(i16){ winapi.LOWORD(lparam), winapi.HIWORD(lparam) } },
            .KeyUp => Event{ .Key = KeyEvent{ .key = @enumFromInt(wparam), .state = .Released } },
            .KeyDown => Event{ .Key = KeyEvent{ .key = @enumFromInt(wparam), .state = .Pressed } },
            .Close => Event{ .Close = undefined },
            .Destroy => Event{ .Destroy = undefined },
            else => Event{ .Unknown = undefined },
        };
    }
};

pub const EventHandler = *const fn (Event) void;

handle: winapi.HWND = undefined,
dc: winapi.HDC = undefined,
gl_context: winapi.HGLRC = undefined,
is_focused: bool = false,
mouse_pos: math.Vec2(u16) = math.Vec2(u16){ 0, 0 },
event_handler: EventHandler,

pub var _instance: ?@This() = null;

pub fn init(options: Options) !void {
    if (isInitialized()) return Error.ConvasWindowAlreadyInitialized;

    _instance = @This(){ .event_handler = options.event_handler };

    const window = &_instance.?;

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
        try convas._getModuleInstanceHandle(),
        null,
    ) orelse return WinapiError.CreateWindowExWFail;

    errdefer deinit();

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

    //gl.ortho(0.0, 1.0, 1.0, 0.0, 1.0, -1.0);
}

pub fn deinit() void {
    if (_instance) |window| {
        _ = gl.deleteContext(window.gl_context);
        _ = winapi.DestroyWindow(window.handle);
        _instance = null;
    }
}

pub fn setVisibility(visibility: Visibility) !void {
    if (_instance) |window| {
        _ = winapi.ShowWindow(window.handle, visibility);
    } else {
        return Error.ConvasWindowNotInitialized;
    }
}

pub fn show() !void {
    try setVisibility(.Show);
}

pub fn hide() !void {
    try setVisibility(.Hide);
}

pub fn isInitialized() bool {
    return _instance != null;
}

pub fn isFocused() !bool {
    if (_instance) |window| return window.is_focused;

    return Error.WindowNotInitialized;
}

pub fn pollEvents() bool {
    if (_instance) |window| {
        var msg = std.mem.zeroes(winapi.MSG);

        while (winapi.PeekMessageW(&msg, window.handle, 0, 0, winapi.PeekMessageAction.Remove) == winapi.TRUE) {
            _ = winapi.TranslateMessage(&msg);
            _ = winapi.DispatchMessageW(&msg);
        }

        return isInitialized();
    }

    return false;
}

pub fn _get() !@This() {
    return _instance orelse Error.ConvasWindowNotInitialized;
}

pub fn update() void {
    if (_instance) |window| {
        gl.clearColor(1.0, 1.0, 1.0, 0.0);
        gl.clear(gl.AttributeMask.ColorBufferBit);

        gl.begin(gl.BeginMode.Triangles);

        gl.color3f(0.5, 0.0, 0.5);

        gl.vertex2f(-0.5, -0.5);
        gl.vertex2f(0.5, -0.5);
        gl.vertex2f(0.0, 0.5);

        gl.end();

        gl.flush();

        _ = gl.swapBuffers(window.dc);
    }
}
