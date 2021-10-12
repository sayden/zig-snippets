const std = @import("std");

pub fn main() !void {
    // Strings concatenation can be done in various ways. A "painful" one is using 
    // std.mem.concat, this requires a multidimensional const slice which is not
    // very intuitive to build
    const multi = [_] []const u8{
        "hello",
        " ",
        "world",
    };
    var page = std.heap.page_allocator;

    const string1 = try std.mem.concat(page, u8, multi[0..]);
    defer page.free(string1);
    try std.testing.expectEqualSlices(u8, "hello world", string1);

    // A less "painful" one is to use std.fmt.format
    const string2 = try std.fmt.allocPrint(page, "{s}{s}{s}", .{"hello"," ","world"});
    defer page.free(string2);
    try std.testing.expectEqualSlices(u8, "hello world", string2);

    // Both require allocation on the heap, you can workaround this by using an
    // stack based allocator if the string is "small"
    var buf: [256]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    var fba_allocator = &fba.allocator;

    const string3 = try std.fmt.allocPrint(fba_allocator, "{s}{s}{s}", .{"hello"," ","world"});
    defer fba_allocator.free(string3);
    try std.testing.expectEqualSlices(u8, "hello world", string3);

    // How big the stack allocator can be? Well I'm not sure, but if I run a `ulimit -a` 
    // (or `ulimit -s`) it is 8192 bytes in my linux OS (I got the info from here
    // https://softwareengineering.stackexchange.com/questions/310658/how-much-stack-usage-is-too-much) 
    // Windows folks can maybe track how to check their size by following the link),
    // so the max buffer size is definitely less than this number, because we are 
    // already using some space in the stack for other stuff.
}