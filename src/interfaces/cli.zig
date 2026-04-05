const std = @import("std");
const core = @import("easytouch_core");
const platform = @import("../core/platform.zig");
const runtime = @import("../runtime/root.zig");
const mcp_stdio = @import("mcp_stdio.zig");

pub fn run(allocator: std.mem.Allocator, args: []const []const u8) !u8 {
    if (args.len == 0) {
        printHelp();
        return 0;
    }

    const command = args[0];

    if (std.mem.eql(u8, command, "help")) {
        printHelp();
        return 0;
    }
    if (std.mem.eql(u8, command, "status")) {
        printStatus();
        return 0;
    }
    if (std.mem.eql(u8, command, "platforms")) {
        printPlatforms();
        return 0;
    }
    if (std.mem.eql(u8, command, "interfaces")) {
        printInterfaceOverview();
        return 0;
    }
    if (std.mem.eql(u8, command, "requirements")) {
        printRequirements();
        return 0;
    }
    if (std.mem.eql(u8, command, "mcp-stdio")) {
        const output_mode = if (findOptionValue(args[1..], "--output")) |value|
            core.model.parseOutputMode(value) orelse return error.InvalidOutputMode
        else
            .text;
        if (output_mode == .json) {
            try mcp_stdio.printManifestJson();
        } else {
            try mcp_stdio.serve(allocator);
        }
        return 0;
    }

    if (std.mem.eql(u8, command, "system") and args.len >= 2 and std.mem.eql(u8, args[1], "os-info")) {
        const output_mode = try readOutputMode(args[2..]);
        const response = try runtime.systemOsInfo(allocator);
        return try emit(output_mode, response, printOsInfoText);
    }

    if (std.mem.eql(u8, command, "system") and args.len >= 2 and std.mem.eql(u8, args[1], "cpu-info")) {
        const output_mode = try readOutputMode(args[2..]);
        const response = try runtime.systemCpuInfo(allocator);
        return try emit(output_mode, response, printCpuInfoText);
    }

    if (std.mem.eql(u8, command, "system") and args.len >= 2 and std.mem.eql(u8, args[1], "memory-info")) {
        const output_mode = try readOutputMode(args[2..]);
        const response = try runtime.systemMemoryInfo(allocator);
        return try emit(output_mode, response, printMemoryInfoText);
    }

    if (std.mem.eql(u8, command, "system") and args.len >= 2 and std.mem.eql(u8, args[1], "disk-list")) {
        const output_mode = try readOutputMode(args[2..]);
        const response = try runtime.systemDiskList(allocator);
        return try emit(output_mode, response, printDiskListText);
    }

    if (std.mem.eql(u8, command, "system") and args.len >= 2 and std.mem.eql(u8, args[1], "process-list")) {
        const output_mode = try readOutputMode(args[2..]);
        const response = try runtime.systemProcessList(allocator);
        return try emit(output_mode, response, printProcessListText);
    }

    if (std.mem.eql(u8, command, "system") and args.len >= 2 and std.mem.eql(u8, args[1], "hardware-info")) {
        const output_mode = try readOutputMode(args[2..]);
        const response = try runtime.systemHardwareInfo(allocator);
        return try emit(output_mode, response, printHardwareInfoText);
    }

    if (std.mem.eql(u8, command, "system") and args.len >= 2 and std.mem.eql(u8, args[1], "network-info")) {
        const output_mode = try readOutputMode(args[2..]);
        const response = try runtime.systemNetworkInfo(allocator);
        return try emit(output_mode, response, printNetworkInfoText);
    }

    if (std.mem.eql(u8, command, "mouse") and args.len >= 2 and std.mem.eql(u8, args[1], "position")) {
        const output_mode = try readOutputMode(args[2..]);
        const response = try runtime.mousePosition(allocator);
        return try emit(output_mode, response, printPointText);
    }

    if (std.mem.eql(u8, command, "mouse") and args.len >= 2 and std.mem.eql(u8, args[1], "move")) {
        const output_mode = try readOutputMode(args[2..]);
        const x_value = findOptionValue(args[2..], "--x") orelse {
            const response = core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.invalid_args, "Missing required --x value.", null);
            return try emit(output_mode, response, printAckText);
        };
        const y_value = findOptionValue(args[2..], "--y") orelse {
            const response = core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.invalid_args, "Missing required --y value.", null);
            return try emit(output_mode, response, printAckText);
        };

        const x = std.fmt.parseInt(i32, x_value, 10) catch {
            const response = core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.invalid_args, "Invalid --x value. Use a signed 32-bit integer.", x_value);
            return try emit(output_mode, response, printAckText);
        };
        const y = std.fmt.parseInt(i32, y_value, 10) catch {
            const response = core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.invalid_args, "Invalid --y value. Use a signed 32-bit integer.", y_value);
            return try emit(output_mode, response, printAckText);
        };

        const duration_ms = if (findOptionValue(args[2..], "--duration-ms")) |value|
            std.fmt.parseInt(u32, value, 10) catch {
                const response = core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.invalid_args, "Invalid --duration-ms value. Use an integer in range 0..4294967295.", value);
                return try emit(output_mode, response, printAckText);
            }
        else
            null;

        const jitter_px = if (findOptionValue(args[2..], "--jitter-px")) |value|
            std.fmt.parseInt(i32, value, 10) catch {
                const response = core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.invalid_args, "Invalid --jitter-px value. Use a signed 32-bit integer.", value);
                return try emit(output_mode, response, printAckText);
            }
        else
            null;

        const step_delay_ms = if (findOptionValue(args[2..], "--step-delay-ms")) |value|
            std.fmt.parseInt(u32, value, 10) catch {
                const response = core.model.failure(core.model.Ack, "mouse.move", core.errors.codes.invalid_args, "Invalid --step-delay-ms value. Use an integer in range 0..4294967295.", value);
                return try emit(output_mode, response, printAckText);
            }
        else
            null;

        const response = try runtime.mouseMove(allocator, x, y, duration_ms, jitter_px, step_delay_ms);
        return try emit(output_mode, response, printAckText);
    }

    if (std.mem.eql(u8, command, "mouse") and args.len >= 2 and std.mem.eql(u8, args[1], "click")) {
        const output_mode = try readOutputMode(args[2..]);
        const button = if (findOptionValue(args[2..], "--button")) |value|
            parseMouseButton(value) orelse {
                const response = core.model.failure(core.model.Ack, "mouse.click", core.errors.codes.invalid_args, "Invalid --button value. Use left, right, or middle.", value);
                return try emit(output_mode, response, printAckText);
            }
        else
            core.model.MouseButton.left;

        const count = if (findOptionValue(args[2..], "--count")) |value|
            std.fmt.parseInt(u8, value, 10) catch {
                const response = core.model.failure(core.model.Ack, "mouse.click", core.errors.codes.invalid_args, "Invalid --count value. Use an integer in range 1..255.", value);
                return try emit(output_mode, response, printAckText);
            }
        else
            1;

        const response = try runtime.mouseClick(allocator, button, count);
        return try emit(output_mode, response, printAckText);
    }

    if (std.mem.eql(u8, command, "mouse") and args.len >= 2 and std.mem.eql(u8, args[1], "scroll")) {
        const output_mode = try readOutputMode(args[2..]);
        const delta_value = findOptionValue(args[2..], "--delta") orelse {
            const response = core.model.failure(core.model.Ack, "mouse.scroll", core.errors.codes.invalid_args, "Missing required --delta value.", null);
            return try emit(output_mode, response, printAckText);
        };
        const delta = std.fmt.parseInt(i32, delta_value, 10) catch {
            const response = core.model.failure(core.model.Ack, "mouse.scroll", core.errors.codes.invalid_args, "Invalid --delta value. Use a signed 32-bit integer.", delta_value);
            return try emit(output_mode, response, printAckText);
        };

        const response = try runtime.mouseScroll(allocator, delta);
        return try emit(output_mode, response, printAckText);
    }

    if (std.mem.eql(u8, command, "window") and args.len >= 2 and std.mem.eql(u8, args[1], "list")) {
        const output_mode = try readOutputMode(args[2..]);
        const include_hidden = hasFlag(args[2..], "--include-hidden");
        const pid = if (findOptionValue(args[2..], "--pid")) |value|
            std.fmt.parseInt(u32, value, 10) catch {
                const response = core.model.failure(core.model.WindowList, "window.list", core.errors.codes.invalid_args, "Invalid --pid value. Use a non-negative 32-bit process id.", value);
                return try emit(output_mode, response, printWindowListText);
            }
        else
            null;
        const response = try runtime.windowList(allocator, include_hidden, pid);
        return try emit(output_mode, response, printWindowListText);
    }

    if (std.mem.eql(u8, command, "window") and args.len >= 2 and std.mem.eql(u8, args[1], "foreground")) {
        const output_mode = try readOutputMode(args[2..]);
        const response = try runtime.windowForeground(allocator);
        return try emit(output_mode, response, printForegroundText);
    }

    if (std.mem.eql(u8, command, "window") and args.len >= 2 and std.mem.eql(u8, args[1], "activate")) {
        const output_mode = try readOutputMode(args[2..]);
        const handle_value = findOptionValue(args[2..], "--handle") orelse {
            const response = core.model.failure(core.model.Ack, "window.activate", core.errors.codes.invalid_args, "Missing required --handle value.", null);
            return try emit(output_mode, response, printAckText);
        };
        const handle = parseHandleValue(handle_value) catch {
            const response = core.model.failure(core.model.Ack, "window.activate", core.errors.codes.invalid_args, "Invalid --handle value. Use a decimal handle or a 0x-prefixed hex handle.", handle_value);
            return try emit(output_mode, response, printAckText);
        };
        const response = try runtime.windowActivate(allocator, handle);
        return try emit(output_mode, response, printAckText);
    }

    if (std.mem.eql(u8, command, "window") and args.len >= 2 and std.mem.eql(u8, args[1], "show")) {
        const output_mode = try readOutputMode(args[2..]);
        const handle_value = findOptionValue(args[2..], "--handle") orelse {
            const response = core.model.failure(core.model.Ack, "window.show", core.errors.codes.invalid_args, "Missing required --handle value.", null);
            return try emit(output_mode, response, printAckText);
        };
        const handle = parseHandleValue(handle_value) catch {
            const response = core.model.failure(core.model.Ack, "window.show", core.errors.codes.invalid_args, "Invalid --handle value. Use a decimal handle or a 0x-prefixed hex handle.", handle_value);
            return try emit(output_mode, response, printAckText);
        };
        const response = try runtime.windowShow(allocator, handle);
        return try emit(output_mode, response, printAckText);
    }

    if (std.mem.eql(u8, command, "window") and args.len >= 2 and std.mem.eql(u8, args[1], "minimize")) {
        const output_mode = try readOutputMode(args[2..]);
        const handle_value = findOptionValue(args[2..], "--handle") orelse {
            const response = core.model.failure(core.model.Ack, "window.minimize", core.errors.codes.invalid_args, "Missing required --handle value.", null);
            return try emit(output_mode, response, printAckText);
        };
        const handle = parseHandleValue(handle_value) catch {
            const response = core.model.failure(core.model.Ack, "window.minimize", core.errors.codes.invalid_args, "Invalid --handle value. Use a decimal handle or a 0x-prefixed hex handle.", handle_value);
            return try emit(output_mode, response, printAckText);
        };
        const response = try runtime.windowMinimize(allocator, handle);
        return try emit(output_mode, response, printAckText);
    }

    if (std.mem.eql(u8, command, "window") and args.len >= 2 and std.mem.eql(u8, args[1], "maximize")) {
        const output_mode = try readOutputMode(args[2..]);
        const handle_value = findOptionValue(args[2..], "--handle") orelse {
            const response = core.model.failure(core.model.Ack, "window.maximize", core.errors.codes.invalid_args, "Missing required --handle value.", null);
            return try emit(output_mode, response, printAckText);
        };
        const handle = parseHandleValue(handle_value) catch {
            const response = core.model.failure(core.model.Ack, "window.maximize", core.errors.codes.invalid_args, "Invalid --handle value. Use a decimal handle or a 0x-prefixed hex handle.", handle_value);
            return try emit(output_mode, response, printAckText);
        };
        const response = try runtime.windowMaximize(allocator, handle);
        return try emit(output_mode, response, printAckText);
    }

    if (std.mem.eql(u8, command, "window") and args.len >= 2 and std.mem.eql(u8, args[1], "restore")) {
        const output_mode = try readOutputMode(args[2..]);
        const handle_value = findOptionValue(args[2..], "--handle") orelse {
            const response = core.model.failure(core.model.Ack, "window.restore", core.errors.codes.invalid_args, "Missing required --handle value.", null);
            return try emit(output_mode, response, printAckText);
        };
        const handle = parseHandleValue(handle_value) catch {
            const response = core.model.failure(core.model.Ack, "window.restore", core.errors.codes.invalid_args, "Invalid --handle value. Use a decimal handle or a 0x-prefixed hex handle.", handle_value);
            return try emit(output_mode, response, printAckText);
        };
        const response = try runtime.windowRestore(allocator, handle);
        return try emit(output_mode, response, printAckText);
    }

    if (std.mem.eql(u8, command, "window") and args.len >= 2 and std.mem.eql(u8, args[1], "move")) {
        const output_mode = try readOutputMode(args[2..]);
        const handle_value = findOptionValue(args[2..], "--handle") orelse {
            const response = core.model.failure(core.model.Ack, "window.move", core.errors.codes.invalid_args, "Missing required --handle value.", null);
            return try emit(output_mode, response, printAckText);
        };
        const x_value = findOptionValue(args[2..], "--x") orelse {
            const response = core.model.failure(core.model.Ack, "window.move", core.errors.codes.invalid_args, "Missing required --x value.", null);
            return try emit(output_mode, response, printAckText);
        };
        const y_value = findOptionValue(args[2..], "--y") orelse {
            const response = core.model.failure(core.model.Ack, "window.move", core.errors.codes.invalid_args, "Missing required --y value.", null);
            return try emit(output_mode, response, printAckText);
        };

        const handle = parseHandleValue(handle_value) catch {
            const response = core.model.failure(core.model.Ack, "window.move", core.errors.codes.invalid_args, "Invalid --handle value. Use a decimal handle or a 0x-prefixed hex handle.", handle_value);
            return try emit(output_mode, response, printAckText);
        };
        const x = std.fmt.parseInt(i32, x_value, 10) catch {
            const response = core.model.failure(core.model.Ack, "window.move", core.errors.codes.invalid_args, "Invalid --x value. Use a signed 32-bit integer.", x_value);
            return try emit(output_mode, response, printAckText);
        };
        const y = std.fmt.parseInt(i32, y_value, 10) catch {
            const response = core.model.failure(core.model.Ack, "window.move", core.errors.codes.invalid_args, "Invalid --y value. Use a signed 32-bit integer.", y_value);
            return try emit(output_mode, response, printAckText);
        };

        const width = if (findOptionValue(args[2..], "--width")) |value|
            std.fmt.parseInt(i32, value, 10) catch {
                const response = core.model.failure(core.model.Ack, "window.move", core.errors.codes.invalid_args, "Invalid --width value. Use a signed 32-bit integer.", value);
                return try emit(output_mode, response, printAckText);
            }
        else
            null;

        const height = if (findOptionValue(args[2..], "--height")) |value|
            std.fmt.parseInt(i32, value, 10) catch {
                const response = core.model.failure(core.model.Ack, "window.move", core.errors.codes.invalid_args, "Invalid --height value. Use a signed 32-bit integer.", value);
                return try emit(output_mode, response, printAckText);
            }
        else
            null;

        const response = try runtime.windowMove(allocator, handle, x, y, width, height);
        return try emit(output_mode, response, printAckText);
    }

    if (std.mem.eql(u8, command, "window") and args.len >= 2 and std.mem.eql(u8, args[1], "find")) {
        const output_mode = try readOutputMode(args[2..]);
        const title = findOptionValue(args[2..], "--title") orelse {
            const response = core.model.failure(core.model.WindowMatch, "window.find", core.errors.codes.invalid_args, "Missing required --title value.", null);
            return try emit(output_mode, response, printWindowMatchText);
        };
        const match_mode = if (findOptionValue(args[2..], "--match")) |value|
            core.model.parseMatchMode(value) orelse {
                const response = core.model.failure(core.model.WindowMatch, "window.find", core.errors.codes.invalid_args, "Invalid --match value. Use contains or exact.", value);
                return try emit(output_mode, response, printWindowMatchText);
            }
        else
            .contains;
        const include_hidden = hasFlag(args[2..], "--include-hidden");
        const pid = if (findOptionValue(args[2..], "--pid")) |value|
            std.fmt.parseInt(u32, value, 10) catch {
                const response = core.model.failure(core.model.WindowMatch, "window.find", core.errors.codes.invalid_args, "Invalid --pid value. Use a non-negative 32-bit process id.", value);
                return try emit(output_mode, response, printWindowMatchText);
            }
        else
            null;

        const response = try runtime.windowFind(allocator, title, match_mode, include_hidden, pid);
        return try emit(output_mode, response, printWindowMatchText);
    }

    if (std.mem.eql(u8, command, "window") and args.len >= 2 and std.mem.eql(u8, args[1], "close")) {
        const output_mode = try readOutputMode(args[2..]);
        const handle_value = findOptionValue(args[2..], "--handle") orelse {
            const response = core.model.failure(core.model.Ack, "window.close", core.errors.codes.invalid_args, "Missing required --handle value.", null);
            return try emit(output_mode, response, printAckText);
        };
        const handle = parseHandleValue(handle_value) catch {
            const response = core.model.failure(core.model.Ack, "window.close", core.errors.codes.invalid_args, "Invalid --handle value. Use a decimal handle or a 0x-prefixed hex handle.", handle_value);
            return try emit(output_mode, response, printAckText);
        };
        const response = try runtime.windowClose(allocator, handle);
        return try emit(output_mode, response, printAckText);
    }

    if (std.mem.eql(u8, command, "app") and args.len >= 2 and std.mem.eql(u8, args[1], "launch")) {
        const output_mode = try readOutputMode(args[2..]);
        const target = findOptionValue(args[2..], "--target") orelse {
            const response = core.model.failure(core.model.Ack, "app.launch", core.errors.codes.invalid_args, "Missing required --target value.", null);
            return try emit(output_mode, response, printAckText);
        };
        const response = try runtime.appLaunch(allocator, target);
        return try emit(output_mode, response, printAckText);
    }

    if (std.mem.eql(u8, command, "clipboard") and args.len >= 2 and std.mem.eql(u8, args[1], "get-text")) {
        const output_mode = try readOutputMode(args[2..]);
        const response = try runtime.clipboardGetText(allocator);
        return try emit(output_mode, response, printClipboardText);
    }

    if (std.mem.eql(u8, command, "clipboard") and args.len >= 2 and std.mem.eql(u8, args[1], "set-text")) {
        const output_mode = try readOutputMode(args[2..]);
        const text = findOptionValue(args[2..], "--text") orelse {
            const response = core.model.failure(core.model.Ack, "clipboard.set_text", core.errors.codes.invalid_args, "Missing required --text value.", null);
            return try emit(output_mode, response, printAckText);
        };
        const response = try runtime.clipboardSetText(allocator, text);
        return try emit(output_mode, response, printAckText);
    }

    if (std.mem.eql(u8, command, "clipboard") and args.len >= 2 and std.mem.eql(u8, args[1], "get-files")) {
        const output_mode = try readOutputMode(args[2..]);
        const response = try runtime.clipboardGetFiles(allocator);
        return try emit(output_mode, response, printClipboardFilesText);
    }

    if (std.mem.eql(u8, command, "clipboard") and args.len >= 2 and std.mem.eql(u8, args[1], "set-files")) {
        const output_mode = try readOutputMode(args[2..]);
        const paths = findOptionValue(args[2..], "--paths") orelse {
            const response = core.model.failure(core.model.Ack, "clipboard.set_files", core.errors.codes.invalid_args, "Missing required --paths value.", null);
            return try emit(output_mode, response, printAckText);
        };
        const response = try runtime.clipboardSetFiles(allocator, paths);
        return try emit(output_mode, response, printAckText);
    }

    if (std.mem.eql(u8, command, "clipboard") and args.len >= 2 and std.mem.eql(u8, args[1], "set-image")) {
        const output_mode = try readOutputMode(args[2..]);
        const path = findOptionValue(args[2..], "--path") orelse {
            const response = core.model.failure(core.model.Ack, "clipboard.set_image", core.errors.codes.invalid_args, "Missing required --path value.", null);
            return try emit(output_mode, response, printAckText);
        };
        const response = try runtime.clipboardSetImage(allocator, path);
        return try emit(output_mode, response, printAckText);
    }

    if (std.mem.eql(u8, command, "keyboard") and args.len >= 2 and std.mem.eql(u8, args[1], "key")) {
        const output_mode = try readOutputMode(args[2..]);
        const key = findOptionValue(args[2..], "--key") orelse {
            const response = core.model.failure(core.model.Ack, "keyboard.key_press", core.errors.codes.invalid_args, "Missing required --key value.", null);
            return try emit(output_mode, response, printAckText);
        };
        const response = try runtime.keyboardKeyPress(allocator, key);
        return try emit(output_mode, response, printAckText);
    }

    if (std.mem.eql(u8, command, "keyboard") and args.len >= 2 and std.mem.eql(u8, args[1], "hotkey")) {
        const output_mode = try readOutputMode(args[2..]);
        const keys = findOptionValue(args[2..], "--keys") orelse {
            const response = core.model.failure(core.model.Ack, "keyboard.hotkey", core.errors.codes.invalid_args, "Missing required --keys value.", null);
            return try emit(output_mode, response, printAckText);
        };
        const response = try runtime.keyboardHotkey(allocator, keys);
        return try emit(output_mode, response, printAckText);
    }

    if (std.mem.eql(u8, command, "keyboard") and args.len >= 2 and std.mem.eql(u8, args[1], "type")) {
        const output_mode = try readOutputMode(args[2..]);
        const text = findOptionValue(args[2..], "--text") orelse {
            const response = core.model.failure(core.model.Ack, "keyboard.type_text", core.errors.codes.invalid_args, "Missing required --text value.", null);
            return try emit(output_mode, response, printAckText);
        };
        const response = try runtime.keyboardTypeText(allocator, text);
        return try emit(output_mode, response, printAckText);
    }

    if (std.mem.eql(u8, command, "keyboard") and args.len >= 2 and std.mem.eql(u8, args[1], "type-keys")) {
        const output_mode = try readOutputMode(args[2..]);
        const text = findOptionValue(args[2..], "--text") orelse {
            const response = core.model.failure(core.model.Ack, "keyboard.type_keys", core.errors.codes.invalid_args, "Missing required --text value.", null);
            return try emit(output_mode, response, printAckText);
        };
        const key_delay_ms = if (findOptionValue(args[2..], "--key-delay-ms")) |value|
            std.fmt.parseInt(u32, value, 10) catch {
                const response = core.model.failure(core.model.Ack, "keyboard.type_keys", core.errors.codes.invalid_args, "Invalid --key-delay-ms value. Use a non-negative 32-bit integer.", value);
                return try emit(output_mode, response, printAckText);
            }
        else
            null;
        const response = try runtime.keyboardTypeKeys(allocator, text, key_delay_ms);
        return try emit(output_mode, response, printAckText);
    }

    if (std.mem.eql(u8, command, "keyboard") and args.len >= 2 and std.mem.eql(u8, args[1], "ime-switch")) {
        const output_mode = try readOutputMode(args[2..]);
        const strategy = findOptionValue(args[2..], "--strategy");
        const response = try runtime.keyboardImeSwitch(allocator, strategy);
        return try emit(output_mode, response, printAckText);
    }

    if (std.mem.eql(u8, command, "keyboard") and args.len >= 2 and std.mem.eql(u8, args[1], "caps-lock")) {
        const output_mode = try readOutputMode(args[2..]);
        const state = findOptionValue(args[2..], "--state");
        const response = try runtime.keyboardCapsLock(allocator, state);
        return try emit(output_mode, response, printAckText);
    }

    if (std.mem.eql(u8, command, "keyboard") and args.len >= 2 and std.mem.eql(u8, args[1], "paste")) {
        const output_mode = try readOutputMode(args[2..]);
        const expected_title = findOptionValue(args[2..], "--expect-title");
        const match_mode = if (findOptionValue(args[2..], "--match")) |value|
            core.model.parseMatchMode(value) orelse {
                const response = core.model.failure(core.model.Ack, "keyboard.paste", core.errors.codes.invalid_args, "Invalid --match value. Use contains or exact.", value);
                return try emit(output_mode, response, printAckText);
            }
        else
            .contains;
        const response = try runtime.keyboardPaste(allocator, expected_title, match_mode);
        return try emit(output_mode, response, printAckText);
    }

    if (std.mem.eql(u8, command, "screen") and args.len >= 2 and std.mem.eql(u8, args[1], "capture")) {
        const output_mode = try readOutputMode(args[2..]);
        const path = if (findOptionValue(args[2..], "--path")) |value|
            value
        else
            try defaultCapturePath(allocator);

        const display_id = if (findOptionValue(args[2..], "--display-id")) |value|
            std.fmt.parseInt(u32, value, 10) catch {
                const response = core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.invalid_args, "Invalid --display-id value. Use a non-negative 32-bit integer.", value);
                return try emit(output_mode, response, printScreenCaptureText);
            }
        else
            null;

        const window_handle = if (findOptionValue(args[2..], "--window-handle")) |value|
            parseHandleValue(value) catch {
                const response = core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.invalid_args, "Invalid --window-handle value. Use a decimal handle or a 0x-prefixed hex handle.", value);
                return try emit(output_mode, response, printScreenCaptureText);
            }
        else
            null;

        if (display_id != null and window_handle != null) {
            const response = core.model.failure(core.model.ScreenCapture, "screen.capture", core.errors.codes.invalid_args, "--display-id and --window-handle cannot be used together.", null);
            return try emit(output_mode, response, printScreenCaptureText);
        }

        const response = try runtime.screenCapture(allocator, path, display_id, window_handle);
        return try emit(output_mode, response, printScreenCaptureText);
    }

    if (std.mem.eql(u8, command, "screen") and args.len >= 2 and std.mem.eql(u8, args[1], "pixel-color")) {
        const output_mode = try readOutputMode(args[2..]);
        const x_value = findOptionValue(args[2..], "--x") orelse {
            const response = core.model.failure(core.model.PixelColor, "screen.pixel_color", core.errors.codes.invalid_args, "Missing required --x value.", null);
            return try emit(output_mode, response, printPixelColorText);
        };
        const y_value = findOptionValue(args[2..], "--y") orelse {
            const response = core.model.failure(core.model.PixelColor, "screen.pixel_color", core.errors.codes.invalid_args, "Missing required --y value.", null);
            return try emit(output_mode, response, printPixelColorText);
        };
        const x = std.fmt.parseInt(i32, x_value, 10) catch {
            const response = core.model.failure(core.model.PixelColor, "screen.pixel_color", core.errors.codes.invalid_args, "Invalid --x value. Use a signed 32-bit integer.", x_value);
            return try emit(output_mode, response, printPixelColorText);
        };
        const y = std.fmt.parseInt(i32, y_value, 10) catch {
            const response = core.model.failure(core.model.PixelColor, "screen.pixel_color", core.errors.codes.invalid_args, "Invalid --y value. Use a signed 32-bit integer.", y_value);
            return try emit(output_mode, response, printPixelColorText);
        };

        const response = try runtime.screenPixelColor(allocator, x, y);
        return try emit(output_mode, response, printPixelColorText);
    }

    if (std.mem.eql(u8, command, "screen") and args.len >= 2 and std.mem.eql(u8, args[1], "displays")) {
        const output_mode = try readOutputMode(args[2..]);
        const response = try runtime.screenDisplays(allocator);
        return try emit(output_mode, response, printDisplayListText);
    }

    if (std.mem.eql(u8, command, "wait") and args.len >= 2 and std.mem.eql(u8, args[1], "window")) {
        const output_mode = try readOutputMode(args[2..]);
        const title = findOptionValue(args[2..], "--title") orelse {
            const response = core.model.failure(core.model.WaitWindow, "wait.window", core.errors.codes.invalid_args, "Missing required --title value.", null);
            return try emit(output_mode, response, printWaitWindowText);
        };
        const timeout_ms = if (findOptionValue(args[2..], "--timeout-ms")) |value|
            std.fmt.parseInt(u64, value, 10) catch 2000
        else
            2000;
        const match_mode = if (findOptionValue(args[2..], "--match")) |value|
            core.model.parseMatchMode(value) orelse .contains
        else
            .contains;
        const foreground_only = hasFlag(args[2..], "--foreground-only");
        const response = try runtime.waitWindow(allocator, title, timeout_ms, match_mode, foreground_only);
        return try emit(output_mode, response, printWaitWindowText);
    }

    if (std.mem.eql(u8, command, "wait") and args.len >= 2 and std.mem.eql(u8, args[1], "focus")) {
        const output_mode = try readOutputMode(args[2..]);
        const title = findOptionValue(args[2..], "--title") orelse {
            const response = core.model.failure(core.model.WaitWindow, "wait.focus", core.errors.codes.invalid_args, "Missing required --title value.", null);
            return try emit(output_mode, response, printWaitWindowText);
        };
        const timeout_ms = if (findOptionValue(args[2..], "--timeout-ms")) |value|
            std.fmt.parseInt(u64, value, 10) catch 2000
        else
            2000;
        const match_mode = if (findOptionValue(args[2..], "--match")) |value|
            core.model.parseMatchMode(value) orelse .contains
        else
            .contains;
        const response = try runtime.waitFocus(allocator, title, timeout_ms, match_mode);
        return try emit(output_mode, response, printWaitWindowText);
    }

    if (std.mem.eql(u8, command, "wait") and args.len >= 2 and std.mem.eql(u8, args[1], "activate")) {
        const output_mode = try readOutputMode(args[2..]);
        const handle_value = findOptionValue(args[2..], "--handle") orelse {
            const response = core.model.failure(core.model.WaitWindow, "wait.activate", core.errors.codes.invalid_args, "Missing required --handle value.", null);
            return try emit(output_mode, response, printWaitWindowText);
        };
        const handle = parseHandleValue(handle_value) catch {
            const response = core.model.failure(core.model.WaitWindow, "wait.activate", core.errors.codes.invalid_args, "Invalid --handle value. Use a decimal handle or a 0x-prefixed hex handle.", handle_value);
            return try emit(output_mode, response, printWaitWindowText);
        };
        const timeout_ms = if (findOptionValue(args[2..], "--timeout-ms")) |value|
            std.fmt.parseInt(u64, value, 10) catch 2000
        else
            2000;
        const expect_active = if (findOptionValue(args[2..], "--expect-active")) |value|
            parseBoolValue(value) orelse {
                const response = core.model.failure(core.model.WaitWindow, "wait.activate", core.errors.codes.invalid_args, "Invalid --expect-active value. Use true or false.", value);
                return try emit(output_mode, response, printWaitWindowText);
            }
        else
            true;
        const response = try runtime.waitActivate(allocator, handle, timeout_ms, expect_active);
        return try emit(output_mode, response, printWaitWindowText);
    }

    if (std.mem.eql(u8, command, "wait") and args.len >= 2 and std.mem.eql(u8, args[1], "pixel")) {
        const output_mode = try readOutputMode(args[2..]);
        const x_value = findOptionValue(args[2..], "--x") orelse {
            const response = core.model.failure(core.model.WaitPixel, "wait.pixel", core.errors.codes.invalid_args, "Missing required --x value.", null);
            return try emit(output_mode, response, printWaitPixelText);
        };
        const y_value = findOptionValue(args[2..], "--y") orelse {
            const response = core.model.failure(core.model.WaitPixel, "wait.pixel", core.errors.codes.invalid_args, "Missing required --y value.", null);
            return try emit(output_mode, response, printWaitPixelText);
        };
        const hex = findOptionValue(args[2..], "--hex") orelse {
            const response = core.model.failure(core.model.WaitPixel, "wait.pixel", core.errors.codes.invalid_args, "Missing required --hex value.", null);
            return try emit(output_mode, response, printWaitPixelText);
        };
        const x = std.fmt.parseInt(i32, x_value, 10) catch {
            const response = core.model.failure(core.model.WaitPixel, "wait.pixel", core.errors.codes.invalid_args, "Invalid --x value. Use a signed 32-bit integer.", x_value);
            return try emit(output_mode, response, printWaitPixelText);
        };
        const y = std.fmt.parseInt(i32, y_value, 10) catch {
            const response = core.model.failure(core.model.WaitPixel, "wait.pixel", core.errors.codes.invalid_args, "Invalid --y value. Use a signed 32-bit integer.", y_value);
            return try emit(output_mode, response, printWaitPixelText);
        };
        const timeout_ms = if (findOptionValue(args[2..], "--timeout-ms")) |value|
            std.fmt.parseInt(u64, value, 10) catch 2000
        else
            2000;
        const response = try runtime.waitPixel(allocator, x, y, hex, timeout_ms);
        return try emit(output_mode, response, printWaitPixelText);
    }

    if (std.mem.eql(u8, command, "wait") and args.len >= 2 and std.mem.eql(u8, args[1], "clipboard")) {
        const output_mode = try readOutputMode(args[2..]);
        const expected_text = findOptionValue(args[2..], "--expect-text");
        const timeout_ms = if (findOptionValue(args[2..], "--timeout-ms")) |value|
            std.fmt.parseInt(u64, value, 10) catch 2000
        else
            2000;
        const match_mode = if (findOptionValue(args[2..], "--match")) |value|
            core.model.parseMatchMode(value) orelse .contains
        else
            .contains;
        const response = try runtime.waitClipboard(allocator, expected_text, timeout_ms, match_mode);
        return try emit(output_mode, response, printWaitClipboardText);
    }

    if (std.mem.eql(u8, command, "wait") and args.len >= 2 and std.mem.eql(u8, args[1], "process")) {
        const output_mode = try readOutputMode(args[2..]);
        const name = findOptionValue(args[2..], "--name");
        const pid = if (findOptionValue(args[2..], "--pid")) |value|
            std.fmt.parseInt(u32, value, 10) catch {
                const response = core.model.failure(core.model.WaitProcess, "wait.process", core.errors.codes.invalid_args, "Invalid --pid value. Use a non-negative 32-bit integer.", value);
                return try emit(output_mode, response, printWaitProcessText);
            }
        else
            null;
        const expect_running = if (findOptionValue(args[2..], "--expect-running")) |value|
            parseBoolValue(value) orelse {
                const response = core.model.failure(core.model.WaitProcess, "wait.process", core.errors.codes.invalid_args, "Invalid --expect-running value. Use true or false.", value);
                return try emit(output_mode, response, printWaitProcessText);
            }
        else
            true;
        const timeout_ms = if (findOptionValue(args[2..], "--timeout-ms")) |value|
            std.fmt.parseInt(u64, value, 10) catch 2000
        else
            2000;
        const match_mode = if (findOptionValue(args[2..], "--match")) |value|
            core.model.parseMatchMode(value) orelse .contains
        else
            .contains;

        const response = try runtime.waitProcess(allocator, name, pid, expect_running, timeout_ms, match_mode);
        return try emit(output_mode, response, printWaitProcessText);
    }

    printHelp();
    return 1;
}

