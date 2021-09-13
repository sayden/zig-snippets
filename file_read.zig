const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("example.txt", std.fs.File.OpenFlags{.read = true});
    defer file.close();

    var buffer: [100]u8 = undefined;

    // Read first line only
    const line = try file.reader().readUntilDelimiterOrEof(&buffer, '\n');
    std.debug.print("{s}\n", .{line});

    // Read all
    // const bytes_read = try file.readAll(&buffer);
    // std.debug.print("{s}\n", .{buffer[0..bytes_read]});
}