const std = @import("std");
const builtin = @import("builtin");
const core = @import("easytouch_core");

const BOOL = i32;
const UINT = u32;
const DWORD = u32;
const WORD = u16;
const LONG = i32;
const LPARAM = isize;
const HANDLE = ?*anyopaque;
const HWND = HANDLE;
const HDC = HANDLE;
const HBITMAP = HANDLE;
const HGDIOBJ = HANDLE;
const HGLOBAL = HANDLE;
const HMONITOR = HANDLE;
const MAX_PATH: usize = 260;
const ULONG_PTR = usize;

const CF_UNICODETEXT: UINT = 13;
const CF_HDROP: UINT = 15;
const GMEM_MOVEABLE: UINT = 0x0002;
const GMEM_ZEROINIT: UINT = 0x0040;
const INPUT_KEYBOARD: DWORD = 1;
const KEYEVENTF_KEYUP: DWORD = 0x0002;
const KEYEVENTF_UNICODE: DWORD = 0x0004;
const BI_RGB: DWORD = 0;
const DIB_RGB_COLORS: UINT = 0;
const SRCCOPY: DWORD = 0x00CC0020;
const MOUSEEVENTF_LEFTDOWN: DWORD = 0x0002;
const MOUSEEVENTF_LEFTUP: DWORD = 0x0004;
const MOUSEEVENTF_RIGHTDOWN: DWORD = 0x0008;
const MOUSEEVENTF_RIGHTUP: DWORD = 0x0010;
const MOUSEEVENTF_MIDDLEDOWN: DWORD = 0x0020;
const MOUSEEVENTF_MIDDLEUP: DWORD = 0x0040;
const MOUSEEVENTF_WHEEL: DWORD = 0x0800;
const CLR_INVALID: DWORD = 0xFFFF_FFFF;
const SM_XVIRTUALSCREEN: i32 = 76;
const SM_YVIRTUALSCREEN: i32 = 77;
const SM_CXVIRTUALSCREEN: i32 = 78;
const SM_CYVIRTUALSCREEN: i32 = 79;
const VK_CONTROL: WORD = 0x11;
const VK_V: WORD = 0x56;
const VK_SHIFT: WORD = 0x10;
const VK_MENU: WORD = 0x12;
const VK_RETURN: WORD = 0x0D;
const VK_ESCAPE: WORD = 0x1B;
const VK_SPACE: WORD = 0x20;
const VK_TAB: WORD = 0x09;
const VK_BACK: WORD = 0x08;
const VK_DELETE: WORD = 0x2E;
const VK_INSERT: WORD = 0x2D;
const VK_HOME: WORD = 0x24;
const VK_END: WORD = 0x23;
const VK_PRIOR: WORD = 0x21;
const VK_NEXT: WORD = 0x22;
const VK_LEFT: WORD = 0x25;
const VK_UP: WORD = 0x26;
const VK_RIGHT: WORD = 0x27;
const VK_DOWN: WORD = 0x28;
const SW_RESTORE: i32 = 9;
const SW_SHOWNORMAL: i32 = 1;
const WM_CLOSE: UINT = 0x0010;
const MONITORINFOF_PRIMARY: DWORD = 0x0000_0001;
const DRIVE_UNKNOWN: UINT = 0;
const DRIVE_NO_ROOT_DIR: UINT = 1;
const DRIVE_REMOVABLE: UINT = 2;
const DRIVE_FIXED: UINT = 3;
const DRIVE_REMOTE: UINT = 4;
const DRIVE_CDROM: UINT = 5;
const DRIVE_RAMDISK: UINT = 6;
const TH32CS_SNAPPROCESS: DWORD = 0x0000_0002;

const RECT = extern struct {
    left: LONG,
    top: LONG,
    right: LONG,
    bottom: LONG,
};

const POINT = extern struct {
    x: LONG,
    y: LONG,
};

const SYSTEM_INFO = extern struct {
    Anonymous: extern union {
        dwOemId: DWORD,
        s: extern struct {
            wProcessorArchitecture: WORD,
            wReserved: WORD,
        },
    },
    dwPageSize: DWORD,
    lpMinimumApplicationAddress: ?*anyopaque,
    lpMaximumApplicationAddress: ?*anyopaque,
    dwActiveProcessorMask: usize,
    dwNumberOfProcessors: DWORD,
    dwProcessorType: DWORD,
    dwAllocationGranularity: DWORD,
    wProcessorLevel: WORD,
    wProcessorRevision: WORD,
};

const MEMORYSTATUSEX = extern struct {
    dwLength: DWORD,
    dwMemoryLoad: DWORD,
    ullTotalPhys: u64,
    ullAvailPhys: u64,
    ullTotalPageFile: u64,
    ullAvailPageFile: u64,
    ullTotalVirtual: u64,
    ullAvailVirtual: u64,
    ullAvailExtendedVirtual: u64,
};

const PROCESSENTRY32W = extern struct {
    dwSize: DWORD,
    cntUsage: DWORD,
    th32ProcessID: DWORD,
    th32DefaultHeapID: usize,
    th32ModuleID: DWORD,
    cntThreads: DWORD,
    th32ParentProcessID: DWORD,
    pcPriClassBase: LONG,
    dwFlags: DWORD,
    szExeFile: [MAX_PATH]u16,
};

const CLSID = extern struct {
    Data1: u32,
    Data2: u16,
    Data3: u16,
    Data4: [8]u8,
};

const GdiplusStartupInput = extern struct {
    GdiplusVersion: UINT,
    DebugEventCallback: ?*const anyopaque,
    SuppressBackgroundThread: BOOL,
    SuppressExternalCodecs: BOOL,
};

const GpImage = opaque {};
const GpBitmap = opaque {};

const PNG_ENCODER_CLSID = CLSID{
    .Data1 = 0x557cf406,
    .Data2 = 0x1a04,
    .Data3 = 0x11d3,
    .Data4 = .{ 0x9a, 0x73, 0x00, 0x00, 0xf8, 0x1e, 0xf3, 0x2e },
};

const MONITORINFOEXW = extern struct {
    cbSize: DWORD,
    rcMonitor: RECT,
    rcWork: RECT,
    dwFlags: DWORD,
    szDevice: [32]u16,
};

const OSVERSIONINFOEXW = extern struct {
    dwOSVersionInfoSize: DWORD,
    dwMajorVersion: DWORD,
    dwMinorVersion: DWORD,
    dwBuildNumber: DWORD,
    dwPlatformId: DWORD,
    szCSDVersion: [128]u16,
    wServicePackMajor: WORD,
    wServicePackMinor: WORD,
    wSuiteMask: WORD,
    wProductType: u8,
    wReserved: u8,
};

const BITMAPINFOHEADER = extern struct {
    biSize: DWORD,
    biWidth: LONG,
    biHeight: LONG,
    biPlanes: WORD,
    biBitCount: WORD,
    biCompression: DWORD,
    biSizeImage: DWORD,
    biXPelsPerMeter: LONG,
    biYPelsPerMeter: LONG,
    biClrUsed: DWORD,
    biClrImportant: DWORD,
};

const RGBQUAD = extern struct {
    rgbBlue: u8,
    rgbGreen: u8,
    rgbRed: u8,
    rgbReserved: u8,
};

const BITMAPINFO = extern struct {
    bmiHeader: BITMAPINFOHEADER,
    bmiColors: [1]RGBQUAD,
};

const MOUSEINPUT = extern struct {
    dx: LONG,
    dy: LONG,
    mouseData: DWORD,
    dwFlags: DWORD,
    time: DWORD,
    dwExtraInfo: usize,
};

const KEYBDINPUT = extern struct {
    wVk: WORD,
    wScan: WORD,
    dwFlags: DWORD,
    time: DWORD,
    dwExtraInfo: usize,
};

const HARDWAREINPUT = extern struct {
    uMsg: DWORD,
    wParamL: WORD,
    wParamH: WORD,
};

const INPUT = extern struct {
    type: DWORD,
    Anonymous: extern union {
        mi: MOUSEINPUT,
        ki: KEYBDINPUT,
        hi: HARDWAREINPUT,
    },
};

