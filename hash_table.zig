const std = @import("std");
const Allocator = std.mem.Allocator;
const expect = std.testing.expect;

fn DataItem(comptime T: type) type {
    return struct {
        data: T,
        key: u64,
    };
}

fn HashArray(comptime T: type) type {
    return struct {
        const Self = @This();

        const HashError = error{
            NotFound,
        };

        ar: []?DataItem(T),
        SIZE: u64,

        fn hashCode(self: *Self, key: u64) u64 {
            return key % self.SIZE;
        }

        pub fn init(size: u64, alloc: *Allocator) !Self {
            return Self{
                .ar = try alloc.alloc(?DataItem(T), size),
                .SIZE = size,
            };
        }

        pub fn insert(self: *Self, key: u64, data: T) void {
            const item = DataItem(T){
                .data = data,
                .key = key,
            };

            //get the hash
            var hash_index = self.hashCode(key);

            while (self.itemAt(hash_index)) |_| : (hash_index += 1) {
                hash_index %= self.SIZE; //wrap around the table
            }

            self.ar[hash_index] = item;
        }

        pub fn delete(self: *Self, key: u64) !DataItem(T) {
            var hash_index = self.hashCode(key); //get the hash

            //move in array until an empty
            return while (self.itemAt(hash_index)) |cur_item| : ({
                hash_index += 1;
                hash_index %= self.SIZE;
            }) {
                if (cur_item.key == key) {
                    self.setItemAt(hash_index, null);
                    return cur_item;
                }
            } else HashError.NotFound;
        }

        fn search(self: *Self, key: u64) ?DataItem(T) {
            var hash_index = self.hashCode(key); //get the hash

            //move in array until empty
            return while (self.itemAt(hash_index)) |cur_item| : ({
                hash_index += 1;
                hash_index %= self.SIZE;
            }) {
                if (cur_item.key == key) return cur_item;
            } else null;
        }

        fn setItemAt(self: *Self, index: u64, item: ?DataItem(T)) void {
            self.ar[index] = item;
        }

        fn itemAt(self: *Self, index: u64) ?DataItem(T) {
            return self.ar[index];
        }

        fn display(self: *Self) void {
            for (self.ar) |maybe_item| {
                if (maybe_item) |item|
                    std.debug.print(" ({d},{any})", .{ item.key, item.data })
                else
                    std.debug.print(" ~~ ", .{});
            }

            std.debug.print("\n", .{});
        }
    };
}

// using a wrapper to allow printing pretty names. By default the formatter {any}
// in display() on HashArray will print the array of bytes instead of the text.
const MyFormattedString = struct {
    innerString: []const u8,

    pub fn new(text: []const u8) MyFormattedString {
        return MyFormattedString{
            .innerString = text,
        };
    }

    pub fn format(
        self: MyFormattedString,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        //We won't use this
        _ = fmt;
        _ = options;

        try writer.print("{s}", .{self.innerString});
    }
};

pub fn main() !void {
    // Using arena allocator over the page allocator to free only once (as an exercise)
    var arena_alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_alloc.deinit();
    var allocator = &arena_alloc.allocator;

    try withU64(allocator);
    try withStrings(allocator);
}

fn withStrings(alloc: *Allocator) !void {
    std.debug.print("\n",.{});

    var hash_array = try HashArray(MyFormattedString).init(20, alloc);

    hash_array.insert(1, MyFormattedString.new("hello"));
    hash_array.insert(2, MyFormattedString.new("world"));
    hash_array.insert(42, MyFormattedString.new("mario"));
    hash_array.insert(4, MyFormattedString.new("tyrion"));
    hash_array.insert(12, MyFormattedString.new("tesla"));
    hash_array.insert(14, MyFormattedString.new("ula"));

    hash_array.display();

    var deleted_item = try hash_array.delete(2);
    std.debug.print("Item with key '{d}' deleted\n", .{deleted_item.key});

    hash_array.display();

    _ = hash_array.delete(111) catch |err| std.debug.print("could not delete record '111': {s}\n", .{err});

    var item = hash_array.search(12) orelse unreachable;
    std.debug.print("Item found: key={1d} value={0d}\n", item);

    _ = hash_array.search(111) orelse std.debug.print("Value '{d}' not found\n", .{111});
}

fn withU64(alloc: *Allocator) !void {
    var hash_array = try HashArray(u64).init(30, alloc);

    hash_array.insert(1, 20);
    hash_array.insert(2, 70);
    hash_array.insert(42, 80);
    hash_array.insert(4, 25);
    hash_array.insert(12, 44);
    hash_array.insert(14, 32);
    hash_array.insert(17, 11);
    hash_array.insert(13, 78);
    hash_array.insert(37, 97);

    hash_array.display();

    var deleted_item = try hash_array.delete(17);
    std.debug.print("Item with key '{d}' deleted\n", .{deleted_item.key});

    hash_array.display();

    _ = hash_array.delete(111) catch |err| std.debug.print("could not delete record '111': {s}\n", .{err});

    var item = hash_array.search(13) orelse unreachable;
    std.debug.print("Item found: key={1d} value={0d}\n", item);

    _ = hash_array.search(111) orelse std.debug.print("Value '{d}' not found\n", .{111});
}
