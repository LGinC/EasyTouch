const std = @import("std");
const core = @import("easytouch_core");
const runtime = @import("../runtime/root.zig");

const JsonValue = std.json.Value;
const JsonObject = std.json.ObjectMap;
const JsonArray = std.json.Array;

const protocol_version = "2024-11-05";
const server_version = "1.0.8-dev";

const RpcError = struct {
    code: i64,
    message: []const u8,
    data: ?[]const u8 = null,
};

const PropertySpec = struct {
    key: []const u8,
    type_name: []const u8,
    description: []const u8,
    enum_values: ?[]const []const u8 = null,
};

pub fn printPlan() void {
    std.debug.print("EasyTouch MCP stdio server\n", .{});
    std.debug.print("- transport: stdio\n", .{});
    std.debug.print("- protocol: JSON-RPC framed with Content-Length headers\n", .{});
    std.debug.print("- tool registry source: shared library capability registry\n", .{});
    std.debug.print("- capability batch: observe_*, clipboard_*, keyboard_*, window_*, system_*, wait_*\n", .{});
    std.debug.print("- artifact strategy: return structured metadata plus screenshot file paths\n", .{});
    std.debug.print("- current registry:\n", .{});
    for (core.capability.all) |item| {
        std.debug.print("  - {s} -> {s}\n", .{ item.mcp_tool, item.id });
    }
    std.debug.print("- status: ready (use `et mcp-stdio` to start the server)\n", .{});
}

pub fn printManifestJson() !void {
    try core.output.printJson(.{
        .transport = "stdio",
        .status = "ready",
        .protocol_version = protocol_version,
        .tools = core.capability.all,
    });
}

pub fn serve(allocator: std.mem.Allocator) !void {
    var read_buffer: [4096]u8 = undefined;
    var file_reader = std.fs.File.stdin().reader(&read_buffer);
    const stdin = &file_reader.interface;

    var write_buffer: [4096]u8 = undefined;
    var file_writer = std.fs.File.stdout().writer(&write_buffer);
    const stdout = &file_writer.interface;

    while (true) {
        var arena = std.heap.ArenaAllocator.init(allocator);
        defer arena.deinit();

        const body = (readFramedMessage(arena.allocator(), stdin) catch |err| {
            try writeErrorResponse(arena.allocator(), stdout, JsonValue{ .null = {} }, .{
                .code = -32700,
                .message = "Failed to read or frame the MCP request.",
                .data = @errorName(err),
            });
            continue;
        }) orelse break;

        const parsed = std.json.parseFromSlice(JsonValue, arena.allocator(), body, .{}) catch |err| {
            try writeErrorResponse(arena.allocator(), stdout, JsonValue{ .null = {} }, .{
                .code = -32700,
                .message = "Failed to parse the MCP request body as JSON.",
                .data = @errorName(err),
            });
            continue;
        };

        try handleMessage(arena.allocator(), stdout, parsed.value);
    }

    try stdout.flush();
}

fn handleMessage(allocator: std.mem.Allocator, stdout: *std.Io.Writer, message: JsonValue) !void {
    const request = switch (message) {
        .object => |object| object,
        else => {
            try writeErrorResponse(allocator, stdout, JsonValue{ .null = {} }, .{
                .code = -32600,
                .message = "MCP requests must be JSON objects.",
                .data = null,
            });
            return;
        },
    };

    const id = request.get("id");
    const method = switch (request.get("method") orelse JsonValue{ .null = {} }) {
        .string => |value| value,
        else => {
            if (id) |request_id| {
                try writeErrorResponse(allocator, stdout, request_id, .{
                    .code = -32600,
                    .message = "MCP requests must include a string method.",
                    .data = null,
                });
            }
            return;
        },
    };

    if (std.mem.eql(u8, method, "notifications/initialized") or std.mem.eql(u8, method, "$/cancelRequest")) {
        return;
    }

    if (id == null) {
        return;
    }
    const request_id = id.?;

    if (std.mem.eql(u8, method, "initialize")) {
        const result = try buildInitializeResult(allocator);
        try writeResultResponse(allocator, stdout, request_id, result);
        return;
    }

    if (std.mem.eql(u8, method, "ping")) {
        const result = try emptyObjectValue(allocator);
        try writeResultResponse(allocator, stdout, request_id, result);
        return;
    }

    if (std.mem.eql(u8, method, "tools/list")) {
        const result = try buildToolsListResult(allocator);
        try writeResultResponse(allocator, stdout, request_id, result);
        return;
    }

    if (std.mem.eql(u8, method, "tools/call")) {
        try handleToolCall(allocator, stdout, request_id, request.get("params"));
        return;
    }

    try writeErrorResponse(allocator, stdout, request_id, .{
        .code = -32601,
        .message = "Unsupported MCP method.",
        .data = method,
    });
}