fn emit(output_mode: core.model.OutputMode, response: anytype, text_printer: *const fn (@TypeOf(response)) void) !u8 {
    if (output_mode == .json) {
        try core.output.printJson(response);
    } else {
        text_printer(response);
    }
    return if (response.ok) 0 else 1;
}

fn printStatus() void {
    std.debug.print("EasyTouch Zig runtime\n", .{});
    std.debug.print("Installed artifact name: et\n", .{});
    std.debug.print("Current host: {s}\n", .{platform.current().label});
    std.debug.print("Use `et help` to inspect runtime commands.\n", .{});
}

fn printPlatforms() void {
    for (platform.all, 0..) |item, index| {
        if (index != 0) {
            std.debug.print("\n", .{});
        }
        std.debug.print("{s} ({s})\n", .{ item.label, item.id });
        printList("Native APIs", item.native_stack);
        printList("Capability modules", item.capability_modules);
        printList("Main blockers", item.blockers);
    }
}

pub fn printHelp() void {
    std.debug.print("EasyTouch Zig runtime\n", .{});
    std.debug.print("Usage: et <command> [subcommand] [options]\n\n", .{});
    std.debug.print("Core commands:\n", .{});
    std.debug.print("- status\n", .{});
    std.debug.print("- platforms\n", .{});
    std.debug.print("- interfaces\n", .{});
    std.debug.print("- requirements\n", .{});
    std.debug.print("- mcp-stdio [--output json]\n\n", .{});
    std.debug.print("Automation commands:\n", .{});
    for (core.capability.all) |item| {
        std.debug.print("- {s}\n", .{item.cli_path});
    }
    std.debug.print("\nCommon option: --output text|json (default: json)\n", .{});
}

