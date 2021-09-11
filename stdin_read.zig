const std = @import("std");

pub fn main() void {
    const stdin = std.io.getStdIn();

    std.debug.print("Enter your name\n", .{});

    var buffer: [8]u8 = undefined;
    var reader = stdin.reader();
    var line = reader.readUntilDelimiterOrEof(&buffer, '\n');

    std.debug.print("Hello {s}\n", .{line});
}