extern "user32" fn EnumWindows(lpEnumFunc: *const fn (HWND, LPARAM) callconv(.c) BOOL, lParam: LPARAM) callconv(.c) BOOL;
extern "user32" fn IsWindow(hWnd: HWND) callconv(.c) BOOL;
extern "user32" fn IsWindowVisible(hWnd: HWND) callconv(.c) BOOL;
extern "user32" fn IsIconic(hWnd: HWND) callconv(.c) BOOL;
extern "user32" fn GetWindowRect(hWnd: HWND, lpRect: *RECT) callconv(.c) BOOL;
extern "user32" fn GetWindowTextLengthW(hWnd: HWND) callconv(.c) i32;
extern "user32" fn GetWindowTextW(hWnd: HWND, lpString: [*:0]u16, nMaxCount: i32) callconv(.c) i32;
extern "user32" fn GetClassNameW(hWnd: HWND, lpClassName: [*:0]u16, nMaxCount: i32) callconv(.c) i32;
extern "user32" fn GetWindowThreadProcessId(hWnd: HWND, lpdwProcessId: *DWORD) callconv(.c) DWORD;
extern "user32" fn GetForegroundWindow() callconv(.c) HWND;
extern "user32" fn SetForegroundWindow(hWnd: HWND) callconv(.c) BOOL;
extern "user32" fn BringWindowToTop(hWnd: HWND) callconv(.c) BOOL;
extern "user32" fn ShowWindow(hWnd: HWND, nCmdShow: i32) callconv(.c) BOOL;
extern "user32" fn PostMessageW(hWnd: HWND, Msg: UINT, wParam: usize, lParam: isize) callconv(.c) BOOL;
extern "user32" fn GetCursorPos(lpPoint: *POINT) callconv(.c) BOOL;
extern "user32" fn SetCursorPos(x: i32, y: i32) callconv(.c) BOOL;
extern "user32" fn mouse_event(dwFlags: DWORD, dx: DWORD, dy: DWORD, dwData: DWORD, dwExtraInfo: usize) callconv(.c) void;
extern "user32" fn AttachThreadInput(idAttach: DWORD, idAttachTo: DWORD, fAttach: BOOL) callconv(.c) BOOL;
extern "user32" fn OpenClipboard(hWndNewOwner: HWND) callconv(.c) BOOL;
extern "user32" fn CloseClipboard() callconv(.c) BOOL;
extern "user32" fn EmptyClipboard() callconv(.c) BOOL;
extern "user32" fn GetClipboardData(format: UINT) callconv(.c) HANDLE;
extern "user32" fn SetClipboardData(uFormat: UINT, hMem: HANDLE) callconv(.c) HANDLE;
extern "user32" fn IsClipboardFormatAvailable(format: UINT) callconv(.c) BOOL;
extern "user32" fn SendInput(cInputs: UINT, pInputs: [*]INPUT, cbSize: i32) callconv(.c) UINT;
extern "user32" fn GetDC(hWnd: HWND) callconv(.c) HDC;
extern "user32" fn ReleaseDC(hWnd: HWND, hDC: HDC) callconv(.c) i32;
extern "user32" fn GetSystemMetrics(nIndex: i32) callconv(.c) i32;
extern "user32" fn GetPixel(hdc: HDC, x: i32, y: i32) callconv(.c) DWORD;
extern "user32" fn EnumDisplayMonitors(hdc: HDC, lprcClip: ?*const RECT, lpfnEnum: *const fn (HMONITOR, HDC, *RECT, LPARAM) callconv(.c) BOOL, dwData: LPARAM) callconv(.c) BOOL;
extern "user32" fn GetMonitorInfoW(hMonitor: HMONITOR, lpmi: *MONITORINFOEXW) callconv(.c) BOOL;

extern "kernel32" fn GetLastError() callconv(.c) DWORD;
extern "kernel32" fn GetCurrentThreadId() callconv(.c) DWORD;
extern "kernel32" fn GetComputerNameW(lpBuffer: [*]u16, nSize: *DWORD) callconv(.c) BOOL;
extern "kernel32" fn GetSystemInfo(lpSystemInfo: *SYSTEM_INFO) callconv(.c) void;
extern "kernel32" fn GlobalMemoryStatusEx(lpBuffer: *MEMORYSTATUSEX) callconv(.c) BOOL;
extern "kernel32" fn GetLogicalDrives() callconv(.c) DWORD;
extern "kernel32" fn GetDriveTypeW(lpRootPathName: [*:0]const u16) callconv(.c) UINT;
extern "kernel32" fn GetDiskFreeSpaceExW(lpDirectoryName: [*:0]const u16, lpFreeBytesAvailableToCaller: *u64, lpTotalNumberOfBytes: *u64, lpTotalNumberOfFreeBytes: *u64) callconv(.c) BOOL;
extern "kernel32" fn GetVolumeInformationW(lpRootPathName: [*:0]const u16, lpVolumeNameBuffer: [*:0]u16, nVolumeNameSize: DWORD, lpVolumeSerialNumber: ?*DWORD, lpMaximumComponentLength: ?*DWORD, lpFileSystemFlags: ?*DWORD, lpFileSystemNameBuffer: ?[*:0]u16, nFileSystemNameSize: DWORD) callconv(.c) BOOL;
extern "kernel32" fn CreateToolhelp32Snapshot(dwFlags: DWORD, th32ProcessID: DWORD) callconv(.c) HANDLE;
extern "kernel32" fn Process32FirstW(hSnapshot: HANDLE, lppe: *PROCESSENTRY32W) callconv(.c) BOOL;
extern "kernel32" fn Process32NextW(hSnapshot: HANDLE, lppe: *PROCESSENTRY32W) callconv(.c) BOOL;
extern "kernel32" fn CloseHandle(hObject: HANDLE) callconv(.c) BOOL;
extern "kernel32" fn GlobalAlloc(uFlags: UINT, dwBytes: usize) callconv(.c) HGLOBAL;
extern "kernel32" fn GlobalLock(hMem: HGLOBAL) callconv(.c) ?*anyopaque;
extern "kernel32" fn GlobalUnlock(hMem: HGLOBAL) callconv(.c) BOOL;
extern "kernel32" fn GlobalFree(hMem: HGLOBAL) callconv(.c) HGLOBAL;

extern "shell32" fn DragQueryFileW(hDrop: HANDLE, iFile: UINT, lpszFile: ?[*:0]u16, cch: UINT) callconv(.c) UINT;
extern "shell32" fn ShellExecuteW(hwnd: HWND, lpOperation: [*:0]const u16, lpFile: [*:0]const u16, lpParameters: ?[*:0]const u16, lpDirectory: ?[*:0]const u16, nShowCmd: i32) callconv(.c) HANDLE;

extern "gdi32" fn CreateCompatibleDC(hdc: HDC) callconv(.c) HDC;
extern "gdi32" fn DeleteDC(hdc: HDC) callconv(.c) BOOL;
extern "gdi32" fn CreateCompatibleBitmap(hdc: HDC, cx: i32, cy: i32) callconv(.c) HBITMAP;
extern "gdi32" fn SelectObject(hdc: HDC, h: HGDIOBJ) callconv(.c) HGDIOBJ;
extern "gdi32" fn BitBlt(hdc: HDC, x: i32, y: i32, cx: i32, cy: i32, hdcSrc: HDC, x1: i32, y1: i32, rop: DWORD) callconv(.c) BOOL;
extern "gdi32" fn DeleteObject(ho: HGDIOBJ) callconv(.c) BOOL;
extern "gdi32" fn GetDIBits(hdc: HDC, hbm: HBITMAP, start: UINT, lines: UINT, bits: ?*anyopaque, bmi: *BITMAPINFO, usage: UINT) callconv(.c) i32;

extern "gdiplus" fn GdiplusStartup(token: *ULONG_PTR, input: *const GdiplusStartupInput, output: ?*const anyopaque) callconv(.c) i32;
extern "gdiplus" fn GdiplusShutdown(token: ULONG_PTR) callconv(.c) void;
extern "gdiplus" fn GdipCreateBitmapFromHBITMAP(hbm: HBITMAP, hpal: HANDLE, bitmap: *?*GpBitmap) callconv(.c) i32;
extern "gdiplus" fn GdipSaveImageToFile(image: *GpImage, filename: [*:0]const u16, clsidEncoder: *const CLSID, encoderParams: ?*const anyopaque) callconv(.c) i32;
extern "gdiplus" fn GdipDisposeImage(image: *GpImage) callconv(.c) i32;

extern "ntdll" fn RtlGetVersion(lpVersionInformation: *OSVERSIONINFOEXW) callconv(.c) i32;

pub fn systemOsInfo(allocator: std.mem.Allocator) !core.model.OsInfoResponse {
    var version_info = std.mem.zeroes(OSVERSIONINFOEXW);
    version_info.dwOSVersionInfoSize = @sizeOf(OSVERSIONINFOEXW);

    if (RtlGetVersion(&version_info) != 0) {
        return core.model.failure(core.model.OsInfo, "system.os_info", core.errors.codes.system_error, "RtlGetVersion failed.", try lastErrorDetail(allocator));
    }

    var machine_name_buffer: [256]u16 = undefined;
    var machine_name_size: DWORD = machine_name_buffer.len;
    var machine_name: []const u8 = "unknown-host";
    if (GetComputerNameW(&machine_name_buffer, &machine_name_size) != 0) {
        machine_name = try std.unicode.utf16LeToUtf8Alloc(allocator, machine_name_buffer[0..machine_name_size]);
    }

    const version = try std.fmt.allocPrint(allocator, "{d}.{d}.{d}", .{
        version_info.dwMajorVersion,
        version_info.dwMinorVersion,
        version_info.dwBuildNumber,
    });

    return core.model.success("system.os_info", core.model.OsInfo{
        .platform = "windows",
        .arch = @tagName(builtin.cpu.arch),
        .version = version,
        .build = version_info.dwBuildNumber,
        .machine_name = machine_name,
        .runtime = "win32",
    });
}

