const std = @import("std");
const builtin = @import("builtin");
const core = @import("easytouch_core");

const x11 = if (builtin.os.tag == .linux) struct {
    const Bool = c_int;
    const Atom = c_ulong;
    const Window = c_ulong;
    const Drawable = c_ulong;
    const Time = c_ulong;
    const XYPixmap: c_int = 1;
    const ZPixmap: c_int = 2;
    const AllPlanes: c_ulong = ~@as(c_ulong, 0);
    const Display = opaque {};
    const Visual = opaque {};
    const Screen = opaque {};

    const False: Bool = 0;
    const True: Bool = 1;
    const Success: c_int = 0;
    const ClientMessage: c_int = 33;
    const IsViewable: c_int = 2;
    const CurrentTime: Time = 0;
    const RevertToParent: c_int = 2;
    const AnyPropertyType: Atom = 0;
    const SubstructureNotifyMask: c_long = 1 << 19;
    const SubstructureRedirectMask: c_long = 1 << 20;

    const atom_net_active_window: [:0]const u8 = "_NET_ACTIVE_WINDOW";
    const atom_net_client_list: [:0]const u8 = "_NET_CLIENT_LIST";
    const atom_net_client_list_stacking: [:0]const u8 = "_NET_CLIENT_LIST_STACKING";
    const atom_net_wm_name: [:0]const u8 = "_NET_WM_NAME";
    const atom_net_wm_pid: [:0]const u8 = "_NET_WM_PID";
    const atom_net_close_window: [:0]const u8 = "_NET_CLOSE_WINDOW";

    const XWindowAttributes = extern struct {
        x: c_int,
        y: c_int,
        width: c_int,
        height: c_int,
        border_width: c_int,
        depth: c_int,
        visual: ?*Visual,
        root: Window,
        class: c_int,
        bit_gravity: c_int,
        win_gravity: c_int,
        backing_store: c_int,
        backing_planes: c_ulong,
        backing_pixel: c_ulong,
        save_under: Bool,
        colormap: c_ulong,
        map_installed: Bool,
        map_state: c_int,
        all_event_masks: c_long,
        your_event_mask: c_long,
        do_not_propagate_mask: c_long,
        override_redirect: Bool,
        screen: ?*Screen,
    };

    const XClassHint = extern struct {
        res_name: ?[*:0]u8,
        res_class: ?[*:0]u8,
    };

    const XImage = extern struct {
        width: c_int,
        height: c_int,
        xoffset: c_int,
        format: c_int,
        data: ?[*]u8,
        byte_order: c_int,
        bitmap_unit: c_int,
        bitmap_bit_order: c_int,
        bitmap_pad: c_int,
        depth: c_int,
        bytes_per_line: c_int,
        bits_per_pixel: c_int,
        red_mask: c_ulong,
        green_mask: c_ulong,
        blue_mask: c_ulong,
    };

    const XClientMessageData = extern union {
        b: [20]u8,
        s: [10]i16,
        l: [5]c_long,
    };

    const XClientMessageEvent = extern struct {
        type: c_int,
        serial: c_ulong,
        send_event: Bool,
        display: ?*Display,
        window: Window,
        message_type: Atom,
        format: c_int,
        data: XClientMessageData,
    };

    const XEvent = extern union {
        xclient: XClientMessageEvent,
        pad: [24]c_long,
    };

    extern "X11" fn XOpenDisplay(display_name: ?[*:0]const u8) ?*Display;
    extern "X11" fn XCloseDisplay(display: *Display) c_int;
    extern "X11" fn XDefaultRootWindow(display: *Display) Window;
    extern "X11" fn XInternAtom(display: *Display, atom_name: [*:0]const u8, only_if_exists: Bool) Atom;
    extern "X11" fn XGetWindowProperty(
        display: *Display,
        window: Window,
        property: Atom,
        long_offset: c_long,
        long_length: c_long,
        delete: Bool,
        req_type: Atom,
        actual_type_return: *Atom,
        actual_format_return: *c_int,
        nitems_return: *c_ulong,
        bytes_after_return: *c_ulong,
        prop_return: *?[*]u8,
    ) c_int;
    extern "X11" fn XFree(data: ?*anyopaque) c_int;
    extern "X11" fn XFetchName(display: *Display, window: Window, window_name_return: *?[*:0]u8) c_int;
    extern "X11" fn XGetClassHint(display: *Display, window: Window, class_hints_return: *XClassHint) c_int;
    extern "X11" fn XGetWindowAttributes(display: *Display, window: Window, window_attributes_return: *XWindowAttributes) c_int;
    extern "X11" fn XTranslateCoordinates(display: *Display, src_window: Window, dest_window: Window, src_x: c_int, src_y: c_int, dest_x_return: *c_int, dest_y_return: *c_int, child_return: *Window) Bool;
    extern "X11" fn XGetInputFocus(display: *Display, focus_return: *Window, revert_to_return: *c_int) c_int;
    extern "X11" fn XGetImage(display: *Display, d: Drawable, x: c_int, y: c_int, width: c_uint, height: c_uint, plane_mask: c_ulong, format: c_int) ?*XImage;
    extern "X11" fn XGetPixel(ximage: *XImage, x: c_int, y: c_int) c_ulong;
    extern "X11" fn XDestroyImage(ximage: *XImage) c_int;
    extern "X11" fn XMapRaised(display: *Display, window: Window) c_int;
    extern "X11" fn XRaiseWindow(display: *Display, window: Window) c_int;
    extern "X11" fn XSetInputFocus(display: *Display, focus: Window, revert_to: c_int, time: Time) c_int;
    extern "X11" fn XSendEvent(display: *Display, window: Window, propagate: Bool, event_mask: c_long, event_send: *XEvent) c_int;
    extern "X11" fn XFlush(display: *Display) c_int;
    extern "X11" fn XSync(display: *Display, discard: Bool) c_int;

    fn internAtom(display: *Display, name: [:0]const u8) Atom {
        return XInternAtom(display, name.ptr, False);
    }

    fn systemFailure(comptime T: type, allocator: std.mem.Allocator, capability: []const u8, message: []const u8, err: anyerror) core.model.Envelope(T) {
        const detail = std.fmt.allocPrint(allocator, "linux_x11_error={s}", .{@errorName(err)}) catch @errorName(err);
        return core.model.failure(T, capability, core.errors.codes.system_error, message, detail);
    }

    fn openDisplay() ?*Display {
        return XOpenDisplay(null);
    }

    fn getWindowIds(allocator: std.mem.Allocator, display: *Display, root: Window) ![]Window {
        if (try readWindowArrayProperty(allocator, display, root, atom_net_client_list_stacking)) |windows| {
            return windows;
        }
        if (try readWindowArrayProperty(allocator, display, root, atom_net_client_list)) |windows| {
            return windows;
        }
        return allocator.alloc(Window, 0);
    }

    fn readWindowArrayProperty(allocator: std.mem.Allocator, display: *Display, window: Window, property_name: [:0]const u8) !?[]Window {
        const property = internAtom(display, property_name);
        if (property == 0) return null;

        var actual_type: Atom = 0;
        var actual_format: c_int = 0;
        var nitems: c_ulong = 0;
        var bytes_after: c_ulong = 0;
        var raw: ?[*]u8 = null;

        const status = XGetWindowProperty(display, window, property, 0, 4096, False, AnyPropertyType, &actual_type, &actual_format, &nitems, &bytes_after, &raw);
        if (status != Success) return error.PropertyReadFailed;
        if (raw == null or actual_format != 32 or nitems == 0) return null;
        defer _ = XFree(raw);

        const values = @as([*]const c_long, @ptrCast(@alignCast(raw.?)));
        const count = @as(usize, @intCast(nitems));
        var windows = try allocator.alloc(Window, count);
        for (0..count) |index| {
            windows[index] = @as(Window, @intCast(values[index]));
        }
        return windows;
    }

    fn readUtf8Property(allocator: std.mem.Allocator, display: *Display, window: Window, property_name: [:0]const u8) !?[]const u8 {
        const property = internAtom(display, property_name);
        if (property == 0) return null;

        var actual_type: Atom = 0;
        var actual_format: c_int = 0;
        var nitems: c_ulong = 0;
        var bytes_after: c_ulong = 0;
        var raw: ?[*]u8 = null;

        const status = XGetWindowProperty(display, window, property, 0, 1024, False, AnyPropertyType, &actual_type, &actual_format, &nitems, &bytes_after, &raw);
        if (status != Success) return error.PropertyReadFailed;
        if (raw == null or actual_format != 8 or nitems == 0) return null;
        defer _ = XFree(raw);

        return try allocator.dupe(u8, raw.?[0..@as(usize, @intCast(nitems))]);
    }

    fn getWindowTitle(allocator: std.mem.Allocator, display: *Display, window: Window) ![]const u8 {
        if (try readUtf8Property(allocator, display, window, atom_net_wm_name)) |value| {
            return value;
        }

        var raw_name: ?[*:0]u8 = null;
        if (XFetchName(display, window, &raw_name) != 0 and raw_name != null) {
            defer _ = XFree(raw_name);
            return try allocator.dupe(u8, std.mem.sliceTo(raw_name.?, 0));
        }

        return "";
    }

    fn getWindowClass(allocator: std.mem.Allocator, display: *Display, window: Window) ![]const u8 {
        var hint = std.mem.zeroes(XClassHint);
        if (XGetClassHint(display, window, &hint) == 0) {
            return "X11Window";
        }
        defer {
            if (hint.res_name) |value| _ = XFree(value);
            if (hint.res_class) |value| _ = XFree(value);
        }

        if (hint.res_class) |value| {
            return try allocator.dupe(u8, std.mem.sliceTo(value, 0));
        }
        if (hint.res_name) |value| {
            return try allocator.dupe(u8, std.mem.sliceTo(value, 0));
        }
        return "X11Window";
    }

    fn getWindowPid(display: *Display, window: Window) !u32 {
        const property = internAtom(display, atom_net_wm_pid);
        if (property == 0) return 0;

        var actual_type: Atom = 0;
        var actual_format: c_int = 0;
        var nitems: c_ulong = 0;
        var bytes_after: c_ulong = 0;
        var raw: ?[*]u8 = null;

        const status = XGetWindowProperty(display, window, property, 0, 1, False, AnyPropertyType, &actual_type, &actual_format, &nitems, &bytes_after, &raw);
        if (status != Success) return error.PropertyReadFailed;
        if (raw == null or actual_format != 32 or nitems == 0) return 0;
        defer _ = XFree(raw);

        const values = @as([*]const c_long, @ptrCast(@alignCast(raw.?)));
        return @as(u32, @intCast(values[0]));
    }

    fn getForegroundWindowId(display: *Display, root: Window) !Window {
        if (try readSingleWindowProperty(display, root, atom_net_active_window)) |window| {
            return window;
        }

        var focused: Window = 0;
        var revert_to: c_int = 0;
        _ = XGetInputFocus(display, &focused, &revert_to);
        return focused;
    }

    fn readSingleWindowProperty(display: *Display, window: Window, property_name: [:0]const u8) !?Window {
        const property = internAtom(display, property_name);
        if (property == 0) return null;

        var actual_type: Atom = 0;
        var actual_format: c_int = 0;
        var nitems: c_ulong = 0;
        var bytes_after: c_ulong = 0;
        var raw: ?[*]u8 = null;

        const status = XGetWindowProperty(display, window, property, 0, 1, False, AnyPropertyType, &actual_type, &actual_format, &nitems, &bytes_after, &raw);
        if (status != Success) return error.PropertyReadFailed;
        if (raw == null or actual_format != 32 or nitems == 0) return null;
        defer _ = XFree(raw);

        const values = @as([*]const c_long, @ptrCast(@alignCast(raw.?)));
        return @as(Window, @intCast(values[0]));
    }

    fn buildWindowInfo(allocator: std.mem.Allocator, display: *Display, root: Window, window: Window, foreground: Window, include_hidden: bool) !?core.model.WindowInfo {
        var attrs: XWindowAttributes = undefined;
        if (XGetWindowAttributes(display, window, &attrs) == 0) {
            return null;
        }

        const visible = attrs.map_state == IsViewable;
        if (!include_hidden and !visible) {
            return null;
        }

        var translated_x: c_int = attrs.x;
        var translated_y: c_int = attrs.y;
        var child: Window = 0;
        _ = XTranslateCoordinates(display, window, root, 0, 0, &translated_x, &translated_y, &child);

        const title = try getWindowTitle(allocator, display, window);
        const class_name = try getWindowClass(allocator, display, window);
        const pid = try getWindowPid(display, window);

        return core.model.WindowInfo{
            .handle = @as(u64, @intCast(window)),
            .pid = pid,
            .title = title,
            .class_name = class_name,
            .visible = visible,
            .is_foreground = window == foreground,
            .bounds = .{
                .left = translated_x,
                .top = translated_y,
                .right = translated_x + attrs.width,
                .bottom = translated_y + attrs.height,
                .width = attrs.width,
                .height = attrs.height,
            },
        };
    }

    fn activateWindow(display: *Display, root: Window, window: Window) void {
        _ = XMapRaised(display, window);
        _ = XRaiseWindow(display, window);

        const active_atom = internAtom(display, atom_net_active_window);
        if (active_atom != 0) {
            var event = std.mem.zeroes(XEvent);
            event.xclient.type = ClientMessage;
            event.xclient.window = window;
            event.xclient.message_type = active_atom;
            event.xclient.format = 32;
            event.xclient.data.l[0] = 2;
            event.xclient.data.l[1] = @as(c_long, @intCast(CurrentTime));
            event.xclient.data.l[2] = 0;
            event.xclient.data.l[3] = 0;
            event.xclient.data.l[4] = 0;
            _ = XSendEvent(display, root, False, SubstructureRedirectMask | SubstructureNotifyMask, &event);
        }

        _ = XSetInputFocus(display, window, RevertToParent, CurrentTime);
        _ = XFlush(display);
        _ = XSync(display, False);
        std.Thread.sleep(150 * std.time.ns_per_ms);
    }

    pub fn windowList(allocator: std.mem.Allocator, include_hidden: bool) !core.model.WindowListResponse {
        const display = openDisplay() orelse {
            return core.model.failure(core.model.WindowList, "window.list", core.errors.codes.system_error, "XOpenDisplay failed while opening the X11 session.", "Ensure DISPLAY points at an X11 desktop session.");
        };
        defer _ = XCloseDisplay(display);

        const root = XDefaultRootWindow(display);
        const foreground = getForegroundWindowId(display, root) catch |err| {
            return systemFailure(core.model.WindowList, allocator, "window.list", "Failed to inspect the active X11 window.", err);
        };
        const window_ids = getWindowIds(allocator, display, root) catch |err| {
            return systemFailure(core.model.WindowList, allocator, "window.list", "Failed to enumerate X11 top-level windows.", err);
        };
        defer allocator.free(window_ids);

        var windows = std.ArrayListUnmanaged(core.model.WindowInfo).empty;
        defer windows.deinit(allocator);

        for (window_ids) |window| {
            const maybe_info = buildWindowInfo(allocator, display, root, window, foreground, include_hidden) catch |err| {
                return systemFailure(core.model.WindowList, allocator, "window.list", "Failed while reading X11 window metadata.", err);
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
        const display = openDisplay() orelse {
            return core.model.failure(core.model.ForegroundWindow, "window.foreground", core.errors.codes.system_error, "XOpenDisplay failed while opening the X11 session.", "Ensure DISPLAY points at an X11 desktop session.");
        };
        defer _ = XCloseDisplay(display);

        const root = XDefaultRootWindow(display);
        const foreground = getForegroundWindowId(display, root) catch |err| {
            return systemFailure(core.model.ForegroundWindow, allocator, "window.foreground", "Failed to inspect the active X11 window.", err);
        };

        if (foreground == 0) {
            return core.model.success("window.foreground", core.model.ForegroundWindow{
                .found = false,
                .window = null,
            });
        }

        const info = (buildWindowInfo(allocator, display, root, foreground, foreground, true) catch |err| {
            return systemFailure(core.model.ForegroundWindow, allocator, "window.foreground", "Failed while reading the active X11 window metadata.", err);
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

        const display = openDisplay() orelse {
            return core.model.failure(core.model.Ack, "window.activate", core.errors.codes.system_error, "XOpenDisplay failed while opening the X11 session.", "Ensure DISPLAY points at an X11 desktop session.");
        };
        defer _ = XCloseDisplay(display);

        const root = XDefaultRootWindow(display);
        const window = @as(Window, @intCast(handle));

        var attrs: XWindowAttributes = undefined;
        if (XGetWindowAttributes(display, window, &attrs) == 0) {
            return core.model.failure(core.model.Ack, "window.activate", core.errors.codes.not_found, "The requested X11 window handle is no longer valid.", try std.fmt.allocPrint(allocator, "target_handle=0x{x}", .{handle}));
        }

        activateWindow(display, root, window);

        const foreground = getForegroundWindowId(display, root) catch |err| {
            return systemFailure(core.model.Ack, allocator, "window.activate", "The X11 activation request was sent, but foreground verification failed.", err);
        };
        if (foreground != window) {
            return core.model.failure(core.model.Ack, "window.activate", core.errors.codes.system_error, "The requested X11 window did not become the active window.", try std.fmt.allocPrint(allocator, "target_handle=0x{x}; actual_foreground_handle=0x{x}", .{ handle, @as(u64, @intCast(foreground)) }));
        }

        const title = getWindowTitle(allocator, display, window) catch |err| {
            return systemFailure(core.model.Ack, allocator, "window.activate", "The X11 window was activated, but reading its title failed.", err);
        };
        return core.model.success("window.activate", core.model.Ack{
            .message = "X11 window activated.",
            .detail = try std.fmt.allocPrint(allocator, "target_handle=0x{x}; title={s}", .{ handle, title }),
        });
    }

    pub fn windowClose(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
        if (handle == 0) {
            return core.model.failure(core.model.Ack, "window.close", core.errors.codes.invalid_args, "Window close requires a non-zero handle.", null);
        }

        const display = openDisplay() orelse {
            return core.model.failure(core.model.Ack, "window.close", core.errors.codes.system_error, "XOpenDisplay failed while opening the X11 session.", "Ensure DISPLAY points at an X11 desktop session.");
        };
        defer _ = XCloseDisplay(display);

        const root = XDefaultRootWindow(display);
        const window = @as(Window, @intCast(handle));

        var attrs: XWindowAttributes = undefined;
        if (XGetWindowAttributes(display, window, &attrs) == 0) {
            return core.model.failure(core.model.Ack, "window.close", core.errors.codes.not_found, "The requested X11 window handle is no longer valid.", try std.fmt.allocPrint(allocator, "target_handle=0x{x}", .{handle}));
        }

        const close_atom = internAtom(display, atom_net_close_window);
        if (close_atom == 0) {
            return core.model.failure(core.model.Ack, "window.close", core.errors.codes.system_error, "X11 window manager does not expose _NET_CLOSE_WINDOW.", null);
        }

        var event = std.mem.zeroes(XEvent);
        event.xclient.type = ClientMessage;
        event.xclient.window = window;
        event.xclient.message_type = close_atom;
        event.xclient.format = 32;
        event.xclient.data.l[0] = @as(c_long, @intCast(CurrentTime));
        event.xclient.data.l[1] = 2;
        event.xclient.data.l[2] = 0;
        event.xclient.data.l[3] = 0;
        event.xclient.data.l[4] = 0;

        if (XSendEvent(display, root, False, SubstructureRedirectMask | SubstructureNotifyMask, &event) == 0) {
            return core.model.failure(core.model.Ack, "window.close", core.errors.codes.system_error, "XSendEvent(_NET_CLOSE_WINDOW) failed.", null);
        }

        _ = XFlush(display);
        _ = XSync(display, False);

        return core.model.success("window.close", core.model.Ack{
            .message = "X11 window close requested.",
            .detail = try std.fmt.allocPrint(allocator, "target_handle=0x{x}", .{handle}),
        });
    }

    pub fn screenPixelColor(allocator: std.mem.Allocator, x: i32, y: i32) !core.model.PixelColorResponse {
        const display = openDisplay() orelse {
            return core.model.failure(core.model.PixelColor, "screen.pixel_color", core.errors.codes.system_error, "XOpenDisplay failed while opening the X11 session.", "Ensure DISPLAY points at an X11 desktop session.");
        };
        defer _ = XCloseDisplay(display);

        const root = XDefaultRootWindow(display);
        const image = XGetImage(display, root, x, y, 1, 1, AllPlanes, ZPixmap) orelse {
            return core.model.failure(core.model.PixelColor, "screen.pixel_color", core.errors.codes.not_found, "The requested pixel is outside the readable root window region.", try std.fmt.allocPrint(allocator, "x={d}; y={d}", .{ x, y }));
        };
        defer _ = XDestroyImage(image);

        const raw = XGetPixel(image, 0, 0);
        const r = channelFromMask(raw, image.red_mask);
        const g = channelFromMask(raw, image.green_mask);
        const b = channelFromMask(raw, image.blue_mask);
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

    fn channelFromMask(pixel: c_ulong, mask: c_ulong) u8 {
        if (mask == 0) return 0;

        const shift: u6 = @intCast(@ctz(mask));
        const max = mask >> shift;
        if (max == 0) return 0;

        const raw = (pixel & mask) >> shift;
        const scaled = (raw * 255) / max;
        return @as(u8, @intCast(scaled));
    }
} else struct {};

pub fn systemOsInfo(allocator: std.mem.Allocator) !core.model.OsInfoResponse {
    const machine_name = linuxHostName(allocator) catch try allocator.dupe(u8, "linux-host");
    const version = linuxKernelVersion(allocator) catch try allocator.dupe(u8, "linux");
    return core.model.success("system.os_info", core.model.OsInfo{
        .platform = "linux",
        .arch = @tagName(builtin.cpu.arch),
        .version = version,
        .build = 0,
        .machine_name = machine_name,
        .runtime = "linux command-backed",
    });
}

pub fn systemCpuInfo(allocator: std.mem.Allocator) !core.model.CpuInfoResponse {
    const logical_cores = linuxLogicalCoreCount(allocator) catch |err| {
        return core.model.failure(core.model.CpuInfo, "system.cpu_info", core.errors.codes.system_error, "Failed to determine Linux logical CPU count.", @errorName(err));
    };
    const page_size = linuxPageSize(allocator) catch |err| {
        return core.model.failure(core.model.CpuInfo, "system.cpu_info", core.errors.codes.system_error, "Failed to determine Linux page size.", @errorName(err));
    };

    return core.model.success("system.cpu_info", core.model.CpuInfo{
        .architecture = @tagName(builtin.cpu.arch),
        .logical_cores = logical_cores,
        .page_size = page_size,
    });
}

pub fn systemMemoryInfo(allocator: std.mem.Allocator) !core.model.MemoryInfoResponse {
    const mem = linuxMemorySnapshot(allocator) catch |err| {
        return core.model.failure(core.model.MemoryInfo, "system.memory_info", core.errors.codes.system_error, "Failed to read Linux memory info.", @errorName(err));
    };

    return core.model.success("system.memory_info", core.model.MemoryInfo{
        .total_physical = mem.total_physical,
        .available_physical = mem.available_physical,
        .used_physical = mem.used_physical,
        .memory_load_percent = mem.memory_load_percent,
    });
}

pub fn systemDiskList(allocator: std.mem.Allocator) !core.model.DiskListResponse {
    const result = linuxRunCommand(allocator, &[_][]const u8{ "df", "-B1", "-P" }, null) catch |err| {
        return core.model.failure(core.model.DiskList, "system.disk_list", core.errors.codes.system_error, "Failed to run df for Linux disk listing.", @errorName(err));
    };
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    if (result.missing or result.exit_code != 0) {
        return core.model.failure(core.model.DiskList, "system.disk_list", core.errors.codes.system_error, "df failed while listing Linux disks.", linuxCommandDetail(allocator, result) catch null);
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
        const total_bytes_text = tokens.next() orelse continue;
        _ = tokens.next() orelse continue;
        const free_bytes_text = tokens.next() orelse continue;
        _ = tokens.next() orelse continue;
        const mount = tokens.next() orelse continue;

        const total_bytes = std.fmt.parseInt(u64, total_bytes_text, 10) catch continue;
        const free_bytes = std.fmt.parseInt(u64, free_bytes_text, 10) catch continue;

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
    const result = linuxRunCommand(allocator, &[_][]const u8{ "ps", "-e", "-o", "pid=,comm=" }, null) catch |err| {
        return core.model.failure(core.model.ProcessList, "system.process_list", core.errors.codes.system_error, "Failed to run ps for Linux process listing.", @errorName(err));
    };
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    if (result.missing or result.exit_code != 0) {
        return core.model.failure(core.model.ProcessList, "system.process_list", core.errors.codes.system_error, "ps failed while listing Linux processes.", linuxCommandDetail(allocator, result) catch null);
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
    const host = linuxHostName(allocator) catch try allocator.dupe(u8, "linux-host");

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
    const link_result = linuxRunCommand(allocator, &[_][]const u8{ "ip", "-o", "link", "show" }, null) catch |err| {
        return core.model.failure(core.model.NetworkInfo, "system.network_info", core.errors.codes.system_error, "Failed to run ip link on Linux.", @errorName(err));
    };
    defer allocator.free(link_result.stdout);
    defer allocator.free(link_result.stderr);

    if (link_result.missing or link_result.exit_code != 0) {
        return core.model.failure(core.model.NetworkInfo, "system.network_info", core.errors.codes.not_implemented, "Linux network info requires the ip command.", linuxCommandDetail(allocator, link_result) catch null);
    }

    const addr_result = linuxRunCommand(allocator, &[_][]const u8{ "ip", "-o", "-4", "addr", "show" }, null) catch |err| {
        return core.model.failure(core.model.NetworkInfo, "system.network_info", core.errors.codes.system_error, "Failed to run ip addr on Linux.", @errorName(err));
    };
    defer allocator.free(addr_result.stdout);
    defer allocator.free(addr_result.stderr);

    var adapters = std.ArrayList(core.model.NetworkAdapter).empty;
    defer adapters.deinit(allocator);

    var lines = std.mem.splitScalar(u8, link_result.stdout, '\n');
    while (lines.next()) |line_raw| {
        const line = std.mem.trim(u8, line_raw, " \t\r");
        if (line.len == 0) continue;

        const first_colon = std.mem.indexOfScalar(u8, line, ':') orelse continue;
        const second_colon_rel = std.mem.indexOfScalar(u8, line[first_colon + 1 ..], ':') orelse continue;
        const second_colon = first_colon + 1 + second_colon_rel;
        const name = std.mem.trim(u8, line[first_colon + 1 .. second_colon], " \t");
        if (std.mem.eql(u8, name, "lo")) continue;

        const mac = linuxParseLinkMac(line) orelse "";
        const ipv4 = linuxFindInterfaceIpv4(addr_result.stdout, name) orelse "";

        try adapters.append(allocator, .{
            .name = try allocator.dupe(u8, name),
            .description = try allocator.dupe(u8, name),
            .ipv4 = try allocator.dupe(u8, ipv4),
            .mac = try allocator.dupe(u8, mac),
            .adapter_type = try allocator.dupe(u8, if (std.mem.startsWith(u8, line, "wl") or std.mem.indexOf(u8, name, "wl") != null) "wireless" else "ethernet"),
            .dhcp_enabled = false,
        });
    }

    const owned = try adapters.toOwnedSlice(allocator);
    return core.model.success("system.network_info", core.model.NetworkInfo{ .count = owned.len, .adapters = owned });
}

pub fn mousePosition(allocator: std.mem.Allocator) !core.model.PointResponse {
    const result = linuxRunCommand(allocator, &[_][]const u8{ "xdotool", "getmouselocation", "--shell" }, null) catch |err| {
        return core.model.failure(core.model.Point, "mouse.position", core.errors.codes.system_error, "Failed to spawn xdotool for Linux mouse position.", @errorName(err));
    };
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    if (result.missing) {
        return core.model.failure(core.model.Point, "mouse.position", core.errors.codes.not_implemented, "Linux mouse automation requires xdotool on an X11/XWayland session.", "Install xdotool and ensure a desktop session is active.");
    }
    if (result.exit_code != 0) {
        return core.model.failure(core.model.Point, "mouse.position", core.errors.codes.system_error, "xdotool failed while reading mouse position.", linuxCommandDetail(allocator, result) catch null);
    }

    const x = linuxParseShellKeyInt(result.stdout, "X") orelse {
        return core.model.failure(core.model.Point, "mouse.position", core.errors.codes.system_error, "xdotool output did not include X coordinate.", null);
    };
    const y = linuxParseShellKeyInt(result.stdout, "Y") orelse {
        return core.model.failure(core.model.Point, "mouse.position", core.errors.codes.system_error, "xdotool output did not include Y coordinate.", null);
    };

    return core.model.success("mouse.position", core.model.Point{ .x = x, .y = y });
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

        linuxMoveMouseAbsolute(allocator, move_x, move_y) catch |err| {
            return linuxAckToolFailure(allocator, "mouse.move", "Linux mouse automation requires xdotool on an X11/XWayland session.", err);
        };
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

    const button_id = switch (button) {
        .left => "1",
        .middle => "2",
        .right => "3",
    };
    const repeat = try std.fmt.allocPrint(allocator, "{d}", .{count});
    defer allocator.free(repeat);

    linuxRunWindowTool(allocator, &[_][]const u8{ "xdotool", "click", "--repeat", repeat, button_id }, "mouse.click", "Linux mouse automation requires xdotool on an X11/XWayland session.") catch |err| {
        return linuxAckToolFailure(allocator, "mouse.click", "Linux mouse automation requires xdotool on an X11/XWayland session.", err);
    };

    return core.model.success("mouse.click", core.model.Ack{ .message = "Mouse click sent.", .detail = try std.fmt.allocPrint(allocator, "button={s}; count={d}", .{ @tagName(button), count }) });
}

pub fn mouseScroll(allocator: std.mem.Allocator, delta: i32) !core.model.AckResponse {
    if (delta == 0) {
        return core.model.failure(core.model.Ack, "mouse.scroll", core.errors.codes.invalid_args, "delta must be non-zero.", null);
    }

    const button_id = if (delta > 0) "4" else "5";
    const repeat_count = @max(@as(i32, 1), @divTrunc(if (delta >= 0) delta else -delta, 120));
    const repeat = try std.fmt.allocPrint(allocator, "{d}", .{repeat_count});
    defer allocator.free(repeat);

    linuxRunWindowTool(allocator, &[_][]const u8{ "xdotool", "click", "--repeat", repeat, button_id }, "mouse.scroll", "Linux mouse automation requires xdotool on an X11/XWayland session.") catch |err| {
        return linuxAckToolFailure(allocator, "mouse.scroll", "Linux mouse automation requires xdotool on an X11/XWayland session.", err);
    };

    return core.model.success("mouse.scroll", core.model.Ack{ .message = "Mouse wheel event sent.", .detail = try std.fmt.allocPrint(allocator, "delta={d}; repeat={d}", .{ delta, repeat_count }) });
}

pub fn windowList(allocator: std.mem.Allocator, include_hidden: bool) !core.model.WindowListResponse {
    if (builtin.os.tag != .linux) {
        return core.model.failure(core.model.WindowList, "window.list", core.errors.codes.not_implemented, "Linux window enumeration is planned but not locally verified yet.", "Phase one will target X11 first.");
    }
    return x11.windowList(allocator, include_hidden);
}

pub fn windowForeground(allocator: std.mem.Allocator) !core.model.ForegroundWindowResponse {
    if (builtin.os.tag != .linux) {
        return core.model.failure(core.model.ForegroundWindow, "window.foreground", core.errors.codes.not_implemented, "Linux foreground-window lookup is planned but not locally verified yet.", "Phase one will target X11 first.");
    }
    return x11.windowForeground(allocator);
}

pub fn windowActivate(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    if (builtin.os.tag != .linux) {
        return core.model.failure(core.model.Ack, "window.activate", core.errors.codes.not_implemented, "Linux window activation is planned but not locally verified yet.", "Phase one will target X11 first.");
    }
    return x11.windowActivate(allocator, handle);
}

pub fn windowShow(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    const window_id = try linuxWindowIdText(allocator, handle);
    defer allocator.free(window_id);
    linuxRunWindowTool(allocator, &[_][]const u8{ "xdotool", "windowmap", window_id }, "window.show", "Linux window show requires xdotool on an X11/XWayland session.") catch |err| {
        return linuxAckToolFailure(allocator, "window.show", "Linux window show requires xdotool on an X11/XWayland session.", err);
    };
    linuxRunWindowTool(allocator, &[_][]const u8{ "xdotool", "windowactivate", window_id }, "window.show", "Linux window activation requires xdotool on an X11/XWayland session.") catch |err| {
        return linuxAckToolFailure(allocator, "window.show", "Linux window activation requires xdotool on an X11/XWayland session.", err);
    };
    return core.model.success("window.show", core.model.Ack{ .message = "Window show requested.", .detail = try std.fmt.allocPrint(allocator, "target_handle=0x{x}", .{handle}) });
}

pub fn windowMinimize(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    const window_id = try linuxWindowIdText(allocator, handle);
    defer allocator.free(window_id);
    linuxRunWindowTool(allocator, &[_][]const u8{ "xdotool", "windowminimize", window_id }, "window.minimize", "Linux window minimize requires xdotool on an X11/XWayland session.") catch |err| {
        return linuxAckToolFailure(allocator, "window.minimize", "Linux window minimize requires xdotool on an X11/XWayland session.", err);
    };
    return core.model.success("window.minimize", core.model.Ack{ .message = "Window minimize requested.", .detail = try std.fmt.allocPrint(allocator, "target_handle=0x{x}", .{handle}) });
}

pub fn windowMaximize(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    const hex_id = try linuxWindowHexIdText(allocator, handle);
    defer allocator.free(hex_id);
    linuxRunWindowTool(allocator, &[_][]const u8{ "wmctrl", "-ir", hex_id, "-b", "add,maximized_vert,maximized_horz" }, "window.maximize", "Linux maximize requires wmctrl on an EWMH-compatible X11 window manager.") catch |err| {
        return linuxAckToolFailure(allocator, "window.maximize", "Linux maximize requires wmctrl on an EWMH-compatible X11 window manager.", err);
    };
    return core.model.success("window.maximize", core.model.Ack{ .message = "Window maximize requested.", .detail = try std.fmt.allocPrint(allocator, "target_handle=0x{x}", .{handle}) });
}

pub fn windowRestore(allocator: std.mem.Allocator, handle: u64) !core.model.AckResponse {
    const hex_id = try linuxWindowHexIdText(allocator, handle);
    defer allocator.free(hex_id);
    linuxRunWindowTool(allocator, &[_][]const u8{ "wmctrl", "-ir", hex_id, "-b", "remove,maximized_vert,maximized_horz,hidden" }, "window.restore", "Linux restore requires wmctrl on an EWMH-compatible X11 window manager.") catch |err| {
        return linuxAckToolFailure(allocator, "window.restore", "Linux restore requires wmctrl on an EWMH-compatible X11 window manager.", err);
    };
    const dec_id = try linuxWindowIdText(allocator, handle);
    defer allocator.free(dec_id);
    _ = linuxRunCommand(allocator, &[_][]const u8{ "xdotool", "windowmap", dec_id }, null) catch {};
    return core.model.success("window.restore", core.model.Ack{ .message = "Window restore requested.", .detail = try std.fmt.allocPrint(allocator, "target_handle=0x{x}", .{handle}) });
}

pub fn windowMove(allocator: std.mem.Allocator, handle: u64, x: i32, y: i32, width: ?i32, height: ?i32) !core.model.AckResponse {
    const current = try windowList(allocator, true);
    if (!current.ok) {
        const failure = current.failure orelse core.errors.ApiError{ .code = core.errors.codes.system_error, .message = "window.list failed before move.", .detail = null };
        return core.model.failure(core.model.Ack, "window.move", failure.code, failure.message, failure.detail);
    }

    var current_window: ?core.model.WindowInfo = null;
    for (current.data.?.windows) |window| {
        if (window.handle == handle) {
            current_window = window;
            break;
        }
    }
    const window = current_window orelse {
        return core.model.failure(core.model.Ack, "window.move", core.errors.codes.not_found, "The requested Linux window handle is no longer present.", try std.fmt.allocPrint(allocator, "target_handle=0x{x}", .{handle}));
    };

    const move_spec = try std.fmt.allocPrint(allocator, "0,{d},{d},{d},{d}", .{ x, y, width orelse window.bounds.width, height orelse window.bounds.height });
    defer allocator.free(move_spec);
    const hex_id = try linuxWindowHexIdText(allocator, handle);
    defer allocator.free(hex_id);
    linuxRunWindowTool(allocator, &[_][]const u8{ "wmctrl", "-ir", hex_id, "-e", move_spec }, "window.move", "Linux window move requires wmctrl on an EWMH-compatible X11 window manager.") catch |err| {
        return linuxAckToolFailure(allocator, "window.move", "Linux window move requires wmctrl on an EWMH-compatible X11 window manager.", err);
    };

    return core.model.success("window.move", core.model.Ack{ .message = "Window move requested.", .detail = try std.fmt.allocPrint(allocator, "target_handle=0x{x}; x={d}; y={d}; width={d}; height={d}", .{ handle, x, y, width orelse window.bounds.width, height orelse window.bounds.height }) });
}

pub fn windowFind(allocator: std.mem.Allocator, title: []const u8, match_mode: core.model.StringMatchMode, include_hidden: bool, pid: ?u32) !core.model.WindowMatchResponse {
    if (builtin.os.tag != .linux) {
        return core.model.failure(core.model.WindowMatch, "window.find", core.errors.codes.not_implemented, "Linux window find is planned but not locally verified yet.", "Phase one will target X11 first.");
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
    if (builtin.os.tag != .linux) {
        return core.model.failure(core.model.Ack, "window.close", core.errors.codes.not_implemented, "Linux window close is planned but not locally verified yet.", "Phase one will target X11 first.");
    }
    return x11.windowClose(allocator, handle);
}

pub fn appLaunch(allocator: std.mem.Allocator, target: []const u8) !core.model.AckResponse {
    if (builtin.os.tag != .linux) {
        return core.model.failure(core.model.Ack, "app.launch", core.errors.codes.not_implemented, "Linux app launch is planned but not locally verified yet.", "Phase one will target desktop-specific launchers.");
    }
    if (target.len == 0) {
        return core.model.failure(core.model.Ack, "app.launch", core.errors.codes.invalid_args, "Launch target cannot be empty.", null);
    }

    var child = std.process.Child.init(&[_][]const u8{ "xdg-open", target }, allocator);
    child.stdin_behavior = .Ignore;
    child.stdout_behavior = .Ignore;
    child.stderr_behavior = .Ignore;
    child.spawn() catch |err| {
        return core.model.failure(core.model.Ack, "app.launch", core.errors.codes.system_error, "Failed to spawn xdg-open.", @errorName(err));
    };

    const term = child.wait() catch |err| {
        return core.model.failure(core.model.Ack, "app.launch", core.errors.codes.system_error, "Failed while waiting for xdg-open.", @errorName(err));
    };
    switch (term) {
        .Exited => |code| {
            if (code != 0) {
                return core.model.failure(core.model.Ack, "app.launch", core.errors.codes.system_error, "xdg-open returned a non-zero exit code.", try std.fmt.allocPrint(allocator, "exit_code={d}", .{code}));
            }
        },
        else => {
            return core.model.failure(core.model.Ack, "app.launch", core.errors.codes.system_error, "xdg-open did not exit normally.", null);
        },
    }

    return core.model.success("app.launch", core.model.Ack{ .message = "Launch requested.", .detail = try std.fmt.allocPrint(allocator, "target={s}", .{target}) });
}

pub fn clipboardGetText(allocator: std.mem.Allocator) !core.model.ClipboardTextResponse {
    const attempt = try linuxClipboardRead(allocator, &[_]LinuxClipboardReadSpec{
        .{ .argv = &[_][]const u8{ "wl-paste", "--no-newline", "--type", "text/plain" }, .requires = "wl-paste on a Wayland session" },
        .{ .argv = &[_][]const u8{ "xclip", "-selection", "clipboard", "-o" }, .requires = "xclip on an X11/XWayland session" },
        .{ .argv = &[_][]const u8{ "xsel", "--clipboard", "--output" }, .requires = "xsel on an X11/XWayland session" },
    });
    switch (attempt.state) {
        .success => return core.model.success("clipboard.get_text", core.model.ClipboardText{ .text = attempt.text.? }),
        .empty => return core.model.failure(core.model.ClipboardText, "clipboard.get_text", core.errors.codes.clipboard_empty, "Clipboard is empty.", null),
        .missing => return core.model.failure(core.model.ClipboardText, "clipboard.get_text", core.errors.codes.not_implemented, "Linux clipboard text support requires wl-paste, xclip, or xsel.", attempt.detail),
        .failed => return core.model.failure(core.model.ClipboardText, "clipboard.get_text", core.errors.codes.system_error, "Failed to read Linux clipboard text.", attempt.detail),
    }
}

pub fn clipboardSetText(allocator: std.mem.Allocator, text: []const u8) !core.model.AckResponse {
    const attempt = try linuxClipboardWrite(allocator, text, &[_]LinuxClipboardWriteSpec{
        .{ .argv = &[_][]const u8{ "wl-copy", "--type", "text/plain" }, .requires = "wl-copy on a Wayland session" },
        .{ .argv = &[_][]const u8{ "xclip", "-selection", "clipboard" }, .requires = "xclip on an X11/XWayland session" },
        .{ .argv = &[_][]const u8{ "xsel", "--clipboard", "--input" }, .requires = "xsel on an X11/XWayland session" },
    });
    if (!attempt.ok) {
        return core.model.failure(core.model.Ack, "clipboard.set_text", attempt.code, attempt.message, attempt.detail);
    }
    return core.model.success("clipboard.set_text", core.model.Ack{ .message = "Clipboard text updated.", .detail = try std.fmt.allocPrint(allocator, "bytes={d}", .{text.len}) });
}

pub fn clipboardGetFiles(allocator: std.mem.Allocator) !core.model.ClipboardFilesResponse {
    const attempt = try linuxClipboardRead(allocator, &[_]LinuxClipboardReadSpec{
        .{ .argv = &[_][]const u8{ "wl-paste", "--no-newline", "--type", "text/uri-list" }, .requires = "wl-paste on a Wayland session" },
        .{ .argv = &[_][]const u8{ "xclip", "-selection", "clipboard", "-t", "text/uri-list", "-o" }, .requires = "xclip on an X11/XWayland session" },
    });
    switch (attempt.state) {
        .success => {
            const files = try linuxParseClipboardFileList(allocator, attempt.text.?);
            if (files.len == 0) {
                return core.model.failure(core.model.ClipboardFiles, "clipboard.get_files", core.errors.codes.clipboard_empty, "Clipboard does not currently contain a file list.", null);
            }
            return core.model.success("clipboard.get_files", core.model.ClipboardFiles{ .files = files });
        },
        .empty => return core.model.failure(core.model.ClipboardFiles, "clipboard.get_files", core.errors.codes.clipboard_empty, "Clipboard is empty.", null),
        .missing => return core.model.failure(core.model.ClipboardFiles, "clipboard.get_files", core.errors.codes.not_implemented, "Linux clipboard file support requires wl-paste or xclip with text/uri-list support.", attempt.detail),
        .failed => return core.model.failure(core.model.ClipboardFiles, "clipboard.get_files", core.errors.codes.system_error, "Failed to read Linux clipboard file list.", attempt.detail),
    }
}

pub fn clipboardSetFiles(allocator: std.mem.Allocator, paths: []const u8) !core.model.AckResponse {
    const payload = try linuxBuildUriListPayload(allocator, paths);
    defer allocator.free(payload);
    const attempt = try linuxClipboardWrite(allocator, payload, &[_]LinuxClipboardWriteSpec{
        .{ .argv = &[_][]const u8{ "wl-copy", "--type", "text/uri-list" }, .requires = "wl-copy on a Wayland session" },
        .{ .argv = &[_][]const u8{ "xclip", "-selection", "clipboard", "-t", "text/uri-list" }, .requires = "xclip on an X11/XWayland session" },
    });
    if (!attempt.ok) {
        return core.model.failure(core.model.Ack, "clipboard.set_files", attempt.code, attempt.message, attempt.detail);
    }
    return core.model.success("clipboard.set_files", core.model.Ack{ .message = "Clipboard file list updated.", .detail = try std.fmt.allocPrint(allocator, "payload_bytes={d}", .{payload.len}) });
}

pub fn clipboardSetImage(allocator: std.mem.Allocator, path: []const u8) !core.model.AckResponse {
    const bytes = std.fs.cwd().readFileAlloc(allocator, path, 16 * 1024 * 1024) catch |err| {
        return core.model.failure(core.model.Ack, "clipboard.set_image", core.errors.codes.system_error, "Failed to read image file for Linux clipboard copy.", @errorName(err));
    };
    defer allocator.free(bytes);

    const attempt = try linuxClipboardWrite(allocator, bytes, &[_]LinuxClipboardWriteSpec{
        .{ .argv = &[_][]const u8{ "wl-copy", "--type", "image/png" }, .requires = "wl-copy on a Wayland session" },
        .{ .argv = &[_][]const u8{ "xclip", "-selection", "clipboard", "-t", "image/png" }, .requires = "xclip on an X11/XWayland session" },
    });
    if (!attempt.ok) {
        return core.model.failure(core.model.Ack, "clipboard.set_image", attempt.code, attempt.message, attempt.detail);
    }
    return core.model.success("clipboard.set_image", core.model.Ack{ .message = "Clipboard image updated.", .detail = try std.fmt.allocPrint(allocator, "path={s}; bytes={d}", .{ path, bytes.len }) });
}

pub fn keyboardKeyPress(allocator: std.mem.Allocator, key: []const u8) !core.model.AckResponse {
    const normalized = try linuxNormalizeXdotoolCombo(allocator, key, false);
    defer allocator.free(normalized);
    linuxRunWindowTool(allocator, &[_][]const u8{ "xdotool", "key", "--clearmodifiers", normalized }, "keyboard.key_press", "Linux keyboard automation requires xdotool on an X11/XWayland session.") catch |err| {
        return linuxAckToolFailure(allocator, "keyboard.key_press", "Linux keyboard automation requires xdotool on an X11/XWayland session.", err);
    };
    return core.model.success("keyboard.key_press", core.model.Ack{ .message = "Key press sent.", .detail = try std.fmt.allocPrint(allocator, "key={s}", .{normalized}) });
}

pub fn keyboardHotkey(allocator: std.mem.Allocator, keys: []const u8) !core.model.AckResponse {
    const normalized = try linuxNormalizeXdotoolCombo(allocator, keys, true);
    defer allocator.free(normalized);
    linuxRunWindowTool(allocator, &[_][]const u8{ "xdotool", "key", "--clearmodifiers", normalized }, "keyboard.hotkey", "Linux keyboard automation requires xdotool on an X11/XWayland session.") catch |err| {
        return linuxAckToolFailure(allocator, "keyboard.hotkey", "Linux keyboard automation requires xdotool on an X11/XWayland session.", err);
    };
    return core.model.success("keyboard.hotkey", core.model.Ack{ .message = "Hotkey sent.", .detail = try std.fmt.allocPrint(allocator, "keys={s}", .{normalized}) });
}

pub fn keyboardTypeText(allocator: std.mem.Allocator, text: []const u8) !core.model.AckResponse {
    linuxRunWindowTool(allocator, &[_][]const u8{ "xdotool", "type", "--delay", "1", text }, "keyboard.type_text", "Linux text typing requires xdotool on an X11/XWayland session.") catch |err| {
        return linuxAckToolFailure(allocator, "keyboard.type_text", "Linux text typing requires xdotool on an X11/XWayland session.", err);
    };
    return core.model.success("keyboard.type_text", core.model.Ack{ .message = "Text input sent.", .detail = try std.fmt.allocPrint(allocator, "bytes={d}", .{text.len}) });
}

pub fn keyboardTypeKeys(allocator: std.mem.Allocator, text: []const u8, key_delay_ms: ?u32) !core.model.AckResponse {
    const delay_ms = key_delay_ms orelse 30;
    if (delay_ms > 1000) {
        return core.model.failure(core.model.Ack, "keyboard.type_keys", core.errors.codes.invalid_args, "key_delay_ms must be <= 1000.", null);
    }
    const delay = try std.fmt.allocPrint(allocator, "{d}", .{delay_ms});
    defer allocator.free(delay);
    linuxRunWindowTool(allocator, &[_][]const u8{ "xdotool", "type", "--delay", delay, text }, "keyboard.type_keys", "Linux keymap typing requires xdotool on an X11/XWayland session.") catch |err| {
        return linuxAckToolFailure(allocator, "keyboard.type_keys", "Linux keymap typing requires xdotool on an X11/XWayland session.", err);
    };
    return core.model.success("keyboard.type_keys", core.model.Ack{ .message = "Keymap typing sent.", .detail = try std.fmt.allocPrint(allocator, "bytes={d}; key_delay_ms={d}", .{ text.len, delay_ms }) });
}

pub fn keyboardImeSwitch(allocator: std.mem.Allocator, strategy: ?[]const u8) !core.model.AckResponse {
    const resolved = strategy orelse "win-space";
    const combo = if (std.ascii.eqlIgnoreCase(resolved, "win-space"))
        "super+space"
    else if (std.ascii.eqlIgnoreCase(resolved, "alt-shift"))
        "alt+shift"
    else if (std.ascii.eqlIgnoreCase(resolved, "ctrl-shift"))
        "ctrl+shift"
    else
        return core.model.failure(core.model.Ack, "keyboard.ime_switch", core.errors.codes.invalid_args, "Unsupported strategy. Use win-space, alt-shift, or ctrl-shift.", resolved);

    linuxRunWindowTool(allocator, &[_][]const u8{ "xdotool", "key", "--clearmodifiers", combo }, "keyboard.ime_switch", "Linux IME switching requires xdotool on an X11/XWayland session.") catch |err| {
        return linuxAckToolFailure(allocator, "keyboard.ime_switch", "Linux IME switching requires xdotool on an X11/XWayland session.", err);
    };
    return core.model.success("keyboard.ime_switch", core.model.Ack{ .message = "IME switch shortcut sent.", .detail = try std.fmt.allocPrint(allocator, "strategy={s}; combo={s}", .{ resolved, combo }) });
}

pub fn keyboardCapsLock(allocator: std.mem.Allocator, state: ?[]const u8) !core.model.AckResponse {
    const resolved = state orelse "toggle";
    if (std.ascii.eqlIgnoreCase(resolved, "toggle")) {
        linuxRunWindowTool(allocator, &[_][]const u8{ "xdotool", "key", "Caps_Lock" }, "keyboard.caps_lock", "Linux caps lock control requires xdotool on an X11/XWayland session.") catch |err| {
            return linuxAckToolFailure(allocator, "keyboard.caps_lock", "Linux caps lock control requires xdotool on an X11/XWayland session.", err);
        };
        return core.model.success("keyboard.caps_lock", core.model.Ack{ .message = "Caps lock toggled.", .detail = try std.fmt.allocPrint(allocator, "requested={s}", .{resolved}) });
    }

    const current_on = linuxCapsLockState(allocator) catch |err| {
        return core.model.failure(core.model.Ack, "keyboard.caps_lock", core.errors.codes.system_error, "Failed to determine Linux caps lock state.", @errorName(err));
    };
    const target_on = if (std.ascii.eqlIgnoreCase(resolved, "on")) true else if (std.ascii.eqlIgnoreCase(resolved, "off")) false else return core.model.failure(core.model.Ack, "keyboard.caps_lock", core.errors.codes.invalid_args, "Unsupported state. Use toggle, on, or off.", resolved);
    if (current_on != target_on) {
        linuxRunWindowTool(allocator, &[_][]const u8{ "xdotool", "key", "Caps_Lock" }, "keyboard.caps_lock", "Linux caps lock control requires xdotool on an X11/XWayland session.") catch |err| {
            return linuxAckToolFailure(allocator, "keyboard.caps_lock", "Linux caps lock control requires xdotool on an X11/XWayland session.", err);
        };
    }
    return core.model.success("keyboard.caps_lock", core.model.Ack{ .message = "Caps lock state updated.", .detail = try std.fmt.allocPrint(allocator, "requested={s}; active={s}", .{ resolved, if (target_on) "on" else "off" }) });
}

pub fn keyboardPaste(allocator: std.mem.Allocator, expected_title: ?[]const u8, match_mode: core.model.StringMatchMode) !core.model.AckResponse {
    if (expected_title) |title| {
        const current = try windowForeground(allocator);
        if (!current.ok or !current.data.?.found or !textMatches(current.data.?.window.?.title, title, match_mode)) {
            return core.model.failure(core.model.Ack, "keyboard.paste", core.errors.codes.unsafe_operation, "Foreground window title does not match expected_title.", title);
        }
    }
    linuxRunWindowTool(allocator, &[_][]const u8{ "xdotool", "key", "--clearmodifiers", "ctrl+v" }, "keyboard.paste", "Linux synthetic paste currently targets Ctrl+V and requires xdotool on an X11/XWayland session.") catch |err| {
        return linuxAckToolFailure(allocator, "keyboard.paste", "Linux synthetic paste currently targets Ctrl+V and requires xdotool on an X11/XWayland session.", err);
    };
    return core.model.success("keyboard.paste", core.model.Ack{ .message = "Paste shortcut sent.", .detail = if (expected_title) |title| try std.fmt.allocPrint(allocator, "expected_title={s}", .{title}) else null });
}

pub fn screenCapture(allocator: std.mem.Allocator, path: []const u8, display_id: ?u32, window_handle: ?u64) !core.model.ScreenCaptureResponse {
    if (builtin.os.tag != .linux) {
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.not_implemented, "Linux screen capture is planned but not locally verified yet.", "Phase one will target X11 first.");
    }

    if (display_id != null and window_handle != null) {
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.invalid_args, "display_id and window_handle cannot be used together.", null);
    }

    if (display_id != null or window_handle != null) {
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.not_implemented, "Linux selective capture by display_id/window_handle is not implemented yet.", "Use default full-desktop capture on Linux for now.");
    }

    if (std.fs.path.dirname(path)) |dir_name| {
        try std.fs.cwd().makePath(dir_name);
    }

    const commands = [_][]const []const u8{
        &[_][]const u8{ "grim", path },
        &[_][]const u8{ "gnome-screenshot", "-f", path },
        &[_][]const u8{ "scrot", path },
        &[_][]const u8{ "import", "-window", "root", path },
    };

    var saw_command: bool = false;
    var saw_permission_or_session_issue: bool = false;
    var first_failure_detail: ?[]const u8 = null;

    for (commands) |command| {
        const result = try runCaptureCommandDetailed(allocator, command);
        switch (result.state) {
            .success => {
                const size = try fileSize(path);
                if (size == 0) {
                    return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.system_error, "Capture command exited successfully but wrote an empty file.", path);
                }

                return core.model.success("screen.capture", core.model.ScreenCapture{
                    .path = path,
                    .width = 0,
                    .height = 0,
                    .format = "png",
                });
            },
            .missing => {},
            .permission_or_session => {
                saw_command = true;
                saw_permission_or_session_issue = true;
                if (first_failure_detail == null) first_failure_detail = result.detail;
            },
            .failed => {
                saw_command = true;
                if (first_failure_detail == null) first_failure_detail = result.detail;
            },
        }
    }

    if (saw_permission_or_session_issue) {
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.permission_denied, "Screenshot command was found but the desktop session denied capture.", first_failure_detail orelse "Check desktop permissions and session type (X11/Wayland). ");
    }
    if (saw_command) {
        return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.system_error, "Screenshot command was found but failed.", first_failure_detail);
    }
    return core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.not_implemented, "No supported Linux screenshot tool was found.", "Tried: grim, gnome-screenshot, scrot, import.");
}

pub fn screenPixelColor(allocator: std.mem.Allocator, x: i32, y: i32) !core.model.PixelColorResponse {
    if (builtin.os.tag != .linux) {
        return core.model.failure(core.model.PixelColor, "screen.pixel_color", core.errors.codes.not_implemented, "Linux pixel color inspection is planned but not locally verified yet.", "Phase one will target X11 first.");
    }
    return x11.screenPixelColor(allocator, x, y);
}

pub fn screenDisplays(allocator: std.mem.Allocator) !core.model.DisplayListResponse {
    if (builtin.os.tag != .linux) {
        return core.model.failure(core.model.DisplayList, "screen.displays", core.errors.codes.not_implemented, "Linux display enumeration is planned but not locally verified yet.", "Phase one will target X11 first.");
    }

    var child = std.process.Child.init(&[_][]const u8{ "xrandr", "--query" }, allocator);
    child.stdin_behavior = .Ignore;
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Ignore;
    child.spawn() catch |err| {
        if (err == error.FileNotFound) {
            return core.model.failure(core.model.DisplayList, "screen.displays", core.errors.codes.not_implemented, "xrandr command was not found on this Linux host.", "Install xrandr or run in an X11 desktop session.");
        }
        return core.model.failure(core.model.DisplayList, "screen.displays", core.errors.codes.system_error, "Failed to spawn xrandr command.", @errorName(err));
    };

    const stdout_pipe = child.stdout orelse {
        _ = child.kill() catch {};
        return core.model.failure(core.model.DisplayList, "screen.displays", core.errors.codes.system_error, "xrandr stdout pipe was unavailable.", null);
    };
    const output = stdout_pipe.reader().readAllAlloc(allocator, 256 * 1024) catch |err| {
        _ = child.kill() catch {};
        return core.model.failure(core.model.DisplayList, "screen.displays", core.errors.codes.system_error, "Failed to read xrandr output.", @errorName(err));
    };
    defer allocator.free(output);

    const term = child.wait() catch |err| {
        return core.model.failure(core.model.DisplayList, "screen.displays", core.errors.codes.system_error, "Failed while waiting for xrandr.", @errorName(err));
    };
    switch (term) {
        .Exited => |code| {
            if (code != 0) {
                return core.model.failure(core.model.DisplayList, "screen.displays", core.errors.codes.system_error, "xrandr returned a non-zero exit code.", try std.fmt.allocPrint(allocator, "exit_code={d}", .{code}));
            }
        },
        else => {
            return core.model.failure(core.model.DisplayList, "screen.displays", core.errors.codes.system_error, "xrandr did not exit normally.", null);
        },
    }

    var displays = std.ArrayList(core.model.DisplayInfo).empty;
    defer displays.deinit(allocator);

    var lines = std.mem.splitScalar(u8, output, '\n');
    while (lines.next()) |line_raw| {
        const line = std.mem.trim(u8, line_raw, " \t\r");
        if (line.len == 0) continue;

        const parsed = parseXrandrDisplayLine(line) orelse continue;
        try displays.append(allocator, core.model.DisplayInfo{
            .id = @as(u32, @intCast(displays.items.len + 1)),
            .name = try allocator.dupe(u8, parsed.name),
            .is_primary = parsed.is_primary,
            .bounds = parsed.bounds,
        });
    }

    if (displays.items.len == 0) {
        return core.model.failure(core.model.DisplayList, "screen.displays", core.errors.codes.system_error, "xrandr returned output, but no connected displays could be parsed.", "Check if the host desktop exposes connected outputs.");
    }

    const owned = try displays.toOwnedSlice(allocator);
    return core.model.success("screen.displays", core.model.DisplayList{
        .count = owned.len,
        .displays = owned,
    });
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
            return core.model.failure(core.model.WaitWindow, "wait.activate", core.errors.codes.timeout, "Timed out while waiting for Linux window activation state transition.", try std.fmt.allocPrint(allocator, "target_handle=0x{x}; expect_active={s}", .{ handle, if (expect_active) "true" else "false" }));
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

const CaptureCommandState = enum {
    success,
    missing,
    permission_or_session,
    failed,
};

const CaptureCommandResult = struct {
    state: CaptureCommandState,
    detail: ?[]const u8 = null,
};

fn runCaptureCommandDetailed(allocator: std.mem.Allocator, argv: []const []const u8) !CaptureCommandResult {
    var child = std.process.Child.init(argv, allocator);
    child.stdin_behavior = .Ignore;
    child.stdout_behavior = .Ignore;
    child.stderr_behavior = .Ignore;

    child.spawn() catch |err| {
        if (err == error.FileNotFound) {
            return .{ .state = .missing };
        }
        return err;
    };

    const term = try child.wait();
    return switch (term) {
        .Exited => |code| if (code == 0)
            .{ .state = .success }
        else if (code == 1)
            .{ .state = .permission_or_session, .detail = try std.fmt.allocPrint(allocator, "command={s}; exit_code={d}", .{ argv[0], code }) }
        else
            .{ .state = .failed, .detail = try std.fmt.allocPrint(allocator, "command={s}; exit_code={d}", .{ argv[0], code }) },
        else => .{ .state = .failed, .detail = try std.fmt.allocPrint(allocator, "command={s}; abnormal_termination=true", .{argv[0]}) },
    };
}

fn fileSize(path: []const u8) !u64 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const stat = try file.stat();
    return stat.size;
}

const ParsedDisplay = struct {
    name: []const u8,
    is_primary: bool,
    bounds: core.model.Rect,
};

fn parseXrandrDisplayLine(line: []const u8) ?ParsedDisplay {
    var tokens = std.mem.tokenizeAny(u8, line, " \t");
    const name = tokens.next() orelse return null;
    const status = tokens.next() orelse return null;
    if (!std.mem.eql(u8, status, "connected")) return null;

    var is_primary = false;
    var geometry_token: ?[]const u8 = null;
    while (tokens.next()) |token| {
        if (std.mem.eql(u8, token, "primary")) {
            is_primary = true;
            continue;
        }
        if (parseXrandrGeometry(token)) |bounds| {
            geometry_token = token;
            _ = bounds;
            break;
        }
    }

    const token = geometry_token orelse return null;
    const bounds = parseXrandrGeometry(token) orelse return null;
    return .{ .name = name, .is_primary = is_primary, .bounds = bounds };
}

fn parseXrandrGeometry(token: []const u8) ?core.model.Rect {
    const x_pos = std.mem.indexOfScalar(u8, token, 'x') orelse return null;
    const width = std.fmt.parseInt(i32, token[0..x_pos], 10) catch return null;
    if (width <= 0) return null;

    const rest = token[x_pos + 1 ..];
    var split_index: usize = 0;
    while (split_index < rest.len and rest[split_index] != '+' and rest[split_index] != '-') : (split_index += 1) {}
    if (split_index == 0 or split_index >= rest.len) return null;

    const height = std.fmt.parseInt(i32, rest[0..split_index], 10) catch return null;
    if (height <= 0) return null;

    const x_parse = parseSignedInt(rest, split_index) orelse return null;
    const y_parse = parseSignedInt(rest, x_parse.next_index) orelse return null;

    return .{
        .left = x_parse.value,
        .top = y_parse.value,
        .right = x_parse.value + width,
        .bottom = y_parse.value + height,
        .width = width,
        .height = height,
    };
}

const SignedParse = struct {
    value: i32,
    next_index: usize,
};

fn parseSignedInt(text: []const u8, start: usize) ?SignedParse {
    if (start >= text.len) return null;
    if (text[start] != '+' and text[start] != '-') return null;

    var end = start + 1;
    while (end < text.len and text[end] >= '0' and text[end] <= '9') : (end += 1) {}
    if (end == start + 1) return null;

    const value = std.fmt.parseInt(i32, text[start..end], 10) catch return null;
    return .{ .value = value, .next_index = end };
}

const LinuxCommandResult = struct {
    stdout: []u8,
    stderr: []u8,
    exit_code: i32,
    missing: bool = false,
};

const LinuxClipboardReadSpec = struct {
    argv: []const []const u8,
    requires: []const u8,
};

const LinuxClipboardWriteSpec = struct {
    argv: []const []const u8,
    requires: []const u8,
};

const LinuxClipboardReadState = enum {
    success,
    empty,
    missing,
    failed,
};

const LinuxClipboardReadResult = struct {
    state: LinuxClipboardReadState,
    text: ?[]const u8 = null,
    detail: ?[]const u8 = null,
};

const LinuxClipboardWriteResult = struct {
    ok: bool,
    code: []const u8,
    message: []const u8,
    detail: ?[]const u8,
};

const LinuxMemorySnapshot = struct {
    total_physical: u64,
    available_physical: u64,
    used_physical: u64,
    memory_load_percent: u32,
};

fn linuxRunCommand(allocator: std.mem.Allocator, argv: []const []const u8, stdin_bytes: ?[]const u8) !LinuxCommandResult {
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

fn linuxCommandDetail(allocator: std.mem.Allocator, result: LinuxCommandResult) ![]const u8 {
    const stderr_text = std.mem.trim(u8, result.stderr, " \t\r\n");
    const stdout_text = std.mem.trim(u8, result.stdout, " \t\r\n");
    if (stderr_text.len > 0) return std.fmt.allocPrint(allocator, "exit_code={d}; stderr={s}", .{ result.exit_code, stderr_text });
    if (stdout_text.len > 0) return std.fmt.allocPrint(allocator, "exit_code={d}; stdout={s}", .{ result.exit_code, stdout_text });
    return std.fmt.allocPrint(allocator, "exit_code={d}", .{result.exit_code});
}

fn linuxReadFileAlloc(allocator: std.mem.Allocator, path: []const u8) ![]u8 {
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();
    return try file.readToEndAlloc(allocator, 8 * 1024 * 1024);
}

fn linuxHostName(allocator: std.mem.Allocator) ![]const u8 {
    const result = try linuxRunCommand(allocator, &[_][]const u8{ "hostname" }, null);
    defer allocator.free(result.stderr);
    if (result.missing or result.exit_code != 0) {
        allocator.free(result.stdout);
        return error.HostnameUnavailable;
    }
    return trimOwnedTrailingWhitespace(allocator, result.stdout);
}

fn linuxKernelVersion(allocator: std.mem.Allocator) ![]const u8 {
    const result = try linuxRunCommand(allocator, &[_][]const u8{ "uname", "-r" }, null);
    defer allocator.free(result.stderr);
    if (result.missing or result.exit_code != 0) {
        allocator.free(result.stdout);
        return error.UnameUnavailable;
    }
    return trimOwnedTrailingWhitespace(allocator, result.stdout);
}

fn linuxLogicalCoreCount(allocator: std.mem.Allocator) !u32 {
    const cpuinfo = try linuxReadFileAlloc(allocator, "/proc/cpuinfo");
    defer allocator.free(cpuinfo);
    var count: u32 = 0;
    var lines = std.mem.splitScalar(u8, cpuinfo, '\n');
    while (lines.next()) |line| {
        if (std.mem.startsWith(u8, line, "processor")) count += 1;
    }
    if (count == 0) return error.CpuCountUnavailable;
    return count;
}

fn linuxPageSize(allocator: std.mem.Allocator) !u32 {
    const result = try linuxRunCommand(allocator, &[_][]const u8{ "getconf", "PAGESIZE" }, null);
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);
    if (result.missing or result.exit_code != 0) return error.PageSizeUnavailable;
    const trimmed = std.mem.trim(u8, result.stdout, " \t\r\n");
    return try std.fmt.parseInt(u32, trimmed, 10);
}

fn linuxMemorySnapshot(allocator: std.mem.Allocator) !LinuxMemorySnapshot {
    const meminfo = try linuxReadFileAlloc(allocator, "/proc/meminfo");
    defer allocator.free(meminfo);

    const total_kb = linuxParseMeminfoKiB(meminfo, "MemTotal") orelse return error.MemTotalUnavailable;
    const available_kb = linuxParseMeminfoKiB(meminfo, "MemAvailable") orelse linuxParseMeminfoKiB(meminfo, "MemFree") orelse return error.MemAvailableUnavailable;
    const total_bytes = total_kb * 1024;
    const available_bytes = available_kb * 1024;
    const used_bytes = total_bytes -| available_bytes;
    const load_percent: u32 = if (total_bytes == 0) 0 else @intCast((used_bytes * 100) / total_bytes);

    return .{
        .total_physical = total_bytes,
        .available_physical = available_bytes,
        .used_physical = used_bytes,
        .memory_load_percent = load_percent,
    };
}

fn linuxParseMeminfoKiB(meminfo: []const u8, key: []const u8) ?u64 {
    var lines = std.mem.splitScalar(u8, meminfo, '\n');
    while (lines.next()) |line| {
        if (!std.mem.startsWith(u8, line, key)) continue;
        const colon = std.mem.indexOfScalar(u8, line, ':') orelse return null;
        const rest = std.mem.trim(u8, line[colon + 1 ..], " \t");
        var tokens = std.mem.tokenizeAny(u8, rest, " \t");
        const value = tokens.next() orelse return null;
        return std.fmt.parseInt(u64, value, 10) catch null;
    }
    return null;
}

fn linuxParseLinkMac(line: []const u8) ?[]const u8 {
    const marker = "link/ether ";
    const index = std.mem.indexOf(u8, line, marker) orelse return null;
    const rest = line[index + marker.len ..];
    const end = std.mem.indexOfAny(u8, rest, " \t") orelse rest.len;
    return rest[0..end];
}

fn linuxFindInterfaceIpv4(output: []const u8, iface: []const u8) ?[]const u8 {
    var lines = std.mem.splitScalar(u8, output, '\n');
    while (lines.next()) |line_raw| {
        const line = std.mem.trim(u8, line_raw, " \t\r");
        if (line.len == 0) continue;
        const first_colon = std.mem.indexOfScalar(u8, line, ':') orelse continue;
        const second_colon_rel = std.mem.indexOfScalar(u8, line[first_colon + 1 ..], ':') orelse continue;
        const second_colon = first_colon + 1 + second_colon_rel;
        const name = std.mem.trim(u8, line[first_colon + 1 .. second_colon], " \t");
        if (!std.mem.eql(u8, name, iface)) continue;
        const inet_marker = " inet ";
        const inet_index = std.mem.indexOf(u8, line, inet_marker) orelse continue;
        const rest = line[inet_index + inet_marker.len ..];
        const end = std.mem.indexOfAny(u8, rest, "/ \t") orelse rest.len;
        return rest[0..end];
    }
    return null;
}

fn linuxParseShellKeyInt(output: []const u8, key: []const u8) ?i32 {
    var lines = std.mem.splitScalar(u8, output, '\n');
    while (lines.next()) |line_raw| {
        const line = std.mem.trim(u8, line_raw, " \t\r");
        if (!std.mem.startsWith(u8, line, key)) continue;
        if (line.len <= key.len + 1 or line[key.len] != '=') continue;
        return std.fmt.parseInt(i32, line[key.len + 1 ..], 10) catch null;
    }
    return null;
}

fn linuxMoveMouseAbsolute(allocator: std.mem.Allocator, x: i32, y: i32) !void {
    const xs = try std.fmt.allocPrint(allocator, "{d}", .{x});
    defer allocator.free(xs);
    const ys = try std.fmt.allocPrint(allocator, "{d}", .{y});
    defer allocator.free(ys);
    try linuxRunWindowTool(allocator, &[_][]const u8{ "xdotool", "mousemove", "--sync", xs, ys }, "mouse.move", "Linux mouse automation requires xdotool on an X11/XWayland session.");
}

fn linuxWindowIdText(allocator: std.mem.Allocator, handle: u64) ![]const u8 {
    return std.fmt.allocPrint(allocator, "{d}", .{handle});
}

fn linuxWindowHexIdText(allocator: std.mem.Allocator, handle: u64) ![]const u8 {
    return std.fmt.allocPrint(allocator, "0x{x}", .{handle});
}

fn linuxRunWindowTool(allocator: std.mem.Allocator, argv: []const []const u8, capability: []const u8, missing_message: []const u8) !void {
    const result = try linuxRunCommand(allocator, argv, null);
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);
    if (result.missing) {
        return error.MissingLinuxTool;
    }
    if (result.exit_code != 0) {
        const detail = linuxCommandDetail(allocator, result) catch null;
        _ = detail;
        switch (capability[0]) {
            else => {},
        }
        return error.LinuxToolFailed;
    }
    _ = missing_message;
    _ = capability;
}

