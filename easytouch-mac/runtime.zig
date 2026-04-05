const std = @import("std");
const builtin = @import("builtin");
const core = @import("easytouch_core");

const macos = if (builtin.os.tag == .macos) struct {
    const Bool = u8;
    const CFIndex = c_long;
    const CFStringEncoding = u32;
    const CFStringEncodingUTF8: CFStringEncoding = 0x0800_0100;
    const CFNumberSInt64Type: c_int = 4;
    const kCGWindowListOptionAll: u32 = 0;
    const kCGWindowListOptionOnScreenOnly: u32 = 1;
    const kSetFrontProcessFrontWindowOnly: u32 = 1;
    const kCGImageAlphaPremultipliedLast: u32 = 1;
    const kCGBitmapByteOrder32Big: u32 = 4 << 12;
    const coregraphics_success: i32 = 0;

    const CGDirectDisplayID = u32;
    const CGDisplayCount = u32;

    const CFType = opaque {};
    const CFArray = opaque {};
    const CFDictionary = opaque {};
    const CFString = opaque {};
    const CFNumber = opaque {};
    const CFBoolean = opaque {};
    const CGImage = opaque {};
    const CGContext = opaque {};
    const CGColorSpace = opaque {};

    const CFTypeRef = ?*CFType;
    const CFArrayRef = ?*CFArray;
    const CFDictionaryRef = ?*CFDictionary;
    const CFStringRef = ?*CFString;
    const CFNumberRef = ?*CFNumber;
    const CFBooleanRef = ?*CFBoolean;
    const CGImageRef = ?*CGImage;
    const CGContextRef = ?*CGContext;
    const CGColorSpaceRef = ?*CGColorSpace;

    const CGPoint = extern struct {
        x: f64,
        y: f64,
    };

    const CGSize = extern struct {
        width: f64,
        height: f64,
    };

    const CGRect = extern struct {
        origin: CGPoint,
        size: CGSize,
    };

    const ProcessSerialNumber = extern struct {
        highLongOfPSN: u32,
        lowLongOfPSN: u32,
    };

    extern "ApplicationServices" fn CGWindowListCopyWindowInfo(option: u32, relative_to_window: u32) CFArrayRef;
    extern "ApplicationServices" fn CGRectMakeWithDictionaryRepresentation(dict: CFDictionaryRef, rect: *CGRect) Bool;
    extern "ApplicationServices" fn CFRelease(value: CFTypeRef) void;
    extern "ApplicationServices" fn CFArrayGetCount(array: CFArrayRef) CFIndex;
    extern "ApplicationServices" fn CFArrayGetValueAtIndex(array: CFArrayRef, index: CFIndex) ?*const anyopaque;
    extern "ApplicationServices" fn CFDictionaryGetValue(dict: CFDictionaryRef, key: ?*const anyopaque) ?*const anyopaque;
    extern "ApplicationServices" fn CFStringCreateWithCString(allocator: ?*const anyopaque, c_string: [*:0]const u8, encoding: CFStringEncoding) CFStringRef;
    extern "ApplicationServices" fn CFStringGetLength(value: CFStringRef) CFIndex;
    extern "ApplicationServices" fn CFStringGetMaximumSizeForEncoding(length: CFIndex, encoding: CFStringEncoding) CFIndex;
    extern "ApplicationServices" fn CFStringGetCString(value: CFStringRef, buffer: [*]u8, buffer_size: CFIndex, encoding: CFStringEncoding) Bool;
    extern "ApplicationServices" fn CFNumberGetValue(number: CFNumberRef, number_type: c_int, value_ptr: *anyopaque) Bool;
    extern "ApplicationServices" fn CFBooleanGetValue(boolean: CFBooleanRef) Bool;
    extern "ApplicationServices" fn GetProcessForPID(pid: c_int, psn: *ProcessSerialNumber) i32;
    extern "ApplicationServices" fn SetFrontProcessWithOptions(psn: *const ProcessSerialNumber, options: u32) i32;
    extern "ApplicationServices" fn CGGetOnlineDisplayList(max_displays: u32, active_displays: ?[*]CGDirectDisplayID, display_count: *CGDisplayCount) i32;
    extern "ApplicationServices" fn CGMainDisplayID() CGDirectDisplayID;
    extern "ApplicationServices" fn CGDisplayBounds(display: CGDirectDisplayID) CGRect;
    extern "ApplicationServices" fn CGDisplayCreateImageForRect(display: CGDirectDisplayID, rect: CGRect) CGImageRef;
    extern "ApplicationServices" fn CGColorSpaceCreateDeviceRGB() CGColorSpaceRef;
    extern "ApplicationServices" fn CGColorSpaceRelease(space: CGColorSpaceRef) void;
    extern "ApplicationServices" fn CGBitmapContextCreate(data: ?*anyopaque, width: usize, height: usize, bits_per_component: usize, bytes_per_row: usize, space: CGColorSpaceRef, bitmap_info: u32) CGContextRef;
    extern "ApplicationServices" fn CGContextDrawImage(context: CGContextRef, rect: CGRect, image: CGImageRef) void;
    extern "ApplicationServices" fn CGContextRelease(context: CGContextRef) void;

    const WindowKeys = struct {
        number: CFStringRef,
        owner_pid: CFStringRef,
        name: CFStringRef,
        owner_name: CFStringRef,
        bounds: CFStringRef,
        onscreen: CFStringRef,
        layer: CFStringRef,

        fn init() !WindowKeys {
            return .{
                .number = createKey("kCGWindowNumber") orelse return error.OutOfMemory,
                .owner_pid = createKey("kCGWindowOwnerPID") orelse return error.OutOfMemory,
                .name = createKey("kCGWindowName") orelse return error.OutOfMemory,
                .owner_name = createKey("kCGWindowOwnerName") orelse return error.OutOfMemory,
                .bounds = createKey("kCGWindowBounds") orelse return error.OutOfMemory,
                .onscreen = createKey("kCGWindowIsOnscreen") orelse return error.OutOfMemory,
                .layer = createKey("kCGWindowLayer") orelse return error.OutOfMemory,
            };
        }

        fn deinit(self: WindowKeys) void {
            release(self.number);
            release(self.owner_pid);
            release(self.name);
            release(self.owner_name);
            release(self.bounds);
            release(self.onscreen);
            release(self.layer);
        }
    };

    fn createKey(name: [:0]const u8) CFStringRef {
        return CFStringCreateWithCString(null, name.ptr, CFStringEncodingUTF8);
    }

    fn release(value: anytype) void {
        if (value) |typed| {
            const raw: CFTypeRef = @ptrCast(typed);
            CFRelease(raw);
        }
    }

    fn systemFailure(comptime T: type, allocator: std.mem.Allocator, capability: []const u8, message: []const u8, err: anyerror) core.model.Envelope(T) {
        const detail = std.fmt.allocPrint(allocator, "macos_window_error={s}", .{@errorName(err)}) catch @errorName(err);
        return core.model.failure(T, capability, core.errors.codes.system_error, message, detail);
    }

    fn castArrayRef(raw: ?*const anyopaque) CFArrayRef {
        return @ptrCast(@constCast(raw));
    }

    fn castDictionaryRef(raw: ?*const anyopaque) CFDictionaryRef {
        return @ptrCast(@constCast(raw));
    }

    fn castStringRef(raw: ?*const anyopaque) CFStringRef {
        return @ptrCast(@constCast(raw));
    }

    fn castNumberRef(raw: ?*const anyopaque) CFNumberRef {
        return @ptrCast(@constCast(raw));
    }

    fn castBooleanRef(raw: ?*const anyopaque) CFBooleanRef {
        return @ptrCast(@constCast(raw));
    }

    fn readNumberU64(dict: CFDictionaryRef, key: CFStringRef) !?u64 {
        const raw = CFDictionaryGetValue(dict, key) orelse return null;
        var value: i64 = 0;
        if (CFNumberGetValue(castNumberRef(raw), CFNumberSInt64Type, @ptrCast(&value)) == 0) {
            return error.NumberConversionFailed;
        }
        if (value < 0) return 0;
        return @as(u64, @intCast(value));
    }

    fn readNumberI32(dict: CFDictionaryRef, key: CFStringRef) !?i32 {
        const raw = CFDictionaryGetValue(dict, key) orelse return null;
        var value: i64 = 0;
        if (CFNumberGetValue(castNumberRef(raw), CFNumberSInt64Type, @ptrCast(&value)) == 0) {
            return error.NumberConversionFailed;
        }
        return @as(i32, @intCast(value));
    }

    fn readBool(dict: CFDictionaryRef, key: CFStringRef) ?bool {
        const raw = CFDictionaryGetValue(dict, key) orelse return null;
        return CFBooleanGetValue(castBooleanRef(raw)) != 0;
    }

    fn readString(allocator: std.mem.Allocator, dict: CFDictionaryRef, key: CFStringRef) !?[]const u8 {
        const raw = CFDictionaryGetValue(dict, key) orelse return null;
        const value = castStringRef(raw);
        const length = CFStringGetLength(value);
        const capacity = CFStringGetMaximumSizeForEncoding(length, CFStringEncodingUTF8) + 1;
        const buffer_len = @as(usize, @intCast(capacity));
        var buffer = try allocator.alloc(u8, buffer_len);
        defer allocator.free(buffer);
        errdefer allocator.free(buffer);

        if (CFStringGetCString(value, buffer.ptr, capacity, CFStringEncodingUTF8) == 0) {
            return error.StringConversionFailed;
        }

        const slice = std.mem.sliceTo(buffer[0..buffer_len], 0);
        return try allocator.dupe(u8, slice);
    }

    fn readBounds(dict: CFDictionaryRef, key: CFStringRef) !?core.model.Rect {
        const raw = CFDictionaryGetValue(dict, key) orelse return null;
        var rect: CGRect = undefined;
        if (CGRectMakeWithDictionaryRepresentation(castDictionaryRef(raw), &rect) == 0) {
            return error.BoundsConversionFailed;
        }

        const left = @as(i32, @intFromFloat(@round(rect.origin.x)));
        const top = @as(i32, @intFromFloat(@round(rect.origin.y)));
        const width = @as(i32, @intFromFloat(@round(rect.size.width)));
        const height = @as(i32, @intFromFloat(@round(rect.size.height)));
        return .{
            .left = left,
            .top = top,
            .right = left + width,
            .bottom = top + height,
            .width = width,
            .height = height,
        };
    }

    fn listWindowArray(option: u32) CFArrayRef {
        return CGWindowListCopyWindowInfo(option, 0);
    }

    fn frontWindowHandle(keys: WindowKeys) !u64 {
        const array = listWindowArray(kCGWindowListOptionOnScreenOnly) orelse return 0;
        defer release(array);

        const count = @as(usize, @intCast(CFArrayGetCount(array)));
        for (0..count) |index| {
            const raw = CFArrayGetValueAtIndex(array, @as(CFIndex, @intCast(index))) orelse continue;
            const dict = castDictionaryRef(raw);
            const layer = (try readNumberI32(dict, keys.layer)) orelse continue;
            if (layer != 0) continue;
            const visible = readBool(dict, keys.onscreen) orelse false;
            if (!visible) continue;
            return (try readNumberU64(dict, keys.number)) orelse 0;
        }

        return 0;
    }

    fn buildWindowInfo(allocator: std.mem.Allocator, dict: CFDictionaryRef, keys: WindowKeys, foreground_handle: u64, include_hidden: bool) !?core.model.WindowInfo {
        const layer = (try readNumberI32(dict, keys.layer)) orelse return null;
        if (layer != 0) return null;

        const handle = (try readNumberU64(dict, keys.number)) orelse return null;
        const pid_raw = (try readNumberU64(dict, keys.owner_pid)) orelse return null;
        const visible = readBool(dict, keys.onscreen) orelse false;
        if (!include_hidden and !visible) return null;

        const bounds = (try readBounds(dict, keys.bounds)) orelse return null;
        const title = (try readString(allocator, dict, keys.name)) orelse "";
        const owner_name = (try readString(allocator, dict, keys.owner_name)) orelse "CGWindow";

        return core.model.WindowInfo{
            .handle = handle,
            .pid = @as(u32, @intCast(pid_raw)),
            .title = title,
            .class_name = owner_name,
            .visible = visible,
            .is_foreground = handle == foreground_handle,
            .bounds = bounds,
        };
    }

    fn locateWindowByHandle(allocator: std.mem.Allocator, keys: WindowKeys, handle: u64) !?core.model.WindowInfo {
        const array = listWindowArray(kCGWindowListOptionAll) orelse return null;
        defer release(array);

        const foreground_handle = try frontWindowHandle(keys);
        const count = @as(usize, @intCast(CFArrayGetCount(array)));
        for (0..count) |index| {
            const raw = CFArrayGetValueAtIndex(array, @as(CFIndex, @intCast(index))) orelse continue;
            const dict = castDictionaryRef(raw);
            const window_handle = (try readNumberU64(dict, keys.number)) orelse continue;
            if (window_handle != handle) continue;
            return try buildWindowInfo(allocator, dict, keys, foreground_handle, true);
        }

        return null;
    }

    pub fn windowList(allocator: std.mem.Allocator, include_hidden: bool) !core.model.WindowListResponse {
        const keys = try WindowKeys.init();
        defer keys.deinit();

        const array = listWindowArray(kCGWindowListOptionAll) orelse {
            return core.model.failure(core.model.WindowList, "window.list", core.errors.codes.system_error, "CGWindowListCopyWindowInfo returned no window snapshot.", "Check whether the macOS window server is available.");
        };
        defer release(array);

        const foreground_handle = frontWindowHandle(keys) catch |err| {
            return systemFailure(core.model.WindowList, allocator, "window.list", "Failed to inspect the macOS frontmost window.", err);
        };

        var windows = std.ArrayListUnmanaged(core.model.WindowInfo).empty;
        defer windows.deinit(allocator);

        const count = @as(usize, @intCast(CFArrayGetCount(array)));
        for (0..count) |index| {
            const raw = CFArrayGetValueAtIndex(array, @as(CFIndex, @intCast(index))) orelse continue;
            const dict = castDictionaryRef(raw);
            const maybe_info = buildWindowInfo(allocator, dict, keys, foreground_handle, include_hidden) catch |err| {
                return systemFailure(core.model.WindowList, allocator, "window.list", "Failed while translating the CoreGraphics window snapshot.", err);
            };
            if (maybe_info) |info| {
                try windows.append(allocator, info);
            }
        }

        const owned = try windows.toOwnedSlice(allocator);
        return core.model.success("window.list", core.model.WindowList{
            .count = owned.len,
            .windows = owned,
        });
    }

    pub fn windowForeground(allocator: std.mem.Allocator) !core.model.ForegroundWindowResponse {
        const keys = try WindowKeys.init();
        defer keys.deinit();

        const handle = frontWindowHandle(keys) catch |err| {
            return systemFailure(core.model.ForegroundWindow, allocator, "window.foreground", "Failed to inspect the macOS frontmost window.", err);
        };
        if (handle == 0) {
            return core.model.success("window.foreground", core.model.ForegroundWindow{
                .found = false,
                .window = null,
            });
        }

        const info = (locateWindowByHandle(allocator, keys, handle) catch |err| {
            return systemFailure(core.model.ForegroundWindow, allocator, "window.foreground", "Failed while reading the macOS frontmost window details.", err);
        }) orelse {
            return core.model.success("window.foreground", core.model.ForegroundWindow{
                .found = false,
                .window = null,
            });
        };

        return core.model.success("window.foreground", core.model.ForegroundWindow{
            .found = true,
            .window = info,
        });
    }

    pub fn windowActivate(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
        if (handle == 0) {
            return core.model.failure(core.model.Ack, "window.activate", core.errors.codes.invalid_args, "Window activation requires a non-zero handle.", null);
        }

        const keys = try WindowKeys.init();
        defer keys.deinit();

        const target = (locateWindowByHandle(allocator, keys, handle) catch |err| {
            return systemFailure(core.model.Ack, allocator, "window.activate", "Failed while resolving the requested macOS window handle.", err);
        }) orelse {
            return core.model.failure(core.model.Ack, "window.activate", core.errors.codes.not_found, "The requested macOS window handle is no longer present in the CoreGraphics snapshot.", try std.fmt.allocPrint(allocator, "target_handle=0x{x}", .{handle}));
        };

        var psn = std.mem.zeroes(ProcessSerialNumber);
        if (GetProcessForPID(@as(c_int, @intCast(target.pid)), &psn) != 0) {
            return core.model.failure(core.model.Ack, "window.activate", core.errors.codes.system_error, "GetProcessForPID failed while preparing a macOS activation request.", try std.fmt.allocPrint(allocator, "target_handle=0x{x}; pid={d}", .{ handle, target.pid }));
        }

        if (SetFrontProcessWithOptions(&psn, 0) != 0 or SetFrontProcessWithOptions(&psn, kSetFrontProcessFrontWindowOnly) != 0) {
            return core.model.failure(core.model.Ack, "window.activate", core.errors.codes.system_error, "SetFrontProcessWithOptions failed while requesting macOS foreground activation.", try std.fmt.allocPrint(allocator, "target_handle=0x{x}; pid={d}", .{ handle, target.pid }));
        }

        std.time.sleep(200 * std.time.ns_per_ms);

        const actual_handle = frontWindowHandle(keys) catch |err| {
            return systemFailure(core.model.Ack, allocator, "window.activate", "The macOS activation request was sent, but foreground verification failed.", err);
        };
        if (actual_handle != handle) {
            return core.model.failure(core.model.Ack, "window.activate", core.errors.codes.system_error, "The owning macOS application was activated, but the requested window did not become frontmost.", try std.fmt.allocPrint(allocator, "target_handle=0x{x}; actual_foreground_handle=0x{x}; pid={d}", .{ handle, actual_handle, target.pid }));
        }

        return core.model.success("window.activate", core.model.Ack{
            .message = "macOS window activated.",
            .detail = try std.fmt.allocPrint(allocator, "target_handle=0x{x}; title={s}; pid={d}", .{ handle, target.title, target.pid }),
        });
    }

    pub fn screenDisplays(allocator: std.mem.Allocator) !core.model.DisplayListResponse {
        var count: CGDisplayCount = 0;
        if (CGGetOnlineDisplayList(0, null, &count) != coregraphics_success) {
            return core.model.failure(core.model.DisplayList, "screen.displays", core.errors.codes.system_error, "CGGetOnlineDisplayList failed while querying display count.", null);
        }
        if (count == 0) {
            return core.model.success("screen.displays", core.model.DisplayList{ .count = 0, .displays = try allocator.alloc(core.model.DisplayInfo, 0) });
        }

        var ids = try allocator.alloc(CGDirectDisplayID, count);
        defer allocator.free(ids);

        if (CGGetOnlineDisplayList(count, ids.ptr, &count) != coregraphics_success) {
            return core.model.failure(core.model.DisplayList, "screen.displays", core.errors.codes.system_error, "CGGetOnlineDisplayList failed while reading display list.", null);
        }

        const main_display = CGMainDisplayID();
        var displays = std.ArrayListUnmanaged(core.model.DisplayInfo).empty;
        defer displays.deinit(allocator);

        for (ids[0..count], 0..) |display_id, index| {
            const bounds = CGDisplayBounds(display_id);
            const left = @as(i32, @intFromFloat(@round(bounds.origin.x)));
            const top = @as(i32, @intFromFloat(@round(bounds.origin.y)));
            const width = @as(i32, @intFromFloat(@round(bounds.size.width)));
            const height = @as(i32, @intFromFloat(@round(bounds.size.height)));
            if (width <= 0 or height <= 0) continue;

            try displays.append(allocator, core.model.DisplayInfo{
                .id = @as(u32, @intCast(index + 1)),
                .name = try std.fmt.allocPrint(allocator, "Display-{d}", .{display_id}),
                .is_primary = display_id == main_display,
                .bounds = .{
                    .left = left,
                    .top = top,
                    .right = left + width,
                    .bottom = top + height,
                    .width = width,
                    .height = height,
                },
            });
        }

        const owned = try displays.toOwnedSlice(allocator);
        return core.model.success("screen.displays", core.model.DisplayList{
            .count = owned.len,
            .displays = owned,
        });
    }

    pub fn screenPixelColor(allocator: std.mem.Allocator, x: i32, y: i32) !core.model.PixelColorResponse {
        var count: CGDisplayCount = 0;
        if (CGGetOnlineDisplayList(0, null, &count) != coregraphics_success) {
            return core.model.failure(core.model.PixelColor, "screen.pixel_color", core.errors.codes.system_error, "CGGetOnlineDisplayList failed while querying display count.", null);
        }
        if (count == 0) {
            return core.model.failure(core.model.PixelColor, "screen.pixel_color", core.errors.codes.not_found, "No active displays were reported by CoreGraphics.", null);
        }

        var ids = try allocator.alloc(CGDirectDisplayID, count);
        defer allocator.free(ids);

        if (CGGetOnlineDisplayList(count, ids.ptr, &count) != coregraphics_success) {
            return core.model.failure(core.model.PixelColor, "screen.pixel_color", core.errors.codes.system_error, "CGGetOnlineDisplayList failed while reading display list.", null);
        }

        var target_display: ?CGDirectDisplayID = null;
        var local_x: i32 = 0;
        var local_y: i32 = 0;
        for (ids[0..count]) |display_id| {
            const bounds = CGDisplayBounds(display_id);
            const left = @as(i32, @intFromFloat(@round(bounds.origin.x)));
            const top = @as(i32, @intFromFloat(@round(bounds.origin.y)));
            const width = @as(i32, @intFromFloat(@round(bounds.size.width)));
            const height = @as(i32, @intFromFloat(@round(bounds.size.height)));
            if (x < left or y < top or x >= left + width or y >= top + height) continue;

            target_display = display_id;
            local_x = x - left;
            local_y = y - top;
            break;
        }

        const display_id = target_display orelse {
            return core.model.failure(core.model.PixelColor, "screen.pixel_color", core.errors.codes.not_found, "The requested pixel is outside all active displays.", try std.fmt.allocPrint(allocator, "x={d}; y={d}", .{ x, y }));
        };

        const rect = CGRect{
            .origin = .{ .x = @floatFromInt(local_x), .y = @floatFromInt(local_y) },
            .size = .{ .width = 1, .height = 1 },
        };
        const image = CGDisplayCreateImageForRect(display_id, rect) orelse {
            return core.model.failure(core.model.PixelColor, "screen.pixel_color", core.errors.codes.permission_denied, "CoreGraphics denied pixel capture for the requested coordinate.", "Grant Screen Recording permission to the terminal/app host.");
        };
        defer release(image);

        const color_space = CGColorSpaceCreateDeviceRGB() orelse {
            return core.model.failure(core.model.PixelColor, "screen.pixel_color", core.errors.codes.system_error, "CGColorSpaceCreateDeviceRGB failed.", null);
        };
        defer CGColorSpaceRelease(color_space);

        var rgba = [_]u8{ 0, 0, 0, 0 };
        const context = CGBitmapContextCreate(@ptrCast(&rgba), 1, 1, 8, 4, color_space, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big) orelse {
            return core.model.failure(core.model.PixelColor, "screen.pixel_color", core.errors.codes.system_error, "CGBitmapContextCreate failed.", null);
        };
        defer CGContextRelease(context);

        const draw_rect = CGRect{
            .origin = .{ .x = 0, .y = 0 },
            .size = .{ .width = 1, .height = 1 },
        };
        CGContextDrawImage(context, draw_rect, image);

        const r = rgba[0];
        const g = rgba[1];
        const b = rgba[2];
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
} else struct {};

pub fn systemOsInfo(allocator: std.mem.Allocator) !core.model.OsInfoResponse {
    const machine_name = try std.fmt.allocPrint(allocator, "macos-host-unverified", .{});
    const version = try std.fmt.allocPrint(allocator, "macos-runtime-unverified", .{});
    return core.model.success("system.os_info", core.model.OsInfo{
        .platform = "macos",
        .arch = @tagName(builtin.cpu.arch),
        .version = version,
        .build = 0,
        .machine_name = machine_name,
        .runtime = "macos stub",
    });
}

pub fn systemCpuInfo(_: std.mem.Allocator) !core.model.CpuInfoResponse {
    return core.model.failure(core.model.CpuInfo, "system.cpu_info", core.errors.codes.not_implemented, "macOS cpu info is planned but not locally verified yet.", "Phase one will target CoreGraphics and AX APIs.");
}

pub fn systemMemoryInfo(_: std.mem.Allocator) !core.model.MemoryInfoResponse {
    return core.model.failure(core.model.MemoryInfo, "system.memory_info", core.errors.codes.not_implemented, "macOS memory info is planned but not locally verified yet.", "Phase one will target CoreGraphics and AX APIs.");
}

pub fn systemDiskList(_: std.mem.Allocator) !core.model.DiskListResponse {
    return core.model.failure(core.model.DiskList, "system.disk_list", core.errors.codes.not_implemented, "macOS disk list is planned but not locally verified yet.", "Phase one will target CoreGraphics and AX APIs.");
}

pub fn systemProcessList(_: std.mem.Allocator) !core.model.ProcessListResponse {
    return core.model.failure(core.model.ProcessList, "system.process_list", core.errors.codes.not_implemented, "macOS process list is planned but not locally verified yet.", "Phase one will target CoreGraphics and AX APIs.");
}

pub fn systemHardwareInfo(_: std.mem.Allocator) !core.model.HardwareInfoResponse {
    return core.model.failure(core.model.HardwareInfo, "system.hardware_info", core.errors.codes.not_implemented, "macOS hardware info is planned but not locally verified yet.", "Phase one will target CoreGraphics and AX APIs.");
}

pub fn systemNetworkInfo(_: std.mem.Allocator) !core.model.NetworkInfoResponse {
    return core.model.failure(core.model.NetworkInfo, "system.network_info", core.errors.codes.not_implemented, "macOS network info is planned but not locally verified yet.", "Phase one will target CoreGraphics and AX APIs.");
}

pub fn mousePosition(_: std.mem.Allocator) !core.model.PointResponse {
    return core.model.failure(core.model.Point, "mouse.position", core.errors.codes.not_implemented, "macOS mouse position is planned but not locally verified yet.", "Phase one will target CoreGraphics events.");
}

pub fn mouseMove(_: std.mem.Allocator, _: i32, _: i32, _: ?u32, _: ?i32, _: ?u32) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.not_implemented, "macOS mouse move is planned but not locally verified yet.", "Phase one will target CoreGraphics events.");
}

