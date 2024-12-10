const std = @import("std");
const builtin = @import("builtin");


pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSafe
    });

    // Exposing as a dependency for other projects
    const package = b.addModule("lime", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize
    });

    package.addIncludePath(b.path("libs/include"));

    // Making executable for this project
    const exe = b.addExecutable(.{
        .name = "lime",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.addIncludePath(b.path("libs/include"));

    // Adding cross-platform dependency
    switch (builtin.os.tag) {
        .windows => {
            // TODO
        },
        .macos => {
            package.addObjectFile(b.path("libs/macOS/libz.a"));
            package.addObjectFile(b.path("libs/macOS/libspng.a"));

            exe.addObjectFile(b.path("libs/macOS/libz.a"));
            exe.addObjectFile(b.path("libs/macOS/libspng.a"));
        },
        else => @panic("Codebase is not tailored for this platform!")
    }

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&b.addRunArtifact(exe).step);
}
