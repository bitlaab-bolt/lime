const std = @import("std");
const debug = std.debug;

const png = @import("./core/png.zig");

pub fn main() !void {
    var gpa_mem = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa_mem.deinit() == .ok);
    const heap = gpa_mem.allocator();

    // Loads RAW pixels
    const image = try png.loadImage(heap, "./tests/gbitlaab.png");
    defer png.freeImage(heap, image.data);

    switch(image) {
        .err => |v| {
            std.debug.print("Error: {s}\n", .{v});
            return error.FailedToLoad;
        },
        .data => |v| {
            // `v` Contains Raw pixel data
            std.debug.print("Total pixels {d}\n", .{v.len});
        },
        .ihdr => unreachable
    }

    // Loads IHDR info
    const ihdr = try png.loadImageHeader("./tests/bitlaab.png");
    debug.print("Result: {any}\n", .{ihdr.ihdr});
}
