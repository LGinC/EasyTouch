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
    const CGEvent = opaque {};
    const CGImage = opaque {};
    const CGContext = opaque {};
    const CGColorSpace = opaque {};

    const CFTypeRef = ?*CFType;
    const CFArrayRef = ?*CFArray;
    const CFDictionaryRef = ?*CFDictionary;
    const CFStringRef = ?*CFString;
    const CFNumberRef = ?*CFNumber;
    const CFBooleanRef = ?*CFBoolean;
    const CGEventRef = ?*CGEvent;
    const CGImageRef = ?*CGImage;
    const CGContextRef = ?*CGContext;
    const CGColorSpaceRef = ?*CGColorSpace;

    const kCGHIDEventTap: u32 = 0;
    const kCGEventLeftMouseDown: u32 = 1;
    const kCGEventLeftMouseUp: u32 = 2;
    const kCGEventRightMouseDown: u32 = 3;
    const kCGEventRightMouseUp: u32 = 4;
    const kCGEventMouseMoved: u32 = 5;
    const kCGEventOtherMouseDown: u32 = 25;
    const kCGEventOtherMouseUp: u32 = 26;
    const kCGScrollEventUnitLine: u32 = 1;
    const kCGMouseButtonLeft: u32 = 0;
    const kCGMouseButtonRight: u32 = 1;
    const kCGMouseButtonCenter: u32 = 2;

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
    extern "ApplicationServices" fn CGEventCreate(source: ?*const anyopaque) CGEventRef;
    extern "ApplicationServices" fn CGEventGetLocation(event: CGEventRef) CGPoint;
    extern "ApplicationServices" fn CGWarpMouseCursorPosition(new_cursor_position: CGPoint) i32;
    extern "ApplicationServices" fn CGEventCreateMouseEvent(source: ?*const anyopaque, mouse_type: u32, mouse_cursor_position: CGPoint, mouse_button: u32) CGEventRef;
    extern "ApplicationServices" fn CGEventCreateScrollWheelEvent(source: ?*const anyopaque, units: u32, wheel_count: u32, wheel1: i32) CGEventRef;
    extern "ApplicationServices" fn CGEventPost(tap: u32, event: CGEventRef) void;
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
            const ValueType = @TypeOf(value);
            switch (@typeInfo(ValueType)) {
                .optional => {
                    if (value) |typed| {
                        const raw: CFTypeRef = @ptrCast(typed);
                        CFRelease(raw);
                    }
                },
                else => {
                    const raw: CFTypeRef = @ptrCast(value);
                    CFRelease(raw);
                },
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

        std.Thread.sleep(200 * std.time.ns_per_ms);

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
    const machine_name = macHostName(allocator) catch try allocator.dupe(u8, "mac-host");
    const version = macSwVers(allocator) catch try allocator.dupe(u8, "macOS");
    return core.model.success("system.os_info", core.model.OsInfo{
        .platform = "macos",
        .arch = @tagName(builtin.cpu.arch),
        .version = version,
        .build = 0,
        .machine_name = machine_name,
        .runtime = "macos command-backed + coregraphics",
    });
}

pub fn systemCpuInfo(allocator: std.mem.Allocator) !core.model.CpuInfoResponse {
    const logical_cores = macSysctlU32(allocator, "hw.logicalcpu") catch |err| {
        return core.model.failure(core.model.CpuInfo, "system.cpu_info", core.errors.codes.system_error, "Failed to query macOS logical CPU count.", @errorName(err));
    };
    const page_size = macSysctlU32(allocator, "hw.pagesize") catch |err| {
        return core.model.failure(core.model.CpuInfo, "system.cpu_info", core.errors.codes.system_error, "Failed to query macOS page size.", @errorName(err));
    };
    return core.model.success("system.cpu_info", core.model.CpuInfo{
        .architecture = @tagName(builtin.cpu.arch),
        .logical_cores = logical_cores,
        .page_size = page_size,
    });
}

pub fn systemMemoryInfo(allocator: std.mem.Allocator) !core.model.MemoryInfoResponse {
    const total_physical = macSysctlU64(allocator, "hw.memsize") catch |err| {
        return core.model.failure(core.model.MemoryInfo, "system.memory_info", core.errors.codes.system_error, "Failed to query macOS memory size.", @errorName(err));
    };
    const available_physical = macAvailableMemory(allocator) catch |err| {
        return core.model.failure(core.model.MemoryInfo, "system.memory_info", core.errors.codes.system_error, "Failed to estimate macOS available memory.", @errorName(err));
    };
    const used_physical = total_physical -| available_physical;
    const load_percent: u32 = if (total_physical == 0) 0 else @intCast((used_physical * 100) / total_physical);

    return core.model.success("system.memory_info", core.model.MemoryInfo{
        .total_physical = total_physical,
        .available_physical = available_physical,
        .used_physical = used_physical,
        .memory_load_percent = load_percent,
    });
}

pub fn systemDiskList(allocator: std.mem.Allocator) !core.model.DiskListResponse {
    const result = macRunCommand(allocator, &[_][]const u8{ "df", "-kP" }, null) catch |err| {
        return core.model.failure(core.model.DiskList, "system.disk_list", core.errors.codes.system_error, "Failed to run df on macOS.", @errorName(err));
    };
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);
    if (result.missing or result.exit_code != 0) {
        return core.model.failure(core.model.DiskList, "system.disk_list", core.errors.codes.system_error, "df failed while listing macOS disks.", macCommandDetail(allocator, result) catch null);
    }

    var disks = std.ArrayList(core.model.DiskInfo).empty;
    defer disks.deinit(allocator);
    var lines = std.mem.splitScalar(u8, result.stdout, '\n');
    _ = lines.next();
    while (lines.next()) |line_raw| {
        const line = std.mem.trim(u8, line_raw, " \t\r");
        if (line.len == 0) continue;
        var tokens = std.mem.tokenizeAny(u8, line, " \t");
        const filesystem = tokens.next() orelse continue;
        const total_kb_text = tokens.next() orelse continue;
        _ = tokens.next() orelse continue;
        const free_kb_text = tokens.next() orelse continue;
        _ = tokens.next() orelse continue;
        const mount = tokens.next() orelse continue;
        const total_bytes = (std.fmt.parseInt(u64, total_kb_text, 10) catch continue) * 1024;
        const free_bytes = (std.fmt.parseInt(u64, free_kb_text, 10) catch continue) * 1024;
        try disks.append(allocator, .{
            .mount = try allocator.dupe(u8, mount),
            .volume_name = try allocator.dupe(u8, filesystem),
            .drive_type = try allocator.dupe(u8, "filesystem"),
            .total_bytes = total_bytes,
            .free_bytes = free_bytes,
        });
    }
    const owned = try disks.toOwnedSlice(allocator);
    return core.model.success("system.disk_list", core.model.DiskList{ .count = owned.len, .disks = owned });
}

