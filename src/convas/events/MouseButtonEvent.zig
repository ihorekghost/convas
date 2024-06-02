const input = @import("../input.zig");

button: input.MouseButton,
state: input.MouseButtonState,

pub fn isPressed(event: @This()) bool {
    return event.state == .Pressed;
}

pub fn isReleased(event: @This()) bool {
    return event.state == .Released;
}
