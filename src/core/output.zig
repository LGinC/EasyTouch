const std = @import("std");

pub fn printJson(value: anytype) !void {
    var buffer: [4096]u8 = undefined;
    var file_writer = std.fs.File.stdout().writer(&buffer);
    const stdout = &file_writer.interface;

    try std.json.Stringify.value(value, .{ .whitespace = .indent_2 }, stdout);
    try stdout.writeByte('\n');
    try stdout.flush();
}

pub fn printErrorText(capability: []const u8, code: []const u8, message: []const u8, detail: ?[]const u8) void {
    std.debug.print("{s}: error {s}\n", .{ capability, code });
    std.debug.print("- message: {s}\n", .{message});
    if (detail) |value| {
        std.debug.print("- detail: {s}\n", .{value});
    }
}
