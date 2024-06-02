const std = @import("std");
const meta = @import("meta.zig");
const windows = std.os.windows;

pub usingnamespace windows;

pub fn LOWORD(number: anytype) i16 {
    comptime {
        if (!meta.isNumeric(@TypeOf(number))) @compileError("\"number\" must be a numeric type!");
    }

    return @intCast(number & 0xffff);
}

pub fn HIWORD(number: anytype) i16 {
    comptime {
        if (!meta.isNumeric(@TypeOf(number))) @compileError("\"number\" must be a numeric type!");
    }

    return @intCast((number >> 16) & 0xffff);
}

//Kernel32
pub extern "Kernel32" fn GetModuleHandleW(lpModuleName: ?windows.LPCWSTR) callconv(windows.WINAPI) windows.HMODULE;
pub extern "Kernel32" fn GetLastError() callconv(windows.WINAPI) windows.DWORD;

//Gdi32
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

pub extern "Gdi32" fn SetPixelFormat(hdc: windows.HDC, format: i32, ppfd: *const PIXELFORMATDESCRIPTOR) windows.BOOL;
pub extern "Gdi32" fn CreateSolidBrush(color: windows.DWORD) callconv(windows.WINAPI) ?windows.HBRUSH;
pub extern "Gdi32" fn DeleteObject(object: *opaque {}) callconv(windows.WINAPI) windows.BOOL;
pub extern "Gdi32" fn ChoosePixelFormat(hdc: windows.HDC, ppfd: *const PIXELFORMATDESCRIPTOR) callconv(windows.WINAPI) i32;

//User32 (-------------------------------------
pub const SystemMetric = enum(i32) {
    ScreenWidth = 0,
    ScreenHeight = 1,
    _,
};

pub const WNDPROC = *const fn (windows.HWND, WindowMessageType, windows.WPARAM, windows.LPARAM) callconv(windows.WINAPI) windows.LRESULT;

pub const PeekMessageAction = struct {
    pub const Remove = 1;
};

pub const WindowLong = enum(i32) {
    GWLPUserData = -21,
    _,
};

pub const Cursor = struct {
    pub const Arrow = MAKEINTRESOURCEW(32512);
};

pub const WindowStyle = struct {
    pub const MinimizeBox = 0x00020000;
    pub const MaximizeBox = 0x00010000;
    pub const Caption = 0x00C00000;
    pub const SysMenu = 0x00080000;
    pub const ThickFrame = 0x00040000;
    pub const Overlapped = 0;
    pub const OverlappedWindow = MinimizeBox | MaximizeBox | Caption | SysMenu | ThickFrame | Overlapped;
};

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
    _,
};

pub const WindowClassStyle = enum(windows.UINT) {
    OwnDC = 0x0020,
};

pub const WindowVisibility = enum(i32) {
    pub fn fromBool(visible: bool) i32 {
        return switch (visible) {
            true => @This().Show,
            false => @This().Hide,
        };
    }

    Show = 5,
    Hide = 0,
    _,
};

pub const WNDCLASSW = extern struct {
    style: windows.UINT,
    lpfnWndProc: WNDPROC,
    cbClsExtra: i32,
    cbWndExtra: i32,
    hInstance: windows.HINSTANCE,
    hIcon: ?windows.HICON,
    hCursor: ?windows.HCURSOR,
    hbrBackground: ?windows.HBRUSH,
    lpszMenuName: ?windows.LPCWSTR,
    lpszClassName: windows.LPCWSTR,
};

pub const MSG = extern struct {
    hwnd: windows.HWND,
    msg: WindowMessageType,
    wparam: windows.WPARAM,
    lparam: windows.LPARAM,
    time: windows.DWORD,
    cursor: windows.POINT,
    lpPrivate: windows.DWORD,
};

