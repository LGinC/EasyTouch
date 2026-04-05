pub const codes = struct {
    pub const invalid_args = "invalid_args";
    pub const unsupported_host = "unsupported_host";
    pub const not_implemented = "not_implemented";
    pub const permission_denied = "permission_denied";
    pub const timeout = "timeout";
    pub const interrupted_by_user = "interrupted_by_user";
    pub const system_error = "system_error";
    pub const unsafe_operation = "unsafe_operation";
    pub const clipboard_empty = "clipboard_empty";
    pub const not_found = "not_found";
};

pub const ApiError = struct {
    code: []const u8,
    message: []const u8,
    detail: ?[]const u8 = null,
};
