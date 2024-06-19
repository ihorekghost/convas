//!Bindings for OpenGL. **Everything for private use, except getVersion() and getExtensions().**
const std = @import("std");

const winapi = @import("../winapi/winapi.zig");
const raw = @import("raw.zig");

const WINAPI = winapi.WINAPI;

pub const Error = error{
    SelectContextFail,
    CreateContextFail,
    DeleteContextFail,
    GetProcAddressFail,
    SwapIntervalFail,
    CreateShaderFail,
    SwapBuffersFail,
};

//OpenGL types
pub const GLenum = u32;
pub const GLboolean = u8;
pub const GLbitfield = u32;
pub const GLbyte = i8;
pub const GLshort = i16;
pub const GLint = i32;
pub const GLsizei = i32;
pub const GLubyte = u8;
pub const GLushort = u16;
pub const GLuint = u32;
pub const GLfloat = f32;
pub const GLclampf = f32;
pub const GLdouble = f64;
pub const GLclampd = f64;
pub const GLchar = c_char;
pub const GLvoid = void;

pub const AttributeMask = struct {
    pub const ColorBufferBit = 0x00004000;
};

pub const BeginMode = enum(GLenum) {
    Triangles = 0x0004,
};

pub const StringName = enum(GLenum) {
    Version = 0x1F02,
    Extensions = 0x1F03,
    Renderer = 0x1F01,
    Vendor = 0x1F00,
};

pub const ShaderType = enum(GLenum) {
    Vertex = 0x8B31,
    Fragment = 0x8B30,
};

extern "Opengl32" fn glOrtho(left: GLdouble, right: GLdouble, bottom: GLdouble, top: GLdouble, zNear: GLdouble, zFar: GLdouble) callconv(WINAPI) void;
extern "Opengl32" fn glClearColor(red: GLclampf, green: GLclampf, blue: GLclampf, alpha: GLclampf) callconv(WINAPI) void;
extern "Opengl32" fn glBegin(mode: BeginMode) callconv(WINAPI) void;
extern "Opengl32" fn glEnd() callconv(WINAPI) void;
extern "Opengl32" fn glClear(mask: GLbitfield) callconv(WINAPI) void;
extern "Opengl32" fn glColor3f(red: GLfloat, green: GLfloat, blue: GLfloat) callconv(WINAPI) void;
extern "Opengl32" fn glFlush() callconv(WINAPI) void;
extern "Opengl32" fn glVertex2f(x: GLfloat, y: GLfloat) callconv(WINAPI) void;
extern "Opengl32" fn glViewport(x: GLint, y: GLint, width: GLsizei, height: GLsizei) callconv(WINAPI) void;
extern "Opengl32" fn glGetString(string: StringName) callconv(WINAPI) [*:0]const u8;

extern "Opengl32" fn wglMakeCurrent(dc: ?winapi.HDC, hglrc: ?winapi.HGLRC) callconv(WINAPI) winapi.BOOL;
extern "Opengl32" fn wglCreateContext(hdc: winapi.HDC) callconv(WINAPI) ?winapi.HGLRC;
extern "Opengl32" fn wglDeleteContext(hglrc: winapi.HGLRC) callconv(WINAPI) winapi.BOOL;
extern "Gdi32" fn SwapBuffers(hdc: winapi.HDC) callconv(WINAPI) winapi.BOOL;

pub fn createContext(hdc: winapi.HDC) !winapi.HGLRC {
    const context = wglCreateContext(hdc);

    if (context) |result| return result;

    return Error.CreateContextFail;
}

pub fn selectContext(dc: ?winapi.HDC, hglrc: ?winapi.HGLRC) !void {
    if (wglMakeCurrent(dc, hglrc) == winapi.FALSE) return Error.SelectContextFail;
}

pub fn deleteContext(hglrc: winapi.HGLRC) !void {
    if (wglDeleteContext(hglrc) == winapi.FALSE) return Error.DeleteContextFail;
}

pub fn getVersion() [*:0]const u8 {
    return getString(StringName.Version);
}

pub fn getExtensions() [*:0]const u8 {
    return getString(StringName.Extensions);
}

pub fn swapInterval(interval: c_int) !void {
    if (wglSwapIntervalEXT(interval) == winapi.FALSE) return Error.SwapIntervalFail;
}

pub fn createShader(shader_type: ShaderType) !GLuint {
    const result = glCreateShader(shader_type);

    if (result == 0) return Error.CreateShaderFail;

    return result;
}

pub fn swapBuffers(hdc: winapi.HDC) !void {
    if (SwapBuffers(hdc) == winapi.FALSE) return Error.SwapBuffersFail;
}

pub const ortho = glOrtho;
pub const clearColor = glClearColor;
pub const begin = glBegin;
pub const end = glEnd;
pub const clear = glClear;
pub const color3f = glColor3f;
pub const flush = glFlush;
pub const vertex2f = glVertex2f;
pub const viewport = glViewport;
pub const getString = glGetString;

var wglSwapIntervalEXT: *fn (interval: c_int) callconv(WINAPI) winapi.BOOL = undefined;

var glCreateShader: *fn (shader_type: ShaderType) callconv(.C) GLuint = undefined;

pub var shaderSource: *fn (shader: GLuint, count: GLsizei, string: **const GLchar, length: *const GLint) callconv(.C) void = undefined;
pub var compileShader: *fn (shader: GLuint) callconv(.C) void = undefined;
pub var getShaderiv: *fn (shader: GLuint, name: GLenum, params: *GLint) callconv(.C) void = undefined;
pub var getShaderInfoLog: *fn (shader: GLuint, maxLength: GLsizei, length: *GLsizei, info_log: *GLchar) callconv(.C) void = undefined;
pub var createProgram: *fn () callconv(.C) GLuint = undefined;
pub var attachShader: *fn (program: GLuint, shader: GLuint) callconv(.C) void = undefined;
pub var linkProgram: *fn (program: GLuint) callconv(.C) void = undefined;

//Dynamic Load
pub fn getProcAddress(name: winapi.LPCSTR) !winapi.PROC {
    if (raw.wglGetProcAddress(name)) |proc| return proc;

    return Error.GetProcAddressFail;
}

pub fn init() !void {
    wglSwapIntervalEXT = @ptrCast(try getProcAddress("wglSwapIntervalEXT"));
    glCreateShader = @ptrCast(try getProcAddress("glCreateShader"));
    shaderSource = @ptrCast(try getProcAddress("glShaderSource"));
    getShaderiv = @ptrCast(try getProcAddress("glGetShaderiv"));
    getShaderInfoLog = @ptrCast(try getProcAddress("glGetShaderInfoLog"));
    createProgram = @ptrCast(try getProcAddress("glCreateProgram"));
    attachShader = @ptrCast(try getProcAddress("glAttachShader"));
    linkProgram = @ptrCast(try getProcAddress("glLinkProgram"));
    compileShader = @ptrCast(try getProcAddress("glCompileShader"));
}
