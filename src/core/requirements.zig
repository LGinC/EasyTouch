pub const RequirementGroup = struct {
    title: []const u8,
    items: []const []const u8,
};

pub const groups = [_]RequirementGroup{
    .{
        .title = "Observation and state",
        .items = &[_][]const u8{
            "Screenshots, monitor layout, active window, window list, and pixel inspection",
            "Element tree access through UI Automation, AT-SPI, or AXUIElement",
            "System, process, and application state for decision making",
            "User activity detection so the runtime can notice manual takeover",
        },
    },
    .{
        .title = "Actions and clipboard",
        .items = &[_][]const u8{
            "Mouse, keyboard, scroll, drag and drop, window focus, and app launch",
            "Clipboard read and write for text, HTML, files, and images",
            "High-level copy, paste, and cut actions instead of only raw key sequences",
            "Text entry strategies that choose between typing, paste, and Unicode-safe input",
        },
    },
    .{
        .title = "Waiters and verification",
        .items = &[_][]const u8{
            "Wait for window, focus, process, clipboard, element, and pixel changes",
            "Re-observe the UI after actions to verify that the intended state changed",
            "Timeout, retry, and interruption-aware execution flow",
        },
    },
    .{
        .title = "Human-like automation",
        .items = &[_][]const u8{
            "Mouse trajectory shaping, typing rhythm, pause profiles, and drag curves",
            "User override detection so the bot yields instead of fighting the operator",
            "Emergency stop hotkeys and safe abort behavior",
        },
    },
    .{
        .title = "AI-facing runtime interfaces",
        .items = &[_][]const u8{
            "Embeddable Zig library as the single source of automation behavior",
            "CLI for scripting and debugging with structured JSON output",
            "MCP stdio server that maps the same capabilities into tools",
            "Stable resource identifiers for windows, elements, captures, and sessions",
        },
    },
};
