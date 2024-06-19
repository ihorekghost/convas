const std = @import("std");
const builtin = @import("builtin");

const window_class = @import("window/class.zig");
pub const gl = @import("gl/gl.zig");

pub const winapi = @import("winapi/winapi.zig");
pub const window = @import("window/window.zig");
pub const screen = @import("screen.zig");

pub const utf16LeLiteral = std.unicode.utf8ToUtf16LeStringLiteral;

pub var _instance: ?@This() = null;

//Handle to current executable's module
module_instance_handle: winapi.HINSTANCE,

///**For private use.**
pub fn get() *@This() {
    if (builtin.mode == .Debug or builtin.mode == .ReleaseSafe) {
        if (!isInitialized()) @panic("convas used when not initialized");
    }

    return &_instance.?;
}

///Initialize Convas.
pub fn init() !void {
    if (builtin.mode == .Debug or builtin.mode == .ReleaseSafe) {
        if (isInitialized()) @panic("convas.init() when already initialized");
    }

    _instance = .{ .module_instance_handle = @ptrCast(try winapi.GetModuleHandleW(null)) };

    try window_class.init();
}

///Deinitialize Convas.
pub fn deinit() !void {
    if (builtin.mode == .Debug or builtin.mode == .ReleaseSafe) {
        if (!isInitialized()) @panic("convas.deinit() when already deinitialized");
    }

    if (window.canvas.isInitialized()) try window.canvas.deinit();
    if (window.isInitialized()) try window.deinit();

    try window_class.deinit();

    _instance = null;
}

pub fn isInitialized() bool {
    return _instance != null;
}
