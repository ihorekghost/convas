const input = @import("../../input.zig");
const math = @import("../../math.zig");

button: input.MouseButton,
state: input.MouseButtonState,
pos: math.Vec2(u16) = .{ 0, 0 },

pub fn isPressed(event: @This()) bool {
    return event.state == .Pressed;
}

pub fn isReleased(event: @This()) bool {
    return event.state == .Released;
}
