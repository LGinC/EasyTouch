const std = @import("std");
const api_error = @import("error.zig");

pub const OutputMode = enum {
    text,
    json,
};

pub const StringMatchMode = enum {
    contains,
    exact,
};

pub const Rect = struct {
    left: i32,
    top: i32,
    right: i32,
    bottom: i32,
    width: i32,
    height: i32,
};

pub const Point = struct {
    x: i32,
    y: i32,
};

pub const MouseButton = enum {
    left,
    right,
    middle,
};

pub const WindowInfo = struct {
    handle: u64,
    pid: u32,
    title: []const u8,
    class_name: []const u8,
    visible: bool,
    is_foreground: bool,
    bounds: Rect,
};

pub const OsInfo = struct {
    platform: []const u8,
    arch: []const u8,
    version: []const u8,
    build: u32,
    machine_name: []const u8,
    runtime: []const u8,
};

pub const WindowList = struct {
    count: usize,
    windows: []WindowInfo,
};

pub const ForegroundWindow = struct {
    found: bool,
    window: ?WindowInfo,
};

pub const ClipboardText = struct {
    text: []const u8,
};

pub const ClipboardFiles = struct {
    files: []const []const u8,
};

pub const Ack = struct {
    message: []const u8,
    detail: ?[]const u8 = null,
};

pub const ScreenCapture = struct {
    path: []const u8,
    width: i32,
    height: i32,
    format: []const u8,
};

pub const PixelColor = struct {
    x: i32,
    y: i32,
    r: u8,
    g: u8,
    b: u8,
    hex: []const u8,
};

pub const DisplayInfo = struct {
    id: u32,
    name: []const u8,
    is_primary: bool,
    bounds: Rect,
};

pub const DisplayList = struct {
    count: usize,
    displays: []DisplayInfo,
};

pub const CpuInfo = struct {
    architecture: []const u8,
    logical_cores: u32,
    page_size: u32,
};

pub const MemoryInfo = struct {
    total_physical: u64,
    available_physical: u64,
    used_physical: u64,
    memory_load_percent: u32,
};

pub const DiskInfo = struct {
    mount: []const u8,
    volume_name: []const u8,
    drive_type: []const u8,
    total_bytes: u64,
    free_bytes: u64,
};

pub const DiskList = struct {
    count: usize,
    disks: []DiskInfo,
};

pub const ProcessInfo = struct {
    pid: u32,
    name: []const u8,
};

pub const ProcessList = struct {
    count: usize,
    processes: []ProcessInfo,
};

pub const WindowMatch = struct {
    found: bool,
    window: ?WindowInfo,
};

pub const WaitWindow = struct {
    matched: bool,
    elapsed_ms: u64,
    window: ?WindowInfo,
};

pub const WaitPixel = struct {
    matched: bool,
    elapsed_ms: u64,
    pixel: ?PixelColor,
};

pub const WaitClipboard = struct {
    matched: bool,
    elapsed_ms: u64,
    text: ?[]const u8,
};

pub const WaitProcess = struct {
    matched: bool,
    elapsed_ms: u64,
    process: ?ProcessInfo,
};

pub fn Envelope(comptime T: type) type {
    return struct {
        ok: bool,
        capability: []const u8,
        data: ?T,
        failure: ?api_error.ApiError,
    };
}

pub const OsInfoResponse = Envelope(OsInfo);
pub const WindowListResponse = Envelope(WindowList);
pub const ForegroundWindowResponse = Envelope(ForegroundWindow);
pub const ClipboardTextResponse = Envelope(ClipboardText);
pub const ClipboardFilesResponse = Envelope(ClipboardFiles);
pub const AckResponse = Envelope(Ack);
pub const ScreenCaptureResponse = Envelope(ScreenCapture);
pub const PointResponse = Envelope(Point);
pub const PixelColorResponse = Envelope(PixelColor);
pub const DisplayListResponse = Envelope(DisplayList);
pub const CpuInfoResponse = Envelope(CpuInfo);
pub const MemoryInfoResponse = Envelope(MemoryInfo);
pub const DiskListResponse = Envelope(DiskList);
pub const ProcessListResponse = Envelope(ProcessList);
pub const WindowMatchResponse = Envelope(WindowMatch);
pub const WaitWindowResponse = Envelope(WaitWindow);
pub const WaitFocusResponse = Envelope(WaitWindow);
pub const WaitPixelResponse = Envelope(WaitPixel);
pub const WaitClipboardResponse = Envelope(WaitClipboard);
pub const WaitProcessResponse = Envelope(WaitProcess);

pub fn success(capability: []const u8, data: anytype) Envelope(@TypeOf(data)) {
    return .{
        .ok = true,
        .capability = capability,
        .data = data,
        .failure = null,
    };
}

pub fn failure(comptime T: type, capability: []const u8, code: []const u8, message: []const u8, detail: ?[]const u8) Envelope(T) {
    return .{
        .ok = false,
        .capability = capability,
        .data = null,
        .failure = .{
            .code = code,
            .message = message,
            .detail = detail,
        },
    };
}

pub fn parseOutputMode(value: []const u8) ?OutputMode {
    if (std.mem.eql(u8, value, "text")) return .text;
    if (std.mem.eql(u8, value, "json")) return .json;
    return null;
}

pub fn parseMatchMode(value: []const u8) ?StringMatchMode {
    if (std.mem.eql(u8, value, "contains")) return .contains;
    if (std.mem.eql(u8, value, "exact")) return .exact;
    return null;
}