pub fn systemCpuInfo(allocator: std.mem.Allocator) !core.model.CpuInfoResponse {
    _ = allocator;
    var info = std.mem.zeroes(SYSTEM_INFO);
    GetSystemInfo(&info);
    return core.model.success("system.cpu_info", core.model.CpuInfo{
        .architecture = @tagName(builtin.cpu.arch),
        .logical_cores = info.dwNumberOfProcessors,
        .page_size = info.dwPageSize,
    });
}

pub fn systemMemoryInfo(allocator: std.mem.Allocator) !core.model.MemoryInfoResponse {
    var status = std.mem.zeroes(MEMORYSTATUSEX);
    status.dwLength = @sizeOf(MEMORYSTATUSEX);
    if (GlobalMemoryStatusEx(&status) == 0) {
        return core.model.failure(core.model.MemoryInfo, "system.memory_info", core.errors.codes.system_error, "GlobalMemoryStatusEx failed.", try lastErrorDetail(allocator));
    }

    return core.model.success("system.memory_info", core.model.MemoryInfo{
        .total_physical = status.ullTotalPhys,
        .available_physical = status.ullAvailPhys,
        .used_physical = status.ullTotalPhys - status.ullAvailPhys,
        .memory_load_percent = status.dwMemoryLoad,
    });
}

pub fn systemDiskList(allocator: std.mem.Allocator) !core.model.DiskListResponse {
    const mask = GetLogicalDrives();
    if (mask == 0) {
        return core.model.failure(core.model.DiskList, "system.disk_list", core.errors.codes.system_error, "GetLogicalDrives failed.", try lastErrorDetail(allocator));
    }

    var disks = std.ArrayList(core.model.DiskInfo).empty;
    defer disks.deinit(allocator);

    var letter_index: u5 = 0;
    while (letter_index < 26) : (letter_index += 1) {
        const bit: DWORD = @as(DWORD, 1) << letter_index;
        if ((mask & bit) == 0) continue;

        const letter: u8 = @intCast(@as(u16, 'A') + letter_index);
        var root = [_]u16{ @as(u16, letter), ':', '\\', 0 };
        const root_ptr: [*:0]const u16 = @ptrCast(&root);
        const drive_type = GetDriveTypeW(root_ptr);
        if (drive_type == DRIVE_UNKNOWN or drive_type == DRIVE_NO_ROOT_DIR) continue;

        var free_available: u64 = 0;
        var total_bytes: u64 = 0;
        var total_free: u64 = 0;
        if (GetDiskFreeSpaceExW(root_ptr, &free_available, &total_bytes, &total_free) == 0) {
            continue;
        }

        var volume_name_buffer: [MAX_PATH]u16 = undefined;
        @memset(&volume_name_buffer, 0);
        const has_name = GetVolumeInformationW(root_ptr, @ptrCast(&volume_name_buffer), @intCast(volume_name_buffer.len), null, null, null, null, 0) != 0;
        const volume_name = if (has_name)
            try utf16FixedToUtf8(allocator, volume_name_buffer[0..])
        else
            try allocator.dupe(u8, "");

        const mount = try std.fmt.allocPrint(allocator, "{c}:\\", .{letter});
        try disks.append(allocator, .{
            .mount = mount,
            .volume_name = volume_name,
            .drive_type = driveTypeLabel(drive_type),
            .total_bytes = total_bytes,
            .free_bytes = total_free,
        });
    }

    const owned = try disks.toOwnedSlice(allocator);
    return core.model.success("system.disk_list", core.model.DiskList{
        .count = owned.len,
        .disks = owned,
    });
}

pub fn systemProcessList(allocator: std.mem.Allocator) !core.model.ProcessListResponse {
    const snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (isInvalidHandle(snapshot)) {
        return core.model.failure(core.model.ProcessList, "system.process_list", core.errors.codes.system_error, "CreateToolhelp32Snapshot failed.", try lastErrorDetail(allocator));
    }
    defer _ = CloseHandle(snapshot);

    var processes = std.ArrayList(core.model.ProcessInfo).empty;
    defer processes.deinit(allocator);

    var entry = std.mem.zeroes(PROCESSENTRY32W);
    entry.dwSize = @sizeOf(PROCESSENTRY32W);

    if (Process32FirstW(snapshot, &entry) != 0) {
        while (true) {
            try processes.append(allocator, .{
                .pid = entry.th32ProcessID,
                .name = try utf16FixedToUtf8(allocator, entry.szExeFile[0..]),
            });
            if (Process32NextW(snapshot, &entry) == 0) break;
        }
    }

    const owned = try processes.toOwnedSlice(allocator);
    return core.model.success("system.process_list", core.model.ProcessList{
        .count = owned.len,
        .processes = owned,
    });
}

pub fn mousePosition(allocator: std.mem.Allocator) !core.model.PointResponse {
    _ = allocator;
    var point = std.mem.zeroes(POINT);
    if (GetCursorPos(&point) == 0) {
        return core.model.failure(core.model.Point, "mouse.position", core.errors.codes.system_error, "GetCursorPos failed.", null);
    }

    return core.model.success("mouse.position", core.model.Point{
        .x = point.x,
        .y = point.y,
    });
}

pub fn mouseMove(allocator: std.mem.Allocator, x: i32, y: i32) !core.model.AckResponse {
    if (SetCursorPos(x, y) == 0) {
        return core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.system_error, "SetCursorPos failed.", try lastErrorDetail(allocator));
    }

    return core.model.success("mouse.move", core.model.Ack{
        .message = "Mouse moved.",
        .detail = try std.fmt.allocPrint(allocator, "x={d}; y={d}", .{ x, y }),
    });
}

pub fn mouseClick(allocator: std.mem.Allocator, button: core.model.MouseButton, count: u8) !core.model.AckResponse {
    if (count == 0) {
        return core.model.failure(core.model.Ack, "mouse.click", core.errors.codes.invalid_args, "count must be at least 1.", null);
    }

    const down_up = switch (button) {
        .left => [2]DWORD{ MOUSEEVENTF_LEFTDOWN, MOUSEEVENTF_LEFTUP },
        .right => [2]DWORD{ MOUSEEVENTF_RIGHTDOWN, MOUSEEVENTF_RIGHTUP },
        .middle => [2]DWORD{ MOUSEEVENTF_MIDDLEDOWN, MOUSEEVENTF_MIDDLEUP },
    };

    var remaining: u8 = count;
    while (remaining > 0) : (remaining -= 1) {
        mouse_event(down_up[0], 0, 0, 0, 0);
        mouse_event(down_up[1], 0, 0, 0, 0);
    }

    return core.model.success("mouse.click", core.model.Ack{
        .message = "Mouse click sent.",
        .detail = try std.fmt.allocPrint(allocator, "button={s}; count={d}", .{ @tagName(button), count }),
    });
}

pub fn mouseScroll(allocator: std.mem.Allocator, delta: i32) !core.model.AckResponse {
    if (delta == 0) {
        return core.model.failure(core.model.Ack, "mouse.scroll", core.errors.codes.invalid_args, "delta must be non-zero.", null);
    }

    const wheel_data: DWORD = @bitCast(delta);
    mouse_event(MOUSEEVENTF_WHEEL, 0, 0, wheel_data, 0);

    return core.model.success("mouse.scroll", core.model.Ack{
        .message = "Mouse wheel event sent.",
        .detail = try std.fmt.allocPrint(allocator, "delta={d}", .{delta}),
    });
}

pub fn keyboardKeyPress(allocator: std.mem.Allocator, key: []const u8) !core.model.AckResponse {
    const vk = parseVirtualKey(key) orelse {
        return core.model.failure(core.model.Ack, "keyboard.key_press", core.errors.codes.invalid_args, "Unsupported key value.", key);
    };

    sendInputs(&[_]INPUT{
        keyInput(vk, 0),
        keyInput(vk, KEYEVENTF_KEYUP),
    }) catch {
        return core.model.failure(core.model.Ack, "keyboard.key_press", core.errors.codes.system_error, "SendInput failed.", try lastErrorDetail(allocator));
    };

    return core.model.success("keyboard.key_press", core.model.Ack{
        .message = "Key press sent.",
        .detail = try std.fmt.allocPrint(allocator, "key={s}", .{key}),
    });
}

