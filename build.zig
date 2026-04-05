const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const core_mod = b.createModule(.{
        .root_source_file = b.path("src/core/root.zig"),
    });

    const windows_mod = b.createModule(.{
        .root_source_file = b.path("easytouch-windows/lib.zig"),
    });
    windows_mod.addImport("easytouch_core", core_mod);

    const linux_mod = b.createModule(.{
        .root_source_file = b.path("easytouch-linux/lib.zig"),
    });
    linux_mod.addImport("easytouch_core", core_mod);

    const mac_mod = b.createModule(.{
        .root_source_file = b.path("easytouch-mac/lib.zig"),
    });
    mac_mod.addImport("easytouch_core", core_mod);

    const root_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    root_mod.addImport("easytouch_core", core_mod);
    root_mod.addImport("easytouch_windows", windows_mod);
    root_mod.addImport("easytouch_linux", linux_mod);
    root_mod.addImport("easytouch_mac", mac_mod);

    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib_mod.addImport("easytouch_core", core_mod);
    lib_mod.addImport("easytouch_windows", windows_mod);
    lib_mod.addImport("easytouch_linux", linux_mod);
    lib_mod.addImport("easytouch_mac", mac_mod);

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "easytouch",
        .root_module = lib_mod,
    });

    const exe = b.addExecutable(.{
        .name = "et",
        .root_module = root_mod,
    });

    switch (target.result.os.tag) {
        .linux => {
            lib.root_module.linkSystemLibrary("X11", .{});
            exe.root_module.linkSystemLibrary("X11", .{});
        },
        .macos => {
            lib.root_module.linkFramework("ApplicationServices", .{});
            exe.root_module.linkFramework("ApplicationServices", .{});
        },
        else => {},
    }

    b.installArtifact(lib);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the EasyTouch Zig scaffold");
    run_step.dependOn(&run_cmd.step);

    const check_step = b.step("check", "Compile the EasyTouch Zig scaffold");
    check_step.dependOn(&exe.step);
    check_step.dependOn(&lib.step);
}