fn linuxAckToolFailure(allocator: std.mem.Allocator, capability: []const u8, missing_message: []const u8, err: anyerror) core.model.AckResponse {
    return switch (err) {
        error.MissingLinuxTool => core.model.failure(core.model.Ack, capability, core.errors.codes.not_implemented, missing_message, "Install the required desktop automation tool and run inside an interactive desktop session."),
        error.LinuxToolFailed => core.model.failure(core.model.Ack, capability, core.errors.codes.system_error, "Desktop automation command failed.", null),
        else => core.model.failure(core.model.Ack, capability, core.errors.codes.system_error, "Desktop automation command failed.", @errorName(err)),
    };
}

fn linuxClipboardRead(allocator: std.mem.Allocator, specs: []const LinuxClipboardReadSpec) !LinuxClipboardReadResult {
    var missing_notes = std.ArrayList(u8).empty;
    defer missing_notes.deinit(allocator);

    for (specs) |spec| {
        const result = try linuxRunCommand(allocator, spec.argv, null);
        defer allocator.free(result.stdout);
        defer allocator.free(result.stderr);

        if (result.missing) {
            if (missing_notes.items.len > 0) try missing_notes.appendSlice(allocator, "; ");
            try missing_notes.appendSlice(allocator, spec.requires);
            continue;
        }

        if (result.exit_code == 0) {
            const trimmed = std.mem.trim(u8, result.stdout, "\r\n");
            if (trimmed.len == 0) return .{ .state = .empty };
            return .{ .state = .success, .text = try allocator.dupe(u8, trimmed) };
        }
    }

    if (missing_notes.items.len > 0) {
        return .{ .state = .missing, .detail = try missing_notes.toOwnedSlice(allocator) };
    }
    return .{ .state = .failed, .detail = try allocator.dupe(u8, "clipboard read command returned a non-zero exit code") };
}

