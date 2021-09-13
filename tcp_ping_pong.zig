const std = @import("std");
const net = std.net;

pub fn main() !void {
    const address = try net.Address.resolveIp("0.0.0.0", 8080);
    var stream = try net.tcpConnectToAddress(address);
    defer stream.close();


    const msg = "hello from zig!";
    _ = try stream.write(msg[0..]);

    var res = getResponse(&stream);
    
    std.debug.print("{s}\nBye!\n", .{res});
}

fn getResponse(stream: *std.net.Stream) ![]u8 {
    var buffer: [128]u8 = undefined;
    var bytes_read = try stream.read(&buffer);

    std.debug.print("Read {d} bytes\n", .{bytes_read});

    return buffer[0..bytes_read];
}