fn handleToolCall(allocator: std.mem.Allocator, stdout: *std.Io.Writer, id: JsonValue, params_value: ?JsonValue) !void {
    const params = switch (params_value orelse JsonValue{ .null = {} }) {
        .object => |object| object,
        else => {
            try writeErrorResponse(allocator, stdout, id, .{
                .code = -32602,
                .message = "tools/call params must be an object.",
                .data = null,
            });
            return;
        },
    };

    const tool_name = switch (params.get("name") orelse JsonValue{ .null = {} }) {
        .string => |value| value,
        else => {
            try writeErrorResponse(allocator, stdout, id, .{
                .code = -32602,
                .message = "tools/call params.name must be a string.",
                .data = null,
            });
            return;
        },
    };

    const arguments = switch (params.get("arguments") orelse JsonValue{ .null = {} }) {
        .null => null,
        .object => |object| object,
        else => {
            try writeErrorResponse(allocator, stdout, id, .{
                .code = -32602,
                .message = "tools/call params.arguments must be an object when present.",
                .data = null,
            });
            return;
        },
    };

    if (std.mem.eql(u8, tool_name, "system_os_info")) {
        try writeToolResponse(allocator, stdout, id, try runtime.systemOsInfo(allocator));
        return;
    }
    if (std.mem.eql(u8, tool_name, "system_cpu_info")) {
        try writeToolResponse(allocator, stdout, id, try runtime.systemCpuInfo(allocator));
        return;
    }
    if (std.mem.eql(u8, tool_name, "system_memory_info")) {
        try writeToolResponse(allocator, stdout, id, try runtime.systemMemoryInfo(allocator));
        return;
    }
    if (std.mem.eql(u8, tool_name, "system_disk_list")) {
        try writeToolResponse(allocator, stdout, id, try runtime.systemDiskList(allocator));
        return;
    }
    if (std.mem.eql(u8, tool_name, "system_process_list")) {
        try writeToolResponse(allocator, stdout, id, try runtime.systemProcessList(allocator));
        return;
    }
    if (std.mem.eql(u8, tool_name, "system_hardware_info")) {
        try writeToolResponse(allocator, stdout, id, try runtime.systemHardwareInfo(allocator));
        return;
    }
    if (std.mem.eql(u8, tool_name, "system_network_info")) {
        try writeToolResponse(allocator, stdout, id, try runtime.systemNetworkInfo(allocator));
        return;
    }
    if (std.mem.eql(u8, tool_name, "mouse_position")) {
        try writeToolResponse(allocator, stdout, id, try runtime.mousePosition(allocator));
        return;
    }
    if (std.mem.eql(u8, tool_name, "mouse_move")) {
        const x = (readOptionalI32(arguments, "x") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.invalid_args, "x must be a signed 32-bit integer when provided.", null));
            return;
        }) orelse {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.invalid_args, "x is required and must be a signed 32-bit integer.", null));
            return;
        };
        const y = (readOptionalI32(arguments, "y") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.invalid_args, "y must be a signed 32-bit integer when provided.", null));
            return;
        }) orelse {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.invalid_args, "y is required and must be a signed 32-bit integer.", null));
            return;
        };
        const duration_ms = readOptionalU32(arguments, "duration_ms") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.invalid_args, "duration_ms must be a non-negative integer when provided.", null));
            return;
        };
        const jitter_px = readOptionalI32(arguments, "jitter_px") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.invalid_args, "jitter_px must be a signed 32-bit integer when provided.", null));
            return;
        };
        const step_delay_ms = readOptionalU32(arguments, "step_delay_ms") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.invalid_args, "step_delay_ms must be a non-negative integer when provided.", null));
            return;
        };
        try writeToolResponse(allocator, stdout, id, try runtime.mouseMove(allocator, x, y, duration_ms, jitter_px, step_delay_ms));
        return;
    }
    if (std.mem.eql(u8, tool_name, "mouse_click")) {
        const button = (readOptionalMouseButton(arguments, "button") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "mouse.click", core.errors.codes.invalid_args, "button must be one of left, right, or middle when provided.", null));
            return;
        }) orelse .left;
        const count = (readOptionalU8(arguments, "count") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "mouse.click", core.errors.codes.invalid_args, "count must be an integer in range 1..255 when provided.", null));
            return;
        }) orelse 1;
        try writeToolResponse(allocator, stdout, id, try runtime.mouseClick(allocator, button, count));
        return;
    }
    if (std.mem.eql(u8, tool_name, "mouse_scroll")) {
        const delta = (readOptionalI32(arguments, "delta") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "mouse.scroll", core.errors.codes.invalid_args, "delta must be a signed 32-bit integer when provided.", null));
            return;
        }) orelse {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "mouse.scroll", core.errors.codes.invalid_args, "delta is required and must be a signed 32-bit integer.", null));
            return;
        };
        try writeToolResponse(allocator, stdout, id, try runtime.mouseScroll(allocator, delta));
        return;
    }
    if (std.mem.eql(u8, tool_name, "window_list")) {
        const include_hidden = readOptionalBool(arguments, "include_hidden") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WindowList, "window.list", core.errors.codes.invalid_args, "include_hidden must be a boolean when provided.", null));
            return;
        } orelse false;
        const pid = readOptionalU32(arguments, "pid") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WindowList, "window.list", core.errors.codes.invalid_args, "pid must be a non-negative 32-bit integer when provided.", null));
            return;
        };
        try writeToolResponse(allocator, stdout, id, try runtime.windowList(allocator, include_hidden, pid));
        return;
    }
    if (std.mem.eql(u8, tool_name, "window_foreground")) {
        try writeToolResponse(allocator, stdout, id, try runtime.windowForeground(allocator));
        return;
    }
    if (std.mem.eql(u8, tool_name, "window_activate")) {
        const handle = (readOptionalU64(arguments, "handle") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "window.activate", core.errors.codes.invalid_args, "handle must be a non-negative integer when provided.", null));
            return;
        }) orelse {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "window.activate", core.errors.codes.invalid_args, "handle is required and must be a non-negative integer.", null));
            return;
        };
        try writeToolResponse(allocator, stdout, id, try runtime.windowActivate(allocator, handle));
        return;
    }
    if (std.mem.eql(u8, tool_name, "window_show")) {
        const handle = (readOptionalU64(arguments, "handle") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "window.show", core.errors.codes.invalid_args, "handle must be a non-negative integer when provided.", null));
            return;
        }) orelse {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "window.show", core.errors.codes.invalid_args, "handle is required and must be a non-negative integer.", null));
            return;
        };
        try writeToolResponse(allocator, stdout, id, try runtime.windowShow(allocator, handle));
        return;
    }
    if (std.mem.eql(u8, tool_name, "window_minimize")) {
        const handle = (readOptionalU64(arguments, "handle") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "window.minimize", core.errors.codes.invalid_args, "handle must be a non-negative integer when provided.", null));
            return;
        }) orelse {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "window.minimize", core.errors.codes.invalid_args, "handle is required and must be a non-negative integer.", null));
            return;
        };
        try writeToolResponse(allocator, stdout, id, try runtime.windowMinimize(allocator, handle));
        return;
    }
    if (std.mem.eql(u8, tool_name, "window_maximize")) {
        const handle = (readOptionalU64(arguments, "handle") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "window.maximize", core.errors.codes.invalid_args, "handle must be a non-negative integer when provided.", null));
            return;
        }) orelse {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "window.maximize", core.errors.codes.invalid_args, "handle is required and must be a non-negative integer.", null));
            return;
        };
        try writeToolResponse(allocator, stdout, id, try runtime.windowMaximize(allocator, handle));
        return;
    }
    if (std.mem.eql(u8, tool_name, "window_restore")) {
        const handle = (readOptionalU64(arguments, "handle") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "window.restore", core.errors.codes.invalid_args, "handle must be a non-negative integer when provided.", null));
            return;
        }) orelse {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "window.restore", core.errors.codes.invalid_args, "handle is required and must be a non-negative integer.", null));
            return;
        };
        try writeToolResponse(allocator, stdout, id, try runtime.windowRestore(allocator, handle));
        return;
    }
    if (std.mem.eql(u8, tool_name, "window_move")) {
        const handle = (readOptionalU64(arguments, "handle") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "window.move", core.errors.codes.invalid_args, "handle must be a non-negative integer when provided.", null));
            return;
        }) orelse {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "window.move", core.errors.codes.invalid_args, "handle is required and must be a non-negative integer.", null));
            return;
        };
        const x = (readOptionalI32(arguments, "x") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "window.move", core.errors.codes.invalid_args, "x must be a signed 32-bit integer when provided.", null));
            return;
        }) orelse {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "window.move", core.errors.codes.invalid_args, "x is required and must be a signed 32-bit integer.", null));
            return;
        };
        const y = (readOptionalI32(arguments, "y") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "window.move", core.errors.codes.invalid_args, "y must be a signed 32-bit integer when provided.", null));
            return;
        }) orelse {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "window.move", core.errors.codes.invalid_args, "y is required and must be a signed 32-bit integer.", null));
            return;
        };
        const width = readOptionalI32(arguments, "width") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "window.move", core.errors.codes.invalid_args, "width must be a signed 32-bit integer when provided.", null));
            return;
        };
        const height = readOptionalI32(arguments, "height") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "window.move", core.errors.codes.invalid_args, "height must be a signed 32-bit integer when provided.", null));
            return;
        };

        try writeToolResponse(allocator, stdout, id, try runtime.windowMove(allocator, handle, x, y, width, height));
        return;
    }
    if (std.mem.eql(u8, tool_name, "window_find")) {
        const title = readRequiredString(arguments, "title") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WindowMatch, "window.find", core.errors.codes.invalid_args, "title is required and must be a string.", null));
            return;
        } orelse unreachable;
        const match_mode = readOptionalMatchMode(arguments) catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WindowMatch, "window.find", core.errors.codes.invalid_args, "match must be 'contains' or 'exact' when provided.", null));
            return;
        } orelse .contains;
        const include_hidden = readOptionalBool(arguments, "include_hidden") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WindowMatch, "window.find", core.errors.codes.invalid_args, "include_hidden must be a boolean when provided.", null));
            return;
        } orelse false;
        const pid = readOptionalU32(arguments, "pid") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WindowMatch, "window.find", core.errors.codes.invalid_args, "pid must be a non-negative 32-bit integer when provided.", null));
            return;
        };
        try writeToolResponse(allocator, stdout, id, try runtime.windowFind(allocator, title, match_mode, include_hidden, pid));
        return;
    }
    if (std.mem.eql(u8, tool_name, "window_close")) {
        const handle = (readOptionalU64(arguments, "handle") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "window.close", core.errors.codes.invalid_args, "handle must be a non-negative integer when provided.", null));
            return;
        }) orelse {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "window.close", core.errors.codes.invalid_args, "handle is required and must be a non-negative integer.", null));
            return;
        };
        try writeToolResponse(allocator, stdout, id, try runtime.windowClose(allocator, handle));
        return;
    }
    if (std.mem.eql(u8, tool_name, "app_launch")) {
        const target = readRequiredString(arguments, "target") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "app.launch", core.errors.codes.invalid_args, "target is required and must be a string.", null));
            return;
        } orelse unreachable;
        try writeToolResponse(allocator, stdout, id, try runtime.appLaunch(allocator, target));
        return;
    }
    if (std.mem.eql(u8, tool_name, "clipboard_get_text")) {
        try writeToolResponse(allocator, stdout, id, try runtime.clipboardGetText(allocator));
        return;
    }
    if (std.mem.eql(u8, tool_name, "clipboard_set_text")) {
        const text = readRequiredString(arguments, "text") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "clipboard.set_text", core.errors.codes.invalid_args, "text is required and must be a string.", null));
            return;
        } orelse unreachable;
        try writeToolResponse(allocator, stdout, id, try runtime.clipboardSetText(allocator, text));
        return;
    }
    if (std.mem.eql(u8, tool_name, "clipboard_get_files")) {
        try writeToolResponse(allocator, stdout, id, try runtime.clipboardGetFiles(allocator));
        return;
    }
    if (std.mem.eql(u8, tool_name, "clipboard_set_files")) {
        const paths = readRequiredString(arguments, "paths") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "clipboard.set_files", core.errors.codes.invalid_args, "paths is required and must be a string.", null));
            return;
        } orelse unreachable;
        try writeToolResponse(allocator, stdout, id, try runtime.clipboardSetFiles(allocator, paths));
        return;
    }
    if (std.mem.eql(u8, tool_name, "clipboard_set_image")) {
        const path = readRequiredString(arguments, "path") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "clipboard.set_image", core.errors.codes.invalid_args, "path is required and must be a string.", null));
            return;
        } orelse unreachable;
        try writeToolResponse(allocator, stdout, id, try runtime.clipboardSetImage(allocator, path));
        return;
    }
    if (std.mem.eql(u8, tool_name, "keyboard_key_press")) {
        const key = readRequiredString(arguments, "key") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "keyboard.key_press", core.errors.codes.invalid_args, "key is required and must be a string.", null));
            return;
        } orelse unreachable;
        try writeToolResponse(allocator, stdout, id, try runtime.keyboardKeyPress(allocator, key));
        return;
    }
    if (std.mem.eql(u8, tool_name, "keyboard_hotkey")) {
        const keys = readRequiredString(arguments, "keys") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "keyboard.hotkey", core.errors.codes.invalid_args, "keys is required and must be a string.", null));
            return;
        } orelse unreachable;
        try writeToolResponse(allocator, stdout, id, try runtime.keyboardHotkey(allocator, keys));
        return;
    }
    if (std.mem.eql(u8, tool_name, "keyboard_type_text")) {
        const text = readRequiredString(arguments, "text") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "keyboard.type_text", core.errors.codes.invalid_args, "text is required and must be a string.", null));
            return;
        } orelse unreachable;
        try writeToolResponse(allocator, stdout, id, try runtime.keyboardTypeText(allocator, text));
        return;
    }
    if (std.mem.eql(u8, tool_name, "keyboard_type_keys")) {
        const text = readRequiredString(arguments, "text") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "keyboard.type_keys", core.errors.codes.invalid_args, "text is required and must be a string.", null));
            return;
        } orelse unreachable;
        const key_delay_ms = readOptionalU32(arguments, "key_delay_ms") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "keyboard.type_keys", core.errors.codes.invalid_args, "key_delay_ms must be a non-negative integer when provided.", null));
            return;
        };
        try writeToolResponse(allocator, stdout, id, try runtime.keyboardTypeKeys(allocator, text, key_delay_ms));
        return;
    }
    if (std.mem.eql(u8, tool_name, "keyboard_ime_switch")) {
        const strategy = readOptionalString(arguments, "strategy") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "keyboard.ime_switch", core.errors.codes.invalid_args, "strategy must be a string when provided.", null));
            return;
        };
        try writeToolResponse(allocator, stdout, id, try runtime.keyboardImeSwitch(allocator, strategy));
        return;
    }
    if (std.mem.eql(u8, tool_name, "keyboard_caps_lock")) {
        const state = readOptionalString(arguments, "state") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "keyboard.caps_lock", core.errors.codes.invalid_args, "state must be a string when provided.", null));
            return;
        };
        try writeToolResponse(allocator, stdout, id, try runtime.keyboardCapsLock(allocator, state));
        return;
    }
    if (std.mem.eql(u8, tool_name, "keyboard_paste")) {
        const expected_title = readOptionalString(arguments, "expect_title") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "keyboard.paste", core.errors.codes.invalid_args, "expect_title must be a string when provided.", null));
            return;
        };
        const match_mode = readOptionalMatchMode(arguments) catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.Ack, "keyboard.paste", core.errors.codes.invalid_args, "match must be 'contains' or 'exact' when provided.", null));
            return;
        } orelse .contains;
        try writeToolResponse(allocator, stdout, id, try runtime.keyboardPaste(allocator, expected_title, match_mode));
        return;
    }
    if (std.mem.eql(u8, tool_name, "screen_capture")) {
        const path = (readOptionalString(arguments, "path") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.invalid_args, "path must be a string when provided.", null));
            return;
        }) orelse try std.fmt.allocPrint(allocator, "zig-out/captures/easytouch-mcp-capture.png", .{});
        const display_id = readOptionalU32(arguments, "display_id") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.invalid_args, "display_id must be a non-negative 32-bit integer when provided.", null));
            return;
        };
        const window_handle = readOptionalU64(arguments, "window_handle") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.invalid_args, "window_handle must be a non-negative integer when provided.", null));
            return;
        };
        if (display_id != null and window_handle != null) {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.invalid_args, "display_id and window_handle cannot be used together.", null));
            return;
        }

        try writeToolResponse(allocator, stdout, id, try runtime.screenCapture(allocator, path, display_id, window_handle));
        return;
    }
    if (std.mem.eql(u8, tool_name, "screen_pixel_color")) {
        const x = (readOptionalI32(arguments, "x") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.PixelColor, "screen.pixel_color", core.errors.codes.invalid_args, "x must be a signed 32-bit integer when provided.", null));
            return;
        }) orelse {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.PixelColor, "screen.pixel_color", core.errors.codes.invalid_args, "x is required and must be a signed 32-bit integer.", null));
            return;
        };
        const y = (readOptionalI32(arguments, "y") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.PixelColor, "screen.pixel_color", core.errors.codes.invalid_args, "y must be a signed 32-bit integer when provided.", null));
            return;
        }) orelse {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.PixelColor, "screen.pixel_color", core.errors.codes.invalid_args, "y is required and must be a signed 32-bit integer.", null));
            return;
        };
        try writeToolResponse(allocator, stdout, id, try runtime.screenPixelColor(allocator, x, y));
        return;
    }
    if (std.mem.eql(u8, tool_name, "screen_displays")) {
        try writeToolResponse(allocator, stdout, id, try runtime.screenDisplays(allocator));
        return;
    }
    if (std.mem.eql(u8, tool_name, "wait_window")) {
        const title = readRequiredString(arguments, "title") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitWindow, "wait.window", core.errors.codes.invalid_args, "title is required and must be a string.", null));
            return;
        } orelse unreachable;
        const timeout_ms = readOptionalU64(arguments, "timeout_ms") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitWindow, "wait.window", core.errors.codes.invalid_args, "timeout_ms must be a non-negative integer when provided.", null));
            return;
        } orelse 2000;
        const match_mode = readOptionalMatchMode(arguments) catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitWindow, "wait.window", core.errors.codes.invalid_args, "match must be 'contains' or 'exact' when provided.", null));
            return;
        } orelse .contains;
        const foreground_only = readOptionalBool(arguments, "foreground_only") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitWindow, "wait.window", core.errors.codes.invalid_args, "foreground_only must be a boolean when provided.", null));
            return;
        } orelse false;
        try writeToolResponse(allocator, stdout, id, try runtime.waitWindow(allocator, title, timeout_ms, match_mode, foreground_only));
        return;
    }
    if (std.mem.eql(u8, tool_name, "wait_focus")) {
        const title = readRequiredString(arguments, "title") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitWindow, "wait.focus", core.errors.codes.invalid_args, "title is required and must be a string.", null));
            return;
        } orelse unreachable;
        const timeout_ms = readOptionalU64(arguments, "timeout_ms") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitWindow, "wait.focus", core.errors.codes.invalid_args, "timeout_ms must be a non-negative integer when provided.", null));
            return;
        } orelse 2000;
        const match_mode = readOptionalMatchMode(arguments) catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitWindow, "wait.focus", core.errors.codes.invalid_args, "match must be 'contains' or 'exact' when provided.", null));
            return;
        } orelse .contains;
        try writeToolResponse(allocator, stdout, id, try runtime.waitFocus(allocator, title, timeout_ms, match_mode));
        return;
    }
    if (std.mem.eql(u8, tool_name, "wait_activate")) {
        const handle = (readOptionalU64(arguments, "handle") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitWindow, "wait.activate", core.errors.codes.invalid_args, "handle must be a non-negative integer when provided.", null));
            return;
        }) orelse {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitWindow, "wait.activate", core.errors.codes.invalid_args, "handle is required and must be a non-negative integer.", null));
            return;
        };
        const timeout_ms = readOptionalU64(arguments, "timeout_ms") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitWindow, "wait.activate", core.errors.codes.invalid_args, "timeout_ms must be a non-negative integer when provided.", null));
            return;
        } orelse 2000;
        const expect_active = readOptionalBool(arguments, "expect_active") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitWindow, "wait.activate", core.errors.codes.invalid_args, "expect_active must be a boolean when provided.", null));
            return;
        } orelse true;
        try writeToolResponse(allocator, stdout, id, try runtime.waitActivate(allocator, handle, timeout_ms, expect_active));
        return;
    }
    if (std.mem.eql(u8, tool_name, "wait_pixel")) {
        const x = (readOptionalI32(arguments, "x") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitPixel, "wait.pixel", core.errors.codes.invalid_args, "x must be a signed 32-bit integer when provided.", null));
            return;
        }) orelse {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitPixel, "wait.pixel", core.errors.codes.invalid_args, "x is required and must be a signed 32-bit integer.", null));
            return;
        };
        const y = (readOptionalI32(arguments, "y") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitPixel, "wait.pixel", core.errors.codes.invalid_args, "y must be a signed 32-bit integer when provided.", null));
            return;
        }) orelse {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitPixel, "wait.pixel", core.errors.codes.invalid_args, "y is required and must be a signed 32-bit integer.", null));
            return;
        };
        const hex = readRequiredString(arguments, "hex") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitPixel, "wait.pixel", core.errors.codes.invalid_args, "hex is required and must be a string.", null));
            return;
        } orelse unreachable;
        const timeout_ms = readOptionalU64(arguments, "timeout_ms") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitPixel, "wait.pixel", core.errors.codes.invalid_args, "timeout_ms must be a non-negative integer when provided.", null));
            return;
        } orelse 2000;
        try writeToolResponse(allocator, stdout, id, try runtime.waitPixel(allocator, x, y, hex, timeout_ms));
        return;
    }
    if (std.mem.eql(u8, tool_name, "wait_clipboard")) {
        const expected_text = readOptionalString(arguments, "expect_text") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitClipboard, "wait.clipboard", core.errors.codes.invalid_args, "expect_text must be a string when provided.", null));
            return;
        };
        const timeout_ms = readOptionalU64(arguments, "timeout_ms") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitClipboard, "wait.clipboard", core.errors.codes.invalid_args, "timeout_ms must be a non-negative integer when provided.", null));
            return;
        } orelse 2000;
        const match_mode = readOptionalMatchMode(arguments) catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitClipboard, "wait.clipboard", core.errors.codes.invalid_args, "match must be 'contains' or 'exact' when provided.", null));
            return;
        } orelse .contains;
        try writeToolResponse(allocator, stdout, id, try runtime.waitClipboard(allocator, expected_text, timeout_ms, match_mode));
        return;
    }
    if (std.mem.eql(u8, tool_name, "wait_process")) {
        const name = readOptionalString(arguments, "name") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitProcess, "wait.process", core.errors.codes.invalid_args, "name must be a string when provided.", null));
            return;
        };
        const pid = readOptionalU32(arguments, "pid") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitProcess, "wait.process", core.errors.codes.invalid_args, "pid must be a non-negative 32-bit integer when provided.", null));
            return;
        };
        const expect_running = readOptionalBool(arguments, "expect_running") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitProcess, "wait.process", core.errors.codes.invalid_args, "expect_running must be a boolean when provided.", null));
            return;
        } orelse true;
        const timeout_ms = readOptionalU64(arguments, "timeout_ms") catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitProcess, "wait.process", core.errors.codes.invalid_args, "timeout_ms must be a non-negative integer when provided.", null));
            return;
        } orelse 2000;
        const match_mode = readOptionalMatchMode(arguments) catch {
            try writeToolResponse(allocator, stdout, id, core.model.failure(core.model.WaitProcess, "wait.process", core.errors.codes.invalid_args, "match must be 'contains' or 'exact' when provided.", null));
            return;
        } orelse .contains;
        try writeToolResponse(allocator, stdout, id, try runtime.waitProcess(allocator, name, pid, expect_running, timeout_ms, match_mode));
        return;
    }

    try writeErrorResponse(allocator, stdout, id, .{
        .code = -32602,
        .message = "Unknown EasyTouch tool.",
        .data = tool_name,
    });
}