pub fn systemProcessList(allocator: std.mem.Allocator) !core.model.ProcessListResponse {
    const result = macRunCommand(allocator, &[_][]const u8{ "ps", "-axo", "pid=,comm=" }, null) catch |err| {
        return core.model.failure(core.model.ProcessList, "system.process_list", core.errors.codes.system_error, "Failed to run ps on macOS.", @errorName(err));
    };
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);
    if (result.missing or result.exit_code != 0) {
        return core.model.failure(core.model.ProcessList, "system.process_list", core.errors.codes.system_error, "ps failed while listing macOS processes.", macCommandDetail(allocator, result) catch null);
    }

    var processes = std.ArrayList(core.model.ProcessInfo).empty;
    defer processes.deinit(allocator);
    var lines = std.mem.splitScalar(u8, result.stdout, '\n');
    while (lines.next()) |line_raw| {
        const line = std.mem.trim(u8, line_raw, " \t\r");
        if (line.len == 0) continue;
        var tokens = std.mem.tokenizeAny(u8, line, " \t");
        const pid_text = tokens.next() orelse continue;
        const name = tokens.next() orelse continue;
        const pid = std.fmt.parseInt(u32, pid_text, 10) catch continue;
        try processes.append(allocator, .{ .pid = pid, .name = try allocator.dupe(u8, name) });
    }
    const owned = try processes.toOwnedSlice(allocator);
    return core.model.success("system.process_list", core.model.ProcessList{ .count = owned.len, .processes = owned });
}

pub fn systemHardwareInfo(allocator: std.mem.Allocator) !core.model.HardwareInfoResponse {
    const cpu = try systemCpuInfo(allocator);
    if (!cpu.ok) {
        const failure = cpu.failure orelse core.errors.ApiError{ .code = core.errors.codes.system_error, .message = "system.cpu_info failed while building hardware info.", .detail = null };
        return core.model.failure(core.model.HardwareInfo, "system.hardware_info", failure.code, failure.message, failure.detail);
    }
    const mem = try systemMemoryInfo(allocator);
    if (!mem.ok) {
        const failure = mem.failure orelse core.errors.ApiError{ .code = core.errors.codes.system_error, .message = "system.memory_info failed while building hardware info.", .detail = null };
        return core.model.failure(core.model.HardwareInfo, "system.hardware_info", failure.code, failure.message, failure.detail);
    }
    const host = macHostName(allocator) catch try allocator.dupe(u8, "mac-host");

    return core.model.success("system.hardware_info", core.model.HardwareInfo{
        .architecture = cpu.data.?.architecture,
        .logical_cores = cpu.data.?.logical_cores,
        .page_size = cpu.data.?.page_size,
        .total_physical = mem.data.?.total_physical,
        .total_virtual = mem.data.?.total_physical,
        .machine_name = host,
    });
}

pub fn systemNetworkInfo(allocator: std.mem.Allocator) !core.model.NetworkInfoResponse {
    const result = macRunCommand(allocator, &[_][]const u8{ "ifconfig" }, null) catch |err| {
        return core.model.failure(core.model.NetworkInfo, "system.network_info", core.errors.codes.system_error, "Failed to run ifconfig on macOS.", @errorName(err));
    };
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);
    if (result.missing or result.exit_code != 0) {
        return core.model.failure(core.model.NetworkInfo, "system.network_info", core.errors.codes.system_error, "ifconfig failed while listing macOS adapters.", macCommandDetail(allocator, result) catch null);
    }

    var adapters = std.ArrayList(core.model.NetworkAdapter).empty;
    defer adapters.deinit(allocator);
    try macParseIfconfig(allocator, result.stdout, &adapters);
    const owned = try adapters.toOwnedSlice(allocator);
    return core.model.success("system.network_info", core.model.NetworkInfo{ .count = owned.len, .adapters = owned });
}

pub fn mousePosition(allocator: std.mem.Allocator) !core.model.PointResponse {
    _ = allocator;
    const event = macos.CGEventCreate(null) orelse {
        return core.model.failure(core.model.Point, "mouse.position", core.errors.codes.system_error, "CGEventCreate failed while reading macOS mouse position.", null);
    };
    defer macos.release(event);
    const location = macos.CGEventGetLocation(event);
    return core.model.success("mouse.position", core.model.Point{ .x = @intFromFloat(@round(location.x)), .y = @intFromFloat(@round(location.y)) });
}

pub fn mouseMove(allocator: std.mem.Allocator, x: i32, y: i32, duration_ms: ?u32, jitter_px: ?i32, step_delay_ms: ?u32) !core.model.AckResponse {
    const resolved_duration_ms = duration_ms orelse 280;
    const resolved_jitter_px = jitter_px orelse 3;
    const resolved_step_delay_ms = step_delay_ms orelse 8;

    if (resolved_jitter_px < 0 or resolved_jitter_px > 64) {
        return core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.invalid_args, "jitter_px must be in range 0..64.", null);
    }

    const start = try mousePosition(allocator);
    if (!start.ok) {
        const failure = start.failure orelse core.errors.ApiError{ .code = core.errors.codes.system_error, .message = "mouse.position failed before move.", .detail = null };
        return core.model.failure(core.model.Ack, "mouse.move", failure.code, failure.message, failure.detail);
    }

    const dx = x - start.data.?.x;
    const dy = y - start.data.?.y;
    if (dx == 0 and dy == 0) {
        return core.model.success("mouse.move", core.model.Ack{ .message = "Mouse already at target.", .detail = try std.fmt.allocPrint(allocator, "x={d}; y={d}", .{ x, y }) });
    }

    const abs_dx = if (dx >= 0) dx else -dx;
    const abs_dy = if (dy >= 0) dy else -dy;
    const dominant_axis = if (abs_dx > abs_dy) abs_dx else abs_dy;
    const distance_steps = @max(@min(@divTrunc(dominant_axis, 6), 240), 12);
    const timing_steps = if (resolved_step_delay_ms == 0) 0 else @as(i32, @intCast(resolved_duration_ms / resolved_step_delay_ms));
    const steps = @max(@min(if (distance_steps > timing_steps) distance_steps else timing_steps, 240), 12);

    var step_index: i32 = 1;
    while (step_index <= steps) : (step_index += 1) {
        const t = @as(f64, @floatFromInt(step_index)) / @as(f64, @floatFromInt(steps));
        const eased = 1.0 - (1.0 - t) * (1.0 - t);
        const base_xf = @as(f64, @floatFromInt(start.data.?.x)) + @as(f64, @floatFromInt(dx)) * eased;
        const base_yf = @as(f64, @floatFromInt(start.data.?.y)) + @as(f64, @floatFromInt(dy)) * eased;
        const wave = t * (std.math.pi * 3.0);
        const fade = 1.0 - t;
        const jitter_strength = @as(f64, @floatFromInt(resolved_jitter_px)) * fade;
        const jitter_x = if (resolved_jitter_px == 0 or step_index == steps) 0 else @as(i32, @intFromFloat(@round(jitter_strength * std.math.sin(wave))));
        const jitter_y = if (resolved_jitter_px == 0 or step_index == steps) 0 else @as(i32, @intFromFloat(@round(jitter_strength * std.math.cos(wave * 1.31))));
        const move_x = if (step_index == steps) x else @as(i32, @intFromFloat(@round(base_xf))) + jitter_x;
        const move_y = if (step_index == steps) y else @as(i32, @intFromFloat(@round(base_yf))) + jitter_y;
        if (macos.CGWarpMouseCursorPosition(.{ .x = @floatFromInt(move_x), .y = @floatFromInt(move_y) }) != 0) {
            return core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.system_error, "CGWarpMouseCursorPosition failed while moving the macOS cursor.", null);
        }
        if (resolved_step_delay_ms > 0 and step_index < steps) {
            std.Thread.sleep(@as(u64, resolved_step_delay_ms) * std.time.ns_per_ms);
        }
    }

    return core.model.success("mouse.move", core.model.Ack{ .message = "Mouse moved with human-like trajectory.", .detail = try std.fmt.allocPrint(allocator, "x={d}; y={d}; duration_ms={d}; jitter_px={d}; step_delay_ms={d}; steps={d}", .{ x, y, resolved_duration_ms, resolved_jitter_px, resolved_step_delay_ms, steps }) });
}