pub fn printInterfaceOverview() void {
    std.debug.print("EasyTouch interfaces\n", .{});
    std.debug.print("- library: shared Zig runtime for all platform automation behavior\n", .{});
    std.debug.print("- cli: shell-friendly entry point with human and JSON output modes\n", .{});
    std.debug.print("- mcp stdio: AI tool transport that reuses the same capability registry\n", .{});
    std.debug.print("\nCurrent capability registry:\n", .{});
    for (core.capability.all) |item| {
        std.debug.print("- {s}: {s}\n", .{ item.id, item.summary });
    }
}

pub fn printRequirements() void {
    std.debug.print("EasyTouch AI runtime requirements\n", .{});
    for (core.requirements.groups, 0..) |group, group_index| {
        if (group_index != 0) {
            std.debug.print("\n", .{});
        }
        std.debug.print("{s}:\n", .{group.title});
        for (group.items) |item| {
            std.debug.print("- {s}\n", .{item});
        }
    }
}

fn printList(title: []const u8, items: []const []const u8) void {
    std.debug.print("{s}:\n", .{title});
    for (items) |entry| {
        std.debug.print("- {s}\n", .{entry});
    }
}

fn printOsInfoText(response: core.model.OsInfoResponse) void {
    if (!response.ok) {
        printResponseError(response.capability, response.failure);
        return;
    }
    const data = response.data.?;
    std.debug.print("{s}\n", .{response.capability});
    std.debug.print("- platform: {s}\n", .{data.platform});
    std.debug.print("- arch: {s}\n", .{data.arch});
    std.debug.print("- version: {s}\n", .{data.version});
    std.debug.print("- build: {d}\n", .{data.build});
    std.debug.print("- machine_name: {s}\n", .{data.machine_name});
    std.debug.print("- runtime: {s}\n", .{data.runtime});
}

