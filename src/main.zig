const std = @import("std");
const convas = @import("convas/convas.zig");
const console = convas.console;

fn init() !void {
    try convas.init();

    try console.init();

    try console.show();
}

fn deinit() !void {
    try convas.deinit();
}

fn printErrorCode() void {
    std.debug.print("Error code : {}\n", .{convas.getLastWinError()});
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    _ = stdout;

    init() catch |err| {
        printErrorCode();
        return err;
    };

    _ = try stdin.readByte();

    deinit() catch |err| {
        printErrorCode();
        return err;
    };
}
