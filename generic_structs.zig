const std = @import("std");

fn AddTwo(comptime T: type) type {
    return struct {
        n: T,
        const Self = @This();

        fn result(self: Self) T {
            return self.n+2;
        }
    };
}


pub fn main() void {
    const n = AddTwo(u32){ .n = 2 };
    const res = n.result();
    std.debug.print("R: {d}\n",.{res});
}