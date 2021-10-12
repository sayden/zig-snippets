const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var string_literal:*const [30:0]u8 = "talk is cheap show me the code";
    print("Type of string_literal         {s}   Size:  {d}\n", .{ @TypeOf(string_literal), @sizeOf(@TypeOf(string_literal)) });
    // Type of string_literal         *const [30:0]u8   Size:  8

    // So why string literals are somehow hard on Zig? Well, looking at the type value of the first variable, `string_literal`, it is a `*const [30:0]u8`
    // or, in plain words: a pointer to a constant value represented by an array of 30 u8 items. The good thing is that it's a pointer, so it occupies 
    // only 8 bytes if I want to move it around (the underlying array still is 31 bytes of size but I don't need to move it). The bad news is that it's 
    // not very flexible to pass it around to other functions because the type has the size associated (so I can only use 30 bytes 'strings' on
    // functions for this example) which is the exact numbers of bytes of the sentence "talk is cheap show me the code"

    var string_literal_array = string_literal.*;
    print("Type of string_literal_array   {s}          Size: {d}\n", .{ @TypeOf(string_literal_array), @sizeOf(@TypeOf(string_literal_array)) });
    // Type of string_literal_array   [30:0]u8          Size: 31

    // Here the situation is a bit worse. Now I don't have a pointer but, instead, I have an array directly. This means that if I pass it to a function
    // which accepts 30 bytes arrays, Zig will copy the entire array to the function. But this is what slices are for, right? To create runtime pointers
    // to regions of an array that will contain a memory direction and a length.

    var string_literal_slice = string_literal_array[0..];
    print("Type of string_literal_slice   {s}         Size:  {d}\n", .{ @TypeOf(string_literal_slice), @sizeOf(@TypeOf(string_literal_slice)) });
    // Type of string_literal_slice   *[30:0]u8         Size:  8

    // Back to square zero? I kind of progressed a bit. Now I have a pointer to an array, like at the beginning, but the size of the array is still there.
    // The good news is that this is again only 8 bytes to move around. The bad news is that it is still not flexible to use it in a function that accepts
    // arbitrary size slices. And it's not constant... so... if I modify it, will the original be modified too?

    string_literal_slice[16] = '0';
    print("'{s}' != '{s}' == {s}?\n", .{string_literal, string_literal_slice, string_literal_array});
    // 'talk is cheap show me the code' != 'talk is cheap sh0w me the code' == talk is cheap sh0w me the code?

    // Nope. The original is left intact because when I created string_literal_array var, I copied the contents of `string_literal`.

    var string_literal_coerced: []u8 = string_literal_slice;
    print("Type of string_literal_coerced {s}              Size: {d}\n", .{ @TypeOf(string_literal_coerced), @sizeOf(@TypeOf(string_literal_coerced)) });
    // Type of string_literal_coerced []u8              Size: 16

    // And this is what we really wanted. The size is not part of the type anymore, but that doesn't mean that the size is unknown, it's still stored in
    // the slice but, and I repeat, **the size is not part of the type**. The slice occupies 16 bytes, 8 bytes for the pointer and 8 bytes to store the
    // slice size.

    var string_literal_size_unknown: [*]u8 = string_literal_slice;
    print("Type of string_literal_coerced {s}             Size:  {d}\n", .{ @TypeOf(string_literal_size_unknown), @sizeOf(@TypeOf(string_literal_size_unknown)) });

    // This is the last thingy. Here the size of the slice **is not part of the type** AND it is also **unknown*, so just a pointer to the beginning of an array
    // without size information, effectively 8 bytes in memory. Why using this if I won't know when to stop? Because the size might be stored somewhere else
    // like in a local variable or something like that. Why use it? I might want to use this in situations where the number of items in an array are not the 
    // same that the value returned by `array.len`. For example when allocating an array of values, the slice returned is []u8:

    var page = std.heap.page_allocator;

    var mem: []u8 = try page.alloc(u8,8);
    defer page.free(mem);
    mem[0] = 'a';
    print("Type of mem                    {s}              Size: {d}. Content: {s}\n", .{ @TypeOf(mem), @sizeOf(@TypeOf(mem)), mem });
    // Type of mem                    []u8              Size: 16. Content: a�������

    // Like this. My slice has size 10 but only the first byte has valid values. One way to solve this is to pass a "slice of the slice" like mem[0..1] which
    // effectively says "this slice actually starts in 0 and has length 1" which can be coerced to []u8. At the end, it's some kind of type restriction to 
    // disallow the use of `len` in some parts of the code.

    var unknown_size: [*]u8 = mem.ptr;
    _ = unknown_size;

    // BTW I can get an unknown size slice using slice.ptr
    print("Type of unknown_size           {s}             Size:  {d}\n", .{ @TypeOf(unknown_size), @sizeOf(@TypeOf(unknown_size)) });
}