pub fn keyboardHotkey(allocator: std.mem.Allocator, keys: []const u8) !core.model.AckResponse {
    var token_iter = std.mem.tokenizeScalar(u8, keys, '+');
    var parsed_keys: [16]WORD = undefined;
    var count: usize = 0;
    while (token_iter.next()) |token_raw| {
        const token = std.mem.trim(u8, token_raw, " \t");
        if (token.len == 0) continue;
        if (count >= parsed_keys.len) {
            return core.model.failure(core.model.Ack, "keyboard.hotkey", core.errors.codes.invalid_args, "Too many keys in combo. Maximum is 16.", keys);
        }
        parsed_keys[count] = parseVirtualKey(token) orelse {
            return core.model.failure(core.model.Ack, "keyboard.hotkey", core.errors.codes.invalid_args, "Unsupported key in combo.", token);
        };
        count += 1;
    }

    if (count == 0) {
        return core.model.failure(core.model.Ack, "keyboard.hotkey", core.errors.codes.invalid_args, "keys must contain at least one key name.", null);
    }

    var inputs = std.ArrayList(INPUT).empty;
    defer inputs.deinit(allocator);
    try inputs.ensureTotalCapacity(allocator, count * 2);

    for (parsed_keys[0..count]) |vk| {
        try inputs.append(allocator, keyInput(vk, 0));
    }
    var reverse_index = count;
    while (reverse_index > 0) {
        reverse_index -= 1;
        try inputs.append(allocator, keyInput(parsed_keys[reverse_index], KEYEVENTF_KEYUP));
    }

    sendInputs(inputs.items) catch {
        return core.model.failure(core.model.Ack, "keyboard.hotkey", core.errors.codes.system_error, "SendInput failed.", try lastErrorDetail(allocator));
    };

    return core.model.success("keyboard.hotkey", core.model.Ack{
        .message = "Hotkey sent.",
        .detail = try std.fmt.allocPrint(allocator, "keys={s}", .{keys}),
    });
}

pub fn keyboardTypeText(allocator: std.mem.Allocator, text: []const u8) !core.model.AckResponse {
    const utf16 = try std.unicode.utf8ToUtf16LeAlloc(allocator, text);
    defer allocator.free(utf16);

    for (utf16) |unit| {
        sendInputs(&[_]INPUT{
            keyUnicodeInput(unit, KEYEVENTF_UNICODE),
            keyUnicodeInput(unit, KEYEVENTF_UNICODE | KEYEVENTF_KEYUP),
        }) catch {
            return core.model.failure(core.model.Ack, "keyboard.type_text", core.errors.codes.system_error, "SendInput failed while typing text.", try lastErrorDetail(allocator));
        };
    }

    return core.model.success("keyboard.type_text", core.model.Ack{
        .message = "Text input sent.",
        .detail = try std.fmt.allocPrint(allocator, "utf16_units={d}", .{utf16.len}),
    });
}

pub fn windowList(allocator: std.mem.Allocator, include_hidden: bool) !core.model.WindowListResponse {
    var context = EnumContext{
        .allocator = allocator,
        .include_hidden = include_hidden,
        .foreground = GetForegroundWindow(),
        .windows = .empty,
        .failed = false,
        .failure_detail = null,
    };
    defer context.windows.deinit(allocator);

    const enum_result = EnumWindows(EnumCallbacks.collectWindow, @as(LPARAM, @intCast(@intFromPtr(&context))));

    if (context.failed) {
        return core.model.failure(core.model.WindowList, "window.list", core.errors.codes.system_error, "Failed while collecting windows.", context.failure_detail);
    }

    if (enum_result == 0) {
        return core.model.failure(core.model.WindowList, "window.list", core.errors.codes.system_error, "EnumWindows failed.", try lastErrorDetail(allocator));
    }

    const owned = try context.windows.toOwnedSlice(allocator);
    return core.model.success("window.list", core.model.WindowList{
        .count = owned.len,
        .windows = owned,
    });
}

pub fn windowForeground(allocator: std.mem.Allocator) !core.model.ForegroundWindowResponse {
    const foreground = GetForegroundWindow();
    if (foreground == null) {
        return core.model.success("window.foreground", core.model.ForegroundWindow{
            .found = false,
            .window = null,
        });
    }

    const info = try buildWindowInfo(allocator, foreground, foreground);
    return core.model.success("window.foreground", core.model.ForegroundWindow{
        .found = true,
        .window = info,
    });
}

pub fn windowActivate(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    if (handle == 0) {
        return core.model.failure(core.model.Ack, "window.activate", core.errors.codes.invalid_args, "Window activation requires a non-zero handle.", null);
    }

    const hwnd: HWND = @ptrFromInt(handle);
    if (IsWindow(hwnd) == 0) {
        return core.model.failure(core.model.Ack, "window.activate", core.errors.codes.not_found, "The requested window handle is no longer valid.", try std.fmt.allocPrint(allocator, "target_handle=0x{x}", .{handle}));
    }

    const activation_detail = try requestForegroundActivation(allocator, hwnd, handle);
    const foreground = try waitForForegroundWindow(hwnd, 12, 150);
    if (foreground != hwnd) {
        const actual_handle = if (foreground) |value| @intFromPtr(value) else 0;
        return core.model.failure(core.model.Ack, "window.activate", core.errors.codes.system_error, "The requested window did not become the foreground window.", try std.fmt.allocPrint(allocator, "{s}; actual_foreground_handle=0x{x}", .{ activation_detail, actual_handle }));
    }

    const title = try getWindowTitle(allocator, hwnd);
    return core.model.success("window.activate", core.model.Ack{
        .message = "Window activated.",
        .detail = try std.fmt.allocPrint(allocator, "{s}; title={s}", .{ activation_detail, title }),
    });
}

pub fn windowFind(allocator: std.mem.Allocator, title: []const u8, match_mode: core.model.StringMatchMode, include_hidden: bool, pid: ?u32) !core.model.WindowMatchResponse {
    const list_response = try windowList(allocator, include_hidden);
    if (!list_response.ok) {
        const failure = list_response.failure orelse core.errors.ApiError{ .code = core.errors.codes.system_error, .message = "window.list failed while searching.", .detail = null };
        return core.model.failure(core.model.WindowMatch, "window.find", failure.code, failure.message, failure.detail);
    }

    const data = list_response.data.?;
    for (data.windows) |window| {
        if (pid) |wanted_pid| {
            if (window.pid != wanted_pid) continue;
        }
        if (!titleMatches(window.title, title, match_mode)) continue;

        return core.model.success("window.find", core.model.WindowMatch{
            .found = true,
            .window = try cloneWindowInfo(allocator, window),
        });
    }

    return core.model.success("window.find", core.model.WindowMatch{
        .found = false,
        .window = null,
    });
}

pub fn windowClose(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    if (handle == 0) {
        return core.model.failure(core.model.Ack, "window.close", core.errors.codes.invalid_args, "Window close requires a non-zero handle.", null);
    }

    const hwnd: HWND = @ptrFromInt(handle);
    if (IsWindow(hwnd) == 0) {
        return core.model.failure(core.model.Ack, "window.close", core.errors.codes.not_found, "The requested window handle is no longer valid.", try std.fmt.allocPrint(allocator, "target_handle=0x{x}", .{handle}));
    }

    if (PostMessageW(hwnd, WM_CLOSE, 0, 0) == 0) {
        return core.model.failure(core.model.Ack, "window.close", core.errors.codes.system_error, "PostMessageW(WM_CLOSE) failed.", try lastErrorDetail(allocator));
    }

    return core.model.success("window.close", core.model.Ack{
        .message = "Window close requested.",
        .detail = try std.fmt.allocPrint(allocator, "target_handle=0x{x}", .{handle}),
    });
}

pub fn appLaunch(allocator: std.mem.Allocator, target: []const u8) !core.model.AckResponse {
    if (target.len == 0) {
        return core.model.failure(core.model.Ack, "app.launch", core.errors.codes.invalid_args, "Launch target cannot be empty.", null);
    }

    const open_utf16 = try std.unicode.utf8ToUtf16LeAllocZ(allocator, "open");
    defer allocator.free(open_utf16);
    const target_utf16 = try std.unicode.utf8ToUtf16LeAllocZ(allocator, target);
    defer allocator.free(target_utf16);

    const result = ShellExecuteW(null, @ptrCast(open_utf16.ptr), @ptrCast(target_utf16.ptr), null, null, SW_SHOWNORMAL);
    if (result == null) {
        return core.model.failure(core.model.Ack, "app.launch", core.errors.codes.system_error, "ShellExecuteW failed to launch target.", try lastErrorDetail(allocator));
    }

    const code = @intFromPtr(result.?);
    if (code <= 32) {
        return core.model.failure(core.model.Ack, "app.launch", core.errors.codes.system_error, "ShellExecuteW returned launch error code.", try std.fmt.allocPrint(allocator, "shell_execute_code={d}", .{code}));
    }

    return core.model.success("app.launch", core.model.Ack{
        .message = "Launch requested.",
        .detail = try std.fmt.allocPrint(allocator, "target={s}", .{target}),
    });
}