pub fn mouseClick(_: std.mem.Allocator, _: core.model.MouseButton, _: u8) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "mouse.click", core.errors.codes.not_implemented, "macOS mouse click is planned but not locally verified yet.", "Phase one will target CoreGraphics events.");
}

pub fn mouseScroll(_: std.mem.Allocator, _: i32) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "mouse.scroll", core.errors.codes.not_implemented, "macOS mouse scroll is planned but not locally verified yet.", "Phase one will target CoreGraphics events.");
}

pub fn windowList(allocator: std.mem.Allocator, include_hidden: bool) !core.model.WindowListResponse {
    if (builtin.os.tag != .macos) {
        return core.model.failure(core.model.WindowList, "window.list", core.errors.codes.not_implemented, "macOS window enumeration is planned but not locally verified yet.", "Phase one will target CoreGraphics and AX APIs.");
    }
    return macos.windowList(allocator, include_hidden);
}

pub fn windowForeground(allocator: std.mem.Allocator) !core.model.ForegroundWindowResponse {
    if (builtin.os.tag != .macos) {
        return core.model.failure(core.model.ForegroundWindow, "window.foreground", core.errors.codes.not_implemented, "macOS foreground-window lookup is planned but not locally verified yet.", "Phase one will target CoreGraphics and AX APIs.");
    }
    return macos.windowForeground(allocator);
}

