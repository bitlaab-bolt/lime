//! # High Level Abstraction for Underlying Libraries


pub const Png = @import("./core/png.zig");

/// # API Bindings for Underlying Libraries
pub const Api = struct {
    pub const spng = @import("./binding/spng.zig");
};
