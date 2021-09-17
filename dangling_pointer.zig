const std = @import("std");

pub fn main() !void {
    var p = pointer();

    // here it works
    std.debug.print("{s}\n", .{p.msg});

    // but here it won't as expected, I don't understand well 
    // why it works in the previous case.
    printMsg(p);
}

const MyStruct = struct {
    msg: []const u8,
};

fn pointer() *MyStruct {
    var m = MyStruct{
        .msg = "hello",
    };
    return &m;
}

fn printMsg(p: *MyStruct) void {
    std.debug.print("{s}\n", .{p.msg});
}