pub fn windowActivate(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    if (builtin.os.tag != .macos) {
        return core.model.failure(core.model.Ack, "window.activate", core.errors.codes.not_implemented, "macOS window activation is planned but not locally verified yet.", "Phase one will target CoreGraphics and AX APIs.");
    }
    return macos.windowActivate(allocator, handle);
}

pub fn windowShow(_: std.mem.Allocator, _: u64) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "window.show", core.errors.codes.not_implemented, "macOS window show is planned but not locally verified yet.", "Phase one will target CoreGraphics and AX APIs.");
}

pub fn windowMinimize(_: std.mem.Allocator, _: u64) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "window.minimize", core.errors.codes.not_implemented, "macOS window minimize is planned but not locally verified yet.", "Phase one will target CoreGraphics and AX APIs.");
}

pub fn windowMaximize(_: std.mem.Allocator, _: u64) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "window.maximize", core.errors.codes.not_implemented, "macOS window maximize is planned but not locally verified yet.", "Phase one will target CoreGraphics and AX APIs.");
}

pub fn windowRestore(_: std.mem.Allocator, _: u64) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "window.restore", core.errors.codes.not_implemented, "macOS window restore is planned but not locally verified yet.", "Phase one will target CoreGraphics and AX APIs.");
}

pub fn windowMove(_: std.mem.Allocator, _: u64, _: i32, _: i32, _: ?i32, _: ?i32) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "window.move", core.errors.codes.not_implemented, "macOS window move is planned but not locally verified yet.", "Phase one will target CoreGraphics and AX APIs.");
}

