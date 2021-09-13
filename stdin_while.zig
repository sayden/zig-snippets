const std = @import("std");

const MyEnum = enum {
    @".exit",
    @".help",
    @".unrecognized",
};

pub fn main() !void {
    const stdin = std.io.getStdIn();

    std.debug.print("Enter your name\n", .{});

    var buffer: [100]u8 = undefined;
    var reader = stdin.reader();

    while (true) {
        var line = try reader.readUntilDelimiterOrEof(&buffer, '\n');

        const conv: MyEnum = std.meta.stringToEnum(MyEnum, line.?) orelse MyEnum.@".unrecognized";

        switch(conv){
            MyEnum.@".exit" =>  {
                std.debug.print("Bye!\n", .{});
                return;
            },
            MyEnum.@".help" => {
                std.debug.print("Possible commands are:!\n.exit => exits the REPL\n.help => Show this help\n", .{});
            },
            MyEnum.@".unrecognized" => {
                std.debug.print("Unrecognized command '{s}'\n", .{line.?});
            },
        }

        
    }

    unreachable;
}
