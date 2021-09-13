const std = @import("std");
const arena = std.heap.ArenaAllocator;

pub fn main() !void {    
    var arena_alloc = arena.init(std.heap.page_allocator);
    defer arena_alloc.deinit();

    var allocator = &arena_alloc.allocator;

    const mem1 = try allocator.alloc(u8, 5);

    for ("hello") |c, i| {
        mem1[i] = c;
    }

    const mem2 = try allocator.alloc(u8, 7);

    for (" world!") |c, i| {
        mem2[i] = c;
    }

    std.debug.print("{s}{s}\n", .{mem1, mem2});
}