//Mouse Button Input Event (--
pub const MouseButton = enum { Left, Right, Middle };

pub const MouseButtonEvent = struct {
    button: MouseButton,
    pressed: bool,
};
// --)

//Key Event (--
pub const KeyEvent = struct {
    key: u8,
    pressed: bool,
};
// --)

pub const InputEventType = enum {
    Close,
    MouseButton,
    Key,
};

pub const InputEvent = union(InputEventType) {
    Close: void,
    MouseButton: MouseButtonEvent,
    Key: KeyEvent,
};
