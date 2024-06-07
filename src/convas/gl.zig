const winapi = @import("winapi.zig");

//OpenGL types
const GLenum = u32;
const GLboolean = u8;
const GLbitfield = u32;
const GLbyte = i8;
const GLshort = i16;

const GLint = i32;
const GLsizei = i32;

const GLubyte = u8;
const GLushort = u16;
const GLuint = u32;

const GLfloat = f32;
const GLclampf = f32;
const GLdouble = f64;
const GLclampd = f64;
const GLvoid = void;

pub const AttributeMask = struct {
    pub const ColorBufferBit = 0x00004000;
};

pub const BeginMode = enum(GLenum) {
    Triangles = 0x0004,
};

pub const createContext = wglCreateContext;
pub const deleteContext = wglDeleteContext;
pub const selectContext = wglMakeCurrent;
pub const ortho = glOrtho;
pub const clearColor = glClearColor;
pub const begin = glBegin;
pub const end = glEnd;
pub const clear = glClear;
pub const color3f = glColor3f;
pub const flush = glFlush;
pub const vertex2f = glVertex2f;
pub const swapBuffers = SwapBuffers;
pub const viewport = glViewport;

extern "Opengl32" fn wglMakeCurrent(dc: ?winapi.HDC, hglrc: ?winapi.HGLRC) callconv(winapi.WINAPI) winapi.BOOL;
extern "Opengl32" fn wglCreateContext(hdc: winapi.HDC) callconv(winapi.WINAPI) ?winapi.HGLRC;
extern "Opengl32" fn wglDeleteContext(hglrc: winapi.HGLRC) callconv(winapi.WINAPI) winapi.BOOL;
extern "Opengl32" fn glOrtho(left: GLdouble, right: GLdouble, bottom: GLdouble, top: GLdouble, zNear: GLdouble, zFar: GLdouble) callconv(winapi.WINAPI) void;
extern "Opengl32" fn glClearColor(red: GLclampf, green: GLclampf, blue: GLclampf, alpha: GLclampf) callconv(winapi.WINAPI) void;
extern "Opengl32" fn glBegin(mode: BeginMode) callconv(winapi.WINAPI) void;
extern "Opengl32" fn glEnd() callconv(winapi.WINAPI) void;
extern "Opengl32" fn glClear(mask: GLbitfield) callconv(winapi.WINAPI) void;
extern "Opengl32" fn glColor3f(red: GLfloat, green: GLfloat, blue: GLfloat) callconv(winapi.WINAPI) void;
extern "Opengl32" fn glFlush() callconv(winapi.WINAPI) void;
extern "Opengl32" fn glVertex2f(x: GLfloat, y: GLfloat) callconv(winapi.WINAPI) void;
extern "Opengl32" fn glViewport(x: GLint, y: GLint, width: GLsizei, height: GLsizei) callconv(winapi.WINAPI) void;

extern "Gdi32" fn SwapBuffers(hdc: winapi.HDC) callconv(winapi.WINAPI) winapi.BOOL;