fn printPointText(response: core.model.PointResponse) void {
    if (!response.ok) {
        printResponseError(response.capability, response.failure);
        return;
    }
    const data = response.data.?;
    std.debug.print("{s}\n", .{response.capability});
    std.debug.print("- x: {d}\n", .{data.x});
    std.debug.print("- y: {d}\n", .{data.y});
}

fn printCpuInfoText(response: core.model.CpuInfoResponse) void {
    if (!response.ok) {
        printResponseError(response.capability, response.failure);
        return;
    }
    const data = response.data.?;
    std.debug.print("{s}\n", .{response.capability});
    std.debug.print("- architecture: {s}\n", .{data.architecture});
    std.debug.print("- logical_cores: {d}\n", .{data.logical_cores});
    std.debug.print("- page_size: {d}\n", .{data.page_size});
}

fn printHardwareInfoText(response: core.model.HardwareInfoResponse) void {
    if (!response.ok) {
        printResponseError(response.capability, response.failure);
        return;
    }
    const data = response.data.?;
    std.debug.print("{s}\n", .{response.capability});
    std.debug.print("- architecture: {s}\n", .{data.architecture});
    std.debug.print("- logical_cores: {d}\n", .{data.logical_cores});
    std.debug.print("- page_size: {d}\n", .{data.page_size});
    std.debug.print("- total_physical: {d}\n", .{data.total_physical});
    std.debug.print("- total_virtual: {d}\n", .{data.total_virtual});
    std.debug.print("- machine_name: {s}\n", .{data.machine_name});
}

