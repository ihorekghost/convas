const std = @import("std");
const convas = @import("convas/convas.zig");
const window = convas.window;

const utf16Le = convas.utf16LeLiteral;

pub fn main() !void {
    try convas.init();

    try window.init(.{ .title = utf16Le("Main") });

    window.show();

    main_loop: while (window.pollEvents()) {
        //Event loop
        while (window.getEvent()) |event| {
            switch (event) {
                .Close => {
                    try window.deinit();
                    break :main_loop;
                },

                else => {},
            }
        }

        window.update();
    }
}
