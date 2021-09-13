const std = @import("std");
const fballoc = std.heap.FixedBufferAllocator;
const arena = std.heap.ArenaAllocator;

pub fn main() !void {
    var buffer: [128]u8 = undefined;
    var fba = fballoc.init(&buffer);
    var fballocator = &fba.allocator;
    
    var arena_alloc = arena.init(fballocator);
    defer arena_alloc.deinit();

    var allocator = &arena_alloc.allocator;

    var mem1 = try allocator.alloc(u8, 5);
    for ("hello") |c, i| {
        mem1[i] = c;
    }

    var mem2 = try allocator.alloc(u8, 6);
    for ("world!") |c, i| {
        mem2[i] = c;
    }
    
    std.debug.print("{s} {s}\n", .{mem1, mem2});
}