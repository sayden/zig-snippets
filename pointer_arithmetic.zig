const std = @import("std");
const expect = std.testing.expect;

pub fn main() !void {
    var array = [_]i32{ 1, 2, 3, 4 };

    var known_at_runtime_zero: usize = 0;
    const slice = array[known_at_runtime_zero..array.len];

    var p = slice.ptr;
    try expect(p[0] == 1);

    // Increment pointer one step
    p += 1;
    try expect(p[0] == 2);
}
