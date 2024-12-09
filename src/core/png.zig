const std = @import("std");
const debug = std.debug;
const Allocator = std.mem.Allocator;

const spng = @import("../binding/spng.zig");


const Error = error { FileNotFound };

const Output = union {
    err: []const u8,
    data: []const u8,
    ihdr: spng.ImageHeader
};

/// # Loads RAW Image Pixels
/// - **WARNING:** You must call `freeImage()` when your are done
pub fn loadImage(heap: Allocator, file_path: []const u8) !Output {
    const ctx = spng.ctxNew(.default);
    defer spng.ctxFree(ctx);

    const file = spng.open(file_path, .r);
    if (file == null) return Error.FileNotFound;
    defer debug.assert(spng.close(file) == 0);

    var rv: i32 = 0;

    rv = spng.setPngFile(ctx, file);
    if (rv != 0) return .{.err = spng.strError(rv)};

    var len: usize = undefined;
    rv = spng.decodeImageSize(ctx, .RGBA8, &len);
    if (rv != 0) return .{.err = spng.strError(rv)};

    const out = try heap.alloc(u8, len);
    rv = spng.decodeImage(ctx, out, len, .RGBA8, .transparent);
    if (rv != 0) return .{.err = spng.strError(rv)};

    return .{.data = out};
}

pub fn freeImage(heap: Allocator, data: []const u8) void {
    heap.free(data);
}

/// # Loads IHDR Info of a Given Image
pub fn loadImageHeader(file_path: []const u8) !Output {
    const ctx = spng.ctxNew(.default);
    defer spng.ctxFree(ctx);

    const file = spng.open(file_path, .r);
    if (file == null) return Error.FileNotFound;
    defer debug.assert(spng.close(file) == 0);

    var rv: i32 = 0;

    rv = spng.setPngFile(ctx, file);
    if (rv != 0) return .{.err = spng.strError(rv)};

    var ihdr = std.mem.zeroes(spng.ImageHeader);

    rv = spng.getIhdr(ctx, &ihdr);
    if (rv != 0) return .{.err = spng.strError(rv)};

    return .{.ihdr = ihdr};
}
