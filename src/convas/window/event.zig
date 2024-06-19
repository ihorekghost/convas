const std = @import("std");

const winapi = @import("../winapi/winapi.zig");

pub const MouseButtonEvent = @import("events/MouseButtonEvent.zig");
pub const KeyEvent = @import("events/KeyEvent.zig");

pub const EventType = enum {
    Destroy,
    Close,
    MouseButton,
    Key,
};

pub const Event = union(EventType) {
    Destroy: void,
    Close: void,
    MouseButton: MouseButtonEvent,
    Key: KeyEvent,

    pub fn fromWindowMessage(msg: winapi.WindowMessage) ?@This() {
        return switch (msg.type) {
            .LMouseButtonUp => Event{ .MouseButton = .{ .button = .Left, .state = .Released } },
            .LMouseButtonDown => Event{ .MouseButton = .{ .button = .Left, .state = .Pressed } },
            .MMouseButtonUp => Event{ .MouseButton = .{ .button = .Middle, .state = .Released } },
            .MMouseButtonDown => Event{ .MouseButton = .{ .button = .Middle, .state = .Pressed } },
            .RMouseButtonUp => Event{ .MouseButton = .{ .button = .Right, .state = .Released } },
            .RMouseButtonDown => Event{ .MouseButton = .{ .button = .Right, .state = .Pressed } },
            .KeyUp => Event{ .Key = .{ .key = @enumFromInt(msg.wparam), .state = .Released } },
            .KeyDown => Event{ .Key = .{ .key = @enumFromInt(msg.wparam), .state = .Pressed } },
            .Close => Event{ .Close = undefined },
            .Destroy => Event{ .Destroy = undefined },
            else => null,
        };
    }
};