pub fn mouseClick(allocator: std.mem.Allocator, button: core.model.MouseButton, count: u8) !core.model.AckResponse {
    if (count == 0) {
        return core.model.failure(core.model.Ack, "mouse.click", core.errors.codes.invalid_args, "count must be at least 1.", null);
    }
    const current = try mousePosition(allocator);
    if (!current.ok) {
        const failure = current.failure orelse core.errors.ApiError{ .code = core.errors.codes.system_error, .message = "mouse.position failed before click.", .detail = null };
        return core.model.failure(core.model.Ack, "mouse.click", failure.code, failure.message, failure.detail);
    }

    const point = macos.CGPoint{ .x = @floatFromInt(current.data.?.x), .y = @floatFromInt(current.data.?.y) };
    const event_types = switch (button) {
        .left => [2]u32{ macos.kCGEventLeftMouseDown, macos.kCGEventLeftMouseUp },
        .right => [2]u32{ macos.kCGEventRightMouseDown, macos.kCGEventRightMouseUp },
        .middle => [2]u32{ macos.kCGEventOtherMouseDown, macos.kCGEventOtherMouseUp },
    };
    const mouse_button = switch (button) {
        .left => macos.kCGMouseButtonLeft,
        .right => macos.kCGMouseButtonRight,
        .middle => macos.kCGMouseButtonCenter,
    };

    var remaining = count;
    while (remaining > 0) : (remaining -= 1) {
        const down_event = macos.CGEventCreateMouseEvent(null, event_types[0], point, mouse_button) orelse {
            return core.model.failure(core.model.Ack, "mouse.click", core.errors.codes.system_error, "CGEventCreateMouseEvent failed for mouse down on macOS.", null);
        };
        defer macos.release(down_event);
        macos.CGEventPost(macos.kCGHIDEventTap, down_event);

        const up_event = macos.CGEventCreateMouseEvent(null, event_types[1], point, mouse_button) orelse {
            return core.model.failure(core.model.Ack, "mouse.click", core.errors.codes.system_error, "CGEventCreateMouseEvent failed for mouse up on macOS.", null);
        };
        defer macos.release(up_event);
        macos.CGEventPost(macos.kCGHIDEventTap, up_event);
    }

    return core.model.success("mouse.click", core.model.Ack{ .message = "Mouse click sent.", .detail = try std.fmt.allocPrint(allocator, "button={s}; count={d}", .{ @tagName(button), count }) });
}

pub fn mouseScroll(allocator: std.mem.Allocator, delta: i32) !core.model.AckResponse {
    if (delta == 0) {
        return core.model.failure(core.model.Ack, "mouse.scroll", core.errors.codes.invalid_args, "delta must be non-zero.", null);
    }
    const event = macos.CGEventCreateScrollWheelEvent(null, macos.kCGScrollEventUnitLine, 1, delta) orelse {
        return core.model.failure(core.model.Ack, "mouse.scroll", core.errors.codes.system_error, "CGEventCreateScrollWheelEvent failed on macOS.", null);
    };
    defer macos.release(event);
    macos.CGEventPost(macos.kCGHIDEventTap, event);
    return core.model.success("mouse.scroll", core.model.Ack{ .message = "Mouse wheel event sent.", .detail = try std.fmt.allocPrint(allocator, "delta={d}", .{delta}) });
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

pub fn windowShow(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    const target = macResolveWindowTarget(allocator, handle) catch |err| return macAckResolutionFailure(allocator, "window.show", handle, err);
    const pid_text = try std.fmt.allocPrint(allocator, "{d}", .{target.pid});
    defer allocator.free(pid_text);
    macRunAppleScriptOrFailure(allocator, "window.show", macWindowScriptShow, &[_][]const u8{ pid_text, target.title }) catch |err| return macAckScriptFailure("window.show", err);
    return core.model.success("window.show", core.model.Ack{ .message = "macOS window show requested.", .detail = try std.fmt.allocPrint(allocator, "target_handle=0x{x}; title={s}; pid={d}", .{ handle, target.title, target.pid }) });
}

pub fn windowMinimize(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    const target = macResolveWindowTarget(allocator, handle) catch |err| return macAckResolutionFailure(allocator, "window.minimize", handle, err);
    const pid_text = try std.fmt.allocPrint(allocator, "{d}", .{target.pid});
    defer allocator.free(pid_text);
    macRunAppleScriptOrFailure(allocator, "window.minimize", macWindowScriptMinimize, &[_][]const u8{ pid_text, target.title }) catch |err| return macAckScriptFailure("window.minimize", err);
    return core.model.success("window.minimize", core.model.Ack{ .message = "macOS window minimize requested.", .detail = try std.fmt.allocPrint(allocator, "target_handle=0x{x}; title={s}; pid={d}", .{ handle, target.title, target.pid }) });
}

pub fn windowMaximize(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    const target = macResolveWindowTarget(allocator, handle) catch |err| return macAckResolutionFailure(allocator, "window.maximize", handle, err);
    const pid_text = try std.fmt.allocPrint(allocator, "{d}", .{target.pid});
    defer allocator.free(pid_text);
    macRunAppleScriptOrFailure(allocator, "window.maximize", macWindowScriptMaximize, &[_][]const u8{ pid_text, target.title }) catch |err| return macAckScriptFailure("window.maximize", err);
    return core.model.success("window.maximize", core.model.Ack{ .message = "macOS window maximize requested.", .detail = try std.fmt.allocPrint(allocator, "target_handle=0x{x}; title={s}; pid={d}", .{ handle, target.title, target.pid }) });
}

pub fn windowRestore(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    const target = macResolveWindowTarget(allocator, handle) catch |err| return macAckResolutionFailure(allocator, "window.restore", handle, err);
    const pid_text = try std.fmt.allocPrint(allocator, "{d}", .{target.pid});
    defer allocator.free(pid_text);
    macRunAppleScriptOrFailure(allocator, "window.restore", macWindowScriptRestore, &[_][]const u8{ pid_text, target.title }) catch |err| return macAckScriptFailure("window.restore", err);
    return core.model.success("window.restore", core.model.Ack{ .message = "macOS window restore requested.", .detail = try std.fmt.allocPrint(allocator, "target_handle=0x{x}; title={s}; pid={d}", .{ handle, target.title, target.pid }) });
}

pub fn windowMove(allocator: std.mem.Allocator, handle: u64, x: i32, y: i32, width: ?i32, height: ?i32) !core.model.AckResponse {
    const target = macResolveWindowTarget(allocator, handle) catch |err| return macAckResolutionFailure(allocator, "window.move", handle, err);
    const resolved_width = width orelse target.bounds.width;
    const resolved_height = height orelse target.bounds.height;
    const pid_text = try std.fmt.allocPrint(allocator, "{d}", .{target.pid});
    defer allocator.free(pid_text);
    const x_text = try std.fmt.allocPrint(allocator, "{d}", .{x});
    defer allocator.free(x_text);
    const y_text = try std.fmt.allocPrint(allocator, "{d}", .{y});
    defer allocator.free(y_text);
    const width_text = try std.fmt.allocPrint(allocator, "{d}", .{resolved_width});
    defer allocator.free(width_text);
    const height_text = try std.fmt.allocPrint(allocator, "{d}", .{resolved_height});
    defer allocator.free(height_text);
    macRunAppleScriptOrFailure(allocator, "window.move", macWindowScriptMove, &[_][]const u8{ pid_text, target.title, x_text, y_text, width_text, height_text }) catch |err| return macAckScriptFailure("window.move", err);
    return core.model.success("window.move", core.model.Ack{ .message = "macOS window move requested.", .detail = try std.fmt.allocPrint(allocator, "target_handle=0x{x}; x={d}; y={d}; width={d}; height={d}", .{ handle, x, y, resolved_width, resolved_height }) });
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

pub fn windowClose(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    const target = macResolveWindowTarget(allocator, handle) catch |err| return macAckResolutionFailure(allocator, "window.close", handle, err);
    const pid_text = try std.fmt.allocPrint(allocator, "{d}", .{target.pid});
    defer allocator.free(pid_text);
    macRunAppleScriptOrFailure(allocator, "window.close", macWindowScriptClose, &[_][]const u8{ pid_text, target.title }) catch |err| return macAckScriptFailure("window.close", err);
    return core.model.success("window.close", core.model.Ack{ .message = "macOS window close requested.", .detail = try std.fmt.allocPrint(allocator, "target_handle=0x{x}; title={s}; pid={d}", .{ handle, target.title, target.pid }) });
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

pub fn clipboardGetText(allocator: std.mem.Allocator) !core.model.ClipboardTextResponse {
    const result = try macRunCommand(allocator, &[_][]const u8{ "pbpaste" }, null);
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);
    if (result.missing or result.exit_code != 0) {
        return core.model.failure(core.model.ClipboardText, "clipboard.get_text", core.errors.codes.system_error, "pbpaste failed while reading macOS clipboard text.", macCommandDetail(allocator, result) catch null);
    }
    const text = std.mem.trimRight(u8, result.stdout, "\r\n");
    if (text.len == 0) {
        return core.model.failure(core.model.ClipboardText, "clipboard.get_text", core.errors.codes.clipboard_empty, "Clipboard is empty.", null);
    }
    return core.model.success("clipboard.get_text", core.model.ClipboardText{ .text = try allocator.dupe(u8, text) });
}

pub fn clipboardSetText(allocator: std.mem.Allocator, text: []const u8) !core.model.AckResponse {
    const result = try macRunCommand(allocator, &[_][]const u8{ "pbcopy" }, text);
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);
    if (result.missing or result.exit_code != 0) {
        return core.model.failure(core.model.Ack, "clipboard.set_text", core.errors.codes.system_error, "pbcopy failed while writing macOS clipboard text.", macCommandDetail(allocator, result) catch null);
    }
    return core.model.success("clipboard.set_text", core.model.Ack{ .message = "Clipboard text updated.", .detail = try std.fmt.allocPrint(allocator, "bytes={d}", .{text.len}) });
}

pub fn clipboardGetFiles(allocator: std.mem.Allocator) !core.model.ClipboardFilesResponse {
    const result = try macRunAppleScript(allocator, macClipboardGetFilesScript, &[_][]const u8{});
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);
    if (result.missing or result.exit_code != 0) {
        return core.model.failure(core.model.ClipboardFiles, "clipboard.get_files", core.errors.codes.system_error, "osascript failed while reading macOS clipboard files.", macCommandDetail(allocator, result) catch null);
    }
    const trimmed = std.mem.trim(u8, result.stdout, "\r\n");
    if (trimmed.len == 0) {
        return core.model.failure(core.model.ClipboardFiles, "clipboard.get_files", core.errors.codes.clipboard_empty, "Clipboard does not currently contain a file list.", null);
    }
    var files = std.ArrayList([]const u8).empty;
    defer files.deinit(allocator);
    var lines = std.mem.splitScalar(u8, trimmed, '\n');
    while (lines.next()) |line_raw| {
        const line = std.mem.trim(u8, line_raw, " \t\r");
        if (line.len == 0) continue;
        try files.append(allocator, try allocator.dupe(u8, line));
    }
    return core.model.success("clipboard.get_files", core.model.ClipboardFiles{ .files = try files.toOwnedSlice(allocator) });
}

