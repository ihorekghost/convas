const math = @import("../math.zig");

pub const Flags = packed struct {
    resizable: bool = true,
    borderless: bool = false,
};

title: [*:0]const u16 = undefined,
pos: math.Vec2(f32) = .{ 0.25, 0.25 },
size: math.Vec2(f32) = .{ 0.5, 0.5 },
size_glyphs: math.Vec2(u16) = .{ 16, 16 },
flags: Flags = .{},
