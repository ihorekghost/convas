const std = @import("std");

const winapi = @import("../winapi.zig");

pub const MouseButtonEvent = @import("events/MouseButtonEvent.zig");
pub const KeyEvent = @import("events/KeyEvent.zig");

pub const EventType = enum {
    Unknown,
    Close,
    MouseButton,
    Key,
};

pub const Event = union(EventType) {
    Unknown: void,
    Close: void,
    MouseButton: MouseButtonEvent,
    Key: KeyEvent,

    pub fn fromWindowMessage(msg: winapi.WindowMessageType, wparam: winapi.WPARAM, _: winapi.LPARAM) @This() {
        return switch (msg) {
            .LMouseButtonUp => Event{ .MouseButton = .{ .button = .Left, .state = .Released } },
            .LMouseButtonDown => Event{ .MouseButton = .{ .button = .Left, .state = .Pressed } },
            .MMouseButtonUp => Event{ .MouseButton = .{ .button = .Middle, .state = .Released } },
            .MMouseButtonDown => Event{ .MouseButton = .{ .button = .Middle, .state = .Pressed } },
            .RMouseButtonUp => Event{ .MouseButton = .{ .button = .Right, .state = .Released } },
            .RMouseButtonDown => Event{ .MouseButton = .{ .button = .Right, .state = .Pressed } },
            .KeyUp => Event{ .Key = .{ .key = @enumFromInt(wparam), .state = .Released } },
            .KeyDown => Event{ .Key = .{ .key = @enumFromInt(wparam), .state = .Pressed } },
            .Close => Event{ .Close = undefined },
            else => Event{ .Unknown = undefined },
        };
    }
};
