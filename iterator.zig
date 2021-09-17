const std = @import("std");
const expect = std.testing.expect;

fn Numbers() type {
    return struct {
        numbers: []u8,

        const Self = @This();

        fn init(ns: []u8) Self {
            return Self{
                .numbers = ns,
            };
        }

        fn iterator(self: *Self) Iterator {
            return Iterator{
                .numbers = &self.numbers,
            };
        }
    };
}

const Iterator = struct {
    numbers: *[]u8,
    pos: usize = 0,

    const Self = @This();

    pub fn next(self: *Self) ?u8 {
        const index = self.pos;

        return if (index < self.numbers.len) {
            const temp = self.numbers.*[index];
            self.pos += 1;
            return temp;
        } else null;
    }
};

pub fn main() !void {
    var ar = [_]u8{ 1, 2, 3, 4 };
    var outer = Numbers().init(ar[0..]);

    var iterator = outer.iterator();
    while (iterator.next()) |item| {
        std.debug.print("{d}\n", .{item});
    }
}
