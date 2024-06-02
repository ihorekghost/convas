const winapi = @import("winapi.zig");
const math = @import("math.zig");

pub const Error = error{
    ConvasScreenAlreadyInitialized,
    ConvasScreenNotInitialized,
};

var _instance: ?@This() = null;

size: math.Vec2(i32) = .{ 0, 0 },
aspect: f32 = 0.0,

pub fn init() !void {
    if (_instance != null) return Error.ConvasScreenAlreadyInitialized;

    _instance = @This(){};

    const screen = &_instance.?;

    screen.size = .{ @intCast(winapi.GetSystemMetrics(.ScreenWidth)), @intCast(winapi.GetSystemMetrics(.ScreenHeight)) };
    screen.aspect = @as(f32, @floatFromInt(screen.size[0])) / @as(f32, @floatFromInt(screen.size[1]));
}

pub fn deinit() void {
    if (_instance != null) _instance = null;
}

pub fn getSize() !math.Vec2(i32) {
    if (_instance) |screen| {
        return screen.size;
    } else return Error.ConvasScreenNotInitialized;
}

pub fn getAspect() !f32 {
    if (_instance) |screen| {
        return screen.aspect;
    } else return Error.ConvasScreenNotInitialized;
}

pub fn normalizedToScreen(vec: math.Vec2(f32)) !math.Vec2(i32) {
    if (_instance) |screen| {
        return @intFromFloat(@as(math.Vec2(f32), @floatFromInt(screen.size)) * vec);
    } else return Error.ConvasScreenNotInitialized;
}

pub fn screenToNormalized(vec: math.Vec2(i32)) !math.Vec2(f32) {
    if (_instance) |screen| {
        return @as(math.Vec2(f32), @floatFromInt(vec)) / @as(math.Vec2(f32), @floatFromInt(screen.size));
    } else return Error.ConvasScreenNotInitialized;
}

pub fn isInitialized() bool {
    return _instance != null;
}