fn printMemoryInfoText(response: core.model.MemoryInfoResponse) void {
    if (!response.ok) {
        printResponseError(response.capability, response.failure);
        return;
    }
    const data = response.data.?;
    std.debug.print("{s}\n", .{response.capability});
    std.debug.print("- total_physical: {d}\n", .{data.total_physical});
    std.debug.print("- available_physical: {d}\n", .{data.available_physical});
    std.debug.print("- used_physical: {d}\n", .{data.used_physical});
    std.debug.print("- memory_load_percent: {d}\n", .{data.memory_load_percent});
}

fn printDiskListText(response: core.model.DiskListResponse) void {
    if (!response.ok) {
        printResponseError(response.capability, response.failure);
        return;
    }
    const data = response.data.?;
    std.debug.print("{s}\n", .{response.capability});
    std.debug.print("- count: {d}\n", .{data.count});
    for (data.disks) |disk| {
        std.debug.print("  - mount: {s}\n", .{disk.mount});
        std.debug.print("    volume_name: {s}\n", .{disk.volume_name});
        std.debug.print("    drive_type: {s}\n", .{disk.drive_type});
        std.debug.print("    total_bytes: {d}\n", .{disk.total_bytes});
        std.debug.print("    free_bytes: {d}\n", .{disk.free_bytes});
    }
}