fn readFramedMessage(allocator: std.mem.Allocator, stdin: *std.Io.Reader) !?[]u8 {
    var content_length: ?usize = null;
    var saw_header = false;

    while (true) {
        const raw_line = (stdin.takeDelimiter('\n') catch |err| switch (err) {
            error.ReadFailed, error.StreamTooLong => return err,
        }) orelse if (!saw_header) return null else return error.UnexpectedEndOfStream;
        saw_header = true;

        const line = std.mem.trimRight(u8, raw_line, "\r");
        if (line.len == 0) break;

        if (std.mem.startsWith(u8, line, "Content-Length:")) {
            const value = std.mem.trim(u8, line["Content-Length:".len..], " ");
            content_length = try std.fmt.parseInt(usize, value, 10);
        }
    }

    const length = content_length orelse return error.MissingContentLength;
    const body = try allocator.alloc(u8, length);
    var buffers = [_][]u8{body};
    try stdin.readVecAll(&buffers);
    return body;
}

fn writeResultResponse(allocator: std.mem.Allocator, stdout: *std.Io.Writer, id: JsonValue, result: JsonValue) !void {
    var body = std.ArrayList(u8).empty;
    defer body.deinit(allocator);

    const body_writer = body.writer(allocator);
    var adapter = body_writer.adaptToNewApi(&.{});
    const writer = &adapter.new_interface;

    try writer.writeAll("{\"jsonrpc\":\"2.0\",\"id\":");
    try std.json.Stringify.value(id, .{}, writer);
    try writer.writeAll(",\"result\":");
    try std.json.Stringify.value(result, .{}, writer);
    try writer.writeByte('}');

    try writeFramedBody(stdout, body.items);
}