pub fn clipboardSetFiles(allocator: std.mem.Allocator, paths: []const u8) !core.model.AckResponse {
    var args = std.ArrayList([]const u8).empty;
    defer args.deinit(allocator);
    var iter = std.mem.splitScalar(u8, paths, ';');
    while (iter.next()) |entry_raw| {
        const entry = std.mem.trim(u8, entry_raw, " \t\r\n");
        if (entry.len == 0) continue;
        try args.append(allocator, entry);
    }
    if (args.items.len == 0) {
        return core.model.failure(core.model.Ack, "clipboard.set_files", core.errors.codes.invalid_args, "paths must contain at least one file path.", null);
    }
    const result = try macRunAppleScript(allocator, macClipboardSetFilesScript, args.items);
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);
    if (result.missing or result.exit_code != 0) {
        return core.model.failure(core.model.Ack, "clipboard.set_files", core.errors.codes.system_error, "osascript failed while writing macOS clipboard file list.", macCommandDetail(allocator, result) catch null);
    }
    return core.model.success("clipboard.set_files", core.model.Ack{ .message = "Clipboard file list updated.", .detail = try std.fmt.allocPrint(allocator, "count={d}", .{args.items.len}) });
}

pub fn clipboardSetImage(allocator: std.mem.Allocator, path: []const u8) !core.model.AckResponse {
    const result = try macRunJavaScript(allocator, macClipboardSetImageScript, &[_][]const u8{ path });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);
    if (result.missing or result.exit_code != 0) {
        return core.model.failure(core.model.Ack, "clipboard.set_image", core.errors.codes.system_error, "JXA failed while writing macOS clipboard image.", macCommandDetail(allocator, result) catch null);
    }
    return core.model.success("clipboard.set_image", core.model.Ack{ .message = "Clipboard image updated.", .detail = try std.fmt.allocPrint(allocator, "path={s}", .{path}) });
}

pub fn keyboardKeyPress(allocator: std.mem.Allocator, key: []const u8) !core.model.AckResponse {
    const command = macAppleScriptKeyCommand(allocator, key) catch {
        return core.model.failure(core.model.Ack, "keyboard.key_press", core.errors.codes.invalid_args, "Unsupported key value for macOS key press.", key);
    };
    defer allocator.free(command);
    macRunAppleScriptOrFailure(allocator, "keyboard.key_press", command, &[_][]const u8{}) catch |err| return macAckScriptFailure("keyboard.key_press", err);
    return core.model.success("keyboard.key_press", core.model.Ack{ .message = "Key press sent.", .detail = try std.fmt.allocPrint(allocator, "key={s}", .{key}) });
}

pub fn keyboardHotkey(allocator: std.mem.Allocator, keys: []const u8) !core.model.AckResponse {
    const command = macAppleScriptHotkeyCommand(allocator, keys) catch {
        return core.model.failure(core.model.Ack, "keyboard.hotkey", core.errors.codes.invalid_args, "Unsupported hotkey combination for macOS automation.", keys);
    };
    defer allocator.free(command);
    macRunAppleScriptOrFailure(allocator, "keyboard.hotkey", command, &[_][]const u8{}) catch |err| return macAckScriptFailure("keyboard.hotkey", err);
    return core.model.success("keyboard.hotkey", core.model.Ack{ .message = "Hotkey sent.", .detail = try std.fmt.allocPrint(allocator, "keys={s}", .{keys}) });
}