fn requestForegroundActivation(allocator: std.mem.Allocator, hwnd: HWND, handle: u64) ![]const u8 {
    restoreIfMinimized(hwnd);

    const initial_foreground = GetForegroundWindow();
    var target_pid: DWORD = 0;
    const target_thread = GetWindowThreadProcessId(hwnd, &target_pid);
    var foreground_pid: DWORD = 0;
    const foreground_thread: DWORD = if (initial_foreground) |value| GetWindowThreadProcessId(value, &foreground_pid) else 0;
    const current_thread = GetCurrentThreadId();

    var attached_foreground = false;
    if (foreground_thread != 0 and foreground_thread != current_thread) {
        attached_foreground = AttachThreadInput(current_thread, foreground_thread, 1) != 0;
    }
    defer if (attached_foreground) {
        _ = AttachThreadInput(current_thread, foreground_thread, 0);
    };

    var attached_target = false;
    if (target_thread != 0 and target_thread != current_thread and target_thread != foreground_thread) {
        attached_target = AttachThreadInput(current_thread, target_thread, 1) != 0;
    }
    defer if (attached_target) {
        _ = AttachThreadInput(current_thread, target_thread, 0);
    };

    _ = BringWindowToTop(hwnd);
    const set_foreground_result = SetForegroundWindow(hwnd);
    _ = BringWindowToTop(hwnd);
    restoreIfMinimized(hwnd);

    return std.fmt.allocPrint(allocator, "target_handle=0x{x}; current_thread={d}; target_thread={d}; foreground_thread={d}; target_pid={d}; set_foreground_result={d}; win32_last_error={d}", .{
        handle,
        current_thread,
        target_thread,
        foreground_thread,
        target_pid,
        set_foreground_result,
        GetLastError(),
    });
}

fn restoreIfMinimized(hwnd: HWND) void {
    if (IsIconic(hwnd) != 0) {
        _ = ShowWindow(hwnd, SW_RESTORE);
    }
}

fn waitForForegroundWindow(expected: HWND, attempts: usize, delay_ms: u64) !HWND {
    var remaining = attempts;
    while (remaining > 0) : (remaining -= 1) {
        const foreground = GetForegroundWindow();
        if (foreground == expected) return foreground;
        std.Thread.sleep(delay_ms * std.time.ns_per_ms);
    }

    return GetForegroundWindow();
}

pub fn clipboardGetText(allocator: std.mem.Allocator) !core.model.ClipboardTextResponse {
    if (OpenClipboard(null) == 0) {
        return core.model.failure(core.model.ClipboardText, "clipboard.get_text", core.errors.codes.permission_denied, "OpenClipboard failed.", try lastErrorDetail(allocator));
    }
    defer _ = CloseClipboard();

    if (IsClipboardFormatAvailable(CF_UNICODETEXT) == 0) {
        return core.model.failure(core.model.ClipboardText, "clipboard.get_text", core.errors.codes.clipboard_empty, "Clipboard does not currently expose Unicode text.", null);
    }

    const handle = GetClipboardData(CF_UNICODETEXT);
    if (handle == null) {
        return core.model.failure(core.model.ClipboardText, "clipboard.get_text", core.errors.codes.system_error, "GetClipboardData failed.", try lastErrorDetail(allocator));
    }

    const locked = GlobalLock(handle) orelse {
        return core.model.failure(core.model.ClipboardText, "clipboard.get_text", core.errors.codes.system_error, "GlobalLock failed for clipboard text.", try lastErrorDetail(allocator));
    };
    defer _ = GlobalUnlock(handle);

    const wide_text: [*:0]const u16 = @ptrCast(@alignCast(locked));
    const utf16 = std.mem.span(wide_text);
    const text = try std.unicode.utf16LeToUtf8Alloc(allocator, utf16);
    return core.model.success("clipboard.get_text", core.model.ClipboardText{ .text = text });
}

pub fn clipboardSetText(allocator: std.mem.Allocator, text: []const u8) !core.model.AckResponse {
    const utf16 = try std.unicode.utf8ToUtf16LeAllocZ(allocator, text);
    defer allocator.free(utf16);
    const bytes = (utf16.len + 1) * @sizeOf(u16);

    if (OpenClipboard(null) == 0) {
        return core.model.failure(core.model.Ack, "clipboard.set_text", core.errors.codes.permission_denied, "OpenClipboard failed.", try lastErrorDetail(allocator));
    }
    defer _ = CloseClipboard();

    if (EmptyClipboard() == 0) {
        return core.model.failure(core.model.Ack, "clipboard.set_text", core.errors.codes.system_error, "EmptyClipboard failed.", try lastErrorDetail(allocator));
    }

    const memory = GlobalAlloc(GMEM_MOVEABLE | GMEM_ZEROINIT, bytes);
    if (memory == null) {
        return core.model.failure(core.model.Ack, "clipboard.set_text", core.errors.codes.system_error, "GlobalAlloc failed.", try lastErrorDetail(allocator));
    }

    const locked = GlobalLock(memory) orelse {
        _ = GlobalFree(memory);
        return core.model.failure(core.model.Ack, "clipboard.set_text", core.errors.codes.system_error, "GlobalLock failed for clipboard write.", try lastErrorDetail(allocator));
    };

    const dest: [*]u16 = @ptrCast(@alignCast(locked));
    std.mem.copyForwards(u16, dest[0..utf16.len], utf16);
    dest[utf16.len] = 0;
    _ = GlobalUnlock(memory);

    if (SetClipboardData(CF_UNICODETEXT, memory) == null) {
        _ = GlobalFree(memory);
        return core.model.failure(core.model.Ack, "clipboard.set_text", core.errors.codes.system_error, "SetClipboardData failed.", try lastErrorDetail(allocator));
    }

    return core.model.success("clipboard.set_text", core.model.Ack{
        .message = "Clipboard text updated.",
        .detail = "Local validation must restore the previous clipboard value.",
    });
}

pub fn clipboardGetFiles(allocator: std.mem.Allocator) !core.model.ClipboardFilesResponse {
    if (OpenClipboard(null) == 0) {
        return core.model.failure(core.model.ClipboardFiles, "clipboard.get_files", core.errors.codes.permission_denied, "OpenClipboard failed.", try lastErrorDetail(allocator));
    }
    defer _ = CloseClipboard();

    if (IsClipboardFormatAvailable(CF_HDROP) == 0) {
        return core.model.failure(core.model.ClipboardFiles, "clipboard.get_files", core.errors.codes.clipboard_empty, "Clipboard does not currently expose file-drop data.", null);
    }

    const handle = GetClipboardData(CF_HDROP);
    if (handle == null) {
        return core.model.failure(core.model.ClipboardFiles, "clipboard.get_files", core.errors.codes.system_error, "GetClipboardData failed for CF_HDROP.", try lastErrorDetail(allocator));
    }

    const count = DragQueryFileW(handle, 0xFFFF_FFFF, null, 0);
    var files = std.ArrayList([]const u8).empty;
    defer files.deinit(allocator);

    var index: UINT = 0;
    while (index < count) : (index += 1) {
        const char_count = DragQueryFileW(handle, index, null, 0);
        var wide = try allocator.alloc(u16, char_count + 1);
        defer allocator.free(wide);
        @memset(wide, 0);
        _ = DragQueryFileW(handle, index, @ptrCast(wide.ptr), char_count + 1);

        const utf8 = try std.unicode.utf16LeToUtf8Alloc(allocator, wide[0..char_count]);
        try files.append(allocator, utf8);
    }

    const owned = try files.toOwnedSlice(allocator);
    return core.model.success("clipboard.get_files", core.model.ClipboardFiles{ .files = owned });
}

pub fn keyboardPaste(allocator: std.mem.Allocator, expected_title: ?[]const u8, match_mode: core.model.StringMatchMode) !core.model.AckResponse {
    const foreground = GetForegroundWindow() orelse {
        return core.model.failure(core.model.Ack, "keyboard.paste", core.errors.codes.not_found, "No foreground window is available for Ctrl+V.", null);
    };

    if (expected_title) |wanted_title| {
        const current_title = try getWindowTitle(allocator, foreground);
        if (!titleMatches(current_title, wanted_title, match_mode)) {
            const detail = try std.fmt.allocPrint(allocator, "expected_foreground_title={s}; actual_foreground_title={s}", .{ wanted_title, current_title });
            return core.model.failure(core.model.Ack, "keyboard.paste", core.errors.codes.unsafe_operation, "Foreground window no longer matches the guarded paste target.", detail);
        }
    }

    var inputs = [_]INPUT{
        keyInput(VK_CONTROL, 0),
        keyInput(VK_V, 0),
        keyInput(VK_V, KEYEVENTF_KEYUP),
        keyInput(VK_CONTROL, KEYEVENTF_KEYUP),
    };

    const sent = SendInput(inputs.len, &inputs, @sizeOf(INPUT));
    if (sent != inputs.len) {
        return core.model.failure(core.model.Ack, "keyboard.paste", core.errors.codes.system_error, "SendInput failed to deliver Ctrl+V.", null);
    }

    return core.model.success("keyboard.paste", core.model.Ack{
        .message = if (expected_title != null) "Ctrl+V sent after verifying the guarded target window." else "Ctrl+V sent to the active window.",
        .detail = if (expected_title != null) "The foreground title matched the expected target at send time." else "Only run local validation against a test window created by the verification flow.",
    });
}