fn writeErrorResponse(allocator: std.mem.Allocator, stdout: *std.Io.Writer, id: JsonValue, rpc_error: RpcError) !void {
    var body = std.ArrayList(u8).empty;
    defer body.deinit(allocator);

    const body_writer = body.writer(allocator);
    var adapter = body_writer.adaptToNewApi(&.{});
    const writer = &adapter.new_interface;

    try writer.writeAll("{\"jsonrpc\":\"2.0\",\"id\":");
    try std.json.Stringify.value(id, .{}, writer);
    try writer.writeAll(",\"error\":{");
    try writer.writeAll("\"code\":");
    try std.json.Stringify.value(rpc_error.code, .{}, writer);
    try writer.writeAll(",\"message\":");
    try std.json.Stringify.value(rpc_error.message, .{}, writer);
    if (rpc_error.data) |data| {
        try writer.writeAll(",\"data\":");
        try std.json.Stringify.value(data, .{}, writer);
    }
    try writer.writeAll("}}");

    try writeFramedBody(stdout, body.items);
}

fn writeToolResponse(allocator: std.mem.Allocator, stdout: *std.Io.Writer, id: JsonValue, response: anytype) !void {
    const summary = try toolResponseSummary(allocator, response);

    var body = std.ArrayList(u8).empty;
    defer body.deinit(allocator);

    const body_writer = body.writer(allocator);
    var adapter = body_writer.adaptToNewApi(&.{});
    const writer = &adapter.new_interface;

    try writer.writeAll("{\"jsonrpc\":\"2.0\",\"id\":");
    try std.json.Stringify.value(id, .{}, writer);
    try writer.writeAll(",\"result\":{");
    try writer.writeAll("\"content\":[{");
    try writer.writeAll("\"type\":\"text\",\"text\":");
    try std.json.Stringify.value(summary, .{}, writer);
    try writer.writeAll("}],\"structuredContent\":");
    try std.json.Stringify.value(response, .{}, writer);
    try writer.writeAll(",\"isError\":");
    try std.json.Stringify.value(!response.ok, .{}, writer);
    try writer.writeAll("}}");

    try writeFramedBody(stdout, body.items);
}

