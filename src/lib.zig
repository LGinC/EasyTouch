pub const core = @import("easytouch_core");
pub const platform = @import("core/platform.zig");
pub const requirements = core.requirements;
pub const runtime = @import("runtime/root.zig");

pub const interfaces = struct {
    pub const cli = @import("interfaces/cli.zig");
    pub const mcp_stdio = @import("interfaces/mcp_stdio.zig");
};
