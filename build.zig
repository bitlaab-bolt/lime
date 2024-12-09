const std = @import("std");
const builtin = @import("builtin");


pub fn build(b: *std.Build) void {
    // Exposing as a dependency for other packages
    // _ = b.addModule("lime", .{
    //     .root_source_file = b.path("src/root.zig")
    // });

    const lime = b.createModule("lime", .{
        .root_source_file = b.path("src/root.zig")
    });

    lime.addIncludePath(b.path("./libs/include"));
    lime.addObjectFile(b.path("libs/macOS/libz.a"));
    lime.addObjectFile(b.path("libs/macOS/libspng.a"));

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .Debug
    });

    const exe = b.addExecutable(.{
        .name = "lime",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.addIncludePath(b.path("./libs/include"));

    switch (builtin.os.tag) {
        .windows => {
            // TODO
        },
        .macos => {
            exe.addObjectFile(b.path("libs/macOS/libz.a"));
            exe.addObjectFile(b.path("libs/macOS/libspng.a"));
        },
        else => @panic("Codebase is not tailored for this platform!")
    }

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&b.addRunArtifact(exe).step);
}