pub extern "User32" fn RegisterClassW(class: *const WNDCLASSW) callconv(windows.WINAPI) windows.ATOM;
pub extern "User32" fn UnregisterClassW(class_name: windows.LPCWSTR, hInstance: windows.HINSTANCE) callconv(windows.WINAPI) windows.BOOL;
pub extern "User32" fn CreateWindowExW(
    dwExStyle: windows.DWORD,
    lpClassName: ?windows.LPCWSTR,
    lpWindowName: ?windows.LPCWSTR,
    dwStyle: windows.DWORD,
    pos_x: i32,
    pos_y: i32,
    size_x: i32,
    size_y: i32,
    hWndParent: ?windows.HWND,
    hMenu: ?windows.HMENU,
    hInstance: ?windows.HINSTANCE,
    lpPara: ?windows.LPVOID,
) callconv(windows.WINAPI) ?windows.HWND;
pub extern "User32" fn ShowWindow(window: windows.HWND, show_cmd: WindowVisibility) callconv(windows.WINAPI) windows.BOOL;
pub extern "User32" fn DestroyWindow(window: windows.HWND) callconv(windows.WINAPI) windows.BOOL;
pub extern "User32" fn DefWindowProcW(windows.HWND, WindowMessageType, windows.WPARAM, windows.LPARAM) callconv(windows.WINAPI) windows.LRESULT;
pub extern "User32" fn PeekMessageW(msg: *MSG, hwnd: ?windows.HWND, msg_filter_min: windows.UINT, msg_filter_max: windows.UINT, remove_msg: windows.UINT) callconv(windows.WINAPI) windows.BOOL;
pub extern "User32" fn DispatchMessageW(msg: *const MSG) callconv(windows.WINAPI) windows.LRESULT;
pub extern "User32" fn TranslateMessage(msg: *const MSG) callconv(windows.WINAPI) windows.BOOL;
pub extern "User32" fn GetMessageW(msg: *MSG, hwnd: ?windows.HWND, msg_filter_min: windows.UINT, msg_filter_max: windows.UINT) callconv(windows.WINAPI) windows.BOOL;
pub extern "User32" fn LoadCursorW(hInstance: ?windows.HINSTANCE, cursor: windows.LPCWSTR) callconv(windows.WINAPI) windows.HCURSOR;
pub extern "User32" fn PostQuitMessage(exitCode: i32) callconv(windows.WINAPI) void;
pub extern "User32" fn SetWindowLongPtrW(hwnd: windows.HWND, long: WindowLong, value: windows.LONG_PTR) callconv(windows.WINAPI) windows.LONG_PTR;
pub extern "User32" fn GetCursorPos(pos: *windows.POINT) callconv(windows.WINAPI) windows.BOOL;
pub extern "User32" fn GetSystemMetrics(metric: SystemMetric) callconv(windows.WINAPI) i32;
pub extern "User32" fn GetDC(hwnd: ?windows.HWND) callconv(windows.WINAPI) ?windows.HDC;
//--------------------------)

pub fn MAKEINTRESOURCEW(i: anytype) windows.LPCWSTR {
    return @ptrFromInt(i);
}

