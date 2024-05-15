const std = @import("std");
const convas = @import("convas/convas.zig");
const console = convas.console;

fn printErrorCode() void {
    std.debug.print("Error code : {}\n", .{convas.getLastWinError()});
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    _ = stdout;

    errdefer printErrorCode();

    try convas.init();
    try console.init();

    try console.show();

    _ = try stdin.readByte();

    try convas.deinit();
}
