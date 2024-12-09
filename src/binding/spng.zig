const std = @import("std");

const spng = @cImport({
    @cInclude("spng.h");
});


const Ctx = opaque {};

const File = [*c]spng.FILE;

const CtxFlag = enum(i32) {
    default = 0,
    /// Ignore checksum in DEFLATE streams
    ignore_ADLER32 = 1,
    /// Create an encoder context
    encoder = 2
};

/// See https://libspng.org/docs/decode/#supported-format-flag-combinations
const DecodeFlag = enum(i32) {
    default = 0,
    transparent = 1,
    gamma = 2,
    progressive = 256
};

pub const ImageHeader = struct {
    width: u32,
    height: u32,
    bit_depth: u8,
    color_type: u8,
    compression_type: u8,
    filter_type: u8,
    interlace_type: u8
};

/// - See https://libspng.org/docs/decode/#supported-format-flag-combinations
const ImageFormat = enum(i32) {
    RGBA8 = 1,
    RGBA16 = 2,
    RGB8 = 4,
    GA8 = 16,
    GA16 = 32,
    G8 = 64,
    PNG = 256,
    RAW = 512
};

/// # Creates a New Context
/// - **WARNING:** You must call `ctxFree()` when your are done
pub fn ctxNew(flag: CtxFlag) ?*Ctx {
    const ctx = spng.spng_ctx_new(@intFromEnum(flag));
    return @ptrCast(ctx);
}

/// # Releases Context Resources
pub fn ctxFree(ctx: ?*Ctx) void {
    spng.spng_ctx_free(@ptrCast(ctx));
}

/// # Return Error Message for the Given Error Code
pub fn strError(code: i32) []const u8 {
    const msg = spng.spng_strerror(code);
    return std.mem.span(msg);
}

/// - See https://man7.org/linux/man-pages/man3/fopen.3.html
const Mode = enum { r, @"r+", w, @"w+", a, @"a+" };

/// # Issues `fopen()` Syscall
/// - `spng_set_png_file()` expects `[*c]FILE` structure
/// - **WARNING:** You must call `close()` when your are done
pub fn open(file_path: []const u8, mode: Mode) File {
    const file = spng.fopen(file_path.ptr, @tagName(mode));
    return @ptrCast(file);
}

/// # Issues `fclose()` Syscall
pub fn close(file: File) i32 {
    return spng.fclose(file);
}

/// # Set Input or Output File, Depending on Context Type
/// - This can only be done once per context.
pub fn setPngFile(ctx: ?*Ctx, file: File) i32 {
    return spng.spng_set_png_file(@ptrCast(ctx), file);
}

/// # Image Header Info
pub fn getIhdr(ctx: ?*Ctx, ihdr: *ImageHeader) i32 {
    return spng.spng_get_ihdr(@ptrCast(ctx), @ptrCast(ihdr));
}

/// # Calculates Decoded Image Buffer Size
/// - An input PNG must be set
/// - `fmt` is the output image format
pub fn decodeImageSize(ctx: ?*Ctx, fmt: ImageFormat, len: *usize) i32 {
    return spng.spng_decoded_image_size(
        @ptrCast(ctx), @intFromEnum(fmt), @ptrCast(len)
    );
}

/// # Writes Decoded Image to Output
/// - `fmt` is the output image format
pub fn decodeImage(
    ctx: ?*Ctx,
    out: []u8,
    len: usize,
    fmt: ImageFormat,
    flags: DecodeFlag
) i32 {
    return spng.spng_decode_image(
        @ptrCast(ctx),
        @ptrCast(out),
        len,
        @intFromEnum(fmt),
        @intFromEnum(flags)
    );
}
