const win = @import("std").os.windows;
pub usingnamespace win;

pub const WNDPROC = *const fn (win.HWND, win.UINT, win.WPARAM, win.LPARAM) callconv(win.WINAPI) win.LRESULT;

pub const WS_MINIMIZEBOX = 0x00020000;
pub const WS_MAXIMIZEBOX = 0x00010000;
pub const WS_CAPTION = 0x00C00000;
pub const WS_SYSMENU = 0x00080000;
pub const WS_THICKFRAME = 0x00040000;
pub const WS_OVERLAPPED = 0;
pub const WS_OVERLAPPED_WINDOW = (WS_OVERLAPPED | WS_THICKFRAME | WS_CAPTION | WS_MINIMIZEBOX | WS_MAXIMIZEBOX | WS_SYSMENU);

pub const PM_REMOVE = 1;

pub const WM_LBUTTONUP = 0x0202;

pub const WNDCLASSW = extern struct {
    style: win.UINT,
    lpfnWndProc: WNDPROC,
    cbClsExtra: i32,
    cbWndExtra: i32,
    hInstance: win.HINSTANCE,
    hIcon: win.HICON,
    hCursor: win.HCURSOR,
    hbrBackground: win.HBRUSH,
    lpszMenuName: win.LPCWSTR,
    lpszClassName: win.LPCWSTR,
};

pub const MSG = extern struct { hwnd: win.HWND, msg: win.UINT, wparam: win.WPARAM, lparam: win.LPARAM, time: win.DWORD, cursor: win.POINT, lpPrivate: win.DWORD };

pub extern "Kernel32" fn GetModuleHandleW(lpModuleName: ?win.LPCWSTR) callconv(win.WINAPI) win.HMODULE;
pub extern "User32" fn RegisterClassW(class: *const WNDCLASSW) callconv(win.WINAPI) win.ATOM;
pub extern "User32" fn UnregisterClassW(class_name: win.LPCWSTR, hInstance: win.HINSTANCE) callconv(win.WINAPI) win.BOOL;
pub extern "User32" fn CreateWindowExW(
    dwExStyle: win.DWORD,
    lpClassName: ?win.LPCWSTR,
    lpWindowName: ?win.LPCWSTR,
    dwStyle: win.DWORD,
    X: i32,
    Y: i32,
    nWidth: i32,
    nHeight: i32,
    hWndParent: ?win.HWND,
    hMenu: ?win.HMENU,
    hInstance: ?win.HINSTANCE,
    lpPara: ?win.LPVOID,
) callconv(win.WINAPI) ?win.HWND;
pub extern "User32" fn ShowWindow(window: win.HWND, nShowCmd: i32) callconv(win.WINAPI) win.BOOL;
pub extern "User32" fn DestroyWindow(window: win.HWND) callconv(win.WINAPI) win.BOOL;
pub extern "Kernel32" fn GetLastError() callconv(win.WINAPI) win.DWORD;
pub extern "User32" fn DefWindowProcW(win.HWND, win.UINT, win.WPARAM, win.LPARAM) callconv(win.WINAPI) win.LRESULT;
pub extern "Gdi32" fn CreateSolidBrush(color: win.DWORD) callconv(win.WINAPI) ?win.HBRUSH;
pub extern "Gdi32" fn DeleteObject(object: *opaque {}) callconv(win.WINAPI) win.BOOL;
pub extern "User32" fn PeekMessageW(msg: *MSG, hwnd: win.HWND, msg_filter_min: win.UINT, msg_filter_max: win.UINT, remove_msg: win.UINT) callconv(win.WINAPI) win.BOOL;
pub extern "User32" fn DispatchMessageW(msg: *const MSG) callconv(win.WINAPI) win.LRESULT;
pub extern "User32" fn TranslateMessage(msg: *const MSG) callconv(win.WINAPI) win.BOOL;
