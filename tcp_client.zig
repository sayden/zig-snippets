const std = @import("std");
const net = std.net;

pub fn main() !void {
    const address = try net.Address.resolveIp("0.0.0.0", 8080);
    var stream = try net.tcpConnectToAddress(address);
    defer stream.close();

    const msg = "hello from zig!";
    _ = try stream.write(msg[0..]);
}