const builtin = @import("builtin");
const spec = @import("easytouch_core").spec;
const windows = @import("easytouch_windows");
const linux = @import("easytouch_linux");
const mac = @import("easytouch_mac");

pub const all = [_]spec.PlatformSpec{
    windows.platform_spec,
    linux.platform_spec,
    mac.platform_spec,
};

pub fn current() spec.PlatformSpec {
    return switch (builtin.os.tag) {
        .windows => windows.platform_spec,
        .linux => linux.platform_spec,
        .macos => mac.platform_spec,
        else => .{
            .id = "unsupported",
            .label = "Unsupported host",
            .native_stack = &[_][]const u8{
                "No native adapter selected for this target.",
            },
            .capability_modules = &[_][]const u8{
                "Select Windows, Linux, or macOS as the target platform.",
            },
            .blockers = &[_][]const u8{
                "The current host is outside the planned support matrix.",
            },
        },
    };
}
