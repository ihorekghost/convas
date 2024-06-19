const winapi = @import("../winapi/winapi.zig");

pub extern "Opengl32" fn wglGetProcAddress(name: winapi.LPCSTR) callconv(winapi.WINAPI) ?winapi.PROC;
