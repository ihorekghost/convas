const math = @import("../../math.zig");
const gl = @import("../../gl/gl.zig");
const builtin = @import("builtin");
const window = @import("../window.zig");
const winapi = @import("../../winapi/winapi.zig");

pub const Options = @import("Options.zig");

pub const getGLVersion = gl.getVersion();
pub const getGLExtensions = gl.getExtensions();

///**For private use.**
pub var instance: ?@This() = null;

gl_context: winapi.HGLRC = undefined,
hdc: winapi.HDC = undefined,

//The viewport rect
rect: math.Rect(u16) = .{},
size_glyphs: math.Vec2(u16),
glyph_aspect: f32 = 1.0,

///Draw a layer on the canvas. **Changes won't be displayed until canvas.update() is called.**
pub fn drawLayer() void {
    //Make sure that canvas is initialized. Panic otherwise.
    const canvas = get();

    // If minimized, do nothing

    if (canvas.rect.size[0] == 0 or canvas.rect.size[1] == 0) return;

    gl.clear(gl.AttributeMask.ColorBufferBit);

    gl.begin(gl.BeginMode.Triangles);

    gl.color3f(0.5, 0.0, 0.5);

    gl.vertex2f(0.25, 0.75);
    gl.vertex2f(0.75, 0.75);
    gl.vertex2f(0.5, 0.25);

    gl.end();

    gl.flush();
}

///Update changes made by canvas.drawLayer() calls.
pub fn update() void {
    //Make sure that canvas is initialized. Panic otherwise.
    const canvas = get();

    gl.swapBuffers(canvas.hdc) catch {};
}

///Initialize a canvas for drawing. **The window must be initialized before calling this function.**
pub fn init(options: Options) !void {
    if (builtin.mode == .Debug or builtin.mode == .ReleaseSafe) {
        if (isInitialized()) @panic("canvas.init() when already initialized");
    }

    instance = @This(){ .size_glyphs = options.size_glyphs };

    const canvas = &instance.?;
    const window_instance = window.get();

    canvas.hdc = try winapi.GetDC(window_instance.handle);
    errdefer winapi.ReleaseDC(window_instance.handle, canvas.hdc) catch {};

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

    const pixel_format = try winapi.ChoosePixelFormat(canvas.hdc, &pixel_format_descriptor);

    try winapi.SetPixelFormat(canvas.hdc, pixel_format, &pixel_format_descriptor);

    canvas.gl_context = try gl.createContext(canvas.hdc);
    errdefer gl.deleteContext(canvas.gl_context) catch {};

    try gl.selectContext(canvas.hdc, canvas.gl_context);
    errdefer gl.selectContext(null, null) catch {};

    try gl.init();

    try setVSync(options.vsync);

    gl.ortho(0.0, 1.0, 1.0, 0.0, 1.0, -1.0);

    gl.clearColor(1.0, 1.0, 1.0, 0.0);
}

///Deinitialize the canvas. **Window must be initialized at this point.**
pub fn deinit() !void {
    const window_instance = window.get();
    const canvas = get();

    try gl.selectContext(null, null);
    try winapi.ReleaseDC(window_instance.handle, canvas.hdc);
    try gl.deleteContext(canvas.gl_context);

    instance = null;
}

///**For private use.** Get an instance of the canvas.
pub fn get() *@This() {
    if (builtin.mode == .Debug or builtin.mode == .ReleaseSafe) {
        if (!isInitialized()) @panic("canvas is used before initialization");
    }

    return &instance.?;
}

pub fn isInitialized() bool {
    return instance != null;
}

pub fn setVSync(vsync: bool) !void {
    try gl.swapInterval(@intFromBool(vsync));
}
