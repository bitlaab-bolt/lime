/// API Bindings for Underlying Libraries
pub const Api = struct {
    const spng = @import("./binding/spng.zig");
};

/// High Level Abstraction for Underlying Libraries
pub const Utils = struct {
    const Png = @import("./core/png.zig");
};
