const std = @import("std");
const net = std.net;

pub const io_mode = .evented;

pub fn main() !void {
    const address = try net.Address.resolveIp("0.0.0.0", 8080);
    var stream = try net.tcpConnectToAddress(address);
    defer stream.close();

    // Message 1
    const msg = "hello from zig!";
    _ = try stream.write(msg[0..]);

    var frame = async getResponse(&stream);

    std.debug.print("Waiting...", .{});

    // Response 1
    var res = try await frame;

    std.debug.print("{s}\n", .{res});

    // Message 2
    _ = try stream.write(msg[0..]);
    var frame2 = async getResponse(&stream);
}

fn getResponse(stream: *std.net.Stream) ![]u8 {
    var buffer: [128]u8 = undefined;
    var bytes_read = try stream.read(&buffer);

    std.debug.print("({d} bytes received)\n", .{bytes_read});

    return buffer[0..bytes_read];
}

fn getResponseSuspend(stream: *std.net.Stream) ![]u8 {
    var buffer: [128]u8 = undefined;
    var bytes_read = try suspend stream.read(&buffer);

    std.debug.print("({d} bytes received)\n", .{bytes_read});

    return buffer[0..bytes_read];
}