pub fn screenCapture(allocator: std.mem.Allocator, path: []const u8) !core.model.ScreenCaptureResponse {
    if (std.fs.path.dirname(path)) |dir_name| {
        try std.fs.cwd().makePath(dir_name);
    }

    const x = GetSystemMetrics(SM_XVIRTUALSCREEN);
    const y = GetSystemMetrics(SM_YVIRTUALSCREEN);
    const width = GetSystemMetrics(SM_CXVIRTUALSCREEN);
    const height = GetSystemMetrics(SM_CYVIRTUALSCREEN);
    if (width <= 0 or height <= 0) {
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.system_error, "GetSystemMetrics returned an invalid desktop size.", null);
    }

    const screen_dc = GetDC(null);
    if (screen_dc == null) {
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.system_error, "GetDC failed.", try lastErrorDetail(allocator));
    }
    defer _ = ReleaseDC(null, screen_dc);

    const memory_dc = CreateCompatibleDC(screen_dc);
    if (memory_dc == null) {
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.system_error, "CreateCompatibleDC failed.", try lastErrorDetail(allocator));
    }
    defer _ = DeleteDC(memory_dc);

    const bitmap = CreateCompatibleBitmap(screen_dc, width, height);
    if (bitmap == null) {
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.system_error, "CreateCompatibleBitmap failed.", try lastErrorDetail(allocator));
    }
    defer _ = DeleteObject(bitmap);

    const old_object = SelectObject(memory_dc, bitmap) orelse {
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.system_error, "SelectObject failed.", try lastErrorDetail(allocator));
    };
    var bitmap_selected = true;
    defer if (bitmap_selected) {
        _ = SelectObject(memory_dc, old_object);
    };

    if (BitBlt(memory_dc, 0, 0, width, height, screen_dc, x, y, SRCCOPY) == 0) {
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.system_error, "BitBlt failed.", try lastErrorDetail(allocator));
    }

    _ = SelectObject(memory_dc, old_object);
    bitmap_selected = false;

    writePngFromBitmap(allocator, path, bitmap) catch |err| {
        const detail = try std.fmt.allocPrint(allocator, "png_encode_error={s}", .{@errorName(err)});
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.system_error, "Failed to encode screenshot as PNG.", detail);
    };

    return core.model.success("screen.capture", core.model.ScreenCapture{
        .path = path,
        .width = width,
        .height = height,
        .format = "png",
    });
}

fn writePngFromBitmap(allocator: std.mem.Allocator, path: []const u8, bitmap: HBITMAP) !void {
    var startup_input = std.mem.zeroes(GdiplusStartupInput);
    startup_input.GdiplusVersion = 1;

    var token: ULONG_PTR = 0;
    if (GdiplusStartup(&token, &startup_input, null) != 0) {
        return error.GdiplusStartupFailed;
    }
    defer GdiplusShutdown(token);

    var gp_bitmap: ?*GpBitmap = null;
    if (GdipCreateBitmapFromHBITMAP(bitmap, null, &gp_bitmap) != 0 or gp_bitmap == null) {
        return error.GdipCreateBitmapFailed;
    }
    defer _ = GdipDisposeImage(@ptrCast(gp_bitmap.?));

    const path_utf16 = try std.unicode.utf8ToUtf16LeAllocZ(allocator, path);
    defer allocator.free(path_utf16);

    if (GdipSaveImageToFile(@ptrCast(gp_bitmap.?), @ptrCast(path_utf16.ptr), &PNG_ENCODER_CLSID, null) != 0) {
        return error.GdipSaveImageFailed;
    }
}

pub fn screenPixelColor(allocator: std.mem.Allocator, x: i32, y: i32) !core.model.PixelColorResponse {
    const screen_dc = GetDC(null);
    if (screen_dc == null) {
        return core.model.failure(core.model.PixelColor, "screen.pixel_color", core.errors.codes.system_error, "GetDC failed.", try lastErrorDetail(allocator));
    }
    defer _ = ReleaseDC(null, screen_dc);

    const raw = GetPixel(screen_dc, x, y);
    if (raw == CLR_INVALID) {
        return core.model.failure(core.model.PixelColor, "screen.pixel_color", core.errors.codes.system_error, "GetPixel failed.", try lastErrorDetail(allocator));
    }

    const r: u8 = @intCast(raw & 0xFF);
    const g: u8 = @intCast((raw >> 8) & 0xFF);
    const b: u8 = @intCast((raw >> 16) & 0xFF);
    const hex = try std.fmt.allocPrint(allocator, "#{X:0>2}{X:0>2}{X:0>2}", .{ r, g, b });

    return core.model.success("screen.pixel_color", core.model.PixelColor{
        .x = x,
        .y = y,
        .r = r,
        .g = g,
        .b = b,
        .hex = hex,
    });
}

pub fn screenDisplays(allocator: std.mem.Allocator) !core.model.DisplayListResponse {
    var context = DisplayEnumContext{
        .allocator = allocator,
        .displays = .empty,
        .failed = false,
        .failure_detail = null,
    };
    defer context.displays.deinit(allocator);

    const ok = EnumDisplayMonitors(null, null, DisplayEnumCallbacks.collectMonitor, @as(LPARAM, @intCast(@intFromPtr(&context))));
    if (context.failed) {
        return core.model.failure(core.model.DisplayList, "screen.displays", core.errors.codes.system_error, "Display enumeration failed while collecting monitor data.", context.failure_detail);
    }
    if (ok == 0) {
        return core.model.failure(core.model.DisplayList, "screen.displays", core.errors.codes.system_error, "EnumDisplayMonitors failed.", try lastErrorDetail(allocator));
    }

    const owned = try context.displays.toOwnedSlice(allocator);
    return core.model.success("screen.displays", core.model.DisplayList{
        .count = owned.len,
        .displays = owned,
    });
}

pub fn waitWindow(allocator: std.mem.Allocator, title: []const u8, timeout_ms: u64, match_mode: core.model.StringMatchMode, foreground_only: bool) !core.model.WaitWindowResponse {
    const start_ms = std.time.milliTimestamp();
    while (true) {
        var iteration_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer iteration_arena.deinit();

        const snapshot = try windowList(iteration_arena.allocator(), true);
        if (!snapshot.ok) {
            const failure = snapshot.failure orelse core.errors.ApiError{
                .code = core.errors.codes.system_error,
                .message = "window.list failed while polling for a matching window.",
                .detail = null,
            };
            return core.model.failure(core.model.WaitWindow, "wait.window", failure.code, failure.message, failure.detail);
        }

        const data = snapshot.data.?;
        for (data.windows) |window| {
            if (foreground_only and !window.is_foreground) continue;
            if (!titleMatches(window.title, title, match_mode)) continue;

            const owned = try cloneWindowInfo(allocator, window);
            const elapsed_now: u64 = @intCast(std.time.milliTimestamp() - start_ms);
            return core.model.success("wait.window", core.model.WaitWindow{
                .matched = true,
                .elapsed_ms = elapsed_now,
                .window = owned,
            });
        }

        const elapsed_ms: u64 = @intCast(std.time.milliTimestamp() - start_ms);
        if (elapsed_ms >= timeout_ms) {
            return core.model.failure(core.model.WaitWindow, "wait.window", core.errors.codes.timeout, "Timed out while waiting for a matching window.", title);
        }

        std.Thread.sleep(100 * std.time.ns_per_ms);
    }
}

pub fn waitFocus(allocator: std.mem.Allocator, title: []const u8, timeout_ms: u64, match_mode: core.model.StringMatchMode) !core.model.WaitFocusResponse {
    return waitWindow(allocator, title, timeout_ms, match_mode, true);
}

