pub const meta = @import("meta.zig");

pub fn Vec2(comptime T: type) type {
    return @Vector(2, T);
}

pub fn Vec3(comptime T: type) type {
    return @Vector(3, T);
}

pub fn Rect(comptime T: type) type {
    return struct {
        pos: Vec2(T) = .{ 0, 0 },
        size: Vec2(T) = .{ 0, 0 },
    };
}

pub fn length(vec: anytype) comptime_float {
    comptime {
        const vec_type = @typeInfo(@TypeOf(vec));

        if (vec_type != .Vector) {
            @compileError("\"vec\" parameter must be a @Vector(length, type)!");
        }

        if (!meta.isNumeric(vec_type.Vector.child)) {
            @compileError("Vector element type \"{" ++ @typeName(vec_type.Vector.child) ++ "}\" is not supported by length()!");
        }
    }

    //Square all the elements of the vector
    vec *= vec;

    const sum = @reduce(.Add, vec);

    return @sqrt(sum);
}

pub fn fixed_aspect_ratio_scale(size: Vec2(u16), desired_aspect: f32) Rect(u16) {
    const aspect = @as(f32, @floatFromInt(size[0])) / @as(f32, @floatFromInt(size[1]));

    var viewport_pos = Vec2(u16){ 0, 0 };
    var viewport_size = size;

    if (aspect > desired_aspect) {
        viewport_size[0] = @intFromFloat(@as(f32, @floatFromInt(size[1])) * desired_aspect);
        viewport_pos[0] = @divFloor((size[0] - viewport_size[0]), 2);
    } else {
        viewport_size[1] = @intFromFloat(@as(f32, @floatFromInt(size[0])) / desired_aspect);
        viewport_pos[1] = @divFloor((size[1] - viewport_size[1]), 2);
    }

    return .{ .pos = viewport_pos, .size = viewport_size };
}
