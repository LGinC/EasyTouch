const std = @import("std");
const builtin = @import("builtin");
const core = @import("easytouch_core");

const BOOL = i32;
const UINT = u32;
const DWORD = u32;
const ULONG = u32;
const WORD = u16;
const BYTE = u8;
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
const VK_CAPITAL: WORD = 0x14;
const VK_LWIN: WORD = 0x5B;
const SW_SHOW: i32 = 5;
const SW_MINIMIZE: i32 = 6;
const SW_MAXIMIZE: i32 = 3;
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
const ERROR_SUCCESS: DWORD = 0;
const ERROR_BUFFER_OVERFLOW: DWORD = 111;
const MAX_ADAPTER_NAME_LENGTH: usize = 256;
const MAX_ADAPTER_DESCRIPTION_LENGTH: usize = 128;
const MAX_ADAPTER_ADDRESS_LENGTH: usize = 8;
const MIB_IF_TYPE_ETHERNET: UINT = 6;
const MIB_IF_TYPE_PPP: UINT = 23;
const MIB_IF_TYPE_LOOPBACK: UINT = 24;
const IF_TYPE_IEEE80211: UINT = 71;

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

const DROPFILES = extern struct {
    pFiles: DWORD,
    pt: POINT,
    fNC: BOOL,
    fWide: BOOL,
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

const IP_ADDRESS_STRING = extern struct {
    String: [16]u8,
};

const IP_MASK_STRING = extern struct {
    String: [16]u8,
};

const IP_ADDR_STRING = extern struct {
    Next: ?*IP_ADDR_STRING,
    IpAddress: IP_ADDRESS_STRING,
    IpMask: IP_MASK_STRING,
    Context: DWORD,
};

const IP_ADAPTER_INFO = extern struct {
    Next: ?*IP_ADAPTER_INFO,
    ComboIndex: DWORD,
    AdapterName: [MAX_ADAPTER_NAME_LENGTH + 4]u8,
    Description: [MAX_ADAPTER_DESCRIPTION_LENGTH + 4]u8,
    AddressLength: UINT,
    Address: [MAX_ADAPTER_ADDRESS_LENGTH]BYTE,
    Index: DWORD,
    Type: UINT,
    DhcpEnabled: UINT,
    CurrentIpAddress: ?*IP_ADDR_STRING,
    IpAddressList: IP_ADDR_STRING,
    GatewayList: IP_ADDR_STRING,
    DhcpServer: IP_ADDR_STRING,
    HaveWins: BOOL,
    PrimaryWinsServer: IP_ADDR_STRING,
    SecondaryWinsServer: IP_ADDR_STRING,
    LeaseObtained: i64,
    LeaseExpires: i64,
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
extern "user32" fn IsZoomed(hWnd: HWND) callconv(.c) BOOL;
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
extern "user32" fn MoveWindow(hWnd: HWND, X: i32, Y: i32, nWidth: i32, nHeight: i32, bRepaint: BOOL) callconv(.c) BOOL;
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
extern "user32" fn GetKeyState(nVirtKey: i32) callconv(.c) i16;
extern "user32" fn VkKeyScanW(ch: u16) callconv(.c) i16;
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
extern "iphlpapi" fn GetAdaptersInfo(pAdapterInfo: ?*IP_ADAPTER_INFO, pOutBufLen: *ULONG) callconv(.c) DWORD;

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

pub fn systemHardwareInfo(allocator: std.mem.Allocator) !core.model.HardwareInfoResponse {
    var info = std.mem.zeroes(SYSTEM_INFO);
    GetSystemInfo(&info);

    var memory_status = std.mem.zeroes(MEMORYSTATUSEX);
    memory_status.dwLength = @sizeOf(MEMORYSTATUSEX);
    if (GlobalMemoryStatusEx(&memory_status) == 0) {
        return core.model.failure(core.model.HardwareInfo, "system.hardware_info", core.errors.codes.system_error, "GlobalMemoryStatusEx failed.", try lastErrorDetail(allocator));
    }

    var machine_name_buffer: [256]u16 = undefined;
    var machine_name_size: DWORD = machine_name_buffer.len;
    var machine_name: []const u8 = "unknown-host";
    if (GetComputerNameW(&machine_name_buffer, &machine_name_size) != 0) {
        machine_name = try std.unicode.utf16LeToUtf8Alloc(allocator, machine_name_buffer[0..machine_name_size]);
    }

    return core.model.success("system.hardware_info", core.model.HardwareInfo{
        .architecture = @tagName(builtin.cpu.arch),
        .logical_cores = info.dwNumberOfProcessors,
        .page_size = info.dwPageSize,
        .total_physical = memory_status.ullTotalPhys,
        .total_virtual = memory_status.ullTotalVirtual,
        .machine_name = machine_name,
    });
}

pub fn systemNetworkInfo(allocator: std.mem.Allocator) !core.model.NetworkInfoResponse {
    var out_len: ULONG = @sizeOf(IP_ADAPTER_INFO);
    var first = std.mem.zeroes(IP_ADAPTER_INFO);
    var status = GetAdaptersInfo(&first, &out_len);

    var allocated_buffer: ?[]align(@alignOf(IP_ADAPTER_INFO)) u8 = null;
    defer if (allocated_buffer) |buffer| allocator.free(buffer);

    var head: *IP_ADAPTER_INFO = &first;
    if (status == ERROR_BUFFER_OVERFLOW) {
        const buffer = try allocator.alignedAlloc(u8, std.mem.Alignment.fromByteUnits(@alignOf(IP_ADAPTER_INFO)), out_len);
        allocated_buffer = buffer;
        head = @ptrCast(buffer.ptr);
        status = GetAdaptersInfo(head, &out_len);
    }

    if (status != ERROR_SUCCESS) {
        return core.model.failure(core.model.NetworkInfo, "system.network_info", core.errors.codes.system_error, "GetAdaptersInfo failed.", try std.fmt.allocPrint(allocator, "iphlpapi_status={d}", .{status}));
    }

    var adapters = std.ArrayList(core.model.NetworkAdapter).empty;
    defer adapters.deinit(allocator);

    var current: ?*IP_ADAPTER_INFO = head;
    while (current) |adapter| : (current = adapter.Next) {
        const name = try cStringFixedToOwned(allocator, adapter.AdapterName[0..]);
        const description = try cStringFixedToOwned(allocator, adapter.Description[0..]);
        var ipv4 = try cStringFixedToOwned(allocator, adapter.IpAddressList.IpAddress.String[0..]);
        if (std.mem.eql(u8, ipv4, "0.0.0.0")) {
            ipv4 = try allocator.dupe(u8, "");
        }

        const address_len = @min(@as(usize, @intCast(adapter.AddressLength)), adapter.Address.len);
        const mac = try formatMacAddress(allocator, adapter.Address[0..address_len]);

        try adapters.append(allocator, .{
            .name = name,
            .description = description,
            .ipv4 = ipv4,
            .mac = mac,
            .adapter_type = adapterTypeLabel(adapter.Type),
            .dhcp_enabled = adapter.DhcpEnabled != 0,
        });
    }

    const owned = try adapters.toOwnedSlice(allocator);
    return core.model.success("system.network_info", core.model.NetworkInfo{
        .count = owned.len,
        .adapters = owned,
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

fn clampI32(value: i32, min_value: i32, max_value: i32) i32 {
    if (value < min_value) return min_value;
    if (value > max_value) return max_value;
    return value;
}

fn absI32(value: i32) i32 {
    if (value >= 0) return value;
    if (value == std.math.minInt(i32)) return std.math.maxInt(i32);
    return -value;
}

pub fn mouseMove(allocator: std.mem.Allocator, x: i32, y: i32, duration_ms: ?u32, jitter_px: ?i32, step_delay_ms: ?u32) !core.model.AckResponse {
    const resolved_duration_ms = duration_ms orelse 280;
    const resolved_jitter_px = jitter_px orelse 3;
    const resolved_step_delay_ms = step_delay_ms orelse 8;

    if (resolved_jitter_px < 0 or resolved_jitter_px > 64) {
        return core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.invalid_args, "jitter_px must be in range 0..64.", null);
    }
    if (resolved_duration_ms > 120_000) {
        return core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.invalid_args, "duration_ms must be <= 120000.", null);
    }
    if (resolved_step_delay_ms > 1000) {
        return core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.invalid_args, "step_delay_ms must be <= 1000.", null);
    }

    var start = std.mem.zeroes(POINT);
    if (GetCursorPos(&start) == 0) {
        return core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.system_error, "GetCursorPos failed before move.", try lastErrorDetail(allocator));
    }

    const dx = x - start.x;
    const dy = y - start.y;
    if (dx == 0 and dy == 0) {
        return core.model.success("mouse.move", core.model.Ack{
            .message = "Mouse already at target.",
            .detail = try std.fmt.allocPrint(allocator, "x={d}; y={d}", .{ x, y }),
        });
    }

    const abs_dx = absI32(dx);
    const abs_dy = absI32(dy);
    const dominant_axis = if (abs_dx > abs_dy) abs_dx else abs_dy;
    const distance_steps = clampI32(@divTrunc(dominant_axis, 6), 12, 240);
    const timing_steps = if (resolved_step_delay_ms == 0)
        0
    else
        @as(i32, @intCast(resolved_duration_ms / resolved_step_delay_ms));
    const steps = clampI32(if (distance_steps > timing_steps) distance_steps else timing_steps, 12, 240);

    var step_index: i32 = 1;
    while (step_index <= steps) : (step_index += 1) {
        const t = @as(f64, @floatFromInt(step_index)) / @as(f64, @floatFromInt(steps));
        const eased = 1.0 - (1.0 - t) * (1.0 - t);

        const base_xf = @as(f64, @floatFromInt(start.x)) + @as(f64, @floatFromInt(dx)) * eased;
        const base_yf = @as(f64, @floatFromInt(start.y)) + @as(f64, @floatFromInt(dy)) * eased;

        const wave = t * (std.math.pi * 3.0);
        const fade = 1.0 - t;
        const jitter_strength = @as(f64, @floatFromInt(resolved_jitter_px)) * fade;

        const jitter_x = if (resolved_jitter_px == 0 or step_index == steps)
            0
        else
            @as(i32, @intFromFloat(@round(jitter_strength * std.math.sin(wave))));
        const jitter_y = if (resolved_jitter_px == 0 or step_index == steps)
            0
        else
            @as(i32, @intFromFloat(@round(jitter_strength * std.math.cos(wave * 1.31))));

        const move_x = if (step_index == steps)
            x
        else
            @as(i32, @intFromFloat(@round(base_xf))) + jitter_x;
        const move_y = if (step_index == steps)
            y
        else
            @as(i32, @intFromFloat(@round(base_yf))) + jitter_y;

        if (SetCursorPos(move_x, move_y) == 0) {
            return core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.system_error, "SetCursorPos failed during trajectory move.", try lastErrorDetail(allocator));
        }

        if (resolved_step_delay_ms > 0 and step_index < steps) {
            std.Thread.sleep(@as(u64, resolved_step_delay_ms) * std.time.ns_per_ms);
        }
    }

    if (SetCursorPos(x, y) == 0) {
        return core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.system_error, "SetCursorPos failed on final target correction.", try lastErrorDetail(allocator));
    }

    return core.model.success("mouse.move", core.model.Ack{
        .message = "Mouse moved with human-like trajectory.",
        .detail = try std.fmt.allocPrint(allocator, "x={d}; y={d}; duration_ms={d}; jitter_px={d}; step_delay_ms={d}; steps={d}", .{ x, y, resolved_duration_ms, resolved_jitter_px, resolved_step_delay_ms, steps }),
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

pub fn keyboardTypeKeys(allocator: std.mem.Allocator, text: []const u8, key_delay_ms: ?u32) !core.model.AckResponse {
    const delay_ms = key_delay_ms orelse 30;
    if (delay_ms > 1000) {
        return core.model.failure(core.model.Ack, "keyboard.type_keys", core.errors.codes.invalid_args, "key_delay_ms must be <= 1000.", null);
    }

    const utf16 = try std.unicode.utf8ToUtf16LeAlloc(allocator, text);
    defer allocator.free(utf16);

    for (utf16) |unit| {
        if (unit == '\n') {
            sendKeyTap(VK_RETURN) catch {
                return core.model.failure(core.model.Ack, "keyboard.type_keys", core.errors.codes.system_error, "SendInput failed while typing ENTER.", try lastErrorDetail(allocator));
            };
        } else if (unit == '\t') {
            sendKeyTap(VK_TAB) catch {
                return core.model.failure(core.model.Ack, "keyboard.type_keys", core.errors.codes.system_error, "SendInput failed while typing TAB.", try lastErrorDetail(allocator));
            };
        } else {
            const vk_scan = VkKeyScanW(unit);
            if (vk_scan == -1) {
                return core.model.failure(core.model.Ack, "keyboard.type_keys", core.errors.codes.invalid_args, "Character cannot be typed by keyboard layout in keymap mode.", try std.fmt.allocPrint(allocator, "utf16=0x{x}", .{unit}));
            }

            const scan_u16: u16 = @bitCast(vk_scan);
            const vk: WORD = @intCast(scan_u16 & 0x00FF);
            const shift_state: u8 = @intCast((scan_u16 >> 8) & 0x00FF);

            sendVkWithShiftState(vk, shift_state) catch {
                return core.model.failure(core.model.Ack, "keyboard.type_keys", core.errors.codes.system_error, "SendInput failed while typing by keyboard layout.", try lastErrorDetail(allocator));
            };
        }

        if (delay_ms > 0) {
            std.Thread.sleep(@as(u64, delay_ms) * std.time.ns_per_ms);
        }
    }

    return core.model.success("keyboard.type_keys", core.model.Ack{
        .message = "Keymap typing sent.",
        .detail = try std.fmt.allocPrint(allocator, "utf16_units={d}; key_delay_ms={d}", .{ utf16.len, delay_ms }),
    });
}

pub fn keyboardImeSwitch(allocator: std.mem.Allocator, strategy: ?[]const u8) !core.model.AckResponse {
    const resolved = strategy orelse "win-space";

    if (std.ascii.eqlIgnoreCase(resolved, "win-space")) {
        sendInputs(&[_]INPUT{
            keyInput(VK_LWIN, 0),
            keyInput(VK_SPACE, 0),
            keyInput(VK_SPACE, KEYEVENTF_KEYUP),
            keyInput(VK_LWIN, KEYEVENTF_KEYUP),
        }) catch {
            return core.model.failure(core.model.Ack, "keyboard.ime_switch", core.errors.codes.system_error, "SendInput failed for win-space strategy.", try lastErrorDetail(allocator));
        };
    } else if (std.ascii.eqlIgnoreCase(resolved, "alt-shift")) {
        sendInputs(&[_]INPUT{
            keyInput(VK_MENU, 0),
            keyInput(VK_SHIFT, 0),
            keyInput(VK_SHIFT, KEYEVENTF_KEYUP),
            keyInput(VK_MENU, KEYEVENTF_KEYUP),
        }) catch {
            return core.model.failure(core.model.Ack, "keyboard.ime_switch", core.errors.codes.system_error, "SendInput failed for alt-shift strategy.", try lastErrorDetail(allocator));
        };
    } else if (std.ascii.eqlIgnoreCase(resolved, "ctrl-shift")) {
        sendInputs(&[_]INPUT{
            keyInput(VK_CONTROL, 0),
            keyInput(VK_SHIFT, 0),
            keyInput(VK_SHIFT, KEYEVENTF_KEYUP),
            keyInput(VK_CONTROL, KEYEVENTF_KEYUP),
        }) catch {
            return core.model.failure(core.model.Ack, "keyboard.ime_switch", core.errors.codes.system_error, "SendInput failed for ctrl-shift strategy.", try lastErrorDetail(allocator));
        };
    } else {
        return core.model.failure(core.model.Ack, "keyboard.ime_switch", core.errors.codes.invalid_args, "Unsupported strategy. Use win-space, alt-shift, or ctrl-shift.", resolved);
    }

    return core.model.success("keyboard.ime_switch", core.model.Ack{
        .message = "IME switch shortcut sent.",
        .detail = try std.fmt.allocPrint(allocator, "strategy={s}", .{resolved}),
    });
}

pub fn keyboardCapsLock(allocator: std.mem.Allocator, state: ?[]const u8) !core.model.AckResponse {
    const resolved = state orelse "toggle";
    const current_on = (GetKeyState(@as(i32, VK_CAPITAL)) & 0x0001) != 0;

    var target_toggle = false;
    var target_on = current_on;
    if (std.ascii.eqlIgnoreCase(resolved, "toggle")) {
        target_toggle = true;
        target_on = !current_on;
    } else if (std.ascii.eqlIgnoreCase(resolved, "on")) {
        target_toggle = !current_on;
        target_on = true;
    } else if (std.ascii.eqlIgnoreCase(resolved, "off")) {
        target_toggle = current_on;
        target_on = false;
    } else {
        return core.model.failure(core.model.Ack, "keyboard.caps_lock", core.errors.codes.invalid_args, "Unsupported state. Use toggle, on, or off.", resolved);
    }

    if (target_toggle) {
        sendKeyTap(VK_CAPITAL) catch {
            return core.model.failure(core.model.Ack, "keyboard.caps_lock", core.errors.codes.system_error, "SendInput failed while toggling caps lock.", try lastErrorDetail(allocator));
        };
    }

    return core.model.success("keyboard.caps_lock", core.model.Ack{
        .message = "Caps lock state updated.",
        .detail = try std.fmt.allocPrint(allocator, "requested={s}; active={s}", .{ resolved, if (target_on) "on" else "off" }),
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

pub fn windowShow(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    if (handle == 0) {
        return core.model.failure(core.model.Ack, "window.show", core.errors.codes.invalid_args, "Window operation requires a non-zero handle.", null);
    }
    const hwnd: HWND = @ptrFromInt(handle);
    if (IsWindow(hwnd) == 0) {
        return core.model.failure(core.model.Ack, "window.show", core.errors.codes.not_found, "The requested window handle is no longer valid.", try std.fmt.allocPrint(allocator, "target_handle=0x{x}", .{handle}));
    }

    _ = ShowWindow(hwnd, SW_SHOW);
    const activation_detail = try requestForegroundActivation(allocator, hwnd, handle);

    return core.model.success("window.show", core.model.Ack{
        .message = "Window shown and activation requested.",
        .detail = activation_detail,
    });
}

pub fn windowMinimize(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    if (handle == 0) {
        return core.model.failure(core.model.Ack, "window.minimize", core.errors.codes.invalid_args, "Window operation requires a non-zero handle.", null);
    }
    const hwnd: HWND = @ptrFromInt(handle);
    if (IsWindow(hwnd) == 0) {
        return core.model.failure(core.model.Ack, "window.minimize", core.errors.codes.not_found, "The requested window handle is no longer valid.", try std.fmt.allocPrint(allocator, "target_handle=0x{x}", .{handle}));
    }

    _ = ShowWindow(hwnd, SW_MINIMIZE);

    if (IsIconic(hwnd) == 0) {
        return core.model.failure(core.model.Ack, "window.minimize", core.errors.codes.system_error, "Window minimize request did not result in iconic state.", try std.fmt.allocPrint(allocator, "target_handle=0x{x}", .{handle}));
    }

    return core.model.success("window.minimize", core.model.Ack{
        .message = "Window minimized.",
        .detail = try std.fmt.allocPrint(allocator, "target_handle=0x{x}", .{handle}),
    });
}

pub fn windowMaximize(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    if (handle == 0) {
        return core.model.failure(core.model.Ack, "window.maximize", core.errors.codes.invalid_args, "Window operation requires a non-zero handle.", null);
    }
    const hwnd: HWND = @ptrFromInt(handle);
    if (IsWindow(hwnd) == 0) {
        return core.model.failure(core.model.Ack, "window.maximize", core.errors.codes.not_found, "The requested window handle is no longer valid.", try std.fmt.allocPrint(allocator, "target_handle=0x{x}", .{handle}));
    }

    _ = ShowWindow(hwnd, SW_MAXIMIZE);

    if (IsZoomed(hwnd) == 0) {
        return core.model.failure(core.model.Ack, "window.maximize", core.errors.codes.system_error, "Window maximize request did not result in zoomed state.", try std.fmt.allocPrint(allocator, "target_handle=0x{x}", .{handle}));
    }

    return core.model.success("window.maximize", core.model.Ack{
        .message = "Window maximized.",
        .detail = try std.fmt.allocPrint(allocator, "target_handle=0x{x}", .{handle}),
    });
}

pub fn windowRestore(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    if (handle == 0) {
        return core.model.failure(core.model.Ack, "window.restore", core.errors.codes.invalid_args, "Window operation requires a non-zero handle.", null);
    }
    const hwnd: HWND = @ptrFromInt(handle);
    if (IsWindow(hwnd) == 0) {
        return core.model.failure(core.model.Ack, "window.restore", core.errors.codes.not_found, "The requested window handle is no longer valid.", try std.fmt.allocPrint(allocator, "target_handle=0x{x}", .{handle}));
    }

    _ = ShowWindow(hwnd, SW_RESTORE);

    return core.model.success("window.restore", core.model.Ack{
        .message = "Window restore requested.",
        .detail = try std.fmt.allocPrint(allocator, "target_handle=0x{x}", .{handle}),
    });
}

pub fn windowMove(allocator: std.mem.Allocator, handle: u64, x: i32, y: i32, width: ?i32, height: ?i32) !core.model.AckResponse {
    if (handle == 0) {
        return core.model.failure(core.model.Ack, "window.move", core.errors.codes.invalid_args, "Window operation requires a non-zero handle.", null);
    }
    const hwnd: HWND = @ptrFromInt(handle);
    if (IsWindow(hwnd) == 0) {
        return core.model.failure(core.model.Ack, "window.move", core.errors.codes.not_found, "The requested window handle is no longer valid.", try std.fmt.allocPrint(allocator, "target_handle=0x{x}", .{handle}));
    }

    var rect = std.mem.zeroes(RECT);
    if (GetWindowRect(hwnd, &rect) == 0) {
        return core.model.failure(core.model.Ack, "window.move", core.errors.codes.system_error, "GetWindowRect failed while preparing move target.", try lastErrorDetail(allocator));
    }

    const resolved_width = width orelse (rect.right - rect.left);
    const resolved_height = height orelse (rect.bottom - rect.top);

    if (resolved_width <= 0 or resolved_height <= 0) {
        return core.model.failure(core.model.Ack, "window.move", core.errors.codes.invalid_args, "window width and height must be positive.", try std.fmt.allocPrint(allocator, "width={d}; height={d}", .{ resolved_width, resolved_height }));
    }

    if (MoveWindow(hwnd, x, y, resolved_width, resolved_height, 1) == 0) {
        return core.model.failure(core.model.Ack, "window.move", core.errors.codes.system_error, "MoveWindow failed.", try lastErrorDetail(allocator));
    }

    return core.model.success("window.move", core.model.Ack{
        .message = "Window moved.",
        .detail = try std.fmt.allocPrint(allocator, "target_handle=0x{x}; x={d}; y={d}; width={d}; height={d}", .{ handle, x, y, resolved_width, resolved_height }),
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

pub fn clipboardSetFiles(allocator: std.mem.Allocator, paths: []const u8) !core.model.AckResponse {
    var parsed = std.ArrayList([]const u8).empty;
    defer {
        for (parsed.items) |item| allocator.free(item);
        parsed.deinit(allocator);
    }
    try parseSemicolonPaths(allocator, paths, &parsed);
    if (parsed.items.len == 0) {
        return core.model.failure(core.model.Ack, "clipboard.set_files", core.errors.codes.invalid_args, "paths must contain at least one file path.", null);
    }

    const wide_payload = try buildHDropWidePayload(allocator, parsed.items);
    defer allocator.free(wide_payload);

    const bytes = @sizeOf(DROPFILES) + (wide_payload.len * @sizeOf(u16));
    const memory = GlobalAlloc(GMEM_MOVEABLE | GMEM_ZEROINIT, bytes);
    if (memory == null) {
        return core.model.failure(core.model.Ack, "clipboard.set_files", core.errors.codes.system_error, "GlobalAlloc failed.", try lastErrorDetail(allocator));
    }

    const locked = GlobalLock(memory) orelse {
        _ = GlobalFree(memory);
        return core.model.failure(core.model.Ack, "clipboard.set_files", core.errors.codes.system_error, "GlobalLock failed for file-drop payload.", try lastErrorDetail(allocator));
    };

    const payload_ptr: [*]u8 = @ptrCast(locked);
    const dropfiles_ptr: *DROPFILES = @ptrCast(@alignCast(payload_ptr));
    dropfiles_ptr.* = .{
        .pFiles = @sizeOf(DROPFILES),
        .pt = .{ .x = 0, .y = 0 },
        .fNC = 0,
        .fWide = 1,
    };

    const wide_dest: [*]u16 = @ptrCast(@alignCast(payload_ptr + @sizeOf(DROPFILES)));
    std.mem.copyForwards(u16, wide_dest[0..wide_payload.len], wide_payload);
    _ = GlobalUnlock(memory);

    if (OpenClipboard(null) == 0) {
        _ = GlobalFree(memory);
        return core.model.failure(core.model.Ack, "clipboard.set_files", core.errors.codes.permission_denied, "OpenClipboard failed.", try lastErrorDetail(allocator));
    }
    defer _ = CloseClipboard();

    if (EmptyClipboard() == 0) {
        _ = GlobalFree(memory);
        return core.model.failure(core.model.Ack, "clipboard.set_files", core.errors.codes.system_error, "EmptyClipboard failed.", try lastErrorDetail(allocator));
    }

    if (SetClipboardData(CF_HDROP, memory) == null) {
        _ = GlobalFree(memory);
        return core.model.failure(core.model.Ack, "clipboard.set_files", core.errors.codes.system_error, "SetClipboardData failed for CF_HDROP.", try lastErrorDetail(allocator));
    }

    return core.model.success("clipboard.set_files", core.model.Ack{
        .message = "Clipboard file-drop payload updated.",
        .detail = try std.fmt.allocPrint(allocator, "count={d}", .{parsed.items.len}),
    });
}

pub fn clipboardSetImage(allocator: std.mem.Allocator, path: []const u8) !core.model.AckResponse {
    if (path.len == 0) {
        return core.model.failure(core.model.Ack, "clipboard.set_image", core.errors.codes.invalid_args, "path cannot be empty.", null);
    }

    const escaped = try escapeForSingleQuotedPowerShell(allocator, path);
    defer allocator.free(escaped);
    const script = try std.fmt.allocPrint(allocator,
        "Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $img=[System.Drawing.Image]::FromFile('{s}'); [System.Windows.Forms.Clipboard]::SetImage($img); $img.Dispose()",
        .{escaped},
    );
    defer allocator.free(script);

    var child = std.process.Child.init(&[_][]const u8{ "powershell", "-NoProfile", "-STA", "-Command", script }, allocator);
    child.stdin_behavior = .Ignore;
    child.stdout_behavior = .Ignore;
    child.stderr_behavior = .Pipe;

    child.spawn() catch |err| {
        return core.model.failure(core.model.Ack, "clipboard.set_image", core.errors.codes.system_error, "Failed to spawn powershell for clipboard image write.", @errorName(err));
    };

    const term = child.wait() catch |err| {
        return core.model.failure(core.model.Ack, "clipboard.set_image", core.errors.codes.system_error, "Failed while waiting for powershell image clipboard command.", @errorName(err));
    };

    switch (term) {
        .Exited => |code| {
            if (code != 0) {
                return core.model.failure(core.model.Ack, "clipboard.set_image", core.errors.codes.system_error, "PowerShell image clipboard command returned non-zero exit code.", try std.fmt.allocPrint(allocator, "exit_code={d}", .{code}));
            }
        },
        else => {
            return core.model.failure(core.model.Ack, "clipboard.set_image", core.errors.codes.system_error, "PowerShell image clipboard command did not exit normally.", null);
        },
    }

    return core.model.success("clipboard.set_image", core.model.Ack{
        .message = "Clipboard image updated.",
        .detail = try std.fmt.allocPrint(allocator, "path={s}", .{path}),
    });
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

pub fn screenCapture(allocator: std.mem.Allocator, path: []const u8, display_id: ?u32, window_handle: ?u64) !core.model.ScreenCaptureResponse {
    if (std.fs.path.dirname(path)) |dir_name| {
        try std.fs.cwd().makePath(dir_name);
    }

    if (display_id != null and window_handle != null) {
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.invalid_args, "display_id and window_handle cannot be used together.", null);
    }

    var capture_rect = std.mem.zeroes(RECT);
    if (window_handle) |handle| {
        if (handle == 0) {
            return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.invalid_args, "window_handle must be a non-zero window handle.", null);
        }

        const hwnd: HWND = @ptrFromInt(handle);
        if (IsWindow(hwnd) == 0) {
            return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.not_found, "The requested window_handle is not a valid window.", try std.fmt.allocPrint(allocator, "window_handle=0x{x}", .{handle}));
        }

        if (GetWindowRect(hwnd, &capture_rect) == 0) {
            return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.system_error, "GetWindowRect failed for the requested window_handle.", try lastErrorDetail(allocator));
        }
    } else if (display_id) |target_display_id| {
        const displays_response = try screenDisplays(allocator);
        if (!displays_response.ok) {
            const failure = displays_response.failure orelse core.errors.ApiError{ .code = core.errors.codes.system_error, .message = "screen.displays failed while resolving display_id.", .detail = null };
            return core.model.failure(core.model.ScreenCapture, "screen.capture", failure.code, failure.message, failure.detail);
        }

        var found = false;
        for (displays_response.data.?.displays) |display| {
            if (display.id != target_display_id) continue;
            capture_rect.left = display.bounds.left;
            capture_rect.top = display.bounds.top;
            capture_rect.right = display.bounds.right;
            capture_rect.bottom = display.bounds.bottom;
            found = true;
            break;
        }

        if (!found) {
            return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.not_found, "display_id was not found in screen.displays.", try std.fmt.allocPrint(allocator, "display_id={d}", .{target_display_id}));
        }
    } else {
        capture_rect.left = GetSystemMetrics(SM_XVIRTUALSCREEN);
        capture_rect.top = GetSystemMetrics(SM_YVIRTUALSCREEN);
        capture_rect.right = capture_rect.left + GetSystemMetrics(SM_CXVIRTUALSCREEN);
        capture_rect.bottom = capture_rect.top + GetSystemMetrics(SM_CYVIRTUALSCREEN);
    }

    return captureRectToPng(allocator, "screen.capture", path, capture_rect);
}

fn captureRectToPng(allocator: std.mem.Allocator, capability: []const u8, path: []const u8, rect: RECT) !core.model.ScreenCaptureResponse {
    const x = rect.left;
    const y = rect.top;
    const width = rect.right - rect.left;
    const height = rect.bottom - rect.top;

    if (width <= 0 or height <= 0) {
        return core.model.failure(core.model.ScreenCapture, capability, core.errors.codes.system_error, "Capture target rectangle is invalid.", try std.fmt.allocPrint(allocator, "left={d}; top={d}; right={d}; bottom={d}", .{ rect.left, rect.top, rect.right, rect.bottom }));
    }

    const screen_dc = GetDC(null);
    if (screen_dc == null) {
        return core.model.failure(core.model.ScreenCapture, capability, core.errors.codes.system_error, "GetDC failed.", try lastErrorDetail(allocator));
    }
    defer _ = ReleaseDC(null, screen_dc);

    const memory_dc = CreateCompatibleDC(screen_dc);
    if (memory_dc == null) {
        return core.model.failure(core.model.ScreenCapture, capability, core.errors.codes.system_error, "CreateCompatibleDC failed.", try lastErrorDetail(allocator));
    }
    defer _ = DeleteDC(memory_dc);

    const bitmap = CreateCompatibleBitmap(screen_dc, width, height);
    if (bitmap == null) {
        return core.model.failure(core.model.ScreenCapture, capability, core.errors.codes.system_error, "CreateCompatibleBitmap failed.", try lastErrorDetail(allocator));
    }
    defer _ = DeleteObject(bitmap);

    const old_object = SelectObject(memory_dc, bitmap) orelse {
        return core.model.failure(core.model.ScreenCapture, capability, core.errors.codes.system_error, "SelectObject failed.", try lastErrorDetail(allocator));
    };
    var bitmap_selected = true;
    defer if (bitmap_selected) {
        _ = SelectObject(memory_dc, old_object);
    };

    if (BitBlt(memory_dc, 0, 0, width, height, screen_dc, x, y, SRCCOPY) == 0) {
        return core.model.failure(core.model.ScreenCapture, capability, core.errors.codes.system_error, "BitBlt failed.", try lastErrorDetail(allocator));
    }

    _ = SelectObject(memory_dc, old_object);
    bitmap_selected = false;

    writePngFromBitmap(allocator, path, bitmap) catch |err| {
        const detail = try std.fmt.allocPrint(allocator, "png_encode_error={s}", .{@errorName(err)});
        return core.model.failure(core.model.ScreenCapture, capability, core.errors.codes.system_error, "Failed to encode screenshot as PNG.", detail);
    };

    return core.model.success(capability, core.model.ScreenCapture{
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

pub fn elementTree(allocator: std.mem.Allocator, window_handle: ?u64, max_depth: ?u32, max_children: ?u32, max_nodes: ?u32, include_offscreen: bool) !core.model.ElementTreeResponse {
    const target_handle = if (window_handle) |value|
        value
    else blk: {
        const foreground = GetForegroundWindow() orelse {
            return core.model.failure(core.model.ElementTree, "element.tree", core.errors.codes.not_found, "No foreground window is available for element tree inspection.", null);
        };
        break :blk @intFromPtr(foreground);
    };

    if (target_handle == 0) {
        return core.model.failure(core.model.ElementTree, "element.tree", core.errors.codes.invalid_args, "window_handle must be non-zero when provided.", null);
    }

    const hwnd: HWND = @ptrFromInt(target_handle);
    if (IsWindow(hwnd) == 0) {
        return core.model.failure(core.model.ElementTree, "element.tree", core.errors.codes.not_found, "The requested window_handle is not a valid window.", try std.fmt.allocPrint(allocator, "window_handle=0x{x}", .{target_handle}));
    }

    const resolved_max_depth = max_depth orelse 4;
    if (resolved_max_depth == 0 or resolved_max_depth > 12) {
        return core.model.failure(core.model.ElementTree, "element.tree", core.errors.codes.invalid_args, "max_depth must be in range 1..12.", null);
    }

    const resolved_max_children = max_children orelse 20;
    if (resolved_max_children == 0 or resolved_max_children > 100) {
        return core.model.failure(core.model.ElementTree, "element.tree", core.errors.codes.invalid_args, "max_children must be in range 1..100.", null);
    }

    const resolved_max_nodes = max_nodes orelse 250;
    if (resolved_max_nodes == 0 or resolved_max_nodes > 1500) {
        return core.model.failure(core.model.ElementTree, "element.tree", core.errors.codes.invalid_args, "max_nodes must be in range 1..1500.", null);
    }

    const script = try buildElementTreePowerShellScript(allocator, target_handle, resolved_max_depth, resolved_max_children, resolved_max_nodes, include_offscreen);
    const output = try runPowerShellCommand(allocator, script);
    if (output.missing) {
        return core.model.failure(core.model.ElementTree, "element.tree", core.errors.codes.not_implemented, "powershell.exe was not found, so Windows UI Automation inspection is unavailable.", output.stderr);
    }
    if (output.exit_code == null) {
        return core.model.failure(core.model.ElementTree, "element.tree", core.errors.codes.system_error, "PowerShell UI Automation command did not exit normally.", try powerShellCommandDetail(allocator, output));
    }
    if (output.exit_code.? != 0) {
        return core.model.failure(core.model.ElementTree, "element.tree", core.errors.codes.system_error, "PowerShell UI Automation command returned a non-zero exit code.", try powerShellCommandDetail(allocator, output));
    }

    const parsed = std.json.parseFromSlice(PowerShellElementTreePayload, allocator, output.stdout, .{ .ignore_unknown_fields = true }) catch |err| {
        const detail = try std.fmt.allocPrint(allocator, "parse_error={s}; detail={s}", .{ @errorName(err), powerShellTextSnippet(output.stdout) });
        return core.model.failure(core.model.ElementTree, "element.tree", core.errors.codes.system_error, "Failed to parse UI Automation element tree JSON.", detail);
    };
    const payload = parsed.value;

    if (!payload.ok) {
        return core.model.failure(core.model.ElementTree, "element.tree", payload.code orelse core.errors.codes.system_error, payload.message orelse "UI Automation element tree inspection failed.", payload.detail);
    }

    const root = payload.root orelse {
        return core.model.failure(core.model.ElementTree, "element.tree", core.errors.codes.system_error, "UI Automation element tree response did not include a root node.", powerShellTextSnippet(output.stdout));
    };

    return core.model.success("element.tree", core.model.ElementTree{
        .window_handle = payload.window_handle orelse target_handle,
        .window_title = payload.window_title orelse try allocator.dupe(u8, ""),
        .generated_at = payload.generated_at orelse try allocator.dupe(u8, ""),
        .max_depth = payload.max_depth orelse resolved_max_depth,
        .max_children = payload.max_children orelse resolved_max_children,
        .max_nodes = payload.max_nodes orelse resolved_max_nodes,
        .include_offscreen = payload.include_offscreen orelse include_offscreen,
        .root = root,
    });
}

pub fn elementClick(allocator: std.mem.Allocator, element_id: []const u8, window_handle: ?u64, button: core.model.MouseButton, move_duration_ms: ?u32) !core.model.AckResponse {
    if (element_id.len == 0) {
        return core.model.failure(core.model.Ack, "element.click", core.errors.codes.invalid_args, "element_id cannot be empty.", null);
    }

    const target_handle = if (window_handle) |value|
        value
    else blk: {
        const foreground = GetForegroundWindow() orelse {
            return core.model.failure(core.model.Ack, "element.click", core.errors.codes.not_found, "No foreground window is available for element click.", null);
        };
        break :blk @intFromPtr(foreground);
    };

    if (target_handle == 0) {
        return core.model.failure(core.model.Ack, "element.click", core.errors.codes.invalid_args, "window_handle must be non-zero when provided.", null);
    }

    const hwnd: HWND = @ptrFromInt(target_handle);
    if (IsWindow(hwnd) == 0) {
        return core.model.failure(core.model.Ack, "element.click", core.errors.codes.not_found, "The requested window_handle is not a valid window.", try std.fmt.allocPrint(allocator, "window_handle=0x{x}", .{target_handle}));
    }

    const script = try buildElementClickPowerShellScript(allocator, target_handle, element_id);
    const output = try runPowerShellCommand(allocator, script);
    if (output.missing) {
        return core.model.failure(core.model.Ack, "element.click", core.errors.codes.not_implemented, "powershell.exe was not found, so Windows UI Automation element lookup is unavailable.", output.stderr);
    }
    if (output.exit_code == null) {
        return core.model.failure(core.model.Ack, "element.click", core.errors.codes.system_error, "PowerShell UI Automation element lookup did not exit normally.", try powerShellCommandDetail(allocator, output));
    }
    if (output.exit_code.? != 0) {
        return core.model.failure(core.model.Ack, "element.click", core.errors.codes.system_error, "PowerShell UI Automation element lookup returned a non-zero exit code.", try powerShellCommandDetail(allocator, output));
    }

    const parsed = std.json.parseFromSlice(PowerShellElementClickPayload, allocator, output.stdout, .{ .ignore_unknown_fields = true }) catch |err| {
        const detail = try std.fmt.allocPrint(allocator, "parse_error={s}; detail={s}", .{ @errorName(err), powerShellTextSnippet(output.stdout) });
        return core.model.failure(core.model.Ack, "element.click", core.errors.codes.system_error, "Failed to parse UI Automation element lookup JSON.", detail);
    };
    const payload = parsed.value;

    if (!payload.ok) {
        return core.model.failure(core.model.Ack, "element.click", payload.code orelse core.errors.codes.system_error, payload.message orelse "UI Automation element lookup failed.", payload.detail);
    }

    const bounds = payload.bounds orelse {
        return core.model.failure(core.model.Ack, "element.click", core.errors.codes.system_error, "UI Automation element lookup did not include bounds.", powerShellTextSnippet(output.stdout));
    };
    const center = payload.center orelse {
        return core.model.failure(core.model.Ack, "element.click", core.errors.codes.system_error, "UI Automation element lookup did not include a click center.", powerShellTextSnippet(output.stdout));
    };

    if ((payload.is_offscreen orelse false) or bounds.width <= 0 or bounds.height <= 0) {
        return core.model.failure(core.model.Ack, "element.click", core.errors.codes.unsafe_operation, "The requested element does not currently expose a clickable on-screen bounding rectangle.", try std.fmt.allocPrint(allocator, "element_id={s}; is_offscreen={s}; bounds={d},{d},{d},{d}", .{ element_id, if (payload.is_offscreen orelse false) "true" else "false", bounds.left, bounds.top, bounds.right, bounds.bottom }));
    }

    const activation = try windowActivate(allocator, target_handle);
    if (!activation.ok) {
        return activation;
    }

    const move_response = try mouseMove(allocator, center.x, center.y, move_duration_ms orelse 120, 0, 6);
    if (!move_response.ok) {
        return move_response;
    }

    const click_response = try mouseClick(allocator, button, 1);
    if (!click_response.ok) {
        return click_response;
    }

    return core.model.success("element.click", core.model.Ack{
        .message = "Element center click sent.",
        .detail = try std.fmt.allocPrint(allocator, "window_handle=0x{x}; element_id={s}; name={s}; control_type={s}; center={d},{d}; button={s}", .{ target_handle, payload.element_id orelse element_id, payload.name orelse "", payload.control_type orelse "", center.x, center.y, mouseButtonName(button) }),
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

pub fn waitActivate(allocator: std.mem.Allocator, handle: u64, timeout_ms: u64, expect_active: bool) !core.model.WaitWindowResponse {
    if (handle == 0) {
        return core.model.failure(core.model.WaitWindow, "wait.activate", core.errors.codes.invalid_args, "handle must be non-zero.", null);
    }

    const start_ms = nowMs();
    while (true) {
        const foreground = GetForegroundWindow();
        const active = if (foreground) |fg| @intFromPtr(fg) == handle else false;

        if (active == expect_active) {
            const elapsed_ms = nowMs() - start_ms;
            var window: ?core.model.WindowInfo = null;

            if (foreground) |fg| {
                window = try buildWindowInfo(allocator, fg, fg);
            }

            return core.model.success("wait.activate", core.model.WaitWindow{
                .matched = true,
                .elapsed_ms = elapsed_ms,
                .window = window,
            });
        }

        if (nowMs() - start_ms >= timeout_ms) {
            return core.model.failure(core.model.WaitWindow, "wait.activate", core.errors.codes.timeout, "Timed out while waiting for window activation state.", try std.fmt.allocPrint(allocator, "target_handle=0x{x}; expect_active={s}", .{ handle, if (expect_active) "true" else "false" }));
        }

        std.Thread.sleep(100 * std.time.ns_per_ms);
    }
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
    if (std.ascii.eqlIgnoreCase(key, "caps") or std.ascii.eqlIgnoreCase(key, "capslock")) return VK_CAPITAL;
    if (std.ascii.eqlIgnoreCase(key, "win") or std.ascii.eqlIgnoreCase(key, "lwin")) return VK_LWIN;
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

fn sendKeyTap(key: WORD) !void {
    try sendInputs(&[_]INPUT{
        keyInput(key, 0),
        keyInput(key, KEYEVENTF_KEYUP),
    });
}

fn sendVkWithShiftState(vk: WORD, shift_state: u8) !void {
    var inputs = std.ArrayList(INPUT).empty;
    defer inputs.deinit(std.heap.page_allocator);

    if ((shift_state & 1) != 0) try inputs.append(std.heap.page_allocator, keyInput(VK_SHIFT, 0));
    if ((shift_state & 2) != 0) try inputs.append(std.heap.page_allocator, keyInput(VK_CONTROL, 0));
    if ((shift_state & 4) != 0) try inputs.append(std.heap.page_allocator, keyInput(VK_MENU, 0));

    try inputs.append(std.heap.page_allocator, keyInput(vk, 0));
    try inputs.append(std.heap.page_allocator, keyInput(vk, KEYEVENTF_KEYUP));

    if ((shift_state & 4) != 0) try inputs.append(std.heap.page_allocator, keyInput(VK_MENU, KEYEVENTF_KEYUP));
    if ((shift_state & 2) != 0) try inputs.append(std.heap.page_allocator, keyInput(VK_CONTROL, KEYEVENTF_KEYUP));
    if ((shift_state & 1) != 0) try inputs.append(std.heap.page_allocator, keyInput(VK_SHIFT, KEYEVENTF_KEYUP));

    try sendInputs(inputs.items);
}

fn utf16FixedToUtf8(allocator: std.mem.Allocator, values: []const u16) ![]const u8 {
    var len: usize = 0;
    while (len < values.len and values[len] != 0) : (len += 1) {}
    return std.unicode.utf16LeToUtf8Alloc(allocator, values[0..len]);
}

fn cStringFixedToOwned(allocator: std.mem.Allocator, values: []const u8) ![]const u8 {
    var len: usize = 0;
    while (len < values.len and values[len] != 0) : (len += 1) {}
    return allocator.dupe(u8, values[0..len]);
}

fn parseSemicolonPaths(allocator: std.mem.Allocator, raw: []const u8, output: *std.ArrayList([]const u8)) !void {
    var iter = std.mem.splitScalar(u8, raw, ';');
    while (iter.next()) |token_raw| {
        const token = std.mem.trim(u8, token_raw, " \t\r\n");
        if (token.len == 0) continue;
        try output.append(allocator, try allocator.dupe(u8, token));
    }
}

fn buildHDropWidePayload(allocator: std.mem.Allocator, paths: []const []const u8) ![]u16 {
    var out = std.ArrayList(u16).empty;
    defer out.deinit(allocator);

    for (paths) |path| {
        const wide = try std.unicode.utf8ToUtf16LeAlloc(allocator, path);
        defer allocator.free(wide);
        try out.appendSlice(allocator, wide);
        try out.append(allocator, 0);
    }
    try out.append(allocator, 0);

    return out.toOwnedSlice(allocator);
}

fn escapeForSingleQuotedPowerShell(allocator: std.mem.Allocator, value: []const u8) ![]const u8 {
    var out = std.ArrayList(u8).empty;
    defer out.deinit(allocator);

    for (value) |ch| {
        if (ch == '\'') {
            try out.appendSlice(allocator, "''");
        } else {
            try out.append(allocator, ch);
        }
    }

    return out.toOwnedSlice(allocator);
}

fn formatMacAddress(allocator: std.mem.Allocator, bytes: []const u8) ![]const u8 {
    if (bytes.len == 0) return allocator.dupe(u8, "");

    var out = std.ArrayList(u8).empty;
    defer out.deinit(allocator);

    for (bytes, 0..) |value, index| {
        if (index != 0) try out.append(allocator, ':');
        var chunk: [2]u8 = undefined;
        _ = try std.fmt.bufPrint(&chunk, "{X:0>2}", .{value});
        try out.appendSlice(allocator, &chunk);
    }

    return out.toOwnedSlice(allocator);
}

fn adapterTypeLabel(kind: UINT) []const u8 {
    return switch (kind) {
        MIB_IF_TYPE_ETHERNET => "ethernet",
        IF_TYPE_IEEE80211 => "wifi",
        MIB_IF_TYPE_PPP => "ppp",
        MIB_IF_TYPE_LOOPBACK => "loopback",
        else => "other",
    };
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

const PowerShellCommandOutput = struct {
    stdout: []const u8,
    stderr: []const u8,
    exit_code: ?u32,
    missing: bool,
};

const PowerShellElementTreePayload = struct {
    ok: bool,
    code: ?[]const u8 = null,
    message: ?[]const u8 = null,
    detail: ?[]const u8 = null,
    window_handle: ?u64 = null,
    window_title: ?[]const u8 = null,
    generated_at: ?[]const u8 = null,
    max_depth: ?u32 = null,
    max_children: ?u32 = null,
    max_nodes: ?u32 = null,
    include_offscreen: ?bool = null,
    root: ?core.model.UiElementNode = null,
};

const PowerShellElementClickPayload = struct {
    ok: bool,
    code: ?[]const u8 = null,
    message: ?[]const u8 = null,
    detail: ?[]const u8 = null,
    window_handle: ?u64 = null,
    element_id: ?[]const u8 = null,
    name: ?[]const u8 = null,
    control_type: ?[]const u8 = null,
    is_offscreen: ?bool = null,
    bounds: ?core.model.Rect = null,
    center: ?core.model.Point = null,
};

fn buildElementTreePowerShellScript(allocator: std.mem.Allocator, window_handle: u64, max_depth: u32, max_children: u32, max_nodes: u32, include_offscreen: bool) ![]const u8 {
    var script = std.ArrayList(u8).empty;
    errdefer script.deinit(allocator);

    try script.appendSlice(allocator,
        \\$ErrorActionPreference = 'Stop'
        \\[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
        \\Add-Type -AssemblyName UIAutomationClient
        \\Add-Type -AssemblyName UIAutomationTypes
        \\
        \\function Safe-String {
        \\    param($Value)
        \\    if ($null -eq $Value) { return '' }
        \\    return [string]$Value
        \\}
        \\
        \\function Convert-ControlType {
        \\    param($ControlType)
        \\    if ($null -eq $ControlType) { return '' }
        \\    $name = Safe-String $ControlType.ProgrammaticName
        \\    if ($name.StartsWith('ControlType.')) { return $name.Substring(12) }
        \\    return $name
        \\}
        \\
        \\function Convert-Rect {
        \\    param($Rect)
        \\    $left = [int][math]::Round($Rect.Left)
        \\    $top = [int][math]::Round($Rect.Top)
        \\    $right = [int][math]::Round($Rect.Right)
        \\    $bottom = [int][math]::Round($Rect.Bottom)
        \\    [pscustomobject]@{
        \\        left = $left
        \\        top = $top
        \\        right = $right
        \\        bottom = $bottom
        \\        width = [int]($right - $left)
        \\        height = [int]($bottom - $top)
        \\    }
        \\}
        \\
        \\function Convert-Center {
        \\    param($Rect)
        \\    $left = [int][math]::Round($Rect.Left)
        \\    $top = [int][math]::Round($Rect.Top)
        \\    $right = [int][math]::Round($Rect.Right)
        \\    $bottom = [int][math]::Round($Rect.Bottom)
        \\    [pscustomobject]@{
        \\        x = [int][math]::Round(($left + $right) / 2)
        \\        y = [int][math]::Round(($top + $bottom) / 2)
        \\    }
        \\}
        \\
    );

    var writer = script.writer(allocator);
    try writer.print("$windowHandle = [uint64]{d}\n", .{window_handle});
    try writer.print("$maxDepth = [int]{d}\n", .{max_depth});
    try writer.print("$maxChildren = [int]{d}\n", .{max_children});
    try writer.print("$maxNodes = [int]{d}\n", .{max_nodes});
    try writer.print("$includeOffscreen = {s}\n", .{if (include_offscreen) "$true" else "$false"});

    try script.appendSlice(allocator,
        \\$walker = [System.Windows.Automation.TreeWalker]::RawViewWalker
        \\$script:emittedNodes = 0
        \\
        \\function Get-Node {
        \\    param(
        \\        [System.Windows.Automation.AutomationElement]$Element,
        \\        [string]$Path,
        \\        [int]$Depth
        \\    )
        \\    if ($script:emittedNodes -ge $maxNodes) { return $null }
        \\    $script:emittedNodes += 1
        \\    $current = $Element.Current
        \\    $bounds = Convert-Rect $current.BoundingRectangle
        \\    $center = Convert-Center $current.BoundingRectangle
        \\    $children = @()
        \\    if ($Depth -lt $maxDepth -and $script:emittedNodes -lt $maxNodes) {
        \\        $child = $walker.GetFirstChild($Element)
        \\        $rawIndex = 0
        \\        while ($null -ne $child -and $children.Count -lt $maxChildren -and $script:emittedNodes -lt $maxNodes) {
        \\            $childCurrent = $child.Current
        \\            if ($includeOffscreen -or -not [bool]$childCurrent.IsOffscreen) {
        \\                $childPath = if ($Path -eq 'root') { "root/$rawIndex" } else { "$Path/$rawIndex" }
        \\                $childNode = Get-Node -Element $child -Path $childPath -Depth ($Depth + 1)
        \\                if ($null -ne $childNode) {
        \\                    $children += ,$childNode
        \\                }
        \\            }
        \\            $child = $walker.GetNextSibling($child)
        \\            $rawIndex += 1
        \\        }
        \\    }
        \\    [pscustomobject]@{
        \\        element_id = $Path
        \\        name = Safe-String $current.Name
        \\        automation_id = Safe-String $current.AutomationId
        \\        class_name = Safe-String $current.ClassName
        \\        control_type = Convert-ControlType $current.ControlType
        \\        framework_id = Safe-String $current.FrameworkId
        \\        is_enabled = [bool]$current.IsEnabled
        \\        is_offscreen = [bool]$current.IsOffscreen
        \\        has_keyboard_focus = [bool]$current.HasKeyboardFocus
        \\        bounds = $bounds
        \\        center = $center
        \\        children = $children
        \\    }
        \\}
        \\
        \\try {
        \\    $root = [System.Windows.Automation.AutomationElement]::FromHandle([IntPtr]::new([Int64]$windowHandle))
        \\    if ($null -eq $root) { throw 'UI Automation could not resolve the requested window handle.' }
        \\    $result = [pscustomobject]@{
        \\        ok = $true
        \\        window_handle = $windowHandle
        \\        window_title = Safe-String $root.Current.Name
        \\        generated_at = [DateTime]::UtcNow.ToString('o')
        \\        max_depth = [uint32]$maxDepth
        \\        max_children = [uint32]$maxChildren
        \\        max_nodes = [uint32]$maxNodes
        \\        include_offscreen = [bool]$includeOffscreen
        \\        root = Get-Node -Element $root -Path 'root' -Depth 0
        \\    }
        \\} catch {
        \\    $result = [pscustomobject]@{
        \\        ok = $false
        \\        code = 'system_error'
        \\        message = 'UI Automation element tree inspection failed.'
        \\        detail = Safe-String $_.Exception.Message
        \\    }
        \\}
        \\$result | ConvertTo-Json -Depth 100 -Compress
    );

    return script.toOwnedSlice(allocator);
}

fn buildElementClickPowerShellScript(allocator: std.mem.Allocator, window_handle: u64, element_id: []const u8) ![]const u8 {
    const escaped_element_id = try escapeForSingleQuotedPowerShell(allocator, element_id);
    defer allocator.free(escaped_element_id);

    var script = std.ArrayList(u8).empty;
    errdefer script.deinit(allocator);

    try script.appendSlice(allocator,
        \\$ErrorActionPreference = 'Stop'
        \\[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
        \\Add-Type -AssemblyName UIAutomationClient
        \\Add-Type -AssemblyName UIAutomationTypes
        \\
        \\function Safe-String {
        \\    param($Value)
        \\    if ($null -eq $Value) { return '' }
        \\    return [string]$Value
        \\}
        \\
        \\function Convert-ControlType {
        \\    param($ControlType)
        \\    if ($null -eq $ControlType) { return '' }
        \\    $name = Safe-String $ControlType.ProgrammaticName
        \\    if ($name.StartsWith('ControlType.')) { return $name.Substring(12) }
        \\    return $name
        \\}
        \\
        \\function Convert-Rect {
        \\    param($Rect)
        \\    $left = [int][math]::Round($Rect.Left)
        \\    $top = [int][math]::Round($Rect.Top)
        \\    $right = [int][math]::Round($Rect.Right)
        \\    $bottom = [int][math]::Round($Rect.Bottom)
        \\    [pscustomobject]@{
        \\        left = $left
        \\        top = $top
        \\        right = $right
        \\        bottom = $bottom
        \\        width = [int]($right - $left)
        \\        height = [int]($bottom - $top)
        \\    }
        \\}
        \\
        \\function Convert-Center {
        \\    param($Rect)
        \\    $left = [int][math]::Round($Rect.Left)
        \\    $top = [int][math]::Round($Rect.Top)
        \\    $right = [int][math]::Round($Rect.Right)
        \\    $bottom = [int][math]::Round($Rect.Bottom)
        \\    [pscustomobject]@{
        \\        x = [int][math]::Round(($left + $right) / 2)
        \\        y = [int][math]::Round(($top + $bottom) / 2)
        \\    }
        \\}
        \\
    );

    var writer = script.writer(allocator);
    try writer.print("$windowHandle = [uint64]{d}\n", .{window_handle});
    try writer.print("$elementId = '{s}'\n", .{escaped_element_id});

    try script.appendSlice(allocator,
        \\$walker = [System.Windows.Automation.TreeWalker]::RawViewWalker
        \\
        \\function Resolve-Element {
        \\    param(
        \\        [System.Windows.Automation.AutomationElement]$Root,
        \\        [string]$Path
        \\    )
        \\    if ([string]::IsNullOrWhiteSpace($Path) -or $Path -eq 'root') { return $Root }
        \\    $segments = $Path.Split('/')
        \\    $current = $Root
        \\    foreach ($segment in $segments) {
        \\        if ($segment -eq '' -or $segment -eq 'root') { continue }
        \\        [int]$wanted = 0
        \\        if (-not [int]::TryParse($segment, [ref]$wanted)) {
        \\            throw "Invalid element path segment '$segment'."
        \\        }
        \\        $child = $walker.GetFirstChild($current)
        \\        $index = 0
        \\        while ($null -ne $child -and $index -lt $wanted) {
        \\            $child = $walker.GetNextSibling($child)
        \\            $index += 1
        \\        }
        \\        if ($null -eq $child) {
        \\            throw "Element path segment '$segment' was not found."
        \\        }
        \\        $current = $child
        \\    }
        \\    return $current
        \\}
        \\
        \\try {
        \\    $root = [System.Windows.Automation.AutomationElement]::FromHandle([IntPtr]::new([Int64]$windowHandle))
        \\    if ($null -eq $root) { throw 'UI Automation could not resolve the requested window handle.' }
        \\    $target = Resolve-Element -Root $root -Path $elementId
        \\    $current = $target.Current
        \\    $result = [pscustomobject]@{
        \\        ok = $true
        \\        window_handle = $windowHandle
        \\        element_id = $elementId
        \\        name = Safe-String $current.Name
        \\        control_type = Convert-ControlType $current.ControlType
        \\        is_offscreen = [bool]$current.IsOffscreen
        \\        bounds = Convert-Rect $current.BoundingRectangle
        \\        center = Convert-Center $current.BoundingRectangle
        \\    }
        \\} catch {
        \\    $message = Safe-String $_.Exception.Message
        \\    $errorCode = if ($message -like 'Element path segment*' -or $message -like 'UI Automation could not resolve*') { 'not_found' } else { 'system_error' }
        \\    $result = [pscustomobject]@{
        \\        ok = $false
        \\        code = $errorCode
        \\        message = 'UI Automation element lookup failed.'
        \\        detail = $message
        \\    }
        \\}
        \\$result | ConvertTo-Json -Depth 20 -Compress
    );

    return script.toOwnedSlice(allocator);
}

fn runPowerShellCommand(allocator: std.mem.Allocator, script: []const u8) !PowerShellCommandOutput {
    const result = std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "powershell.exe", "-NoProfile", "-STA", "-Command", script },
        .max_output_bytes = 4 * 1024 * 1024,
    }) catch |err| switch (err) {
        error.OutOfMemory => return err,
        error.FileNotFound => return .{
            .stdout = &.{},
            .stderr = try allocator.dupe(u8, "powershell.exe was not found."),
            .exit_code = null,
            .missing = true,
        },
        else => return .{
            .stdout = &.{},
            .stderr = try allocator.dupe(u8, @errorName(err)),
            .exit_code = null,
            .missing = false,
        },
    };

    return .{
        .stdout = result.stdout,
        .stderr = result.stderr,
        .exit_code = switch (result.term) {
            .Exited => |code| code,
            else => null,
        },
        .missing = false,
    };
}

fn powerShellCommandDetail(allocator: std.mem.Allocator, output: PowerShellCommandOutput) !?[]const u8 {
    const stderr = std.mem.trim(u8, output.stderr, " \t\r\n");
    const stdout = std.mem.trim(u8, output.stdout, " \t\r\n");

    if (output.exit_code) |code| {
        if (stderr.len != 0) {
            const detail = try std.fmt.allocPrint(allocator, "exit_code={d}; stderr={s}", .{ code, powerShellTextSnippet(stderr) });
            return detail;
        }
        if (stdout.len != 0) {
            const detail = try std.fmt.allocPrint(allocator, "exit_code={d}; stdout={s}", .{ code, powerShellTextSnippet(stdout) });
            return detail;
        }
        const detail = try std.fmt.allocPrint(allocator, "exit_code={d}", .{code});
        return detail;
    }

    if (stderr.len != 0) {
        const detail = try allocator.dupe(u8, powerShellTextSnippet(stderr));
        return detail;
    }
    if (stdout.len != 0) {
        const detail = try allocator.dupe(u8, powerShellTextSnippet(stdout));
        return detail;
    }
    return null;
}

fn powerShellTextSnippet(text: []const u8) []const u8 {
    const trimmed = std.mem.trim(u8, text, " \t\r\n");
    if (trimmed.len <= 512) return trimmed;
    return trimmed[0..512];
}

fn mouseButtonName(button: core.model.MouseButton) []const u8 {
    return switch (button) {
        .left => "left",
        .right => "right",
        .middle => "middle",
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