pub fn waitPixel(allocator: std.mem.Allocator, x: i32, y: i32, hex: []const u8, timeout_ms: u64) !core.model.WaitPixelResponse {
    const expected = normalizeHexColor(allocator, hex) catch {
        return core.model.failure(core.model.WaitPixel, "wait.pixel", core.errors.codes.invalid_args, "hex must be RRGGBB or #RRGGBB.", hex);
    };

    const start_ms = nowMs();
    while (true) {
        const pixel_response = try screenPixelColor(allocator, x, y);
        if (!pixel_response.ok) {
            const failure = pixel_response.failure orelse core.errors.ApiError{ .code = core.errors.codes.system_error, .message = "screen.pixel_color failed while polling.", .detail = null };
            return core.model.failure(core.model.WaitPixel, "wait.pixel", failure.code, failure.message, failure.detail);
        }

        const pixel = pixel_response.data.?;
        if (std.ascii.eqlIgnoreCase(pixel.hex, expected)) {
            return core.model.success("wait.pixel", core.model.WaitPixel{
                .matched = true,
                .elapsed_ms = nowMs() - start_ms,
                .pixel = pixel,
            });
        }

        if (nowMs() - start_ms >= timeout_ms) {
            return core.model.failure(core.model.WaitPixel, "wait.pixel", core.errors.codes.timeout, "Timed out while waiting for pixel color match.", expected);
        }

        std.Thread.sleep(100 * std.time.ns_per_ms);
    }
}

pub fn waitClipboard(allocator: std.mem.Allocator, expected_text: ?[]const u8, timeout_ms: u64, match_mode: core.model.StringMatchMode) !core.model.WaitClipboardResponse {
    const baseline = try clipboardSnapshotOptional(allocator);
    const start_ms = nowMs();

    while (true) {
        var iteration_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer iteration_arena.deinit();

        const current = try clipboardSnapshotOptional(iteration_arena.allocator());
        if (expected_text) |wanted| {
            if (current) |value| {
                if (titleMatches(value, wanted, match_mode)) {
                    return core.model.success("wait.clipboard", core.model.WaitClipboard{
                        .matched = true,
                        .elapsed_ms = nowMs() - start_ms,
                        .text = try allocator.dupe(u8, value),
                    });
                }
            }
        } else {
            if (!optionalTextEquals(baseline, current)) {
                return core.model.success("wait.clipboard", core.model.WaitClipboard{
                    .matched = true,
                    .elapsed_ms = nowMs() - start_ms,
                    .text = if (current) |value| try allocator.dupe(u8, value) else null,
                });
            }
        }

        if (nowMs() - start_ms >= timeout_ms) {
            return core.model.failure(core.model.WaitClipboard, "wait.clipboard", core.errors.codes.timeout, "Timed out while waiting for clipboard change.", expected_text);
        }

        std.Thread.sleep(100 * std.time.ns_per_ms);
    }
}

pub fn waitProcess(allocator: std.mem.Allocator, name: ?[]const u8, pid: ?u32, expect_running: bool, timeout_ms: u64, match_mode: core.model.StringMatchMode) !core.model.WaitProcessResponse {
    if (name == null and pid == null) {
        return core.model.failure(core.model.WaitProcess, "wait.process", core.errors.codes.invalid_args, "Provide --name or --pid for wait.process.", null);
    }

    const start_ms = nowMs();
    while (true) {
        var iteration_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer iteration_arena.deinit();

        const snapshot = try systemProcessList(iteration_arena.allocator());
        if (!snapshot.ok) {
            const failure = snapshot.failure orelse core.errors.ApiError{ .code = core.errors.codes.system_error, .message = "system.process_list failed while polling.", .detail = null };
            return core.model.failure(core.model.WaitProcess, "wait.process", failure.code, failure.message, failure.detail);
        }

        var found: ?core.model.ProcessInfo = null;
        for (snapshot.data.?.processes) |process| {
            if (pid) |wanted_pid| {
                if (process.pid == wanted_pid) {
                    found = process;
                    break;
                }
            } else if (name) |wanted_name| {
                if (titleMatches(process.name, wanted_name, match_mode)) {
                    found = process;
                    break;
                }
            }
        }

        const is_running = found != null;
        if (is_running == expect_running) {
            return core.model.success("wait.process", core.model.WaitProcess{
                .matched = true,
                .elapsed_ms = nowMs() - start_ms,
                .process = if (found) |value| .{
                    .pid = value.pid,
                    .name = try allocator.dupe(u8, value.name),
                } else null,
            });
        }

        if (nowMs() - start_ms >= timeout_ms) {
            return core.model.failure(core.model.WaitProcess, "wait.process", core.errors.codes.timeout, "Timed out while waiting for process state transition.", if (name) |value| value else null);
        }

        std.Thread.sleep(150 * std.time.ns_per_ms);
    }
}

const EnumContext = struct {
    allocator: std.mem.Allocator,
    include_hidden: bool,
    foreground: HWND,
    windows: std.ArrayList(core.model.WindowInfo),
    failed: bool,
    failure_detail: ?[]const u8,
};

const DisplayEnumContext = struct {
    allocator: std.mem.Allocator,
    displays: std.ArrayList(core.model.DisplayInfo),
    failed: bool,
    failure_detail: ?[]const u8,
};

const EnumCallbacks = struct {
    fn collectWindow(hwnd: HWND, lparam: LPARAM) callconv(.c) BOOL {
        const context: *EnumContext = @ptrFromInt(@as(usize, @intCast(lparam)));
        if (hwnd == null) return 1;

        if (!context.include_hidden and IsWindowVisible(hwnd) == 0) return 1;

        const info = buildWindowInfo(context.allocator, hwnd, context.foreground) catch |err| {
            context.failed = true;
            context.failure_detail = @errorName(err);
            return 0;
        };

        const should_skip = !context.include_hidden and !info.visible;
        if (should_skip) return 1;

        context.windows.append(context.allocator, info) catch |err| {
            context.failed = true;
            context.failure_detail = @errorName(err);
            return 0;
        };
        return 1;
    }
};

const DisplayEnumCallbacks = struct {
    fn collectMonitor(monitor: HMONITOR, _: HDC, _: *RECT, lparam: LPARAM) callconv(.c) BOOL {
        const context: *DisplayEnumContext = @ptrFromInt(@as(usize, @intCast(lparam)));
        var info = std.mem.zeroes(MONITORINFOEXW);
        info.cbSize = @sizeOf(MONITORINFOEXW);

        if (GetMonitorInfoW(monitor, &info) == 0) {
            context.failed = true;
            context.failure_detail = "GetMonitorInfoW failed";
            return 0;
        }

        const name = utf16FixedToUtf8(context.allocator, info.szDevice[0..]) catch |err| {
            context.failed = true;
            context.failure_detail = @errorName(err);
            return 0;
        };

        const next_id: u32 = @intCast(context.displays.items.len + 1);
        context.displays.append(context.allocator, .{
            .id = next_id,
            .name = name,
            .is_primary = (info.dwFlags & MONITORINFOF_PRIMARY) != 0,
            .bounds = .{
                .left = info.rcMonitor.left,
                .top = info.rcMonitor.top,
                .right = info.rcMonitor.right,
                .bottom = info.rcMonitor.bottom,
                .width = info.rcMonitor.right - info.rcMonitor.left,
                .height = info.rcMonitor.bottom - info.rcMonitor.top,
            },
        }) catch |err| {
            context.failed = true;
            context.failure_detail = @errorName(err);
            return 0;
        };

        return 1;
    }
};

fn buildWindowInfo(allocator: std.mem.Allocator, hwnd: HWND, foreground: HWND) !core.model.WindowInfo {
    var pid: DWORD = 0;
    _ = GetWindowThreadProcessId(hwnd, &pid);

    var rect = std.mem.zeroes(RECT);
    _ = GetWindowRect(hwnd, &rect);

    const title = try getWindowTitle(allocator, hwnd);
    const class_name = try getWindowClassName(allocator, hwnd);
    const visible = IsWindowVisible(hwnd) != 0;
    const ptr_value = hwnd orelse return error.InvalidWindowHandle;

    return .{
        .handle = @intFromPtr(ptr_value),
        .pid = pid,
        .title = title,
        .class_name = class_name,
        .visible = visible,
        .is_foreground = hwnd == foreground,
        .bounds = .{
            .left = rect.left,
            .top = rect.top,
            .right = rect.right,
            .bottom = rect.bottom,
            .width = rect.right - rect.left,
            .height = rect.bottom - rect.top,
        },
    };
}

fn getWindowTitle(allocator: std.mem.Allocator, hwnd: HWND) ![]const u8 {
    const length = GetWindowTextLengthW(hwnd);
    if (length <= 0) return allocator.dupe(u8, "");

    const buffer = try allocator.alloc(u16, @as(usize, @intCast(length + 1)));
    defer allocator.free(buffer);
    @memset(buffer, 0);
    const written = GetWindowTextW(hwnd, @ptrCast(buffer.ptr), length + 1);
    if (written <= 0) return allocator.dupe(u8, "");

    return std.unicode.utf16LeToUtf8Alloc(allocator, buffer[0..@as(usize, @intCast(written))]);
}