fn linuxClipboardWrite(allocator: std.mem.Allocator, payload: []const u8, specs: []const LinuxClipboardWriteSpec) !LinuxClipboardWriteResult {
    var missing_notes = std.ArrayList(u8).empty;
    defer missing_notes.deinit(allocator);

    for (specs) |spec| {
        const result = try linuxRunCommand(allocator, spec.argv, payload);
        defer allocator.free(result.stdout);
        defer allocator.free(result.stderr);

        if (result.missing) {
            if (missing_notes.items.len > 0) try missing_notes.appendSlice(allocator, "; ");
            try missing_notes.appendSlice(allocator, spec.requires);
            continue;
        }
        if (result.exit_code == 0) {
            return .{ .ok = true, .code = "", .message = "", .detail = null };
        }
        return .{ .ok = false, .code = core.errors.codes.system_error, .message = "Clipboard command failed.", .detail = try linuxCommandDetail(allocator, result) };
    }

    return .{ .ok = false, .code = core.errors.codes.not_implemented, .message = "No supported Linux clipboard backend was found.", .detail = if (missing_notes.items.len > 0) try missing_notes.toOwnedSlice(allocator) else null };
}

fn linuxParseClipboardFileList(allocator: std.mem.Allocator, text: []const u8) ![]const []const u8 {
    var files = std.ArrayList([]const u8).empty;
    defer files.deinit(allocator);

    var lines = std.mem.splitScalar(u8, text, '\n');
    while (lines.next()) |line_raw| {
        const line = std.mem.trim(u8, line_raw, " \t\r");
        if (line.len == 0 or line[0] == '#') continue;
        if (std.mem.startsWith(u8, line, "file://")) {
            try files.append(allocator, try allocator.dupe(u8, line[7..]));
        } else {
            try files.append(allocator, try allocator.dupe(u8, line));
        }
    }
    return try files.toOwnedSlice(allocator);
}