pub fn windowFind(allocator: std.mem.Allocator, title: []const u8, match_mode: core.model.StringMatchMode, include_hidden: bool, pid: ?u32) !core.model.WindowMatchResponse {
    if (builtin.os.tag != .macos) {
        return core.model.failure(core.model.WindowMatch, "window.find", core.errors.codes.not_implemented, "macOS window find is planned but not locally verified yet.", "Phase one will target CoreGraphics and AX APIs.");
    }

    const list_response = try windowList(allocator, include_hidden);
    if (!list_response.ok) {
        const failure = list_response.failure orelse core.errors.ApiError{ .code = core.errors.codes.system_error, .message = "window.list failed while searching.", .detail = null };
        return core.model.failure(core.model.WindowMatch, "window.find", failure.code, failure.message, failure.detail);
    }

    for (list_response.data.?.windows) |window| {
        if (pid) |wanted_pid| {
            if (window.pid != wanted_pid) continue;
        }
        if (!textMatches(window.title, title, match_mode)) continue;
        return core.model.success("window.find", core.model.WindowMatch{
            .found = true,
            .window = .{
                .handle = window.handle,
                .pid = window.pid,
                .title = try allocator.dupe(u8, window.title),
                .class_name = try allocator.dupe(u8, window.class_name),
                .visible = window.visible,
                .is_foreground = window.is_foreground,
                .bounds = window.bounds,
            },
        });
    }

    return core.model.success("window.find", core.model.WindowMatch{ .found = false, .window = null });
}

