const std = @import("std");
const builtin = @import("builtin");
const core = @import("easytouch_core");
const windows = @import("easytouch_windows");
const linux = @import("easytouch_linux");
const mac = @import("easytouch_mac");

pub fn systemOsInfo(allocator: std.mem.Allocator) !core.model.OsInfoResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.systemOsInfo(allocator),
        .linux => linux.runtime.systemOsInfo(allocator),
        .macos => mac.runtime.systemOsInfo(allocator),
        else => core.model.failure(core.model.OsInfo, "system.os_info", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn systemCpuInfo(allocator: std.mem.Allocator) !core.model.CpuInfoResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.systemCpuInfo(allocator),
        .linux => linux.runtime.systemCpuInfo(allocator),
        .macos => mac.runtime.systemCpuInfo(allocator),
        else => core.model.failure(core.model.CpuInfo, "system.cpu_info", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn systemMemoryInfo(allocator: std.mem.Allocator) !core.model.MemoryInfoResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.systemMemoryInfo(allocator),
        .linux => linux.runtime.systemMemoryInfo(allocator),
        .macos => mac.runtime.systemMemoryInfo(allocator),
        else => core.model.failure(core.model.MemoryInfo, "system.memory_info", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn systemDiskList(allocator: std.mem.Allocator) !core.model.DiskListResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.systemDiskList(allocator),
        .linux => linux.runtime.systemDiskList(allocator),
        .macos => mac.runtime.systemDiskList(allocator),
        else => core.model.failure(core.model.DiskList, "system.disk_list", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn systemProcessList(allocator: std.mem.Allocator) !core.model.ProcessListResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.systemProcessList(allocator),
        .linux => linux.runtime.systemProcessList(allocator),
        .macos => mac.runtime.systemProcessList(allocator),
        else => core.model.failure(core.model.ProcessList, "system.process_list", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn mousePosition(allocator: std.mem.Allocator) !core.model.PointResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.mousePosition(allocator),
        .linux => linux.runtime.mousePosition(allocator),
        .macos => mac.runtime.mousePosition(allocator),
        else => core.model.failure(core.model.Point, "mouse.position", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn mouseMove(allocator: std.mem.Allocator, x: i32, y: i32) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.mouseMove(allocator, x, y),
        .linux => linux.runtime.mouseMove(allocator, x, y),
        .macos => mac.runtime.mouseMove(allocator, x, y),
        else => core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn mouseClick(allocator: std.mem.Allocator, button: core.model.MouseButton, count: u8) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.mouseClick(allocator, button, count),
        .linux => linux.runtime.mouseClick(allocator, button, count),
        .macos => mac.runtime.mouseClick(allocator, button, count),
        else => core.model.failure(core.model.Ack, "mouse.click", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn mouseScroll(allocator: std.mem.Allocator, delta: i32) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.mouseScroll(allocator, delta),
        .linux => linux.runtime.mouseScroll(allocator, delta),
        .macos => mac.runtime.mouseScroll(allocator, delta),
        else => core.model.failure(core.model.Ack, "mouse.scroll", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn windowList(allocator: std.mem.Allocator, include_hidden: bool, pid_filter: ?u32) !core.model.WindowListResponse {
    var response = try switch (builtin.os.tag) {
        .windows => windows.runtime.windowList(allocator, include_hidden),
        .linux => linux.runtime.windowList(allocator, include_hidden),
        .macos => mac.runtime.windowList(allocator, include_hidden),
        else => core.model.failure(core.model.WindowList, "window.list", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };

    if (!response.ok or pid_filter == null) return response;

    if (response.data) |*data| {
        const wanted_pid = pid_filter.?;
        var next_index: usize = 0;
        for (data.windows) |window| {
            if (window.pid != wanted_pid) continue;
            data.windows[next_index] = window;
            next_index += 1;
        }
        data.windows = data.windows[0..next_index];
        data.count = next_index;
    }

    return response;
}

pub fn windowForeground(allocator: std.mem.Allocator) !core.model.ForegroundWindowResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.windowForeground(allocator),
        .linux => linux.runtime.windowForeground(allocator),
        .macos => mac.runtime.windowForeground(allocator),
        else => core.model.failure(core.model.ForegroundWindow, "window.foreground", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn windowActivate(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.windowActivate(allocator, handle),
        .linux => linux.runtime.windowActivate(allocator, handle),
        .macos => mac.runtime.windowActivate(allocator, handle),
        else => core.model.failure(core.model.Ack, "window.activate", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn windowFind(allocator: std.mem.Allocator, title: []const u8, match_mode: core.model.StringMatchMode, include_hidden: bool, pid: ?u32) !core.model.WindowMatchResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.windowFind(allocator, title, match_mode, include_hidden, pid),
        .linux => linux.runtime.windowFind(allocator, title, match_mode, include_hidden, pid),
        .macos => mac.runtime.windowFind(allocator, title, match_mode, include_hidden, pid),
        else => core.model.failure(core.model.WindowMatch, "window.find", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn windowClose(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.windowClose(allocator, handle),
        .linux => linux.runtime.windowClose(allocator, handle),
        .macos => mac.runtime.windowClose(allocator, handle),
        else => core.model.failure(core.model.Ack, "window.close", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn appLaunch(allocator: std.mem.Allocator, target: []const u8) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.appLaunch(allocator, target),
        .linux => linux.runtime.appLaunch(allocator, target),
        .macos => mac.runtime.appLaunch(allocator, target),
        else => core.model.failure(core.model.Ack, "app.launch", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn clipboardGetText(allocator: std.mem.Allocator) !core.model.ClipboardTextResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.clipboardGetText(allocator),
        .linux => linux.runtime.clipboardGetText(allocator),
        .macos => mac.runtime.clipboardGetText(allocator),
        else => core.model.failure(core.model.ClipboardText, "clipboard.get_text", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn clipboardSetText(allocator: std.mem.Allocator, text: []const u8) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.clipboardSetText(allocator, text),
        .linux => linux.runtime.clipboardSetText(allocator, text),
        .macos => mac.runtime.clipboardSetText(allocator, text),
        else => core.model.failure(core.model.Ack, "clipboard.set_text", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn clipboardGetFiles(allocator: std.mem.Allocator) !core.model.ClipboardFilesResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.clipboardGetFiles(allocator),
        .linux => linux.runtime.clipboardGetFiles(allocator),
        .macos => mac.runtime.clipboardGetFiles(allocator),
        else => core.model.failure(core.model.ClipboardFiles, "clipboard.get_files", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn keyboardKeyPress(allocator: std.mem.Allocator, key: []const u8) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.keyboardKeyPress(allocator, key),
        .linux => linux.runtime.keyboardKeyPress(allocator, key),
        .macos => mac.runtime.keyboardKeyPress(allocator, key),
        else => core.model.failure(core.model.Ack, "keyboard.key_press", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn keyboardHotkey(allocator: std.mem.Allocator, keys: []const u8) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.keyboardHotkey(allocator, keys),
        .linux => linux.runtime.keyboardHotkey(allocator, keys),
        .macos => mac.runtime.keyboardHotkey(allocator, keys),
        else => core.model.failure(core.model.Ack, "keyboard.hotkey", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn keyboardTypeText(allocator: std.mem.Allocator, text: []const u8) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.keyboardTypeText(allocator, text),
        .linux => linux.runtime.keyboardTypeText(allocator, text),
        .macos => mac.runtime.keyboardTypeText(allocator, text),
        else => core.model.failure(core.model.Ack, "keyboard.type_text", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn keyboardPaste(allocator: std.mem.Allocator, expected_title: ?[]const u8, match_mode: core.model.StringMatchMode) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.keyboardPaste(allocator, expected_title, match_mode),
        .linux => linux.runtime.keyboardPaste(allocator, expected_title, match_mode),
        .macos => mac.runtime.keyboardPaste(allocator, expected_title, match_mode),
        else => core.model.failure(core.model.Ack, "keyboard.paste", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn screenCapture(allocator: std.mem.Allocator, path: []const u8) !core.model.ScreenCaptureResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.screenCapture(allocator, path),
        .linux => linux.runtime.screenCapture(allocator, path),
        .macos => mac.runtime.screenCapture(allocator, path),
        else => core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn screenPixelColor(allocator: std.mem.Allocator, x: i32, y: i32) !core.model.PixelColorResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.screenPixelColor(allocator, x, y),
        .linux => linux.runtime.screenPixelColor(allocator, x, y),
        .macos => mac.runtime.screenPixelColor(allocator, x, y),
        else => core.model.failure(core.model.PixelColor, "screen.pixel_color", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn screenDisplays(allocator: std.mem.Allocator) !core.model.DisplayListResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.screenDisplays(allocator),
        .linux => linux.runtime.screenDisplays(allocator),
        .macos => mac.runtime.screenDisplays(allocator),
        else => core.model.failure(core.model.DisplayList, "screen.displays", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn waitWindow(allocator: std.mem.Allocator, title: []const u8, timeout_ms: u64, match_mode: core.model.StringMatchMode, foreground_only: bool) !core.model.WaitWindowResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.waitWindow(allocator, title, timeout_ms, match_mode, foreground_only),
        .linux => linux.runtime.waitWindow(allocator, title, timeout_ms, match_mode, foreground_only),
        .macos => mac.runtime.waitWindow(allocator, title, timeout_ms, match_mode, foreground_only),
        else => core.model.failure(core.model.WaitWindow, "wait.window", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn waitFocus(allocator: std.mem.Allocator, title: []const u8, timeout_ms: u64, match_mode: core.model.StringMatchMode) !core.model.WaitFocusResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.waitFocus(allocator, title, timeout_ms, match_mode),
        .linux => linux.runtime.waitFocus(allocator, title, timeout_ms, match_mode),
        .macos => mac.runtime.waitFocus(allocator, title, timeout_ms, match_mode),
        else => core.model.failure(core.model.WaitWindow, "wait.focus", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn waitPixel(allocator: std.mem.Allocator, x: i32, y: i32, hex: []const u8, timeout_ms: u64) !core.model.WaitPixelResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.waitPixel(allocator, x, y, hex, timeout_ms),
        .linux => linux.runtime.waitPixel(allocator, x, y, hex, timeout_ms),
        .macos => mac.runtime.waitPixel(allocator, x, y, hex, timeout_ms),
        else => core.model.failure(core.model.WaitPixel, "wait.pixel", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn waitClipboard(allocator: std.mem.Allocator, expected_text: ?[]const u8, timeout_ms: u64, match_mode: core.model.StringMatchMode) !core.model.WaitClipboardResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.waitClipboard(allocator, expected_text, timeout_ms, match_mode),
        .linux => linux.runtime.waitClipboard(allocator, expected_text, timeout_ms, match_mode),
        .macos => mac.runtime.waitClipboard(allocator, expected_text, timeout_ms, match_mode),
        else => core.model.failure(core.model.WaitClipboard, "wait.clipboard", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn waitProcess(allocator: std.mem.Allocator, name: ?[]const u8, pid: ?u32, expect_running: bool, timeout_ms: u64, match_mode: core.model.StringMatchMode) !core.model.WaitProcessResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.waitProcess(allocator, name, pid, expect_running, timeout_ms, match_mode),
        .linux => linux.runtime.waitProcess(allocator, name, pid, expect_running, timeout_ms, match_mode),
        .macos => mac.runtime.waitProcess(allocator, name, pid, expect_running, timeout_ms, match_mode),
        else => core.model.failure(core.model.WaitProcess, "wait.process", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}