fn writeFramedBody(stdout: *std.Io.Writer, body: []const u8) !void {
    try stdout.print("Content-Length: {d}\r\n\r\n", .{body.len});
    try stdout.writeAll(body);
    try stdout.flush();
}

fn buildInitializeResult(allocator: std.mem.Allocator) !JsonValue {
    var result = JsonObject.init(allocator);
    var capabilities = JsonObject.init(allocator);
    var tools = JsonObject.init(allocator);
    var server_info = JsonObject.init(allocator);

    try putBool(&tools, "listChanged", false);
    try capabilities.put("tools", .{ .object = tools });

    try putString(&server_info, "name", "easytouch");
    try putString(&server_info, "version", server_version);

    try putString(&result, "protocolVersion", protocol_version);
    try result.put("capabilities", .{ .object = capabilities });
    try result.put("serverInfo", .{ .object = server_info });
    try putString(&result, "instructions", "Use tools/list to inspect the EasyTouch registry, then tools/call to run the shared runtime capabilities.");

    return .{ .object = result };
}

fn buildToolsListResult(allocator: std.mem.Allocator) !JsonValue {
    var tools = JsonArray.init(allocator);

    for (core.capability.all) |item| {
        var tool = JsonObject.init(allocator);
        try putString(&tool, "name", item.mcp_tool);
        try putString(&tool, "description", item.summary);
        try tool.put("inputSchema", try buildInputSchema(allocator, item.mcp_tool));
        try tools.append(.{ .object = tool });
    }

    var result = JsonObject.init(allocator);
    try result.put("tools", .{ .array = tools });
    return .{ .object = result };
}