pub fn windowClose(_: std.mem.Allocator, _: u64) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "window.close", core.errors.codes.not_implemented, "macOS window close is planned but not locally verified yet.", "Phase one will target AX APIs.");
}

pub fn appLaunch(allocator: std.mem.Allocator, target: []const u8) !core.model.AckResponse {
    if (builtin.os.tag != .macos) {
        return core.model.failure(core.model.Ack, "app.launch", core.errors.codes.not_implemented, "macOS app launch is planned but not locally verified yet.", "Phase one will target NSWorkspace bridging.");
    }
    if (target.len == 0) {
        return core.model.failure(core.model.Ack, "app.launch", core.errors.codes.invalid_args, "Launch target cannot be empty.", null);
    }

    var child = std.process.Child.init(&[_][]const u8{ "open", target }, allocator);
    child.stdin_behavior = .Ignore;
    child.stdout_behavior = .Ignore;
    child.stderr_behavior = .Ignore;
    child.spawn() catch |err| {
        return core.model.failure(core.model.Ack, "app.launch", core.errors.codes.system_error, "Failed to spawn open command.", @errorName(err));
    };

    const term = child.wait() catch |err| {
        return core.model.failure(core.model.Ack, "app.launch", core.errors.codes.system_error, "Failed while waiting for open command.", @errorName(err));
    };
    switch (term) {
        .Exited => |code| {
            if (code != 0) {
                return core.model.failure(core.model.Ack, "app.launch", core.errors.codes.system_error, "open command returned a non-zero exit code.", try std.fmt.allocPrint(allocator, "exit_code={d}", .{code}));
            }
        },
        else => {
            return core.model.failure(core.model.Ack, "app.launch", core.errors.codes.system_error, "open command did not exit normally.", null);
        },
    }

    return core.model.success("app.launch", core.model.Ack{ .message = "Launch requested.", .detail = try std.fmt.allocPrint(allocator, "target={s}", .{target}) });
}

