pub fn isNumeric(comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .Float, .Int, .ComptimeFloat, .ComptimeInt => true,
        else => false,
    };
}
