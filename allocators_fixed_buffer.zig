const std = @import("std");
const fballoc = std.heap.FixedBufferAllocator;

pub fn main() !void {
    var buffer: [12]u8 = undefined;
    var fba = fballoc.init(&buffer);
    var allocator = &fba.allocator;

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

    std.debug.print("{s}\n", .{buffer});
}