fn buildInputSchema(allocator: std.mem.Allocator, tool_name: []const u8) !JsonValue {
    if (std.mem.eql(u8, tool_name, "system_os_info")) {
        return buildSchema(allocator, &.{}, &.{});
    }
    if (std.mem.eql(u8, tool_name, "system_cpu_info") or std.mem.eql(u8, tool_name, "system_memory_info") or std.mem.eql(u8, tool_name, "system_disk_list") or std.mem.eql(u8, tool_name, "system_process_list")) {
        return buildSchema(allocator, &.{}, &.{});
    }
    if (std.mem.eql(u8, tool_name, "system_hardware_info") or std.mem.eql(u8, tool_name, "system_network_info")) {
        return buildSchema(allocator, &.{}, &.{});
    }
    if (std.mem.eql(u8, tool_name, "mouse_position")) {
        return buildSchema(allocator, &.{}, &.{});
    }
    if (std.mem.eql(u8, tool_name, "mouse_move")) {
        return buildSchema(allocator, &.{
            .{ .key = "x", .type_name = "integer", .description = "Target cursor x coordinate on the virtual desktop." },
            .{ .key = "y", .type_name = "integer", .description = "Target cursor y coordinate on the virtual desktop." },
            .{ .key = "duration_ms", .type_name = "integer", .description = "Optional total move duration in milliseconds. Defaults to 280." },
            .{ .key = "jitter_px", .type_name = "integer", .description = "Optional jitter amplitude in pixels for human-like wobble. Defaults to 3." },
            .{ .key = "step_delay_ms", .type_name = "integer", .description = "Optional per-step delay in milliseconds. Defaults to 8." },
        }, &.{ "x", "y" });
    }
    if (std.mem.eql(u8, tool_name, "mouse_click")) {
        return buildSchema(allocator, &.{
            .{ .key = "button", .type_name = "string", .description = "Mouse button to click.", .enum_values = &.{ "left", "right", "middle" } },
            .{ .key = "count", .type_name = "integer", .description = "How many click cycles to send. Defaults to 1." },
        }, &.{});
    }
    if (std.mem.eql(u8, tool_name, "mouse_scroll")) {
        return buildSchema(allocator, &.{
            .{ .key = "delta", .type_name = "integer", .description = "Wheel delta to send. Positive scrolls up, negative scrolls down." },
        }, &.{"delta"});
    }
    if (std.mem.eql(u8, tool_name, "window_list")) {
        return buildSchema(allocator, &.{
            .{ .key = "include_hidden", .type_name = "boolean", .description = "Include invisible or background helper windows in the result set." },
            .{ .key = "pid", .type_name = "integer", .description = "Optionally limit the result set to one process id." },
        }, &.{});
    }
    if (std.mem.eql(u8, tool_name, "window_foreground")) {
        return buildSchema(allocator, &.{}, &.{});
    }
    if (std.mem.eql(u8, tool_name, "window_activate")) {
        return buildSchema(allocator, &.{
            .{ .key = "handle", .type_name = "integer", .description = "Top-level window handle to activate, usually copied from window_list or window_foreground." },
        }, &.{"handle"});
    }
    if (std.mem.eql(u8, tool_name, "window_show")) {
        return buildSchema(allocator, &.{
            .{ .key = "handle", .type_name = "integer", .description = "Top-level window handle to show and activate." },
        }, &.{"handle"});
    }
    if (std.mem.eql(u8, tool_name, "window_minimize")) {
        return buildSchema(allocator, &.{
            .{ .key = "handle", .type_name = "integer", .description = "Top-level window handle to minimize." },
        }, &.{"handle"});
    }
    if (std.mem.eql(u8, tool_name, "window_maximize")) {
        return buildSchema(allocator, &.{
            .{ .key = "handle", .type_name = "integer", .description = "Top-level window handle to maximize." },
        }, &.{"handle"});
    }
    if (std.mem.eql(u8, tool_name, "window_restore")) {
        return buildSchema(allocator, &.{
            .{ .key = "handle", .type_name = "integer", .description = "Top-level window handle to restore." },
        }, &.{"handle"});
    }
    if (std.mem.eql(u8, tool_name, "window_move")) {
        return buildSchema(allocator, &.{
            .{ .key = "handle", .type_name = "integer", .description = "Top-level window handle to move." },
            .{ .key = "x", .type_name = "integer", .description = "Target left coordinate." },
            .{ .key = "y", .type_name = "integer", .description = "Target top coordinate." },
            .{ .key = "width", .type_name = "integer", .description = "Optional target width. Defaults to current width." },
            .{ .key = "height", .type_name = "integer", .description = "Optional target height. Defaults to current height." },
        }, &.{ "handle", "x", "y" });
    }
    if (std.mem.eql(u8, tool_name, "window_find")) {
        return buildSchema(allocator, &.{
            .{ .key = "title", .type_name = "string", .description = "Window title text to search for." },
            .{ .key = "match", .type_name = "string", .description = "How to compare title text.", .enum_values = &.{ "contains", "exact" } },
            .{ .key = "include_hidden", .type_name = "boolean", .description = "Include invisible or helper windows while searching." },
            .{ .key = "pid", .type_name = "integer", .description = "Optional process id filter." },
        }, &.{"title"});
    }
    if (std.mem.eql(u8, tool_name, "window_close")) {
        return buildSchema(allocator, &.{
            .{ .key = "handle", .type_name = "integer", .description = "Top-level window handle to close." },
        }, &.{"handle"});
    }
    if (std.mem.eql(u8, tool_name, "app_launch")) {
        return buildSchema(allocator, &.{
            .{ .key = "target", .type_name = "string", .description = "Executable path, document path, or URI to open via host shell." },
        }, &.{"target"});
    }
    if (std.mem.eql(u8, tool_name, "clipboard_get_text")) {
        return buildSchema(allocator, &.{}, &.{});
    }
    if (std.mem.eql(u8, tool_name, "clipboard_set_text")) {
        return buildSchema(allocator, &.{
            .{ .key = "text", .type_name = "string", .description = "Unicode text to place on the clipboard." },
        }, &.{"text"});
    }
    if (std.mem.eql(u8, tool_name, "clipboard_get_files")) {
        return buildSchema(allocator, &.{}, &.{});
    }
    if (std.mem.eql(u8, tool_name, "clipboard_set_files")) {
        return buildSchema(allocator, &.{
            .{ .key = "paths", .type_name = "string", .description = "Semicolon-separated file paths to place into clipboard file-drop payload." },
        }, &.{"paths"});
    }
    if (std.mem.eql(u8, tool_name, "clipboard_set_image")) {
        return buildSchema(allocator, &.{
            .{ .key = "path", .type_name = "string", .description = "Image file path to load into clipboard bitmap content." },
        }, &.{"path"});
    }
    if (std.mem.eql(u8, tool_name, "keyboard_key_press")) {
        return buildSchema(allocator, &.{
            .{ .key = "key", .type_name = "string", .description = "Virtual key name such as A, ENTER, TAB, F5, LEFT." },
        }, &.{"key"});
    }
    if (std.mem.eql(u8, tool_name, "keyboard_hotkey")) {
        return buildSchema(allocator, &.{
            .{ .key = "keys", .type_name = "string", .description = "Key combo string such as ctrl+shift+s or alt+tab." },
        }, &.{"keys"});
    }
    if (std.mem.eql(u8, tool_name, "keyboard_type_text")) {
        return buildSchema(allocator, &.{
            .{ .key = "text", .type_name = "string", .description = "Unicode text to type into the focused control." },
        }, &.{"text"});
    }
    if (std.mem.eql(u8, tool_name, "keyboard_type_keys")) {
        return buildSchema(allocator, &.{
            .{ .key = "text", .type_name = "string", .description = "Text to type by keyboard layout key positions instead of direct Unicode injection." },
            .{ .key = "key_delay_ms", .type_name = "integer", .description = "Optional delay per typed key in milliseconds. Defaults to 30." },
        }, &.{"text"});
    }
    if (std.mem.eql(u8, tool_name, "keyboard_ime_switch")) {
        return buildSchema(allocator, &.{
            .{ .key = "strategy", .type_name = "string", .description = "IME switch shortcut strategy.", .enum_values = &.{ "win-space", "alt-shift", "ctrl-shift" } },
        }, &.{});
    }
    if (std.mem.eql(u8, tool_name, "keyboard_caps_lock")) {
        return buildSchema(allocator, &.{
            .{ .key = "state", .type_name = "string", .description = "Target caps lock state.", .enum_values = &.{ "toggle", "on", "off" } },
        }, &.{});
    }
    if (std.mem.eql(u8, tool_name, "keyboard_paste")) {
        return buildSchema(allocator, &.{
            .{ .key = "expect_title", .type_name = "string", .description = "Optional foreground title guard for safe Ctrl+V delivery." },
            .{ .key = "match", .type_name = "string", .description = "How to match the expected title when guarding paste.", .enum_values = &.{ "contains", "exact" } },
        }, &.{});
    }
    if (std.mem.eql(u8, tool_name, "screen_capture")) {
        return buildSchema(allocator, &.{
            .{ .key = "path", .type_name = "string", .description = "Optional PNG output path. Defaults to zig-out/captures/easytouch-mcp-capture.png." },
            .{ .key = "display_id", .type_name = "integer", .description = "Optional display id from screen_displays. If omitted, captures all displays." },
            .{ .key = "window_handle", .type_name = "integer", .description = "Optional window handle for capturing a specific window." },
        }, &.{});
    }
    if (std.mem.eql(u8, tool_name, "screen_pixel_color")) {
        return buildSchema(allocator, &.{
            .{ .key = "x", .type_name = "integer", .description = "Virtual desktop x coordinate." },
            .{ .key = "y", .type_name = "integer", .description = "Virtual desktop y coordinate." },
        }, &.{ "x", "y" });
    }
    if (std.mem.eql(u8, tool_name, "screen_displays")) {
        return buildSchema(allocator, &.{}, &.{});
    }
    if (std.mem.eql(u8, tool_name, "wait_window")) {
        return buildSchema(allocator, &.{
            .{ .key = "title", .type_name = "string", .description = "Window title text to wait for." },
            .{ .key = "timeout_ms", .type_name = "integer", .description = "Timeout in milliseconds before returning timeout." },
            .{ .key = "match", .type_name = "string", .description = "How to compare the title text.", .enum_values = &.{ "contains", "exact" } },
            .{ .key = "foreground_only", .type_name = "boolean", .description = "Only match the current foreground window." },
        }, &.{"title"});
    }
    if (std.mem.eql(u8, tool_name, "wait_focus")) {
        return buildSchema(allocator, &.{
            .{ .key = "title", .type_name = "string", .description = "Foreground window title text to wait for." },
            .{ .key = "timeout_ms", .type_name = "integer", .description = "Timeout in milliseconds before returning timeout." },
            .{ .key = "match", .type_name = "string", .description = "How to compare the title text.", .enum_values = &.{ "contains", "exact" } },
        }, &.{"title"});
    }
    if (std.mem.eql(u8, tool_name, "wait_activate")) {
        return buildSchema(allocator, &.{
            .{ .key = "handle", .type_name = "integer", .description = "Target window handle to monitor activation state." },
            .{ .key = "timeout_ms", .type_name = "integer", .description = "Timeout in milliseconds before returning timeout." },
            .{ .key = "expect_active", .type_name = "boolean", .description = "When true wait for activation; when false wait for deactivation." },
        }, &.{"handle"});
    }
    if (std.mem.eql(u8, tool_name, "wait_pixel")) {
        return buildSchema(allocator, &.{
            .{ .key = "x", .type_name = "integer", .description = "Virtual desktop x coordinate." },
            .{ .key = "y", .type_name = "integer", .description = "Virtual desktop y coordinate." },
            .{ .key = "hex", .type_name = "string", .description = "Expected color in RRGGBB or #RRGGBB format." },
            .{ .key = "timeout_ms", .type_name = "integer", .description = "Timeout in milliseconds before returning timeout." },
        }, &.{ "x", "y", "hex" });
    }
    if (std.mem.eql(u8, tool_name, "wait_clipboard")) {
        return buildSchema(allocator, &.{
            .{ .key = "expect_text", .type_name = "string", .description = "Optional expected clipboard text; if omitted waits for any text change." },
            .{ .key = "timeout_ms", .type_name = "integer", .description = "Timeout in milliseconds before returning timeout." },
            .{ .key = "match", .type_name = "string", .description = "How to compare expected text.", .enum_values = &.{ "contains", "exact" } },
        }, &.{});
    }
    if (std.mem.eql(u8, tool_name, "wait_process")) {
        return buildSchema(allocator, &.{
            .{ .key = "name", .type_name = "string", .description = "Optional process name match condition." },
            .{ .key = "pid", .type_name = "integer", .description = "Optional process id to monitor." },
            .{ .key = "expect_running", .type_name = "boolean", .description = "Expected process state. true=wait until running, false=wait until absent." },
            .{ .key = "timeout_ms", .type_name = "integer", .description = "Timeout in milliseconds before returning timeout." },
            .{ .key = "match", .type_name = "string", .description = "How to compare process name.", .enum_values = &.{ "contains", "exact" } },
        }, &.{});
    }

    return buildSchema(allocator, &.{}, &.{});
}

