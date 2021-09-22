const std = @import("std");
const expect = std.testing.expect;

pub fn main() !void {
    const msg = "405323";

    // Parse a unsigned 4 byte int number from a string
    var res = try std.fmt.parseUnsigned(u32, msg, 10);
    try expect(res == 405323);

    // Serialize a number into a bytes array
    var bytes = std.mem.toBytes(res);
    
    // Parse a 4 byte array to a unsigned int number from
    var n = std.mem.bytesToValue(u32, &bytes);
    try expect(n == 405323);
}
