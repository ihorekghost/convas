const std = @import("std");
const convas = @import("convas/convas.zig");
const window = convas.window;

const utf16Le = convas.utf16LeLiteral;

fn onWindowEvent(event: window.Event) void {
    if (event == .Close) window.deinit();
}

pub fn main() !void {
    try convas.init();
    defer convas.deinit();

    try window.init(.{ .title = utf16Le("My Window"), .event_handler = onWindowEvent });

    try window.show();

    while (window.pollEvents()) {
        window.update();
        std.time.sleep(16_666_666);
    }

    std.debug.print("Window Destroyed!", .{});
}