fn printProcessListText(response: core.model.ProcessListResponse) void {
    if (!response.ok) {
        printResponseError(response.capability, response.failure);
        return;
    }
    const data = response.data.?;
    std.debug.print("{s}\n", .{response.capability});
    std.debug.print("- count: {d}\n", .{data.count});
    for (data.processes) |process| {
        std.debug.print("  - pid: {d}; name: {s}\n", .{ process.pid, process.name });
    }
}

fn printNetworkInfoText(response: core.model.NetworkInfoResponse) void {
    if (!response.ok) {
        printResponseError(response.capability, response.failure);
        return;
    }
    const data = response.data.?;
    std.debug.print("{s}\n", .{response.capability});
    std.debug.print("- count: {d}\n", .{data.count});
    for (data.adapters) |adapter| {
        std.debug.print("  - name: {s}\n", .{adapter.name});
        std.debug.print("    description: {s}\n", .{adapter.description});
        std.debug.print("    ipv4: {s}\n", .{adapter.ipv4});
        std.debug.print("    mac: {s}\n", .{adapter.mac});
        std.debug.print("    adapter_type: {s}\n", .{adapter.adapter_type});
        std.debug.print("    dhcp_enabled: {}\n", .{adapter.dhcp_enabled});
    }
}

fn printWindowListText(response: core.model.WindowListResponse) void {
    if (!response.ok) {
        printResponseError(response.capability, response.failure);
        return;
    }
    const data = response.data.?;
    std.debug.print("{s}\n", .{response.capability});
    std.debug.print("- count: {d}\n", .{data.count});
    for (data.windows) |window| {
        printWindow(window);
    }
}

