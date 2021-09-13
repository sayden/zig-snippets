const std = @import("std");

pub fn main() void {
    var known_at_runtime: usize = 5;
    var ns = [_]u32{2}**5;
    var sl = ns[0..known_at_runtime];
    
    const res_u32 = sum(u32, sl);
    std.debug.print("Result: {d}\n", .{res_u32});
    
    var nsf = [_]f32{2.5}**5;
    const res_f32 = sum(f32, nsf[0..known_at_runtime]);
    std.debug.print("Result: {d}\n", .{res_f32});
}

// generic function
fn sum(comptime T: type, ar: []const T) T {
    var result: T = 0;
    for (ar) |n| {
        result += n;
    }

    return result;
}