fn linuxBuildUriListPayload(allocator: std.mem.Allocator, paths: []const u8) ![]const u8 {
    var buffer = std.ArrayList(u8).empty;
    defer buffer.deinit(allocator);

    var iter = std.mem.splitScalar(u8, paths, ';');
    while (iter.next()) |entry_raw| {
        const entry = std.mem.trim(u8, entry_raw, " \t\r\n");
        if (entry.len == 0) continue;
        try buffer.appendSlice(allocator, "file://");
        try buffer.appendSlice(allocator, entry);
        try buffer.append(allocator, '\n');
    }

    return try buffer.toOwnedSlice(allocator);
}

fn linuxNormalizeXdotoolCombo(allocator: std.mem.Allocator, text: []const u8, is_combo: bool) ![]const u8 {
    if (!is_combo) {
        return allocator.dupe(u8, linuxNormalizeKeyToken(text));
    }

    var parts = std.ArrayList(u8).empty;
    defer parts.deinit(allocator);
    var iter = std.mem.tokenizeScalar(u8, text, '+');
    var first = true;
    while (iter.next()) |token_raw| {
        const token = std.mem.trim(u8, token_raw, " \t");
        if (token.len == 0) continue;
        if (!first) try parts.append(allocator, '+');
        try parts.appendSlice(allocator, linuxNormalizeKeyToken(token));
        first = false;
    }
    if (parts.items.len == 0) return error.EmptyCombo;
    return try parts.toOwnedSlice(allocator);
}

