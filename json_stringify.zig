const std = @import("std");
const json = std.json;

const Person = struct { name: []const u8, surname: []const u8 };

pub fn main() !void {
    const mario = Person{
        .name = "Mario",
        .surname = "Castro",
    };

    var buf: [100]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    var string = std.ArrayList(u8).init(&fba.allocator);
    defer string.deinit();

    try json.stringify(&mario, .{}, string.writer());

    std.debug.print("{s}\n", .{string.toOwnedSlice()});
}