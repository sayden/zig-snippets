const std = @import("std");

pub fn main() !void {
    var page = std.heap.page_allocator;
    const mem = try page.alloc(u8, 5);
    defer page.free(mem);

    const mem1 = try page.alloc(u8, 5);
    defer page.free(mem1);

    // If I build this program with `zig build-exe -O ReleaseSmall` and execute the binary with `strace` this is what I get:
    // $ zig build-exe -O ReleaseSmall allocators_syscall.zig && strace ./allocators_syscall.zig
    //
    //  (strace output)
    //
    //
    //      mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fcb42632000
    //      ^^^^
    //      the first call to page.alloc on line 5
    //
    //      mmap(0x7fcb42633000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fcb42633000
    //      ^^^^
    //      the second call to page.alloc on line 8
    //
    //      And two `free` deferred calls
    //      munmap(0x7fcb42633000, 4096)            = 0
    //      munmap(0x7fcb42632000, 4096)            = 0
    //      ^^^^^^
    //      deferred calls to free memory
    //
    //  exit_group(0)                           = ?
    //  +++ exited with 0 +++

    // So, every time I execute a `page.alloc` a `mmap` syscall if done, which is "slow". So I thought
    // "does it also happen with a fixed buffer allocator? I guess not but I can check it with strace too"

    // std.mem.page_size is a constant that will return the page size for the current operating system, which
    // is a value that DIFFERS and QUITE A LOT between OS. In my case on a linux it's returning a 4096 bytes
    // but on a macosx it's a 16384, 4 times more. This is, as far as I know, the size of a page in the
    // operating system (which in linux is hardcoded in the kernel but you can change it).
    // https://unix.stackexchange.com/questions/128213/how-is-page-size-determined-in-virtual-address-space

    // I also realized, when checked the first 2 `mmap` calls requesting only 5 bytes each (above), that a
    // full 4096 page is requested and 4091 of those bytes are "nullified". You can see the explanation of
    // this in the `alloc` function. But, the address of the first and the second call are 4096 bytes apart.
    // So, does that mean that those 4091 bytes are "lost"? It's some kind of empty space that will be reused
    // somehow at some moment under the hood?

    // Ok great, let's continue.

    // So, I'll do another alloc call but without "wasted" bytes, using the OS page size. One single syscall,
    // and I'll get a single page too.
    var buffer = try page.alloc(u8, std.mem.page_size);
    defer page.free(buffer);

    var fba = std.heap.FixedBufferAllocator.init(buffer);
    var fba_allocator = &fba.allocator;

    var mem2 = try fba_allocator.alloc(u8, 5);
    defer fba_allocator.free(mem2);

    var mem3 = try fba_allocator.alloc(u8, 5);
    defer fba_allocator.free(mem3);

    var mem4 = try fba_allocator.alloc(u8, 5);
    defer fba_allocator.free(mem4);

    //  (strace output)
    //
    //  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f790fc1b000
    //  mmap(0x7f790fc1c000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f790fc1c000
    //  ^^^^
    //  Original 2 calls
    //
    //  mmap(0x7f790fc1d000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f790fc1d000
    //  ^^^^
    //  New call to get a buffer, line 51. After this I "alloc" 3 times using the Fixed Buffer Allocator,
    //  and I don't get more syscalls to get memory.
    //
    //  munmap(0x7f790fc1d000, 4096)            = 0
    //  munmap(0x7f790fc1c000, 4096)            = 0
    //  munmap(0x7f790fc1b000, 4096)            = 0
    //  ^^^^^^
    //  Finally I free everything, the original two calls and the last page.
    //
    //  exit_group(0)                           = ?
    //  +++ exited with 0 +++

    // Last think I checked, what if I request memory bigger than a page size? So a single syscall is made, but
    // I guess that many pages are returned, but definitely there's a single syscall.

    // Wait a sec, I'm gonna check the arena allocator:

    var arena_alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_alloc.deinit();

    var allocator = &arena_alloc.allocator;

    const mem5 = try allocator.alloc(u8, 5);
    _ = mem5;

    const mem6 = try allocator.alloc(u8, 4096);
    _ = mem6;

    // Arena allocator behaves similarly to the fixed allocator but, interestingly if you request "too much memory"
    // a new syscall is done under the hood, in this example of 4 pages or 16384 bytes:
    //
    //  ➜  zig-snippets git:(main) ✗ zig build-exe -O ReleaseSmall allocators_syscall.zig && strace ./allocators_syscall
    //
    //  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f1d276ea000
    //  mmap(0x7f1d276eb000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f1d276eb000
    //  mmap(0x7f1d276ec000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f1d276ec000
    //
    //  mmap(0x7f1d276ed000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f1d276ed000
    //  ^^^^
    //  Initial call from are allocator, a single page
    //  mmap(0x7f1d276ee000, 16384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f1d276ee000
    //  ^^^^
    //  This is the extra call made when I requested 4096 bytes which is higher than the initial page size
    //
    //  munmap(0x7f1d276ee000, 16384)           = 0
    //  munmap(0x7f1d276ed000, 4096)            = 0
    //  munmap(0x7f1d276ec000, 4096)            = 0
    //  munmap(0x7f1d276eb000, 4096)            = 0
    //  munmap(0x7f1d276ea000, 4096)            = 0
    //
    //  exit_group(0)                           = ?
    //  +++ exited with 0 +++
}
