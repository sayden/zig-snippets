const std = @import("std");
const expect = std.testing.expect;

pub fn main() !void {
    const text = "the lazy fox jump over 1 brown dog.";

    var pa = std.heap.page_allocator;
    // This actually allocates an array of optionals![]const u8, so
    // actually a multidimensional array. But in fact, this is an
    // array of optional slice pointers to portions of 'text' const.
    var tokens = try pa.alloc(?[]const u8, 10);
    defer pa.free(tokens);

    // The slice pointer has a size of 16 bytes: 8 bytes for the
    // pointer and 8 bytes for the slice size.
    try expect(@sizeOf(@TypeOf(tokens)) == 16);

    // The total size of the allocated space is 240 bytes, 24 bytes
    // per item: like before, 16 bytes of the slice pointer to elements
    // in the original array and 8 bytes for the optional == 24 bytes
    // multiplied by 10 items == 240 bytes;
    try expect(@sizeOf(@TypeOf(tokens[0])) == 24);
    try expect(std.mem.sliceAsBytes(tokens).len == 240);

    var last: usize = 0;
    var pos: usize = 0;
    for (text) |c, i| {
        // ASCII Space
        if (c == 32) {
            tokens[pos] = text[last..i];
            pos += 1;
            last = i + 1;
        }
    }
    if (last < text.len) {
        tokens[pos] = text[last..];
    }

    for (tokens) |maybe_token| {
        if (maybe_token) |token|
            std.debug.print("'{s}'\n", .{token});
    }

    std.debug.print("\n", .{});

    // The reason to use a optional for the previous array was
    // to work easily with iterators, but there's an overhead
    // of a 50% in size for the array size. I think that to avoid
    // the use of optionals, I need to keep a count in the
    // number of tokens extracted
    var light_tokens = try pa.alloc([]const u8, 10);
    defer pa.free(light_tokens);

    try expect(@sizeOf(@TypeOf(light_tokens)) == 16);
    try expect(@sizeOf(@TypeOf(light_tokens[0])) == 16);
    try expect(std.mem.sliceAsBytes(light_tokens).len == 160);

    var token_count: usize = 0;
    last = 0;
    pos = 0;
    for (text) |c, i| {
        // ASCII Space
        if (c == 32) {
            light_tokens[pos] = text[last..i];
            pos += 1;
            last = i + 1;
            token_count += 1;
        }
    }

    if (last < text.len) {
        light_tokens[pos] = text[last..];
    }
    token_count += 1;

    var i: usize = 0;
    while (i < token_count) : (i += 1) {
        std.debug.print("'{s}'\n", .{light_tokens[i]});
    }
}