fn printWindowMatchText(response: core.model.WindowMatchResponse) void {
    if (!response.ok) {
        printResponseError(response.capability, response.failure);
        return;
    }
    const data = response.data.?;
    std.debug.print("{s}\n", .{response.capability});
    std.debug.print("- found: {}\n", .{data.found});
    if (data.window) |window| {
        printWindow(window);
    }
}

fn printForegroundText(response: core.model.ForegroundWindowResponse) void {
    if (!response.ok) {
        printResponseError(response.capability, response.failure);
        return;
    }
    const data = response.data.?;
    std.debug.print("{s}\n", .{response.capability});
    std.debug.print("- found: {}\n", .{data.found});
    if (data.window) |window| {
        printWindow(window);
    }
}

fn printClipboardText(response: core.model.ClipboardTextResponse) void {
    if (!response.ok) {
        printResponseError(response.capability, response.failure);
        return;
    }
    const data = response.data.?;
    std.debug.print("{s}\n", .{response.capability});
    std.debug.print("- text: {s}\n", .{data.text});
}

fn printClipboardFilesText(response: core.model.ClipboardFilesResponse) void {
    if (!response.ok) {
        printResponseError(response.capability, response.failure);
        return;
    }
    const data = response.data.?;
    std.debug.print("{s}\n", .{response.capability});
    std.debug.print("- count: {d}\n", .{data.files.len});
    for (data.files) |path| {
        std.debug.print("  - {s}\n", .{path});
    }
}

fn printAckText(response: core.model.AckResponse) void {
    if (!response.ok) {
        printResponseError(response.capability, response.failure);
        return;
    }
    const data = response.data.?;
    std.debug.print("{s}\n", .{response.capability});
    std.debug.print("- message: {s}\n", .{data.message});
    if (data.detail) |detail| {
        std.debug.print("- detail: {s}\n", .{detail});
    }
}

