const std = @import("std");
const debug = std.debug;

const png = @import("./core/png.zig");

pub fn main() !void {
    const ihdr = try png.loadImageHeader("./tests/bitlaab.png");
    debug.print("Result: {any}\n", .{ihdr.ihdr});
}
