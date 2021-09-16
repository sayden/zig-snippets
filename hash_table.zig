const std = @import("std");

const size: u8 = 20;

const DataItem = struct {
    data: u64,
    key: u64,
};

const dummy = DataItem{ .data = -1, .key = -1 };

fn hashCode(key: u64) u64 {
    return key % size;
}

fn search(key: u64, hash_array: []?DataItem) ?DataItem {
    //get the hash
    const hash_index = hashCode(key);

    //move in array until empty
    while (hash_array[hash_index] != null) : (hash_index += 1) {
        if (hash_array[hash_index].key == key) {
            return hash_array[hash_index];
        }

        //wrap around the table
        hash_index %= size;
    }

    return null;
}

fn insert(key: u64, data: u64, hash_array: []?DataItem) void {
    var item = DataItem{
        .data = data,
        .key = key,
    };

    //get the hash
    var hash_index = hashCode(key);

    while (hash_array[hash_index] != null and hash_array[hash_index].?.key != -1) : (hash_index += 1) {
        //wrap around the table
        hash_index %= size;
    }

    hash_array[hash_index] = item;
}

fn delete(item: DataItem, hash_array: []?DataItem) ?DataItem {
    const key = item.key;

    //get the hash
    var hash_index = hashCode(key);

    //move in array until an empty
    while (hash_array[hash_index] != null) : (hash_index += 1) {
        if (hash_array[hash_index.key == key]) {
            const temp = hash_array[hash_index];
            //assign dummy
            hash_array[hash_index] = dummy;
            return temp;
        }

        hash_index %= size;
    }

    return null;
}

fn display(hash_array: []?DataItem) void {
    for (hash_array) |item| {
        if (item != null) {
            std.debug.print(" ({d},{d})", .{ item.?.key, item.?.data });
        } else {
            std.debug.print(" ~~ ", .{});
        }
    }
}

pub fn main() !void {
    var pa = std.heap.page_allocator;

    var hash_array = try pa.alloc(?DataItem, size);
    defer pa.free(hash_array);

    insert(1, 20, hash_array);
    insert(2, 70, hash_array);
    insert(42, 80, hash_array);
    insert(4, 25, hash_array);
    insert(12, 44, hash_array);
    insert(14, 32, hash_array);
    insert(17, 11, hash_array);
    insert(13, 78, hash_array);
    insert(37, 97, hash_array);

    display(hash_array);
}
