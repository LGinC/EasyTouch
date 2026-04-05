const spec = @import("easytouch_core").spec;

pub const runtime = @import("runtime.zig");

pub const platform_spec = spec.PlatformSpec{
    .id = "macos",
    .label = "EasyTouch macOS",
    .native_stack = &[_][]const u8{
        "CoreGraphics for input synthesis, display geometry and screenshots",
        "AXUIElement and Accessibility APIs for semantic element inspection",
        "CGWindowList and AppKit/NSWorkspace for window and app state",
        "sysctl, host_statistics and related APIs for system information",
        "Objective-C runtime bridging where AppKit access is required",
    },
    .capability_modules = &[_][]const u8{
        "mouse",
        "keyboard",
        "screenshot",
        "window",
        "system",
        "accessibility",
        "humanizer",
    },
    .blockers = &[_][]const u8{
        "Need Accessibility and Screen Recording permission checks",
        "Need a safe bridge for Objective-C and CoreFoundation ownership rules",
        "Need coordinate conversion between Quartz, displays and accessibility frames",
    },
};
