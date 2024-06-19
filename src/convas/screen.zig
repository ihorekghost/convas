const builtin = @import("builtin");

const winapi = @import("winapi/winapi.zig");
const math = @import("math.zig");

//Size of the screen, in pixels
size: math.Vec2(i32) = .{ 0, 0 },

//Aspect ratio of the screen
aspect: f32 = 0.0,

pub var _instance: ?@This() = null;

pub fn _get() *@This() {
    if (_instance) |*screen| return screen;
    @panic("screen is used when not initialized");
}

pub fn init() !void {
    if (builtin.mode == .Debug or builtin.mode == .ReleaseSafe) {
        if (_instance != null) @panic("screen.init() when already initialized");
    }

    _instance = @This(){};

    const screen = &_instance.?;

    screen.size = .{ @intCast(winapi.GetSystemMetrics(.ScreenWidth)), @intCast(winapi.GetSystemMetrics(.ScreenHeight)) };
    screen.aspect = @as(f32, @floatFromInt(screen.size[0])) / @as(f32, @floatFromInt(screen.size[1]));
}

pub fn deinit() !void {
    if (builtin.mode == .Debug or builtin.mode == .ReleaseSafe) {
        if (_instance == null) @panic("screen.deinit() when already deinitialized");
    }

    _instance = null;
}

pub fn getSize() !math.Vec2(i32) {
    const screen = _get();

    return screen.size;
}

pub fn getAspect() !f32 {
    const screen = _get();

    return screen.aspect;
}

pub fn normalizedToScreen(vec: math.Vec2(f32)) !math.Vec2(i32) {
    const screen = _get();

    return @intFromFloat(@as(math.Vec2(f32), @floatFromInt(screen.size)) * vec);
}

pub fn screenToNormalized(vec: math.Vec2(i32)) math.Vec2(f32) {
    const screen = _get();

    return @as(math.Vec2(f32), @floatFromInt(vec)) / @as(math.Vec2(f32), @floatFromInt(screen.size));
}

pub fn isInitialized() bool {
    return _instance != null;
}
