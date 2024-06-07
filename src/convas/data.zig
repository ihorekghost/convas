const winapi = @import("winapi.zig");

pub var instance: ?@This() = null;

//Handle to current executable's module
module_instance_handle: winapi.HINSTANCE,

pub fn get() *@This() {
    if (instance) |*data| return data;

    @panic("convas used when not initialized!");
}
