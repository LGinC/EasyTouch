const std = @import("std");
const cli = @import("interfaces/cli.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    const argv = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, argv);

    const exit_code = try cli.run(allocator, if (argv.len > 1) argv[1..] else &[_][]const u8{});
    if (exit_code != 0) {
        std.process.exit(exit_code);
    }
}
