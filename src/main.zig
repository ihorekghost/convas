const std = @import("std");
const convas = @import("convas/convas.zig");
const window = convas.window;

pub fn main() !void {
    try convas.init();

    try window.init(window.Options{ .title = convas.utf16LeLiteral("My window!") });

    try window.show();

    while (window.isInitialized()) {
        while (window.getEvent()) |event| {
            _ = event;
        }
    }

    try convas.deinit();
}
