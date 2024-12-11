const std = @import("std");
const builtin = @import("builtin");


pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSafe
    });

    // Exposing as a dependency for other projects
    const pkg = b.addModule("lime", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize
    });

    pkg.addIncludePath(b.path("libs/include"));

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
            switch (builtin.cpu.arch) {
                .x86_64 => {
                    pkg.addObjectFile(
                        b.path("libs/windows/libz-v1.3.1.lib")
                    );
                    pkg.addObjectFile(
                        b.path("libs/windows/libspng-v0.7.4.lib")
                    );

                    exe.addObjectFile(
                        b.path("libs/windows/libz-v1.3.1.lib")
                    );
                    exe.addObjectFile(
                        b.path("libs/windows/libspng-v0.7.4.lib")
                    );
                },
                else => @panic("Unsupported architecture!")
            }
        },
        .macos => {
            switch (builtin.cpu.arch) {
                .aarch64 => {
                    pkg.addObjectFile(b.path("libs/macOS/libz-v1.3.1.a"));
                    pkg.addObjectFile(b.path("libs/macOS/libspng-v0.7.4.a"));

                    exe.addObjectFile(b.path("libs/macOS/libz-v1.3.1.a"));
                    exe.addObjectFile(b.path("libs/macOS/libspng-v0.7.4.a"));
                },
                else => @panic("Unsupported architecture!")
            }
        },
        else => @panic("Codebase is not tailored for this platform!")
    }

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&b.addRunArtifact(exe).step);
}