fn buildSchema(allocator: std.mem.Allocator, specs: []const PropertySpec, required_keys: []const []const u8) !JsonValue {
    var schema = JsonObject.init(allocator);
    var properties = JsonObject.init(allocator);

    try putString(&schema, "type", "object");

    for (specs) |spec| {
        var property = JsonObject.init(allocator);
        try putString(&property, "type", spec.type_name);
        try putString(&property, "description", spec.description);
        if (spec.enum_values) |values| {
            var enum_values = JsonArray.init(allocator);
            for (values) |value| {
                try enum_values.append(.{ .string = value });
            }
            try property.put("enum", .{ .array = enum_values });
        }
        try properties.put(spec.key, .{ .object = property });
    }

    try schema.put("properties", .{ .object = properties });
    if (required_keys.len != 0) {
        var required = JsonArray.init(allocator);
        for (required_keys) |key| {
            try required.append(.{ .string = key });
        }
        try schema.put("required", .{ .array = required });
    }
    try putBool(&schema, "additionalProperties", false);

    return .{ .object = schema };
}

fn emptyObjectValue(allocator: std.mem.Allocator) !JsonValue {
    return .{ .object = JsonObject.init(allocator) };
}

fn putString(object: *JsonObject, key: []const u8, value: []const u8) !void {
    try object.put(key, .{ .string = value });
}

