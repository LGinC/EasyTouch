const spec = @import("easytouch_core").spec;

pub const runtime = @import("runtime.zig");

pub const platform_spec = spec.PlatformSpec{
    .id = "windows",
    .label = "EasyTouch Windows",
    .native_stack = &[_][]const u8{
        "User32 and SendInput for mouse and keyboard injection",
        "GDI BitBlt first, DXGI Desktop Duplication second for screenshots",
        "EnumWindows, GetWindowRect, SetForegroundWindow for window control",
        "UI Automation COM for element inspection and semantic tree access",
        "Toolhelp32, PDH, GlobalMemoryStatusEx and related APIs for system info",
    },
    .capability_modules = &[_][]const u8{
        "mouse",
        "keyboard",
        "screenshot",
        "window",
        "system",
        "uiautomation",
        "humanizer",
    },
    .blockers = &[_][]const u8{
        "Need a clean COM bridge for UI Automation in Zig",
        "Need DPI-aware coordinate normalization across multi-monitor setups",
        "Need to handle UIPI and privilege boundaries when targeting elevated apps",
    },
};
