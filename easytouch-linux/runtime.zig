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
        std.time.sleep(150 * std.time.ns_per_ms);
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
    const machine_name = try std.fmt.allocPrint(allocator, "linux-host-unverified", .{});
    const version = try std.fmt.allocPrint(allocator, "linux-runtime-unverified", .{});
    return core.model.success("system.os_info", core.model.OsInfo{
        .platform = "linux",
        .arch = @tagName(builtin.cpu.arch),
        .version = version,
        .build = 0,
        .machine_name = machine_name,
        .runtime = "linux stub",
    });
}

pub fn systemCpuInfo(_: std.mem.Allocator) !core.model.CpuInfoResponse {
    return core.model.failure(core.model.CpuInfo, "system.cpu_info", core.errors.codes.not_implemented, "Linux cpu info is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn systemMemoryInfo(_: std.mem.Allocator) !core.model.MemoryInfoResponse {
    return core.model.failure(core.model.MemoryInfo, "system.memory_info", core.errors.codes.not_implemented, "Linux memory info is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn systemDiskList(_: std.mem.Allocator) !core.model.DiskListResponse {
    return core.model.failure(core.model.DiskList, "system.disk_list", core.errors.codes.not_implemented, "Linux disk list is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn systemProcessList(_: std.mem.Allocator) !core.model.ProcessListResponse {
    return core.model.failure(core.model.ProcessList, "system.process_list", core.errors.codes.not_implemented, "Linux process list is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn systemHardwareInfo(_: std.mem.Allocator) !core.model.HardwareInfoResponse {
    return core.model.failure(core.model.HardwareInfo, "system.hardware_info", core.errors.codes.not_implemented, "Linux hardware info is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn systemNetworkInfo(_: std.mem.Allocator) !core.model.NetworkInfoResponse {
    return core.model.failure(core.model.NetworkInfo, "system.network_info", core.errors.codes.not_implemented, "Linux network info is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn mousePosition(_: std.mem.Allocator) !core.model.PointResponse {
    return core.model.failure(core.model.Point, "mouse.position", core.errors.codes.not_implemented, "Linux mouse position is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn mouseMove(_: std.mem.Allocator, _: i32, _: i32, _: ?u32, _: ?i32, _: ?u32) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.not_implemented, "Linux mouse move is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn mouseClick(_: std.mem.Allocator, _: core.model.MouseButton, _: u8) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "mouse.click", core.errors.codes.not_implemented, "Linux mouse click is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn mouseScroll(_: std.mem.Allocator, _: i32) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "mouse.scroll", core.errors.codes.not_implemented, "Linux mouse scroll is planned but not locally verified yet.", "Phase one will target X11 first.");
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

pub fn windowShow(_: std.mem.Allocator, _: u64) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "window.show", core.errors.codes.not_implemented, "Linux window show is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn windowMinimize(_: std.mem.Allocator, _: u64) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "window.minimize", core.errors.codes.not_implemented, "Linux window minimize is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn windowMaximize(_: std.mem.Allocator, _: u64) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "window.maximize", core.errors.codes.not_implemented, "Linux window maximize is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn windowRestore(_: std.mem.Allocator, _: u64) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "window.restore", core.errors.codes.not_implemented, "Linux window restore is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn windowMove(_: std.mem.Allocator, _: u64, _: i32, _: i32, _: ?i32, _: ?i32) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "window.move", core.errors.codes.not_implemented, "Linux window move is planned but not locally verified yet.", "Phase one will target X11 first.");
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

pub fn clipboardGetText(_: std.mem.Allocator) !core.model.ClipboardTextResponse {
    return core.model.failure(core.model.ClipboardText, "clipboard.get_text", core.errors.codes.not_implemented, "Linux clipboard support is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn clipboardSetText(_: std.mem.Allocator, _: []const u8) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "clipboard.set_text", core.errors.codes.not_implemented, "Linux clipboard write support is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn clipboardGetFiles(_: std.mem.Allocator) !core.model.ClipboardFilesResponse {
    return core.model.failure(core.model.ClipboardFiles, "clipboard.get_files", core.errors.codes.not_implemented, "Linux clipboard file list support is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn clipboardSetFiles(_: std.mem.Allocator, _: []const u8) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "clipboard.set_files", core.errors.codes.not_implemented, "Linux clipboard file-drop write support is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn clipboardSetImage(_: std.mem.Allocator, _: []const u8) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "clipboard.set_image", core.errors.codes.not_implemented, "Linux clipboard image write support is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn keyboardKeyPress(_: std.mem.Allocator, _: []const u8) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "keyboard.key_press", core.errors.codes.not_implemented, "Linux key press support is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn keyboardHotkey(_: std.mem.Allocator, _: []const u8) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "keyboard.hotkey", core.errors.codes.not_implemented, "Linux hotkey support is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn keyboardTypeText(_: std.mem.Allocator, _: []const u8) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "keyboard.type_text", core.errors.codes.not_implemented, "Linux text typing support is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn keyboardTypeKeys(_: std.mem.Allocator, _: []const u8, _: ?u32) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "keyboard.type_keys", core.errors.codes.not_implemented, "Linux keymap typing support is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn keyboardImeSwitch(_: std.mem.Allocator, _: ?[]const u8) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "keyboard.ime_switch", core.errors.codes.not_implemented, "Linux IME switching support is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn keyboardCapsLock(_: std.mem.Allocator, _: ?[]const u8) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "keyboard.caps_lock", core.errors.codes.not_implemented, "Linux caps lock control is planned but not locally verified yet.", "Phase one will target X11 first.");
}

pub fn keyboardPaste(_: std.mem.Allocator, _: ?[]const u8, _: core.model.StringMatchMode) !core.model.AckResponse {
    return core.model.failure(core.model.Ack, "keyboard.paste", core.errors.codes.not_implemented, "Linux synthetic paste is planned but not locally verified yet.", "Phase one will target X11 first.");
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

pub fn waitActivate(_: std.mem.Allocator, _: u64, _: u64, _: bool) !core.model.WaitWindowResponse {
    return core.model.failure(core.model.WaitWindow, "wait.activate", core.errors.codes.not_implemented, "Linux wait activate support is planned but not locally verified yet.", "Phase one will target X11 first.");
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