pub fn keyboardTypeText(allocator: std.mem.Allocator, text: []const u8) !core.model.AckResponse {
    macRunAppleScriptOrFailure(allocator, "keyboard.type_text", macKeyboardTypeTextScript, &[_][]const u8{text}) catch |err| return macAckScriptFailure("keyboard.type_text", err);
    return core.model.success("keyboard.type_text", core.model.Ack{ .message = "Text input sent.", .detail = try std.fmt.allocPrint(allocator, "bytes={d}", .{text.len}) });
}

pub fn keyboardTypeKeys(allocator: std.mem.Allocator, text: []const u8, key_delay_ms: ?u32) !core.model.AckResponse {
    const delay_ms = key_delay_ms orelse 30;
    if (delay_ms > 1000) {
        return core.model.failure(core.model.Ack, "keyboard.type_keys", core.errors.codes.invalid_args, "key_delay_ms must be <= 1000.", null);
    }
    const delay_text = try std.fmt.allocPrint(allocator, "{d}", .{delay_ms});
    defer allocator.free(delay_text);
    macRunAppleScriptOrFailure(allocator, "keyboard.type_keys", macKeyboardTypeKeysScript, &[_][]const u8{ text, delay_text }) catch |err| return macAckScriptFailure("keyboard.type_keys", err);
    return core.model.success("keyboard.type_keys", core.model.Ack{ .message = "Keymap typing sent.", .detail = try std.fmt.allocPrint(allocator, "bytes={d}; key_delay_ms={d}", .{ text.len, delay_ms }) });
}

pub fn keyboardImeSwitch(allocator: std.mem.Allocator, strategy: ?[]const u8) !core.model.AckResponse {
    const resolved = strategy orelse "win-space";
    const command = if (std.ascii.eqlIgnoreCase(resolved, "win-space"))
        "tell application \"System Events\" to keystroke space using command down"
    else if (std.ascii.eqlIgnoreCase(resolved, "alt-shift"))
        "tell application \"System Events\" to keystroke space using option down"
    else if (std.ascii.eqlIgnoreCase(resolved, "ctrl-shift"))
        "tell application \"System Events\" to keystroke space using control down"
    else
        return core.model.failure(core.model.Ack, "keyboard.ime_switch", core.errors.codes.invalid_args, "Unsupported strategy. Use win-space, alt-shift, or ctrl-shift.", resolved);
    macRunAppleScriptOrFailure(allocator, "keyboard.ime_switch", command, &[_][]const u8{}) catch |err| return macAckScriptFailure("keyboard.ime_switch", err);
    return core.model.success("keyboard.ime_switch", core.model.Ack{ .message = "IME switch shortcut sent.", .detail = try std.fmt.allocPrint(allocator, "strategy={s}", .{resolved}) });
}

pub fn keyboardCapsLock(allocator: std.mem.Allocator, state: ?[]const u8) !core.model.AckResponse {
    const resolved = state orelse "toggle";
    if (!std.ascii.eqlIgnoreCase(resolved, "toggle")) {
        return core.model.failure(core.model.Ack, "keyboard.caps_lock", core.errors.codes.not_implemented, "macOS caps lock currently supports toggle only.", "Stateful on/off detection is not exposed reliably without lower-level HID integration.");
    }
    macRunAppleScriptOrFailure(allocator, "keyboard.caps_lock", "tell application \"System Events\" to key code 57", &[_][]const u8{}) catch |err| return macAckScriptFailure("keyboard.caps_lock", err);
    return core.model.success("keyboard.caps_lock", core.model.Ack{ .message = "Caps lock toggled.", .detail = try std.fmt.allocPrint(allocator, "requested={s}", .{resolved}) });
}

pub fn keyboardPaste(allocator: std.mem.Allocator, expected_title: ?[]const u8, match_mode: core.model.StringMatchMode) !core.model.AckResponse {
    if (expected_title) |title| {
        const current = try windowForeground(allocator);
        if (!current.ok or !current.data.?.found or !textMatches(current.data.?.window.?.title, title, match_mode)) {
            return core.model.failure(core.model.Ack, "keyboard.paste", core.errors.codes.unsafe_operation, "Foreground window title does not match expected_title.", title);
        }
    }
    macRunAppleScriptOrFailure(allocator, "keyboard.paste", "tell application \"System Events\" to keystroke \"v\" using command down", &[_][]const u8{}) catch |err| return macAckScriptFailure("keyboard.paste", err);
    return core.model.success("keyboard.paste", core.model.Ack{ .message = "Paste shortcut sent.", .detail = if (expected_title) |title| try std.fmt.allocPrint(allocator, "expected_title={s}", .{title}) else null });
}

pub fn screenCapture(allocator: std.mem.Allocator, path: []const u8, display_id: ?u32, window_handle: ?u64) !core.model.ScreenCaptureResponse {
    if (builtin.os.tag != .macos) {
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.not_implemented, "macOS screen capture is planned but not locally verified yet.", "Phase one will target CoreGraphics display capture.");
    }

    if (display_id != null and window_handle != null) {
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.invalid_args, "display_id and window_handle cannot be used together.", null);
    }

    if (std.fs.path.dirname(path)) |dir_name| {
        try std.fs.cwd().makePath(dir_name);
    }

    var args = std.ArrayList([]const u8).empty;
    defer args.deinit(allocator);
    try args.append(allocator, "screencapture");
    try args.append(allocator, "-x");
    try args.append(allocator, "-t");
    try args.append(allocator, "png");
    if (display_id) |id| {
        const display_text = try std.fmt.allocPrint(allocator, "{d}", .{id});
        defer allocator.free(display_text);
        try args.append(allocator, "-D");
        try args.append(allocator, display_text);
    }
    if (window_handle) |handle| {
        const handle_text = try std.fmt.allocPrint(allocator, "{d}", .{handle});
        defer allocator.free(handle_text);
        try args.append(allocator, "-l");
        try args.append(allocator, handle_text);
    }
    try args.append(allocator, path);

    var child = std.process.Child.init(args.items, allocator);
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

