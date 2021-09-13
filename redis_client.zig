const std = @import("std");
const net = std.net;

pub fn main() !void {
    const address = try net.Address.resolveIp("172.17.0.2", 6379);
    var stream = try net.tcpConnectToAddress(address);
    defer stream.close();

    // reusable response buffer
    var buffer: [128]u8 = undefined;

    // Commands to send to redis
    const commands = [_][]const u8{
        "ECHO \"Hello world!\"\r\n",
        "EXISTS hello\r\n",
        "SET hello world\r\n",
        "GET hello\r\n",
    };

    for(commands)|command|{
    std.debug.print("$ {s}", .{command});
        // Send command
        _ = try stream.write(command[0..]);

        // Read response
        _ = try stream.read(&buffer);
        try parseResponse(&buffer, buffer.len);
    }
}

fn parseResponse(buffer: [*]u8, len: usize) !void {
    // First byte of Redis is the response type
    const resp_type = buffer[0];

    switch (resp_type) {
        '$' => { //bulk string
            var res = try parseBulkString(buffer, len);
            std.debug.print("'{s}'\n", .{res});
        },
        '+' => { //simple string
            var res = try parseSimpleString(buffer);
            std.debug.print("'{s}'\n", .{res});
        },
        '-' => { //error
            var res = try parseSimpleString(buffer);
            std.debug.print("Error: '{s}'\n", .{res});
        },
        ':' => { //integer
            var res = try parseSimpleString(buffer);
            var n = try std.fmt.parseInt(u32, res, 10);
            std.debug.print("{d}\n", .{n});
        },
        '*' => { //array
            //TODO
        },
        else => {
            @panic("Redis response not recognized");
        },
    }
}

const RedisError = error{ClrNotFound};

// accepts a redis response and returns the message contained without the final \r\n
fn parseSimpleString(in: [*]u8) ![]u8 {
    var i: usize = 0;
    while (true) : (i += 1) {
        if (in[i] == '\n' and i != 0 and in[i - 1] == '\r') {
            return in[1 .. i - 1];
        }
    }

    return RedisError.ClrNotFound;
}

// accepts a redis bulk string response and returns the message inside without the final \r\n
fn parseBulkString(in: [*]u8, size: usize) ![]u8 {
    var index: usize = undefined;
    var total_bytes: usize = undefined;

    var i: usize = 0;
    while (i < size) : (i += 1) {
        if (in[i] == '\n' and i != 0 and in[i - 1] == '\r') {
            index = i + 1;
            total_bytes = try std.fmt.parseInt(usize, in[1 .. i - 1], 10);

            return in[index .. index + total_bytes];
        }
    }

    return RedisError.ClrNotFound;
}