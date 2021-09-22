// gcc -shared -fPIC -o libmylib.so c-libfunction.c
// zig run c-libfunction.zig -lc -lmylib -L.
const std = @import("std");
const libfn = @cImport({
    @cInclude("c-libfunction.c");
});

pub fn main() !void {
    var i: i32 = 0;
    while (i < 10) : (i += 1) {
        var res = libfn.double_me(i);
        std.debug.print("Double of {d} is in C {d}\n", .{i, res});
    }
}
