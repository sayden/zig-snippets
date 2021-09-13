const std = @import("std");

pub fn main() !void {    
    const allocator = std.heap.page_allocator;

    const mem1 = try allocator.alloc(u8, 5);
    defer allocator.free(mem1);

    for ("hello") |c, i| {
        mem1[i] = c;
    }

    const mem2 = try allocator.alloc(u8, 7);
    defer allocator.free(mem2);

    for (" world!") |c, i| {
        mem2[i] = c;
    }

    std.debug.print("{s}{s}\n", .{mem1, mem2});
}