fn putBool(object: *JsonObject, key: []const u8, value: bool) !void {
    try object.put(key, .{ .bool = value });
}

fn readOptionalString(arguments: ?JsonObject, key: []const u8) error{InvalidType}!?[]const u8 {
    const object = arguments orelse return null;
    const value = object.get(key) orelse return null;
    return switch (value) {
        .string => |text| text,
        else => error.InvalidType,
    };
}

fn readRequiredString(arguments: ?JsonObject, key: []const u8) error{ InvalidType, MissingValue }!?[]const u8 {
    const object = arguments orelse return error.MissingValue;
    const value = object.get(key) orelse return error.MissingValue;
    return switch (value) {
        .string => |text| text,
        else => error.InvalidType,
    };
}

fn readOptionalBool(arguments: ?JsonObject, key: []const u8) error{InvalidType}!?bool {
    const object = arguments orelse return null;
    const value = object.get(key) orelse return null;
    return switch (value) {
        .bool => |flag| flag,
        else => error.InvalidType,
    };
}

fn readOptionalU64(arguments: ?JsonObject, key: []const u8) error{ InvalidType, Overflow }!?u64 {
    const object = arguments orelse return null;
    const value = object.get(key) orelse return null;
    return switch (value) {
        .integer => |integer| if (integer < 0) error.InvalidType else std.math.cast(u64, integer) orelse error.Overflow,
        .number_string => |text| std.fmt.parseInt(u64, text, 10) catch return error.InvalidType,
        else => error.InvalidType,
    };
}

fn readOptionalU32(arguments: ?JsonObject, key: []const u8) error{ InvalidType, Overflow }!?u32 {
    const value = (try readOptionalU64(arguments, key)) orelse return null;
    return std.math.cast(u32, value) orelse error.Overflow;
}

fn readOptionalU8(arguments: ?JsonObject, key: []const u8) error{ InvalidType, Overflow }!?u8 {
    const value = (try readOptionalU64(arguments, key)) orelse return null;
    return std.math.cast(u8, value) orelse error.Overflow;
}

fn readOptionalI32(arguments: ?JsonObject, key: []const u8) error{ InvalidType, Overflow }!?i32 {
    const object = arguments orelse return null;
    const value = object.get(key) orelse return null;
    return switch (value) {
        .integer => |integer| std.math.cast(i32, integer) orelse error.Overflow,
        .number_string => |text| std.fmt.parseInt(i32, text, 10) catch return error.InvalidType,
        else => error.InvalidType,
    };
}

fn readOptionalMouseButton(arguments: ?JsonObject, key: []const u8) error{InvalidType}!?core.model.MouseButton {
    const value = (try readOptionalString(arguments, key)) orelse return null;
    if (std.mem.eql(u8, value, "left")) return .left;
    if (std.mem.eql(u8, value, "right")) return .right;
    if (std.mem.eql(u8, value, "middle")) return .middle;
    return error.InvalidType;
}

fn readOptionalMatchMode(arguments: ?JsonObject) error{InvalidType}!?core.model.StringMatchMode {
    const value = (try readOptionalString(arguments, "match")) orelse return null;
    return core.model.parseMatchMode(value) orelse error.InvalidType;
}

fn toolResponseSummary(allocator: std.mem.Allocator, response: anytype) ![]const u8 {
    if (response.ok) {
        return std.fmt.allocPrint(allocator, "{s} completed successfully.", .{response.capability});
    }

    const failure = response.failure orelse core.errors.ApiError{
        .code = core.errors.codes.system_error,
        .message = "The tool failed without structured error details.",
        .detail = null,
    };
    if (failure.detail) |detail| {
        return std.fmt.allocPrint(allocator, "{s} failed ({s}): {s}. detail={s}", .{ response.capability, failure.code, failure.message, detail });
    }
    return std.fmt.allocPrint(allocator, "{s} failed ({s}): {s}.", .{ response.capability, failure.code, failure.message });
}