pub const VirtualKey = enum(usize) {
    LButton = 0x01,
    RButton = 0x02,
    Cancel = 0x03,
    MButton = 0x04,
    XButton1 = 0x05,
    XButton2 = 0x06,
    Back = 0x08,
    Tab = 0x09,
    Clear = 0x0C,
    Return = 0x0D,
    Shift = 0x10,
    Control = 0x11,
    Menu = 0x12,
    Pause = 0x13,
    Capital = 0x14,
    Kana = 0x15,
    ImeOn = 0x16,
    Junja = 0x17,
    Final = 0x18,
    Hanja = 0x19,
    ImeOff = 0x1A,
    Escape = 0x1B,
    Convert = 0x1C,
    NonConvert = 0x1D,
    Accept = 0x1E,
    ModeChange = 0x1F,
    Space = 0x20,
    Prior = 0x21,
    Next = 0x22,
    End = 0x23,
    Home = 0x24,
    Left = 0x25,
    Up = 0x26,
    Right = 0x27,
    Down = 0x28,
    Select = 0x29,
    Print = 0x2A,
    Execute = 0x2B,
    Snapshot = 0x2C,
    Insert = 0x2D,
    Delete = 0x2E,
    Help = 0x2F,
    Zero = 0x30,
    One = 0x31,
    Two = 0x32,
    Three = 0x33,
    Four = 0x34,
    Five = 0x35,
    Six = 0x36,
    Seven = 0x37,
    Eight = 0x38,
    Nine = 0x39,
    A = 0x41,
    B = 0x42,
    C = 0x43,
    D = 0x44,
    E = 0x45,
    F = 0x46,
    G = 0x47,
    H = 0x48,
    I = 0x49,
    J = 0x4A,
    K = 0x4B,
    L = 0x4C,
    M = 0x4D,
    N = 0x4E,
    O = 0x4F,
    P = 0x50,
    Q = 0x51,
    R = 0x52,
    S = 0x53,
    T = 0x54,
    U = 0x55,
    V = 0x56,
    W = 0x57,
    X = 0x58,
    Y = 0x59,
    Z = 0x5A,
    LWin = 0x5B,
    RWin = 0x5C,
    Apps = 0x5D,
    Sleep = 0x5F,
    Numpad0 = 0x60,
    Numpad1 = 0x61,
    Numpad2 = 0x62,
    Numpad3 = 0x63,
    Numpad4 = 0x64,
    Numpad5 = 0x65,
    Numpad6 = 0x66,
    Numpad7 = 0x67,
    Numpad8 = 0x68,
    Numpad9 = 0x69,
    Multiply = 0x6A,
    Add = 0x6B,
    Separator = 0x6C,
    Subtract = 0x6D,
    Decimal = 0x6E,
    Divide = 0x6F,
    F1 = 0x70,
    F2 = 0x71,
    F3 = 0x72,
    F4 = 0x73,
    F5 = 0x74,
    F6 = 0x75,
    F7 = 0x76,
    F8 = 0x77,
    F9 = 0x78,
    F10 = 0x79,
    F11 = 0x7A,
    F12 = 0x7B,
    F13 = 0x7C,
    F14 = 0x7D,
    F15 = 0x7E,
    F16 = 0x7F,
    F17 = 0x80,
    F18 = 0x81,
    F19 = 0x82,
    F20 = 0x83,
    F21 = 0x84,
    F22 = 0x85,
    F23 = 0x86,
    F24 = 0x87,
    NumLock = 0x90,
    Scroll = 0x91,
    LShift = 0xA0,
    RShift = 0xA1,
    LControl = 0xA2,
    RControl = 0xA3,
    LMenu = 0xA4,
    RMenu = 0xA5,
    BrowserBack = 0xA6,
    BrowserForward = 0xA7,
    BrowserRefresh = 0xA8,
    BrowserStop = 0xA9,
    BrowserSearch = 0xAA,
    BrowserFavorites = 0xAB,
    BrowserHome = 0xAC,
    VolumeMute = 0xAD,
    VolumeDown = 0xAE,
    VolumeUp = 0xAF,
    MediaNextTrack = 0xB0,
    MediaPrevTrack = 0xB1,
    MediaStop = 0xB2,
    MediaPlayPause = 0xB3,
    LaunchMail = 0xB4,
    LaunchMediaSelect = 0xB5,
    LaunchApp1 = 0xB6,
    LaunchApp2 = 0xB7,
    Oem1 = 0xBA,
    OemPlus = 0xBB,
    OemComma = 0xBC,
    OemMinus = 0xBD,
    OemPeriod = 0xBE,
    Oem2 = 0xBF,
    Oem3 = 0xC0,
    Oem4 = 0xDB,
    Oem5 = 0xDC,
    Oem6 = 0xDD,
    Oem7 = 0xDE,
    Oem8 = 0xDF,
    Oem102 = 0xE2,
    ProcessKey = 0xE5,
    Packet = 0xE7,
    Attn = 0xF6,
    CrSel = 0xF7,
    ExSel = 0xF8,
    ErEof = 0xF9,
    Play = 0xFA,
    Zoom = 0xFB,
    NoName = 0xFC,
    Pa1 = 0xFD,
    OemClear = 0xFE,
    _,
};
