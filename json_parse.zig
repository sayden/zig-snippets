const std = @import("std");
const json = std.json;

const Place = struct { lat: f32, long: f32 };

pub fn main() !void {
    var stream = json.TokenStream.init(
        \\{ "lat": 40.684540, "long": -74.401422 }
    );

    const x = try json.parse(Place, &stream, .{});

    if (x.lat != 40.684540) {
        unreachable;
    }

    if (x.long != -74.401422) {
        unreachable;
    }
}