const std = @import("std");
const net = std.net;

pub fn main() !void {
    const address = try net.Address.resolveIp("0.0.0.0", 8080);
    var stream = try net.tcpConnectToAddress(address);
    defer stream.close();

    // There's probably a much better/safe/common way to do this.
    var buffer: [128]u8 = undefined;
    while(true) {
        var bytes_read = try stream.read(&buffer);

        if (bytes_read>0){
            std.debug.print("Read {d} bytes. {s}\n", .{bytes_read, buffer[0..bytes_read]});
            bytes_read=0;
        }
    }
}