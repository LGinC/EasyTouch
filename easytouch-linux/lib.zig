const spec = @import("easytouch_core").spec;

pub const runtime = @import("runtime.zig");

pub const platform_spec = spec.PlatformSpec{
    .id = "linux",
    .label = "EasyTouch Linux",
    .native_stack = &[_][]const u8{
        "X11 Xlib, XTest, XRandR, XFixes and XComposite as phase one",
        "XShm or pipewire-based capture optimization as phase two",
        "AT-SPI2 over D-Bus for semantic element inspection",
        "procfs, sysfs and libc for system and process information",
        "Wayland support planned separately because compositor rules differ",
    },
    .capability_modules = &[_][]const u8{
        "mouse",
        "keyboard",
        "screenshot",
        "window",
        "system",
        "atspi",
        "humanizer",
    },
    .blockers = &[_][]const u8{
        "Need to scope phase one to X11 instead of mixing X11 and Wayland",
        "Need a D-Bus strategy for AT-SPI and desktop integration",
        "Need fallback behavior when the session denies synthetic input",
    },
};
