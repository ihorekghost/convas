const std = @import("std");

const windows = std.os.windows;

pub const WindowMessageType = enum(windows.UINT) {
    LMouseButtonUp = 0x0202,
    LMouseButtonDown = 0x0201,
    MMouseButtonUp = 0x0208,
    MMouseButtonDown = 0x0207,
    RMouseButtonUp = 0x0205,
    RMouseButtonDown = 0x0204,
    MouseMove = 0x0200,
    KeyUp = 0x0101,
    KeyDown = 0x0100,
    Close = 0x0010,
    Create = 0x0001,
    Destroy = 0x0002,
    SetFocus = 0x0007,
    KillFocus = 0x0008,
    Resize = 0x0005,
    Resizing = 0x0214,
    Paint = 15,
    _,
};

pub const WNDPROC = *const fn (windows.HWND, WindowMessageType, windows.WPARAM, windows.LPARAM) callconv(windows.WINAPI) windows.LRESULT;

pub const WNDCLASSW = extern struct {
    style: windows.UINT,
    lpfnWndProc: WNDPROC,
    cbClsExtra: c_int,
    cbWndExtra: c_int,
    hInstance: windows.HINSTANCE,
    hIcon: ?windows.HICON,
    hCursor: ?windows.HCURSOR,
    hbrBackground: ?windows.HBRUSH,
    lpszMenuName: ?windows.LPCWSTR,
    lpszClassName: windows.LPCWSTR,
};

pub const PIXELFORMATDESCRIPTOR = extern struct {
    pub const Flags = struct {
        pub const SupportOpenGL = 0x00000020;
        pub const DoubleBuffer = 0x00000001;
        pub const DrawToWindow = 0x00000004;
    };

    pub const PixelType = enum(windows.BYTE) {
        Rgba = 0,
        ColorIndex = 1,
        _,
    };

    nSize: windows.WORD,
    nVersion: windows.WORD,
    dwFlags: windows.DWORD,
    iPixelType: PixelType,
    cColorBits: windows.BYTE,
    cRedBits: windows.BYTE,
    cRedShift: windows.BYTE,
    cGreenBits: windows.BYTE,
    cGreenShift: windows.BYTE,
    cBlueBits: windows.BYTE,
    cBlueShift: windows.BYTE,
    cAlphaBits: windows.BYTE,
    cAlphaShift: windows.BYTE,
    cAccumBits: windows.BYTE,
    cAccumRedBits: windows.BYTE,
    cAccumGreenBits: windows.BYTE,
    cAccumBlueBits: windows.BYTE,
    cAccumAlphaBits: windows.BYTE,
    cDepthBits: windows.BYTE,
    cStencilBits: windows.BYTE,
    cAuxBuffers: windows.BYTE,
    iLayerType: windows.BYTE,
    bReserved: windows.BYTE,
    dwLayerMask: windows.DWORD,
    dwVisibleMask: windows.DWORD,
    dwDamageMask: windows.DWORD,
};

pub extern "User32" fn UnregisterClassW(class_name: windows.LPCWSTR, hInstance: windows.HINSTANCE) callconv(windows.WINAPI) windows.BOOL;
pub extern "Kernel32" fn GetModuleHandleW(lpModuleName: ?windows.LPCWSTR) callconv(windows.WINAPI) ?windows.HMODULE;
pub extern "Gdi32" fn SetPixelFormat(hdc: windows.HDC, format: c_int, ppfd: *const PIXELFORMATDESCRIPTOR) callconv(windows.WINAPI) windows.BOOL;
pub extern "Gdi32" fn ChoosePixelFormat(hdc: windows.HDC, ppfd: *const PIXELFORMATDESCRIPTOR) callconv(windows.WINAPI) c_int;
pub extern "User32" fn RegisterClassW(class: *const WNDCLASSW) callconv(windows.WINAPI) windows.ATOM;
pub extern "User32" fn CreateWindowExW(
    dwExStyle: windows.DWORD,
    lpClassName: ?windows.LPCWSTR,
    lpWindowName: ?windows.LPCWSTR,
    dwStyle: windows.DWORD,
    pos_x: c_int,
    pos_y: c_int,
    size_x: c_int,
    size_y: c_int,
    hWndParent: ?windows.HWND,
    hMenu: ?windows.HMENU,
    hInstance: ?windows.HINSTANCE,
    lpParam: ?windows.LPVOID,
) callconv(windows.WINAPI) ?windows.HWND;
pub extern "User32" fn DestroyWindow(window: windows.HWND) callconv(windows.WINAPI) windows.BOOL;
pub extern "User32" fn LoadCursorW(hInstance: ?windows.HINSTANCE, cursor: windows.LPCWSTR) callconv(windows.WINAPI) ?windows.HCURSOR;
pub extern "User32" fn GetDC(hwnd: ?windows.HWND) callconv(windows.WINAPI) ?windows.HDC;
pub extern "User32" fn ReleaseDC(hwnd: windows.HWND, hdc: windows.HDC) callconv(windows.WINAPI) c_int;