fn printScreenCaptureText(response: core.model.ScreenCaptureResponse) void {
    if (!response.ok) {
        printResponseError(response.capability, response.failure);
        return;
    }
    const data = response.data.?;
    std.debug.print("{s}\n", .{response.capability});
    std.debug.print("- path: {s}\n", .{data.path});
    std.debug.print("- width: {d}\n", .{data.width});
    std.debug.print("- height: {d}\n", .{data.height});
    std.debug.print("- format: {s}\n", .{data.format});
}

fn printPixelColorText(response: core.model.PixelColorResponse) void {
    if (!response.ok) {
        printResponseError(response.capability, response.failure);
        return;
    }
    const data = response.data.?;
    std.debug.print("{s}\n", .{response.capability});
    std.debug.print("- x: {d}\n", .{data.x});
    std.debug.print("- y: {d}\n", .{data.y});
    std.debug.print("- rgb: {d},{d},{d}\n", .{ data.r, data.g, data.b });
    std.debug.print("- hex: {s}\n", .{data.hex});
}

fn printDisplayListText(response: core.model.DisplayListResponse) void {
    if (!response.ok) {
        printResponseError(response.capability, response.failure);
        return;
    }
    const data = response.data.?;
    std.debug.print("{s}\n", .{response.capability});
    std.debug.print("- count: {d}\n", .{data.count});
    for (data.displays) |display| {
        std.debug.print("  - id: {d}\n", .{display.id});
        std.debug.print("    name: {s}\n", .{display.name});
        std.debug.print("    is_primary: {}\n", .{display.is_primary});
        std.debug.print("    bounds: {d},{d} -> {d},{d} ({d}x{d})\n", .{
            display.bounds.left,
            display.bounds.top,
            display.bounds.right,
            display.bounds.bottom,
            display.bounds.width,
            display.bounds.height,
        });
    }
}

fn printWaitWindowText(response: core.model.WaitWindowResponse) void {
    if (!response.ok) {
        printResponseError(response.capability, response.failure);
        return;
    }
    const data = response.data.?;
    std.debug.print("{s}\n", .{response.capability});
    std.debug.print("- matched: {}\n", .{data.matched});
    std.debug.print("- elapsed_ms: {d}\n", .{data.elapsed_ms});
    if (data.window) |window| {
        printWindow(window);
    }
}

fn printWaitPixelText(response: core.model.WaitPixelResponse) void {
    if (!response.ok) {
        printResponseError(response.capability, response.failure);
        return;
    }
    const data = response.data.?;
    std.debug.print("{s}\n", .{response.capability});
    std.debug.print("- matched: {}\n", .{data.matched});
    std.debug.print("- elapsed_ms: {d}\n", .{data.elapsed_ms});
    if (data.pixel) |pixel| {
        std.debug.print("- pixel: ({d},{d}) rgb({d},{d},{d}) {s}\n", .{ pixel.x, pixel.y, pixel.r, pixel.g, pixel.b, pixel.hex });
    }
}

fn printWaitClipboardText(response: core.model.WaitClipboardResponse) void {
    if (!response.ok) {
        printResponseError(response.capability, response.failure);
        return;
    }
    const data = response.data.?;
    std.debug.print("{s}\n", .{response.capability});
    std.debug.print("- matched: {}\n", .{data.matched});
    std.debug.print("- elapsed_ms: {d}\n", .{data.elapsed_ms});
    if (data.text) |text| {
        std.debug.print("- text: {s}\n", .{text});
    }
}

fn printWaitProcessText(response: core.model.WaitProcessResponse) void {
    if (!response.ok) {
        printResponseError(response.capability, response.failure);
        return;
    }
    const data = response.data.?;
    std.debug.print("{s}\n", .{response.capability});
    std.debug.print("- matched: {}\n", .{data.matched});
    std.debug.print("- elapsed_ms: {d}\n", .{data.elapsed_ms});
    if (data.process) |process| {
        std.debug.print("- process: pid={d} name={s}\n", .{ process.pid, process.name });
    }
}

fn printWindow(window: core.model.WindowInfo) void {
    std.debug.print("  - handle: 0x{x}\n", .{window.handle});
    std.debug.print("    pid: {d}\n", .{window.pid});
    std.debug.print("    title: {s}\n", .{window.title});
    std.debug.print("    class_name: {s}\n", .{window.class_name});
    std.debug.print("    visible: {}\n", .{window.visible});
    std.debug.print("    is_foreground: {}\n", .{window.is_foreground});
    std.debug.print("    bounds: {d},{d} -> {d},{d} ({d}x{d})\n", .{
        window.bounds.left,
        window.bounds.top,
        window.bounds.right,
        window.bounds.bottom,
        window.bounds.width,
        window.bounds.height,
    });
}

fn printResponseError(capability: []const u8, err: ?core.errors.ApiError) void {
    const payload = err orelse core.errors.ApiError{ .code = core.errors.codes.system_error, .message = "The command failed without structured error details.", .detail = null };
    core.output.printErrorText(capability, payload.code, payload.message, payload.detail);
}

fn readOutputMode(args: []const []const u8) !core.model.OutputMode {
    if (findOptionValue(args, "--output")) |value| {
        return core.model.parseOutputMode(value) orelse return error.InvalidOutputMode;
    }
    return .json;
}

fn findOptionValue(args: []const []const u8, name: []const u8) ?[]const u8 {
    var index: usize = 0;
    while (index < args.len) : (index += 1) {
        if (std.mem.eql(u8, args[index], name)) {
            if (index + 1 < args.len) return args[index + 1];
            return null;
        }
    }
    return null;
}

fn hasFlag(args: []const []const u8, name: []const u8) bool {
    for (args) |item| {
        if (std.mem.eql(u8, item, name)) return true;
    }
    return false;
}

fn defaultCapturePath(allocator: std.mem.Allocator) ![]const u8 {
    return std.fmt.allocPrint(allocator, "zig-out/captures/easytouch-capture.png", .{});
}

fn parseHandleValue(value: []const u8) !u64 {
    if (std.mem.startsWith(u8, value, "0x") or std.mem.startsWith(u8, value, "0X")) {
        return std.fmt.parseInt(u64, value[2..], 16);
    }
    return std.fmt.parseInt(u64, value, 10);
}

fn parseMouseButton(value: []const u8) ?core.model.MouseButton {
    if (std.mem.eql(u8, value, "left")) return .left;
    if (std.mem.eql(u8, value, "right")) return .right;
    if (std.mem.eql(u8, value, "middle")) return .middle;
    return null;
}

fn parseBoolValue(value: []const u8) ?bool {
    if (std.ascii.eqlIgnoreCase(value, "true")) return true;
    if (std.ascii.eqlIgnoreCase(value, "false")) return false;
    return null;
}
