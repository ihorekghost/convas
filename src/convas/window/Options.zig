const math = @import("../math.zig");

pub const Flags = packed struct {
    ///If true, the window is resizable
    resizable: bool = true,

    ///If true, the window has no borders. Useful for
    borderless: bool = false,
};

///Title of the window in UTF-16 Little Endian encoding
title: [*:0]const u16 = undefined,

///Position of the window relative to screen's upper-left corner
pos: math.Vec2(i32) = default_pos,

///Size of the window, in pixels
size: math.Vec2(i32) = default_size,
flags: Flags = .{},

///Default metric for Options.pos components and Options.size components
pub const default_metric: i32 = @bitCast(@as(u32, 0x80000000));
pub const default_pos = math.Vec2(i32){ default_metric, default_metric };
pub const default_size = default_pos;