pub fn waitActivate(allocator: std.mem.Allocator, handle: u64, timeout_ms: u64, expect_active: bool) !core.model.WaitWindowResponse {
    const start_ms = nowMs();
    while (true) {
        const foreground = try windowForeground(allocator);
        if (!foreground.ok) {
            const failure = foreground.failure orelse core.errors.ApiError{ .code = core.errors.codes.system_error, .message = "window.foreground failed while polling activation state.", .detail = null };
            return core.model.failure(core.model.WaitWindow, "wait.activate", failure.code, failure.message, failure.detail);
        }

        const active_handle = if (foreground.data.?.found and foreground.data.?.window != null) foreground.data.?.window.?.handle else 0;
        if ((active_handle == handle) == expect_active) {
            return core.model.success("wait.activate", core.model.WaitWindow{ .matched = true, .elapsed_ms = nowMs() - start_ms, .window = foreground.data.?.window });
        }

        if (nowMs() - start_ms >= timeout_ms) {
            return core.model.failure(core.model.WaitWindow, "wait.activate", core.errors.codes.timeout, "Timed out while waiting for macOS window activation state transition.", try std.fmt.allocPrint(allocator, "target_handle=0x{x}; expect_active={s}", .{ handle, if (expect_active) "true" else "false" }));
        }

        std.Thread.sleep(100 * std.time.ns_per_ms);
    }
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

const MacCommandResult = struct {
    stdout: []u8,
    stderr: []u8,
    exit_code: i32,
    missing: bool = false,
};

fn macRunCommand(allocator: std.mem.Allocator, argv: []const []const u8, stdin_bytes: ?[]const u8) !MacCommandResult {
    var child = std.process.Child.init(argv, allocator);
    child.stdin_behavior = if (stdin_bytes != null) .Pipe else .Ignore;
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;

    child.spawn() catch |err| {
        if (err == error.FileNotFound) {
            return .{ .stdout = try allocator.dupe(u8, ""), .stderr = try allocator.dupe(u8, ""), .exit_code = -1, .missing = true };
        }
        return err;
    };

    if (stdin_bytes) |bytes| {
        if (child.stdin) |stdin| {
            try stdin.writeAll(bytes);
            stdin.close();
        }
    }

    const stdout = if (child.stdout) |stdout_pipe|
        try stdout_pipe.reader().readAllAlloc(allocator, 8 * 1024 * 1024)
    else
        try allocator.dupe(u8, "");
    const stderr = if (child.stderr) |stderr_pipe|
        try stderr_pipe.reader().readAllAlloc(allocator, 4 * 1024 * 1024)
    else
        try allocator.dupe(u8, "");

    const term = try child.wait();
    const exit_code: i32 = switch (term) {
        .Exited => |code| @intCast(code),
        else => -1,
    };

    return .{ .stdout = stdout, .stderr = stderr, .exit_code = exit_code };
}

fn macCommandDetail(allocator: std.mem.Allocator, result: MacCommandResult) ![]const u8 {
    const stderr_text = std.mem.trim(u8, result.stderr, " \t\r\n");
    const stdout_text = std.mem.trim(u8, result.stdout, " \t\r\n");
    if (stderr_text.len > 0) return std.fmt.allocPrint(allocator, "exit_code={d}; stderr={s}", .{ result.exit_code, stderr_text });
    if (stdout_text.len > 0) return std.fmt.allocPrint(allocator, "exit_code={d}; stdout={s}", .{ result.exit_code, stdout_text });
    return std.fmt.allocPrint(allocator, "exit_code={d}", .{result.exit_code});
}

fn macHostName(allocator: std.mem.Allocator) ![]const u8 {
    const primary = try macRunCommand(allocator, &[_][]const u8{ "scutil", "--get", "LocalHostName" }, null);
    defer allocator.free(primary.stderr);
    if (!primary.missing and primary.exit_code == 0) {
        return trimOwnedTrailingWhitespace(allocator, primary.stdout);
    }
    allocator.free(primary.stdout);

    const fallback = try macRunCommand(allocator, &[_][]const u8{ "hostname" }, null);
    defer allocator.free(fallback.stderr);
    if (fallback.missing or fallback.exit_code != 0) {
        allocator.free(fallback.stdout);
        return error.HostnameUnavailable;
    }
    return trimOwnedTrailingWhitespace(allocator, fallback.stdout);
}

fn macSwVers(allocator: std.mem.Allocator) ![]const u8 {
    const result = try macRunCommand(allocator, &[_][]const u8{ "sw_vers", "-productVersion" }, null);
    defer allocator.free(result.stderr);
    if (result.missing or result.exit_code != 0) {
        allocator.free(result.stdout);
        return error.SwVersUnavailable;
    }
    return trimOwnedTrailingWhitespace(allocator, result.stdout);
}

fn macSysctlU32(allocator: std.mem.Allocator, key: []const u8) !u32 {
    const result = try macRunCommand(allocator, &[_][]const u8{ "sysctl", "-n", key }, null);
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);
    if (result.missing or result.exit_code != 0) return error.SysctlUnavailable;
    return try std.fmt.parseInt(u32, std.mem.trim(u8, result.stdout, " \t\r\n"), 10);
}

fn macSysctlU64(allocator: std.mem.Allocator, key: []const u8) !u64 {
    const result = try macRunCommand(allocator, &[_][]const u8{ "sysctl", "-n", key }, null);
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);
    if (result.missing or result.exit_code != 0) return error.SysctlUnavailable;
    return try std.fmt.parseInt(u64, std.mem.trim(u8, result.stdout, " \t\r\n"), 10);
}

fn macAvailableMemory(allocator: std.mem.Allocator) !u64 {
    const result = try macRunCommand(allocator, &[_][]const u8{ "vm_stat" }, null);
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);
    if (result.missing or result.exit_code != 0) return error.VmStatUnavailable;

    const page_size = macParseVmStatPageSize(result.stdout) orelse 4096;
    const free_pages = macParseVmStatCounter(result.stdout, "Pages free") orelse 0;
    const inactive_pages = macParseVmStatCounter(result.stdout, "Pages inactive") orelse 0;
    const speculative_pages = macParseVmStatCounter(result.stdout, "Pages speculative") orelse 0;
    return (free_pages + inactive_pages + speculative_pages) * page_size;
}

fn macParseVmStatPageSize(output: []const u8) ?u64 {
    const marker = "page size of ";
    const index = std.mem.indexOf(u8, output, marker) orelse return null;
    const rest = output[index + marker.len ..];
    const end = std.mem.indexOf(u8, rest, " bytes") orelse return null;
    return std.fmt.parseInt(u64, rest[0..end], 10) catch null;
}

fn macParseVmStatCounter(output: []const u8, key: []const u8) ?u64 {
    var lines = std.mem.splitScalar(u8, output, '\n');
    while (lines.next()) |line_raw| {
        const line = std.mem.trim(u8, line_raw, " \t\r");
        if (!std.mem.startsWith(u8, line, key)) continue;
        const colon = std.mem.indexOfScalar(u8, line, ':') orelse return null;
        const value_text = std.mem.trim(u8, line[colon + 1 ..], " \t.");
        return std.fmt.parseInt(u64, value_text, 10) catch null;
    }
    return null;
}