fn linuxNormalizeKeyToken(token: []const u8) []const u8 {
    if (std.ascii.eqlIgnoreCase(token, "enter")) return "Return";
    if (std.ascii.eqlIgnoreCase(token, "esc")) return "Escape";
    if (std.ascii.eqlIgnoreCase(token, "space")) return "space";
    if (std.ascii.eqlIgnoreCase(token, "tab")) return "Tab";
    if (std.ascii.eqlIgnoreCase(token, "backspace")) return "BackSpace";
    if (std.ascii.eqlIgnoreCase(token, "delete")) return "Delete";
    if (std.ascii.eqlIgnoreCase(token, "pageup")) return "Page_Up";
    if (std.ascii.eqlIgnoreCase(token, "pagedown")) return "Page_Down";
    if (std.ascii.eqlIgnoreCase(token, "left")) return "Left";
    if (std.ascii.eqlIgnoreCase(token, "right")) return "Right";
    if (std.ascii.eqlIgnoreCase(token, "up")) return "Up";
    if (std.ascii.eqlIgnoreCase(token, "down")) return "Down";
    if (std.ascii.eqlIgnoreCase(token, "ctrl")) return "ctrl";
    if (std.ascii.eqlIgnoreCase(token, "alt")) return "alt";
    if (std.ascii.eqlIgnoreCase(token, "shift")) return "shift";
    if (std.ascii.eqlIgnoreCase(token, "win")) return "super";
    if (std.ascii.eqlIgnoreCase(token, "caps-lock")) return "Caps_Lock";
    return token;
}

fn linuxCapsLockState(allocator: std.mem.Allocator) !bool {
    const result = try linuxRunCommand(allocator, &[_][]const u8{ "xset", "q" }, null);
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);
    if (result.missing or result.exit_code != 0) return error.CapsStateUnavailable;
    return std.mem.indexOf(u8, result.stdout, "Caps Lock:   on") != null or std.mem.indexOf(u8, result.stdout, "Caps Lock:\ton") != null or std.mem.indexOf(u8, result.stdout, "Caps Lock: on") != null;
}

fn trimOwnedTrailingWhitespace(allocator: std.mem.Allocator, bytes: []u8) ![]const u8 {
    const trimmed = std.mem.trimRight(u8, bytes, " \t\r\n");
    if (trimmed.ptr == bytes.ptr and trimmed.len == bytes.len) return bytes;
    const out = try allocator.dupe(u8, trimmed);
    allocator.free(bytes);
    return out;
}