fn getWindowClassName(allocator: std.mem.Allocator, hwnd: HWND) ![]const u8 {
    var buffer: [256]u16 = undefined;
    @memset(&buffer, 0);
    const written = GetClassNameW(hwnd, @ptrCast(&buffer), buffer.len);
    if (written <= 0) return allocator.dupe(u8, "");

    return std.unicode.utf16LeToUtf8Alloc(allocator, buffer[0..@as(usize, @intCast(written))]);
}

fn keyInput(key: WORD, flags: DWORD) INPUT {
    return .{
        .type = INPUT_KEYBOARD,
        .Anonymous = .{
            .ki = .{
                .wVk = key,
                .wScan = 0,
                .dwFlags = flags,
                .time = 0,
                .dwExtraInfo = 0,
            },
        },
    };
}

fn keyUnicodeInput(unit: u16, flags: DWORD) INPUT {
    return .{
        .type = INPUT_KEYBOARD,
        .Anonymous = .{
            .ki = .{
                .wVk = 0,
                .wScan = unit,
                .dwFlags = flags,
                .time = 0,
                .dwExtraInfo = 0,
            },
        },
    };
}

fn parseVirtualKey(key: []const u8) ?WORD {
    if (std.ascii.eqlIgnoreCase(key, "ctrl") or std.ascii.eqlIgnoreCase(key, "control")) return VK_CONTROL;
    if (std.ascii.eqlIgnoreCase(key, "shift")) return VK_SHIFT;
    if (std.ascii.eqlIgnoreCase(key, "alt")) return VK_MENU;
    if (std.ascii.eqlIgnoreCase(key, "enter") or std.ascii.eqlIgnoreCase(key, "return")) return VK_RETURN;
    if (std.ascii.eqlIgnoreCase(key, "esc") or std.ascii.eqlIgnoreCase(key, "escape")) return VK_ESCAPE;
    if (std.ascii.eqlIgnoreCase(key, "space")) return VK_SPACE;
    if (std.ascii.eqlIgnoreCase(key, "tab")) return VK_TAB;
    if (std.ascii.eqlIgnoreCase(key, "backspace")) return VK_BACK;
    if (std.ascii.eqlIgnoreCase(key, "delete") or std.ascii.eqlIgnoreCase(key, "del")) return VK_DELETE;
    if (std.ascii.eqlIgnoreCase(key, "insert") or std.ascii.eqlIgnoreCase(key, "ins")) return VK_INSERT;
    if (std.ascii.eqlIgnoreCase(key, "home")) return VK_HOME;
    if (std.ascii.eqlIgnoreCase(key, "end")) return VK_END;
    if (std.ascii.eqlIgnoreCase(key, "pageup") or std.ascii.eqlIgnoreCase(key, "pgup")) return VK_PRIOR;
    if (std.ascii.eqlIgnoreCase(key, "pagedown") or std.ascii.eqlIgnoreCase(key, "pgdn")) return VK_NEXT;
    if (std.ascii.eqlIgnoreCase(key, "left")) return VK_LEFT;
    if (std.ascii.eqlIgnoreCase(key, "up")) return VK_UP;
    if (std.ascii.eqlIgnoreCase(key, "right")) return VK_RIGHT;
    if (std.ascii.eqlIgnoreCase(key, "down")) return VK_DOWN;

    if (key.len == 1) {
        const ch = std.ascii.toUpper(key[0]);
        if (ch >= 'A' and ch <= 'Z') return @as(WORD, ch);
        if (ch >= '0' and ch <= '9') return @as(WORD, ch);
    }

    if (key.len >= 2 and (key[0] == 'F' or key[0] == 'f')) {
        const num = std.fmt.parseInt(u8, key[1..], 10) catch return null;
        if (num >= 1 and num <= 24) return @as(WORD, 0x70 + num - 1);
    }

    return null;
}

fn sendInputs(inputs: []const INPUT) !void {
    if (inputs.len == 0) return;
    const input_count: UINT = std.math.cast(UINT, inputs.len) orelse return error.TooManyInputs;
    const sent = SendInput(input_count, @ptrCast(@constCast(inputs.ptr)), @sizeOf(INPUT));
    if (sent != input_count) {
        return error.SendInputFailed;
    }
}

fn utf16FixedToUtf8(allocator: std.mem.Allocator, values: []const u16) ![]const u8 {
    var len: usize = 0;
    while (len < values.len and values[len] != 0) : (len += 1) {}
    return std.unicode.utf16LeToUtf8Alloc(allocator, values[0..len]);
}

fn driveTypeLabel(kind: UINT) []const u8 {
    return switch (kind) {
        DRIVE_REMOVABLE => "removable",
        DRIVE_FIXED => "fixed",
        DRIVE_REMOTE => "network",
        DRIVE_CDROM => "cdrom",
        DRIVE_RAMDISK => "ramdisk",
        else => "unknown",
    };
}

fn isInvalidHandle(handle: HANDLE) bool {
    if (handle == null) return true;
    return @intFromPtr(handle.?) == std.math.maxInt(usize);
}

fn titleMatches(candidate: []const u8, wanted: []const u8, match_mode: core.model.StringMatchMode) bool {
    return switch (match_mode) {
        .exact => std.mem.eql(u8, candidate, wanted),
        .contains => std.mem.indexOf(u8, candidate, wanted) != null,
    };
}

fn cloneWindowInfo(allocator: std.mem.Allocator, window: core.model.WindowInfo) !core.model.WindowInfo {
    return .{
        .handle = window.handle,
        .pid = window.pid,
        .title = try allocator.dupe(u8, window.title),
        .class_name = try allocator.dupe(u8, window.class_name),
        .visible = window.visible,
        .is_foreground = window.is_foreground,
        .bounds = window.bounds,
    };
}

fn normalizeHexColor(allocator: std.mem.Allocator, hex: []const u8) ![]const u8 {
    const trimmed = if (hex.len > 0 and hex[0] == '#') hex[1..] else hex;
    if (trimmed.len != 6) return error.InvalidHex;
    _ = try std.fmt.parseInt(u24, trimmed, 16);
    return std.fmt.allocPrint(allocator, "#{s}", .{trimmed});
}

fn clipboardSnapshotOptional(allocator: std.mem.Allocator) !?[]const u8 {
    const response = try clipboardGetText(allocator);
    if (response.ok) return response.data.?.text;

    const failure = response.failure orelse return error.UnexpectedClipboardFailure;
    if (std.mem.eql(u8, failure.code, core.errors.codes.clipboard_empty)) return null;
    return error.ClipboardReadFailed;
}

fn optionalTextEquals(left: ?[]const u8, right: ?[]const u8) bool {
    if (left == null and right == null) return true;
    if (left == null or right == null) return false;
    return std.mem.eql(u8, left.?, right.?);
}

fn nowMs() u64 {
    return @intCast(std.time.milliTimestamp());
}

fn writeBmp(path: []const u8, width: i32, height: i32, pixels: []const u8) !void {
    const file = try std.fs.cwd().createFile(path, .{ .truncate = true });
    defer file.close();

    var buffer: [4096]u8 = undefined;
    var file_writer = file.writer(&buffer);
    const writer = &file_writer.interface;
    const header_size: u32 = 14 + @sizeOf(BITMAPINFOHEADER);
    const file_size: u32 = header_size + @as(u32, @intCast(pixels.len));

    try writer.writeAll("BM");
    try writer.writeInt(u32, file_size, .little);
    try writer.writeInt(u16, 0, .little);
    try writer.writeInt(u16, 0, .little);
    try writer.writeInt(u32, header_size, .little);

    try writer.writeInt(u32, @sizeOf(BITMAPINFOHEADER), .little);
    try writer.writeInt(i32, width, .little);
    try writer.writeInt(i32, height, .little);
    try writer.writeInt(u16, 1, .little);
    try writer.writeInt(u16, 32, .little);
    try writer.writeInt(u32, BI_RGB, .little);
    try writer.writeInt(u32, @as(u32, @intCast(pixels.len)), .little);
    try writer.writeInt(i32, 0, .little);
    try writer.writeInt(i32, 0, .little);
    try writer.writeInt(u32, 0, .little);
    try writer.writeInt(u32, 0, .little);

    const row_bytes: usize = @as(usize, @intCast(width)) * 4;
    var row_index: i32 = height - 1;
    while (row_index >= 0) : (row_index -= 1) {
        const offset = @as(usize, @intCast(row_index)) * row_bytes;
        try writer.writeAll(pixels[offset .. offset + row_bytes]);
    }

    try writer.flush();
}

fn lastErrorDetail(allocator: std.mem.Allocator) ![]const u8 {
    return std.fmt.allocPrint(allocator, "win32_last_error={d}", .{GetLastError()});
}
