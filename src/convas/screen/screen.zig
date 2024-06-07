const winapi = @import("../winapi.zig");
const math = @import("../math.zig");
const data = @import("data.zig");

pub const Error = error{
    ScreenAlreadyInitialized,
    ScreenNotInitialized,
};

const Self = @This();

pub fn init() !void {
    if (data.instance != null) return Error.ScreenAlreadyInitialized;

    data.instance = data{};

    const screen = &data.instance.?;

    screen.size = .{ @intCast(winapi.GetSystemMetrics(.ScreenWidth)), @intCast(winapi.GetSystemMetrics(.ScreenHeight)) };
    screen.aspect = @as(f32, @floatFromInt(screen.size[0])) / @as(f32, @floatFromInt(screen.size[1]));
}

pub fn deinit() !void {
    if (data.instance == null) return Error.ScreenNotInitialized;
    data.instance = null;
}

pub fn getSize() !math.Vec2(i32) {
    const screen = data.get();

    return screen.size;
}

pub fn getAspect() !f32 {
    const screen = data.get();

    return screen.aspect;
}

pub fn normalizedToScreen(vec: math.Vec2(f32)) !math.Vec2(i32) {
    const screen = data.get();

    return @intFromFloat(@as(math.Vec2(f32), @floatFromInt(screen.size)) * vec);
}

pub fn screenToNormalized(vec: math.Vec2(i32)) math.Vec2(f32) {
    const screen = data.get();

    return @as(math.Vec2(f32), @floatFromInt(vec)) / @as(math.Vec2(f32), @floatFromInt(screen.size));
}

pub fn isValid() bool {
    return data.instance != null;
}