pub fn clipboardGetText(_: std.mem.Allocator) !core.model.ClipboardTextResponse {
    return core.model.failure(core.model.ClipboardText, "clipboard.get_text", core.errors.codes.not_implemented, "macOS clipboard support is planned but not locally verified yet.", "Phase one will target NSPasteboard bridges.");
}

pub fn clipboardSetText(_: std.mem.Allocator, _: []const u8) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "clipboard.set_text", core.errors.codes.not_implemented, "macOS clipboard write support is planned but not locally verified yet.", "Phase one will target NSPasteboard bridges.");
}

pub fn clipboardGetFiles(_: std.mem.Allocator) !core.model.ClipboardFilesResponse {
    return core.model.failure(core.model.ClipboardFiles, "clipboard.get_files", core.errors.codes.not_implemented, "macOS clipboard file list support is planned but not locally verified yet.", "Phase one will target NSPasteboard bridges.");
}

pub fn clipboardSetFiles(_: std.mem.Allocator, _: []const u8) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "clipboard.set_files", core.errors.codes.not_implemented, "macOS clipboard file-drop write support is planned but not locally verified yet.", "Phase one will target NSPasteboard bridges.");
}

pub fn clipboardSetImage(_: std.mem.Allocator, _: []const u8) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "clipboard.set_image", core.errors.codes.not_implemented, "macOS clipboard image write support is planned but not locally verified yet.", "Phase one will target NSPasteboard bridges.");
}

