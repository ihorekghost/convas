const std = @import("std");

const data = @import("data.zig");
const winapi = @import("winapi.zig");
const window_class = @import("window_class.zig");

pub const window = @import("window/window.zig");
pub const screen = @import("screen/screen.zig");

pub const utf16LeLiteral = std.unicode.utf8ToUtf16LeStringLiteral;

pub const Error = error{
    ConvasAlreadyInitialized,
    ConvasNotInitialized,
};

pub fn init() !void {
    if (isInitialized()) return Error.ConvasAlreadyInitialized;

    data.instance = .{ .module_instance_handle = @ptrCast(winapi.GetModuleHandleW(null)) };

    screen.init() catch |err| {
        if (err != screen.Error.ScreenAlreadyInitialized) return err;
    };

    try window_class.init();
}

pub fn deinit() !void {
    window.deinit() catch |err| {
        if (err != window.Error.ConvasWindowNotInitialized) return err;
    };
    try screen.deinit();
    try window_class.deinit();
}

pub fn isInitialized() bool {
    return data.instance != null;
}
