const std = @import("std");

//const builtin = @import("builtin");

const time = std.time;

const convas = @import("convas/convas.zig");
const window = convas.window;
const canvas = window.canvas;

pub const log_level: std.log.Level = .info;

pub fn main() !void {
    //Initialize convas namespace.
    try convas.init();

    //Intialize convas.window namespace by creating a window with certain properties.
    try window.init(.{ .title = convas.utf16LeLiteral("asd") });

    //Initialize canvas for drawing with size of 16x16 glyphs.
    try canvas.init(.{ .size_glyphs = .{ 8, 16 } });

    //Print OpenGL version
    std.log.info("OpenGL Version: {s}\n", .{convas.gl.getVersion()});
    std.log.info("OpenGL Extensions: {s}\n", .{convas.gl.getExtensions()});

    //Window is hidden by default, so show it.
    window.show();

    //Initialize timer for delta time calculation.
    //var delta_timer = try time.Timer.start();

    //Application main loop.
    main_loop: while (true) {

        //Update the event queue.
        window.updateEvents();

        //Iterate through every event in the queue and process it.
        for (window.getEvents()) |event| {
            switch (event) {
                .Close => {
                    try window.deinit();
                },
                .Destroy => {
                    try window.canvas.deinit();

                    break :main_loop;
                },
                else => {},
            }
        }

        //Clear the event queue of the window.
        window.clearEvents();

        if (window.isInitialized()) {
            //DRAW HERE ...
            canvas.drawLayer();

            //Apply changes made by drawing.
            canvas.update();

            //Print the FPS.
            //std.debug.print("FPS: {d}\n", .{1.0 / (@as(f64, @floatFromInt(delta_timer.lap())) / time.ns_per_s)});
        }
    }

    //All the subnamespaces can be deinitialize with one call to convas.deinit()
    try convas.deinit();
}
