const std = @import("std");

const winapi = @import("../winapi.zig");
const math = @import("../math.zig");
const event = @import("event.zig");
const gl = @import("../gl.zig");

const Self = @This();

//Handle to the window
handle: winapi.HWND = undefined,

//Handle to DC
dc: winapi.HDC = undefined,

//OpenGL Context
gl_context: winapi.HGLRC = undefined,

//Indicates if the window is focused or not
is_focused: bool = false,

//Position of mouse cursor, in glyphs
mouse_pos: math.Vec2(f32) = math.Vec2(f32){ 0, 0 },

//Size of the window, in glyphs
size_glyphs: math.Vec2(u16) = .{ 0, 0 },

//Rectangle representing the viewport. Relative to window coordinates.
viewport: math.Rect(u16) = .{},

//Aspect ratio of each individual glyph. (width / height)
glyph_aspect: f32 = 1.0,

//Event queue
event_queue: std.BoundedArray(event.Event, 256),

pub var instance: ?Self = null;

pub fn get() *Self {
    if (instance) |*data| return data;
    @panic("window is used after deinit()");
}

pub fn _onMouseMove(pos: math.Vec2(i16)) void {
    const window = get();

    window.mouse_pos = @as(math.Vec2(f32), @floatFromInt((pos - @as(math.Vec2(i16), @intCast(window.viewport.pos))))) / @as(math.Vec2(f32), @floatFromInt(window.size_glyphs));
}

pub fn _onResize(new_size: math.Vec2(u16)) void {
    const window = get();

    window.viewport = math.fixed_aspect_ratio_scale(
        new_size,
        @as(f32, @floatFromInt(window.size_glyphs[0])) / @as(f32, @floatFromInt(window.size_glyphs[1])) * window.glyph_aspect,
    );

    gl.viewport(window.viewport.pos[0], window.viewport.pos[1], window.viewport.size[0], window.viewport.size[1]);
}
