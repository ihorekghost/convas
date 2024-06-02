const std = @import("std");

const winapi = @import("winapi.zig");
const window_class = @import("window_class.zig");

pub const window = @import("window.zig");
pub const screen = @import("screen.zig");

pub const utf16LeLiteral = std.unicode.utf8ToUtf16LeStringLiteral;

pub const Error = error{
    ConvasAlreadyInitialized,
    ConvasNotInitialized,
};

pub var _instance: ?@This() = null;

module_instance_handle: winapi.HINSTANCE,

pub fn init() !void {
    if (isInitialized()) return Error.ConvasAlreadyInitialized;

    _instance = .{ .module_instance_handle = @ptrCast(winapi.GetModuleHandleW(null)) };

    screen.init() catch |err| {
        if (err != screen.Error.ConvasScreenAlreadyInitialized) return err;
    };

    try window_class.init();
}

pub fn deinit() void {
    screen.deinit();
    window_class.deinit();

    _instance = null;
}

pub fn _getModuleInstanceHandle() !winapi.HINSTANCE {
    if (_instance) |convas| return convas.module_instance_handle;

    return Error.ConvasNotInitialized;
}

pub fn isInitialized() bool {
    return _instance != null;
}
