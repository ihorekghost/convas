const math = @import("../math.zig");

const Self = @This();

//Size of the screen, in pixels
size: math.Vec2(i32) = .{ 0, 0 },

//Aspect ratio of the screen
aspect: f32 = 0.0,

pub var instance: ?Self = null;

pub fn get() *Self {
    if (instance) |*data| return data;
    @panic("screen is used when not initialized");
}
