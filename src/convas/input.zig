const winapi = @import("winapi/winapi.zig");

pub const MouseButton = enum(u2) {
    pub fn toString(button: MouseButton) []const u8 {
        return switch (button) {
            .Left => "left",
            .Middle => "middle",
            .Right => "right",
            _ => "",
        };
    }

    Left = 0,
    Right = 1,
    Middle = 2,
    _,
};
pub const MouseButtonState = enum(u1) {
    pub fn toString(state: MouseButtonState) []const u8 {
        return switch (state) {
            .Pressed => "pressed",
            .Released => "released",
        };
    }

    Pressed = 0,
    Released = 1,
};

pub const KeyState = MouseButtonState;
pub const Key = winapi.VirtualKey;
