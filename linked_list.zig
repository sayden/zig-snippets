//! This snippet was painful for my lack of knowledge about memory allocation.
//! It ended up being a VERY NICE EXERCISE once everything *clicked* in my head.
//! The main pain point was the `Cell` allocation. I got many mistakes like
//! overriding the allocated pointer with a local pointer, for example.
//! The "turning point" was the `Cell(T).initAlloc` function and its structure.
//! 
//! At first I was using the Arena allocator, which is OK for a small example.
//!  Yes, it handles the free of all memory allocations at once but if I 
//! remove a single item, that memory won't be freed until the end of the 
//! program execution. So I rewrote the script using a FixedBufferAllocator
//! and manually checking how much memory I needed to provoke a OutOfMemory
//! error.

const std = @import("std");
const expect = std.testing.expect;
const Allocator = std.mem.Allocator;

fn Cell(comptime T: type) type {
    return struct {
        data: T,

        next: ?*Cell(T),

        const Self = @This();

        fn initAlloc(data: T, alloc: *Allocator) !*Self {
            var new_item = try alloc.create(Cell(T));
            new_item.data = data;
            new_item.next = null;
            return new_item;
        }
    };
}

fn LinkedList(comptime T: type) type {
    return struct {
        first: ?*Cell(T) = null,

        alloc: *Allocator,

        const Self = @This();

        const Error = error{
            EmptyList,
            NotFound,
        };

        var this: Self = undefined;

        pub fn init(alloc: *Allocator) Self {
            this = Self{
                .alloc = alloc,
            };

            return this;
        }

        pub fn add(self: *Self, data: T) !void {
            var new_item = try Cell(T).initAlloc(data, self.alloc);

            if (self.first) |first| {
                var p = first;

                while (p.next) |next| {
                    p = next;
                }

                p.next = new_item;
            } else {
                self.first = new_item;
            }

            return;
        }

        // this method can probably be simpler and it DOESN'T
        // DEALLOCATES THE MEMORY
        pub fn remove(self: *Self, data: T) !void {
            var iter = self.iterator();

            var maybe_previous: ?*Cell(T) = null;
            var candidate = self.first;
            var found = false;
            while (iter.next()) |item| {
                if (item.data == data) {
                    candidate = item;
                    found = true;
                    break;
                }
                maybe_previous = candidate;
                candidate = item;
            }

            if (found)  {
                defer self.alloc.destroy(candidate.?);

                if (maybe_previous) |prev| {
                    prev.next = candidate.?.next;
                    // TODO Deallocate candidate memory
                } else {
                    //Removing first item
                    self.first = candidate.?.next;
                    // TODO Deallocate candidate memory
                }
            } else {
                return Error.NotFound;
            }
        }

        pub fn iterator(self: *Self) Iterator(T) {
            return Iterator(T).init(self.first);
        }

        pub fn display(self: *Self) void {
            var iter = self.iterator();

            while (iter.next()) |item| {
                std.debug.print("'{d}'->", .{item.data});
            }

            std.debug.print("\n", .{});
        }
    };
}

fn Iterator(comptime T: type) type {
    return struct {
        const Self = @This();

        current: ?*Cell(T),

        fn init(first: ?*Cell(T)) Self {
            return Self{
                .current = first,
            };
        }

        fn next(self: *Self) ?*Cell(T) {
            if (self.current) |cur| {
                const temp = cur;
                self.current = if (temp.next) |next_item| next_item else null;
                return temp;
            }

            return null;
        }
    };
}

pub fn main() !void {
    // With some trial and error I discovered that for this toy example
    // with 4 items I needed exactly 102 bytes of ~~heap~~ stack allocation.
    // (`buffer` is created on the stack)
    var buffer:[102]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);

    var ll = LinkedList(u64).init(&fba.allocator);

    try ll.add(1);
    try ll.add(2);
    try ll.add(3);

    ll.display();

    ll.remove(2) catch unreachable;
    ll.display();

    try ll.add(4);
    ll.display();

    ll.remove(1) catch unreachable;
    ll.display();

    ll.remove(4) catch unreachable;
    ll.display();
    
    ll.remove(4) catch |err| try expect(err == LinkedList(u64).Error.NotFound);
    // GOTCHA, the `try` clause above is working over the `expect` call, not on `remove`
    // but I can also place it at the beginning with the same result
    try ll.remove(4) catch |err| expect(err == LinkedList(u64).Error.NotFound);

    // This will be a 5th item but we are deallocating nicely so it fits
    try ll.add(5);
    ll.display();

    // This is too much memory because I allocated only 102 bytes for 5 items.
    // Handle this ugly out of memory error nicely
    ll.add(6) catch |err| try expect(err == error.OutOfMemory);
}
