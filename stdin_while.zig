const std = @import("std");

const MyEnum = enum {
    @".exit",
};

pub fn main() !void {
    const stdin = std.io.getStdIn();

    std.debug.print("Enter your name\n", .{});

    var buffer: [8]u8 = undefined;
    var reader = stdin.reader();

    while (true) {
        var line = try reader.readUntilDelimiterOrEof(&buffer, '\n');

        const e = std.meta.stringToEnum(line.?);

        if (e == ".exit") {
            std.debug.print("Bye!\n", .{});
            return;
        } else {
            std.debug.print("Unrecognized command. {s}", .{line});
        }
    }

    unreachable;
}
