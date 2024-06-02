pub const meta = @import("meta.zig");

pub fn Vec2(comptime T: type) type {
    return @Vector(2, T);
}

pub fn Vec3(comptime T: type) type {
    return @Vector(3, T);
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