fn macParseIfconfig(allocator: std.mem.Allocator, output: []const u8, adapters: *std.ArrayList(core.model.NetworkAdapter)) !void {
    var current_name: ?[]const u8 = null;
    var current_ipv4: []const u8 = "";
    var current_mac: []const u8 = "";

    var lines = std.mem.splitScalar(u8, output, '\n');
    while (lines.next()) |line_raw| {
        const line = std.mem.trim(u8, line_raw, "\r");
        if (line.len == 0) continue;
        if (line[0] != '\t' and line[0] != ' ') {
            if (current_name) |name| {
                if (!std.mem.eql(u8, name, "lo0")) {
                    try adapters.append(allocator, .{
                        .name = try allocator.dupe(u8, name),
                        .description = try allocator.dupe(u8, name),
                        .ipv4 = try allocator.dupe(u8, current_ipv4),
                        .mac = try allocator.dupe(u8, current_mac),
                        .adapter_type = try allocator.dupe(u8, if (std.mem.startsWith(u8, name, "en")) "ethernet" else "network"),
                        .dhcp_enabled = false,
                    });
                }
            }
            const colon = std.mem.indexOfScalar(u8, line, ':') orelse continue;
            current_name = line[0..colon];
            current_ipv4 = "";
            current_mac = "";
            continue;
        }

        const trimmed = std.mem.trim(u8, line, " \t");
        if (std.mem.startsWith(u8, trimmed, "inet ")) {
            const rest = trimmed[5..];
            const end = std.mem.indexOfAny(u8, rest, " \t") orelse rest.len;
            current_ipv4 = rest[0..end];
        } else if (std.mem.startsWith(u8, trimmed, "ether ")) {
            const rest = trimmed[6..];
            const end = std.mem.indexOfAny(u8, rest, " \t") orelse rest.len;
            current_mac = rest[0..end];
        }
    }

    if (current_name) |name| {
        if (!std.mem.eql(u8, name, "lo0")) {
            try adapters.append(allocator, .{
                .name = try allocator.dupe(u8, name),
                .description = try allocator.dupe(u8, name),
                .ipv4 = try allocator.dupe(u8, current_ipv4),
                .mac = try allocator.dupe(u8, current_mac),
                .adapter_type = try allocator.dupe(u8, if (std.mem.startsWith(u8, name, "en")) "ethernet" else "network"),
                .dhcp_enabled = false,
            });
        }
    }
}

fn trimOwnedTrailingWhitespace(allocator: std.mem.Allocator, bytes: []u8) ![]const u8 {
    const trimmed = std.mem.trimRight(u8, bytes, " \t\r\n");
    if (trimmed.ptr == bytes.ptr and trimmed.len == bytes.len) return bytes;
    const out = try allocator.dupe(u8, trimmed);
    allocator.free(bytes);
    return out;
}

fn macResolveWindowTarget(allocator: std.mem.Allocator, handle: u64) !core.model.WindowInfo {
    if (handle == 0) return error.InvalidHandle;
    const keys = try macos.WindowKeys.init();
    defer keys.deinit();
    const target = (macos.locateWindowByHandle(allocator, keys, handle) catch return error.WindowLookupFailed) orelse return error.WindowNotFound;
    return target;
}

fn macRunAppleScript(allocator: std.mem.Allocator, script: []const u8, args: []const []const u8) !MacCommandResult {
    var argv = std.ArrayList([]const u8).empty;
    defer argv.deinit(allocator);
    try argv.append(allocator, "osascript");
    try argv.append(allocator, "-e");
    try argv.append(allocator, script);
    for (args) |arg| try argv.append(allocator, arg);
    return macRunCommand(allocator, argv.items, null);
}

fn macRunJavaScript(allocator: std.mem.Allocator, script: []const u8, args: []const []const u8) !MacCommandResult {
    var argv = std.ArrayList([]const u8).empty;
    defer argv.deinit(allocator);
    try argv.append(allocator, "osascript");
    try argv.append(allocator, "-l");
    try argv.append(allocator, "JavaScript");
    try argv.append(allocator, "-e");
    try argv.append(allocator, script);
    for (args) |arg| try argv.append(allocator, arg);
    return macRunCommand(allocator, argv.items, null);
}

fn macRunAppleScriptOrFailure(allocator: std.mem.Allocator, capability: []const u8, script: []const u8, args: []const []const u8) !void {
    const result = try macRunAppleScript(allocator, script, args);
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);
    if (result.missing or result.exit_code != 0) return error.AppleScriptFailed;
    _ = capability;
}

fn macAckResolutionFailure(allocator: std.mem.Allocator, capability: []const u8, handle: u64, err: anyerror) core.model.AckResponse {
    _ = allocator;
    _ = handle;
    return switch (err) {
        error.InvalidHandle => core.model.failure(core.model.Ack, capability, core.errors.codes.invalid_args, "Window operation requires a non-zero handle.", null),
        error.WindowNotFound => core.model.failure(core.model.Ack, capability, core.errors.codes.not_found, "The requested macOS window handle is no longer present in the CoreGraphics snapshot.", null),
        else => core.model.failure(core.model.Ack, capability, core.errors.codes.system_error, "Failed while resolving the requested macOS window handle.", @errorName(err)),
    };
}

fn macAckScriptFailure(capability: []const u8, err: anyerror) core.model.AckResponse {
    return switch (err) {
        error.AppleScriptFailed => core.model.failure(core.model.Ack, capability, core.errors.codes.permission_denied, "macOS automation command failed. Check Accessibility and Automation permissions for the host process.", null),
        else => core.model.failure(core.model.Ack, capability, core.errors.codes.system_error, "macOS automation command failed.", @errorName(err)),
    };
}

fn macAppleScriptKeyCommand(allocator: std.mem.Allocator, key: []const u8) ![]const u8 {
    if (key.len == 1) {
        return std.fmt.allocPrint(allocator, "tell application \"System Events\" to keystroke \"{s}\"", .{key});
    }
    const key_code = macKeyCode(key) orelse return error.UnsupportedKey;
    return std.fmt.allocPrint(allocator, "tell application \"System Events\" to key code {d}", .{key_code});
}

fn macAppleScriptHotkeyCommand(allocator: std.mem.Allocator, keys: []const u8) ![]const u8 {
    var tokens = std.mem.tokenizeScalar(u8, keys, '+');
    var parts = std.ArrayList([]const u8).empty;
    defer parts.deinit(allocator);
    while (tokens.next()) |token_raw| {
        const token = std.mem.trim(u8, token_raw, " \t");
        if (token.len == 0) continue;
        try parts.append(allocator, token);
    }
    if (parts.items.len == 0) return error.UnsupportedKey;
    const main_key = parts.items[parts.items.len - 1];
    var modifiers = std.ArrayList(u8).empty;
    defer modifiers.deinit(allocator);
    if (parts.items.len > 1) {
        try modifiers.appendSlice(allocator, " using {");
        for (parts.items[0 .. parts.items.len - 1], 0..) |modifier, index| {
            if (index > 0) try modifiers.appendSlice(allocator, ", ");
            try modifiers.appendSlice(allocator, macModifierName(modifier) orelse return error.UnsupportedKey);
        }
        try modifiers.append(allocator, '}');
    }
    if (main_key.len == 1) {
        return std.fmt.allocPrint(allocator, "tell application \"System Events\" to keystroke \"{s}\"{s}", .{ main_key, modifiers.items });
    }
    const key_code = macKeyCode(main_key) orelse return error.UnsupportedKey;
    return std.fmt.allocPrint(allocator, "tell application \"System Events\" to key code {d}{s}", .{ key_code, modifiers.items });
}

fn macModifierName(token: []const u8) ?[]const u8 {
    if (std.ascii.eqlIgnoreCase(token, "ctrl")) return "control down";
    if (std.ascii.eqlIgnoreCase(token, "shift")) return "shift down";
    if (std.ascii.eqlIgnoreCase(token, "alt")) return "option down";
    if (std.ascii.eqlIgnoreCase(token, "win") or std.ascii.eqlIgnoreCase(token, "cmd") or std.ascii.eqlIgnoreCase(token, "command")) return "command down";
    return null;
}

