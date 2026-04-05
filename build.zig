const std = @import("std");

fn normalizeLinuxHostTarget(query: std.Target.Query, host: std.Target) std.Target.Query {
    var normalized = query;

    if (host.os.tag != .linux) return normalized;
    if (query.os_tag != .linux) return normalized;
    if (query.cpu_arch == null or query.cpu_arch.? != host.cpu.arch) return normalized;
    if (query.abi != null or query.os_version_min != null or query.os_version_max != null) return normalized;
    if (query.glibc_version != null or query.android_api_level != null) return normalized;
    if (query.dynamic_linker.get() != null) return normalized;

    // Treat host-matching Linux triples as native so Zig can discover libc/X11 paths.
    normalized.cpu_arch = null;
    normalized.os_tag = null;

    switch (normalized.cpu_model) {
        .determined_by_arch_os => {
            if (normalized.cpu_features_add.isEmpty() and normalized.cpu_features_sub.isEmpty()) {
                normalized.cpu_model = .baseline;
            }
        },
        else => {},
    }

    return normalized;
}

fn configureMacSysroot(b: *std.Build, target: std.Build.ResolvedTarget) void {
    if (target.result.os.tag != .macos) return;
    if (b.sysroot != null) return;

    if (b.graph.env_map.get("SDKROOT")) |sdk_root| {
        if (sdk_root.len != 0) {
            b.sysroot = b.dupePath(sdk_root);
            return;
        }
    }

    if (b.graph.host.result.os.tag != .macos) return;

    if (std.zig.system.darwin.getSdk(b.allocator, &target.result)) |sdk_root| {
        b.sysroot = sdk_root;
    }
}

pub fn build(b: *std.Build) void {
    const target_query = normalizeLinuxHostTarget(b.standardTargetOptionsQueryOnly(.{}), b.graph.host.result);
    const target = b.resolveTargetQuery(target_query);
    const optimize = b.standardOptimizeOption(.{});

    configureMacSysroot(b, target);

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
            lib.root_module.link_libc = true;
            exe.root_module.link_libc = true;
            lib.root_module.linkSystemLibrary("X11", .{});
            exe.root_module.linkSystemLibrary("X11", .{});
        },
        .macos => {
            lib.root_module.link_libc = true;
            exe.root_module.link_libc = true;
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
