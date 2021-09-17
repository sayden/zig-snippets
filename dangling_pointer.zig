const std = @import("std");

pub fn main() !void {
    var p = pointer();

    // here it works, which is a bit unexpected
    std.debug.print("{s}\n", .{p.msg});

    // (core dump) but here it won't as expected, I don't 
    // understand well why it works in the previous case.
    printMsg(p);

    var p2 = constPointer();

    // here it works too
    std.debug.print("{s}\n", .{p2.msg});

    // (core dump) but here it won't either
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

fn constPointer()*const MyStruct{
    const m = MyStruct{
        .msg = "world",
    };

    return &m;
}

fn printMsg(p: *const MyStruct) void {
    std.debug.print("{s}\n", .{p.msg});
}