fn macKeyCode(token: []const u8) ?u16 {
    if (std.ascii.eqlIgnoreCase(token, "enter")) return 36;
    if (std.ascii.eqlIgnoreCase(token, "tab")) return 48;
    if (std.ascii.eqlIgnoreCase(token, "esc")) return 53;
    if (std.ascii.eqlIgnoreCase(token, "space")) return 49;
    if (std.ascii.eqlIgnoreCase(token, "delete") or std.ascii.eqlIgnoreCase(token, "backspace")) return 51;
    if (std.ascii.eqlIgnoreCase(token, "forward-delete")) return 117;
    if (std.ascii.eqlIgnoreCase(token, "left")) return 123;
    if (std.ascii.eqlIgnoreCase(token, "right")) return 124;
    if (std.ascii.eqlIgnoreCase(token, "down")) return 125;
    if (std.ascii.eqlIgnoreCase(token, "up")) return 126;
    if (std.ascii.eqlIgnoreCase(token, "home")) return 115;
    if (std.ascii.eqlIgnoreCase(token, "end")) return 119;
    if (std.ascii.eqlIgnoreCase(token, "pageup")) return 116;
    if (std.ascii.eqlIgnoreCase(token, "pagedown")) return 121;
    if (std.ascii.eqlIgnoreCase(token, "f1")) return 122;
    if (std.ascii.eqlIgnoreCase(token, "f2")) return 120;
    if (std.ascii.eqlIgnoreCase(token, "f3")) return 99;
    if (std.ascii.eqlIgnoreCase(token, "f4")) return 118;
    if (std.ascii.eqlIgnoreCase(token, "f5")) return 96;
    if (std.ascii.eqlIgnoreCase(token, "f6")) return 97;
    if (std.ascii.eqlIgnoreCase(token, "f7")) return 98;
    if (std.ascii.eqlIgnoreCase(token, "f8")) return 100;
    if (std.ascii.eqlIgnoreCase(token, "f9")) return 101;
    if (std.ascii.eqlIgnoreCase(token, "f10")) return 109;
    if (std.ascii.eqlIgnoreCase(token, "f11")) return 103;
    if (std.ascii.eqlIgnoreCase(token, "f12")) return 111;
    return null;
}

const macWindowScriptShow =
    "on run argv\n" ++
    "set targetPid to item 1 of argv as integer\n" ++
    "set targetTitle to item 2 of argv\n" ++
    "tell application \"System Events\"\n" ++
    "set targetProc to first application process whose unix id is targetPid\n" ++
    "tell targetProc\n" ++
    "set frontmost to true\n" ++
    "set targetWindow to first window whose name is targetTitle\n" ++
    "set value of attribute \"AXMinimized\" of targetWindow to false\n" ++
    "perform action \"AXRaise\" of targetWindow\n" ++
    "end tell\n" ++
    "end tell\n" ++
    "end run";

const macWindowScriptMinimize =
    "on run argv\n" ++
    "set targetPid to item 1 of argv as integer\n" ++
    "set targetTitle to item 2 of argv\n" ++
    "tell application \"System Events\"\n" ++
    "tell (first application process whose unix id is targetPid)\n" ++
    "set value of attribute \"AXMinimized\" of (first window whose name is targetTitle) to true\n" ++
    "end tell\n" ++
    "end tell\n" ++
    "end run";

const macWindowScriptMaximize =
    "on run argv\n" ++
    "set targetPid to item 1 of argv as integer\n" ++
    "set targetTitle to item 2 of argv\n" ++
    "tell application \"System Events\"\n" ++
    "tell (first application process whose unix id is targetPid)\n" ++
    "set value of attribute \"AXZoomed\" of (first window whose name is targetTitle) to true\n" ++
    "end tell\n" ++
    "end tell\n" ++
    "end run";

const macWindowScriptRestore =
    "on run argv\n" ++
    "set targetPid to item 1 of argv as integer\n" ++
    "set targetTitle to item 2 of argv\n" ++
    "tell application \"System Events\"\n" ++
    "tell (first application process whose unix id is targetPid)\n" ++
    "set targetWindow to first window whose name is targetTitle\n" ++
    "set value of attribute \"AXMinimized\" of targetWindow to false\n" ++
    "set value of attribute \"AXZoomed\" of targetWindow to false\n" ++
    "perform action \"AXRaise\" of targetWindow\n" ++
    "end tell\n" ++
    "end tell\n" ++
    "end run";

const macWindowScriptMove =
    "on run argv\n" ++
    "set targetPid to item 1 of argv as integer\n" ++
    "set targetTitle to item 2 of argv\n" ++
    "set targetX to item 3 of argv as integer\n" ++
    "set targetY to item 4 of argv as integer\n" ++
    "set targetWidth to item 5 of argv as integer\n" ++
    "set targetHeight to item 6 of argv as integer\n" ++
    "tell application \"System Events\"\n" ++
    "tell (first application process whose unix id is targetPid)\n" ++
    "set targetWindow to first window whose name is targetTitle\n" ++
    "set position of targetWindow to {targetX, targetY}\n" ++
    "set size of targetWindow to {targetWidth, targetHeight}\n" ++
    "end tell\n" ++
    "end tell\n" ++
    "end run";

const macWindowScriptClose =
    "on run argv\n" ++
    "set targetPid to item 1 of argv as integer\n" ++
    "set targetTitle to item 2 of argv\n" ++
    "tell application \"System Events\"\n" ++
    "tell (first application process whose unix id is targetPid)\n" ++
    "set targetWindow to first window whose name is targetTitle\n" ++
    "perform action \"AXClose\" of targetWindow\n" ++
    "end tell\n" ++
    "end tell\n" ++
    "end run";

const macClipboardGetFilesScript =
    "on run argv\n" ++
    "try\n" ++
    "set fileAliases to the clipboard as alias list\n" ++
    "set outText to \"\"\n" ++
    "repeat with itemAlias in fileAliases\n" ++
    "set outText to outText & POSIX path of itemAlias & linefeed\n" ++
    "end repeat\n" ++
    "return outText\n" ++
    "on error\n" ++
    "return \"\"\n" ++
    "end try\n" ++
    "end run";

const macClipboardSetFilesScript =
    "on run argv\n" ++
    "set aliasList to {}\n" ++
    "repeat with itemPath in argv\n" ++
    "set end of aliasList to POSIX file itemPath\n" ++
    "end repeat\n" ++
    "set the clipboard to aliasList\n" ++
    "return \"ok\"\n" ++
    "end run";

const macClipboardSetImageScript =
    "function run(argv) {\n" ++
    "ObjC.import('AppKit');\n" ++
    "var path = argv[0];\n" ++
    "var image = $.NSImage.alloc.initWithContentsOfFile($(path));\n" ++
    "if (!image) throw new Error('Unable to load image file');\n" ++
    "var pb = $.NSPasteboard.generalPasteboard;\n" ++
    "pb.clearContents;\n" ++
    "if (!pb.writeObjects($([image]))) throw new Error('NSPasteboard.writeObjects failed');\n" ++
    "return 'ok';\n" ++
    "}";

const macKeyboardTypeTextScript =
    "on run argv\n" ++
    "tell application \"System Events\" to keystroke (item 1 of argv)\n" ++
    "end run";

const macKeyboardTypeKeysScript =
    "on run argv\n" ++
    "set typedText to item 1 of argv\n" ++
    "set delayMs to item 2 of argv as integer\n" ++
    "set delaySeconds to delayMs / 1000\n" ++
    "tell application \"System Events\"\n" ++
    "repeat with charIndex from 1 to count characters of typedText\n" ++
    "keystroke character charIndex of typedText\n" ++
    "if delayMs > 0 then delay delaySeconds\n" ++
    "end repeat\n" ++
    "end tell\n" ++
    "end run";
