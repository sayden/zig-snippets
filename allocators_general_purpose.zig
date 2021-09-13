const std = @import("std");

pub fn main() !void {    
    var gpa = std.heap.GeneralPurposeAllocator(.{.enable_memory_limit = true}){};
    var allocator = &gpa.allocator;
    defer {
        const leaked = gpa.deinit();
        if (leaked) unreachable;
    }

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

    std.debug.print("Total requested bytes: {d}\nNever exceed bytes: {d}\n", .{gpa.total_requested_bytes, gpa.requested_memory_limit});
    std.debug.print("{s}{s}\n", .{mem1, mem2});
}