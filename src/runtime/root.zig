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

pub fn systemHardwareInfo(allocator: std.mem.Allocator) !core.model.HardwareInfoResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.systemHardwareInfo(allocator),
        .linux => linux.runtime.systemHardwareInfo(allocator),
        .macos => mac.runtime.systemHardwareInfo(allocator),
        else => core.model.failure(core.model.HardwareInfo, "system.hardware_info", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn systemNetworkInfo(allocator: std.mem.Allocator) !core.model.NetworkInfoResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.systemNetworkInfo(allocator),
        .linux => linux.runtime.systemNetworkInfo(allocator),
        .macos => mac.runtime.systemNetworkInfo(allocator),
        else => core.model.failure(core.model.NetworkInfo, "system.network_info", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
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

pub fn mouseMove(allocator: std.mem.Allocator, x: i32, y: i32, duration_ms: ?u32, jitter_px: ?i32, step_delay_ms: ?u32) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.mouseMove(allocator, x, y, duration_ms, jitter_px, step_delay_ms),
        .linux => linux.runtime.mouseMove(allocator, x, y, duration_ms, jitter_px, step_delay_ms),
        .macos => mac.runtime.mouseMove(allocator, x, y, duration_ms, jitter_px, step_delay_ms),
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

pub fn windowShow(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.windowShow(allocator, handle),
        .linux => linux.runtime.windowShow(allocator, handle),
        .macos => mac.runtime.windowShow(allocator, handle),
        else => core.model.failure(core.model.Ack, "window.show", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn windowMinimize(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.windowMinimize(allocator, handle),
        .linux => linux.runtime.windowMinimize(allocator, handle),
        .macos => mac.runtime.windowMinimize(allocator, handle),
        else => core.model.failure(core.model.Ack, "window.minimize", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn windowMaximize(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.windowMaximize(allocator, handle),
        .linux => linux.runtime.windowMaximize(allocator, handle),
        .macos => mac.runtime.windowMaximize(allocator, handle),
        else => core.model.failure(core.model.Ack, "window.maximize", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn windowRestore(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.windowRestore(allocator, handle),
        .linux => linux.runtime.windowRestore(allocator, handle),
        .macos => mac.runtime.windowRestore(allocator, handle),
        else => core.model.failure(core.model.Ack, "window.restore", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn windowMove(allocator: std.mem.Allocator, handle: u64, x: i32, y: i32, width: ?i32, height: ?i32) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.windowMove(allocator, handle, x, y, width, height),
        .linux => linux.runtime.windowMove(allocator, handle, x, y, width, height),
        .macos => mac.runtime.windowMove(allocator, handle, x, y, width, height),
        else => core.model.failure(core.model.Ack, "window.move", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
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

pub fn clipboardSetFiles(allocator: std.mem.Allocator, paths: []const u8) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.clipboardSetFiles(allocator, paths),
        .linux => linux.runtime.clipboardSetFiles(allocator, paths),
        .macos => mac.runtime.clipboardSetFiles(allocator, paths),
        else => core.model.failure(core.model.Ack, "clipboard.set_files", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn clipboardSetImage(allocator: std.mem.Allocator, path: []const u8) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.clipboardSetImage(allocator, path),
        .linux => linux.runtime.clipboardSetImage(allocator, path),
        .macos => mac.runtime.clipboardSetImage(allocator, path),
        else => core.model.failure(core.model.Ack, "clipboard.set_image", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
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

pub fn keyboardTypeKeys(allocator: std.mem.Allocator, text: []const u8, key_delay_ms: ?u32) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.keyboardTypeKeys(allocator, text, key_delay_ms),
        .linux => linux.runtime.keyboardTypeKeys(allocator, text, key_delay_ms),
        .macos => mac.runtime.keyboardTypeKeys(allocator, text, key_delay_ms),
        else => core.model.failure(core.model.Ack, "keyboard.type_keys", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn keyboardImeSwitch(allocator: std.mem.Allocator, strategy: ?[]const u8) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.keyboardImeSwitch(allocator, strategy),
        .linux => linux.runtime.keyboardImeSwitch(allocator, strategy),
        .macos => mac.runtime.keyboardImeSwitch(allocator, strategy),
        else => core.model.failure(core.model.Ack, "keyboard.ime_switch", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn keyboardCapsLock(allocator: std.mem.Allocator, state: ?[]const u8) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.keyboardCapsLock(allocator, state),
        .linux => linux.runtime.keyboardCapsLock(allocator, state),
        .macos => mac.runtime.keyboardCapsLock(allocator, state),
        else => core.model.failure(core.model.Ack, "keyboard.caps_lock", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
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

pub fn screenCapture(allocator: std.mem.Allocator, path: []const u8, display_id: ?u32, window_handle: ?u64) !core.model.ScreenCaptureResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.screenCapture(allocator, path, display_id, window_handle),
        .linux => linux.runtime.screenCapture(allocator, path, display_id, window_handle),
        .macos => mac.runtime.screenCapture(allocator, path, display_id, window_handle),
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

pub fn elementTree(allocator: std.mem.Allocator, window_handle: ?u64, max_depth: ?u32, max_children: ?u32, max_nodes: ?u32, include_offscreen: bool) !core.model.ElementTreeResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.elementTree(allocator, window_handle, max_depth, max_children, max_nodes, include_offscreen),
        .linux => linux.runtime.elementTree(allocator, window_handle, max_depth, max_children, max_nodes, include_offscreen),
        .macos => mac.runtime.elementTree(allocator, window_handle, max_depth, max_children, max_nodes, include_offscreen),
        else => core.model.failure(core.model.ElementTree, "element.tree", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn elementClick(allocator: std.mem.Allocator, element_id: []const u8, window_handle: ?u64, button: core.model.MouseButton, move_duration_ms: ?u32) !core.model.AckResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.elementClick(allocator, element_id, window_handle, button, move_duration_ms),
        .linux => linux.runtime.elementClick(allocator, element_id, window_handle, button, move_duration_ms),
        .macos => mac.runtime.elementClick(allocator, element_id, window_handle, button, move_duration_ms),
        else => core.model.failure(core.model.Ack, "element.click", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
    };
}

pub fn elementFind(allocator: std.mem.Allocator, query: core.model.ElementQuery) !core.model.ElementMatchResponse {
    if (!elementQueryHasSelector(query)) {
        return core.model.failure(core.model.ElementMatch, "element.find", core.errors.codes.invalid_args, "Provide at least one selector such as element_id, name, automation_id, class_name, control_type, or framework_id.", null);
    }

    const tree_response = try elementTree(allocator, query.window_handle, query.max_depth, query.max_children, query.max_nodes, query.include_offscreen);
    if (!tree_response.ok) {
        const failure = tree_response.failure orelse core.errors.ApiError{ .code = core.errors.codes.system_error, .message = "element.tree failed while searching for an element.", .detail = null };
        return core.model.failure(core.model.ElementMatch, "element.find", failure.code, failure.message, failure.detail);
    }

    const tree = tree_response.data.?;
    const matched_element = findMatchingElement(tree.root, query);
    const match_detail = if (matched_element) |element_ref|
        try buildElementMatchDetail(allocator, tree, query, element_ref)
    else
        null;

    return core.model.success("element.find", core.model.ElementMatch{
        .found = match_detail != null,
        .match = match_detail,
    });
}

pub fn elementInvoke(allocator: std.mem.Allocator, element_id: []const u8, window_handle: ?u64, action: ?[]const u8, move_duration_ms: ?u32) !core.model.AckResponse {
    if (element_id.len == 0) {
        return core.model.failure(core.model.Ack, "element.invoke", core.errors.codes.invalid_args, "element_id cannot be empty.", null);
    }

    if (action) |value| {
        if (!isSupportedInvokeAction(value)) {
            return core.model.failure(core.model.Ack, "element.invoke", core.errors.codes.invalid_args, "action must be one of invoke, click, or press when provided.", value);
        }
    }

    const click_response = try elementClick(allocator, element_id, window_handle, .left, move_duration_ms);
    if (!click_response.ok) {
        const failure = click_response.failure orelse core.errors.ApiError{ .code = core.errors.codes.system_error, .message = "element.click failed while invoking an element.", .detail = null };
        return core.model.failure(core.model.Ack, "element.invoke", failure.code, failure.message, failure.detail);
    }

    return core.model.success("element.invoke", core.model.Ack{
        .message = "Element invoke completed.",
        .detail = click_response.data.?.detail,
    });
}

pub fn waitElement(allocator: std.mem.Allocator, query: core.model.ElementQuery, timeout_ms: u64, poll_interval_ms: ?u32) !core.model.WaitElementResponse {
    if (!elementQueryHasSelector(query)) {
        return core.model.failure(core.model.WaitElement, "wait.element", core.errors.codes.invalid_args, "Provide at least one selector such as element_id, name, automation_id, class_name, control_type, or framework_id.", null);
    }

    const resolved_poll_interval_ms = poll_interval_ms orelse 200;
    if (resolved_poll_interval_ms == 0 or resolved_poll_interval_ms > 60_000) {
        return core.model.failure(core.model.WaitElement, "wait.element", core.errors.codes.invalid_args, "poll_interval_ms must be in range 1..60000.", null);
    }

    const start_ms = nowMs();
    while (true) {
        var iteration_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer iteration_arena.deinit();

        const iteration_response = try elementFind(iteration_arena.allocator(), query);
        if (!iteration_response.ok) {
            const failure = iteration_response.failure orelse core.errors.ApiError{ .code = core.errors.codes.system_error, .message = "element.find failed while polling for an element.", .detail = null };
            return core.model.failure(core.model.WaitElement, "wait.element", failure.code, failure.message, failure.detail);
        }

        if (iteration_response.data.?.match) |match_detail| {
            return core.model.success("wait.element", core.model.WaitElement{
                .matched = true,
                .elapsed_ms = nowMs() - start_ms,
                .match = try cloneElementMatchDetail(allocator, match_detail),
            });
        }

        if (nowMs() - start_ms >= timeout_ms) {
            return core.model.failure(core.model.WaitElement, "wait.element", core.errors.codes.timeout, "Timed out while waiting for a matching element.", null);
        }

        std.Thread.sleep(@as(u64, resolved_poll_interval_ms) * std.time.ns_per_ms);
    }
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

pub fn waitActivate(allocator: std.mem.Allocator, handle: u64, timeout_ms: u64, expect_active: bool) !core.model.WaitWindowResponse {
    return switch (builtin.os.tag) {
        .windows => windows.runtime.waitActivate(allocator, handle, timeout_ms, expect_active),
        .linux => linux.runtime.waitActivate(allocator, handle, timeout_ms, expect_active),
        .macos => mac.runtime.waitActivate(allocator, handle, timeout_ms, expect_active),
        else => core.model.failure(core.model.WaitWindow, "wait.activate", core.errors.codes.unsupported_host, "This host OS is outside the current EasyTouch support matrix.", null),
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

fn nowMs() u64 {
    return @intCast(std.time.milliTimestamp());
}

fn elementQueryHasSelector(query: core.model.ElementQuery) bool {
    return query.element_id != null or
        query.name != null or
        query.automation_id != null or
        query.class_name != null or
        query.control_type != null or
        query.framework_id != null;
}

fn isSupportedInvokeAction(action: []const u8) bool {
    return std.ascii.eqlIgnoreCase(action, "invoke") or
        std.ascii.eqlIgnoreCase(action, "click") or
        std.ascii.eqlIgnoreCase(action, "press");
}

fn buildElementMatchDetail(allocator: std.mem.Allocator, tree: core.model.ElementTree, query: core.model.ElementQuery, element: core.model.UiElementRef) !core.model.ElementMatchDetail {
    return .{
        .window_handle = tree.window_handle,
        .window_title = tree.window_title,
        .generated_at = tree.generated_at,
        .matched_by = try buildElementMatchReason(allocator, query),
        .element = element,
    };
}

fn cloneElementMatchDetail(allocator: std.mem.Allocator, detail: core.model.ElementMatchDetail) !core.model.ElementMatchDetail {
    return .{
        .window_handle = detail.window_handle,
        .window_title = try allocator.dupe(u8, detail.window_title),
        .generated_at = try allocator.dupe(u8, detail.generated_at),
        .matched_by = try allocator.dupe(u8, detail.matched_by),
        .element = try cloneUiElementRef(allocator, detail.element),
    };
}

fn cloneUiElementRef(allocator: std.mem.Allocator, element: core.model.UiElementRef) !core.model.UiElementRef {
    return .{
        .element_id = try allocator.dupe(u8, element.element_id),
        .name = try allocator.dupe(u8, element.name),
        .automation_id = try allocator.dupe(u8, element.automation_id),
        .class_name = try allocator.dupe(u8, element.class_name),
        .control_type = try allocator.dupe(u8, element.control_type),
        .framework_id = try allocator.dupe(u8, element.framework_id),
        .is_enabled = element.is_enabled,
        .is_offscreen = element.is_offscreen,
        .has_keyboard_focus = element.has_keyboard_focus,
        .bounds = element.bounds,
        .center = element.center,
    };
}

fn buildElementMatchReason(allocator: std.mem.Allocator, query: core.model.ElementQuery) ![]const u8 {
    var fields = std.ArrayList([]const u8).empty;
    defer fields.deinit(allocator);

    if (query.element_id != null) try fields.append(allocator, "element_id");
    if (query.name != null) try fields.append(allocator, "name");
    if (query.automation_id != null) try fields.append(allocator, "automation_id");
    if (query.class_name != null) try fields.append(allocator, "class_name");
    if (query.control_type != null) try fields.append(allocator, "control_type");
    if (query.framework_id != null) try fields.append(allocator, "framework_id");
    if (query.enabled_only) try fields.append(allocator, "enabled_only");
    if (query.focus_only) try fields.append(allocator, "focus_only");

    var buffer = std.ArrayList(u8).empty;
    defer buffer.deinit(allocator);

    for (fields.items, 0..) |field, index| {
        if (index > 0) try buffer.appendSlice(allocator, "+");
        try buffer.appendSlice(allocator, field);
    }

    if (buffer.items.len == 0) {
        try buffer.appendSlice(allocator, "query");
    }

    return try buffer.toOwnedSlice(allocator);
}

fn findMatchingElement(node: core.model.UiElementNode, query: core.model.ElementQuery) ?core.model.UiElementRef {
    if (nodeMatchesQuery(node, query)) {
        return uiElementRefFromNode(node);
    }

    for (node.children) |child| {
        if (findMatchingElement(child, query)) |match| {
            return match;
        }
    }

    return null;
}

fn uiElementRefFromNode(node: core.model.UiElementNode) core.model.UiElementRef {
    return .{
        .element_id = node.element_id,
        .name = node.name,
        .automation_id = node.automation_id,
        .class_name = node.class_name,
        .control_type = node.control_type,
        .framework_id = node.framework_id,
        .is_enabled = node.is_enabled,
        .is_offscreen = node.is_offscreen,
        .has_keyboard_focus = node.has_keyboard_focus,
        .bounds = node.bounds,
        .center = node.center,
    };
}

fn nodeMatchesQuery(node: core.model.UiElementNode, query: core.model.ElementQuery) bool {
    if (query.enabled_only and !node.is_enabled) return false;
    if (query.focus_only and !node.has_keyboard_focus) return false;

    if (query.element_id) |value| {
        if (!std.mem.eql(u8, node.element_id, value)) return false;
    }
    if (!queryStringMatches(node.name, query.name, query.match_mode)) return false;
    if (!queryStringMatches(node.automation_id, query.automation_id, query.match_mode)) return false;
    if (!queryStringMatches(node.class_name, query.class_name, query.match_mode)) return false;
    if (!queryStringMatches(node.control_type, query.control_type, query.match_mode)) return false;
    if (!queryStringMatches(node.framework_id, query.framework_id, query.match_mode)) return false;

    return true;
}

fn queryStringMatches(candidate: []const u8, wanted: ?[]const u8, match_mode: core.model.StringMatchMode) bool {
    const text = wanted orelse return true;
    return switch (match_mode) {
        .exact => std.mem.eql(u8, candidate, text),
        .contains => std.mem.indexOf(u8, candidate, text) != null,
    };
}
