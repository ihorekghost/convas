const math = @import("math.zig");
const EventHandler = @import("window.zig").EventHandler;

pub const Flags = packed struct {
    resizable: bool = true,
    borderless: bool = false,
};

title: [*:0]const u16 = undefined,
pos: math.Vec2(f32) = .{ 0.25, 0.25 },
size: math.Vec2(f32) = .{ 0.5, 0.5 },
sizeGlyphs: math.Vec2(u16) = .{ 16, 16 },
flags: Flags = .{},
event_handler: EventHandler,