pub fn keyboardKeyPress(_: std.mem.Allocator, _: []const u8) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "keyboard.key_press", core.errors.codes.not_implemented, "macOS key press support is planned but not locally verified yet.", "Phase one will target CoreGraphics events.");
}

pub fn keyboardHotkey(_: std.mem.Allocator, _: []const u8) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "keyboard.hotkey", core.errors.codes.not_implemented, "macOS hotkey support is planned but not locally verified yet.", "Phase one will target CoreGraphics events.");
}

pub fn keyboardTypeText(_: std.mem.Allocator, _: []const u8) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "keyboard.type_text", core.errors.codes.not_implemented, "macOS text typing support is planned but not locally verified yet.", "Phase one will target CoreGraphics events.");
}

pub fn keyboardTypeKeys(_: std.mem.Allocator, _: []const u8, _: ?u32) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "keyboard.type_keys", core.errors.codes.not_implemented, "macOS keymap typing support is planned but not locally verified yet.", "Phase one will target CoreGraphics events.");
}

pub fn keyboardImeSwitch(_: std.mem.Allocator, _: ?[]const u8) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "keyboard.ime_switch", core.errors.codes.not_implemented, "macOS IME switching support is planned but not locally verified yet.", "Phase one will target CoreGraphics events.");
}

pub fn keyboardCapsLock(_: std.mem.Allocator, _: ?[]const u8) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "keyboard.caps_lock", core.errors.codes.not_implemented, "macOS caps lock control is planned but not locally verified yet.", "Phase one will target CoreGraphics events.");
}

pub fn keyboardPaste(_: std.mem.Allocator, _: ?[]const u8, _: core.model.StringMatchMode) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "keyboard.paste", core.errors.codes.not_implemented, "macOS synthetic paste is planned but not locally verified yet.", "Phase one will target CoreGraphics events.");
}

pub fn screenCapture(allocator: std.mem.Allocator, path: []const u8, display_id: ?u32, window_handle: ?u64) !core.model.ScreenCaptureResponse {
    if (builtin.os.tag != .macos) {
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.not_implemented, "macOS screen capture is planned but not locally verified yet.", "Phase one will target CoreGraphics display capture.");
    }

    if (display_id != null and window_handle != null) {
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.invalid_args, "display_id and window_handle cannot be used together.", null);
    }

    if (display_id != null or window_handle != null) {
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.not_implemented, "macOS selective capture by display_id/window_handle is not implemented yet.", "Use default full-desktop capture on macOS for now.");
    }

    if (std.fs.path.dirname(path)) |dir_name| {
        try std.fs.cwd().makePath(dir_name);
    }

    var child = std.process.Child.init(&[_][]const u8{ "screencapture", "-x", "-t", "png", path }, allocator);
    child.stdin_behavior = .Ignore;
    child.stdout_behavior = .Ignore;
    child.stderr_behavior = .Ignore;
    child.spawn() catch |err| {
        if (err == error.FileNotFound) {
            return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.not_implemented, "screencapture command was not found on this host.", null);
        }
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.system_error, "Failed to spawn screencapture command.", @errorName(err));
    };

    const term = child.wait() catch |err| {
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.system_error, "Failed while waiting for screencapture command.", @errorName(err));
    };
    switch (term) {
        .Exited => |code| {
            if (code != 0) {
                return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.system_error, "screencapture command returned a non-zero exit code.", try std.fmt.allocPrint(allocator, "exit_code={d}", .{code}));
            }
        },
        else => {
            return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.system_error, "screencapture command did not exit normally.", null);
        },
    }

    const file = std.fs.cwd().openFile(path, .{}) catch {
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.system_error, "screencapture finished but output file was not found.", path);
    };
    defer file.close();

    const stat = file.stat() catch {
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.system_error, "Failed to stat the screenshot output file.", path);
    };
    if (stat.size == 0) {
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.system_error, "Screenshot output file is empty.", path);
    }

    return core.model.success("screen.capture", core.model.ScreenCapture{
        .path = path,
        .width = 0,
        .height = 0,
        .format = "png",
    });
}

