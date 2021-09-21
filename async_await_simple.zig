const std = @import("std");
const debug = std.debug.print;
const rand = std.rand;
const fbaAlloc = std.heap.FixedBufferAllocator;

pub const io_mode = .evented;

pub fn main() !void {
    var i: usize = 0;

    var pa = std.heap.page_allocator;
    var buf = try pa.alloc(@Frame(print), 100);
    defer pa.free(buf);

    debug("{d} bytes allocated\n", .{@sizeOf(@Frame(print)) * 100});

    const pcg = rand.Pcg.init(4);
    var random_number = rand.Random{
        .fillFn = pcg.random.fillFn,
    };

    while (i < 100) : (i += 1) {
        var n = random_number.uintLessThan(usize, 1_000_000_000);
        buf[i] = async print(i, n);
    }

    i = 0;
    while (i < 100) : (i += 1) {
        await buf[i];
    }

    debug("Finish!\n", .{});
}

fn print(i: usize, n: usize) void {
    std.time.sleep(n + 10);
    debug("{d}\n", .{i});
}
