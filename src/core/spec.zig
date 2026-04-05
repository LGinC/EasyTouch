pub const PlatformSpec = struct {
    id: []const u8,
    label: []const u8,
    native_stack: []const []const u8,
    capability_modules: []const []const u8,
    blockers: []const []const u8,
};