pub fn screenPixelColor(allocator: std.mem.Allocator, x: i32, y: i32) !core.model.PixelColorResponse {
    if (builtin.os.tag != .macos) {
        return core.model.failure(core.model.PixelColor, "screen.pixel_color", core.errors.codes.not_implemented, "macOS pixel color inspection is planned but not locally verified yet.", "Phase one will target CoreGraphics display capture.");
    }
    return macos.screenPixelColor(allocator, x, y);
}

pub fn screenDisplays(allocator: std.mem.Allocator) !core.model.DisplayListResponse {
    if (builtin.os.tag != .macos) {
        return core.model.failure(core.model.DisplayList, "screen.displays", core.errors.codes.not_implemented, "macOS display enumeration is planned but not locally verified yet.", "Phase one will target CoreGraphics display capture.");
    }
    return macos.screenDisplays(allocator);
}

pub fn waitWindow(allocator: std.mem.Allocator, title: []const u8, timeout_ms: u64, match_mode: core.model.StringMatchMode, foreground_only: bool) !core.model.WaitWindowResponse {
    const start_ms = nowMs();
    while (true) {
        var iteration_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer iteration_arena.deinit();

        const snapshot = try windowList(iteration_arena.allocator(), true);
        if (!snapshot.ok) {
            const failure = snapshot.failure orelse core.errors.ApiError{ .code = core.errors.codes.system_error, .message = "window.list failed while polling for a matching window.", .detail = null };
            return core.model.failure(core.model.WaitWindow, "wait.window", failure.code, failure.message, failure.detail);
        }

        for (snapshot.data.?.windows) |window| {
            if (foreground_only and !window.is_foreground) continue;
            if (!textMatches(window.title, title, match_mode)) continue;

            return core.model.success("wait.window", core.model.WaitWindow{
                .matched = true,
                .elapsed_ms = nowMs() - start_ms,
                .window = .{
                    .handle = window.handle,
                    .pid = window.pid,
                    .title = try allocator.dupe(u8, window.title),
                    .class_name = try allocator.dupe(u8, window.class_name),
                    .visible = window.visible,
                    .is_foreground = window.is_foreground,
                    .bounds = window.bounds,
                },
            });
        }

        if (nowMs() - start_ms >= timeout_ms) {
            return core.model.failure(core.model.WaitWindow, "wait.window", core.errors.codes.timeout, "Timed out while waiting for a matching window.", title);
        }

        std.Thread.sleep(100 * std.time.ns_per_ms);
    }
}

pub fn waitFocus(allocator: std.mem.Allocator, title: []const u8, timeout_ms: u64, match_mode: core.model.StringMatchMode) !core.model.WaitFocusResponse {
    return waitWindow(allocator, title, timeout_ms, match_mode, true);
}

pub fn waitActivate(_: std.mem.Allocator, _: u64, _: u64, _: bool) !core.model.WaitWindowResponse {
    return core.model.failure(core.model.WaitWindow, "wait.activate", core.errors.codes.not_implemented, "macOS wait activate support is planned but not locally verified yet.", "Phase one will target CoreGraphics and AX APIs.");
}

pub fn waitPixel(allocator: std.mem.Allocator, x: i32, y: i32, hex: []const u8, timeout_ms: u64) !core.model.WaitPixelResponse {
    const expected = normalizeHex(allocator, hex) catch {
        return core.model.failure(core.model.WaitPixel, "wait.pixel", core.errors.codes.invalid_args, "hex must be RRGGBB or #RRGGBB.", hex);
    };
    const start_ms = nowMs();

    while (true) {
        const current = try screenPixelColor(allocator, x, y);
        if (!current.ok) {
            const failure = current.failure orelse core.errors.ApiError{ .code = core.errors.codes.system_error, .message = "screen.pixel_color failed while polling.", .detail = null };
            return core.model.failure(core.model.WaitPixel, "wait.pixel", failure.code, failure.message, failure.detail);
        }

        const pixel = current.data.?;
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
                if (textMatches(value, wanted, match_mode)) {
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
                if (textMatches(process.name, wanted_name, match_mode)) {
                    found = process;
                    break;
                }
            }
        }

        if ((found != null) == expect_running) {
            return core.model.success("wait.process", core.model.WaitProcess{
                .matched = true,
                .elapsed_ms = nowMs() - start_ms,
                .process = if (found) |value| .{ .pid = value.pid, .name = try allocator.dupe(u8, value.name) } else null,
            });
        }

        if (nowMs() - start_ms >= timeout_ms) {
            return core.model.failure(core.model.WaitProcess, "wait.process", core.errors.codes.timeout, "Timed out while waiting for process state transition.", if (name) |value| value else null);
        }

        std.Thread.sleep(150 * std.time.ns_per_ms);
    }
}

fn textMatches(candidate: []const u8, wanted: []const u8, match_mode: core.model.StringMatchMode) bool {
    return switch (match_mode) {
        .exact => std.mem.eql(u8, candidate, wanted),
        .contains => std.mem.indexOf(u8, candidate, wanted) != null,
    };
}

fn normalizeHex(allocator: std.mem.Allocator, hex: []const u8) ![]const u8 {
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
