# zig-snippets

## Mandatory hello world
* [Hello world](hello_world.zig)

## Arrays and Slices
* [Tokenizer:](parsing_tokenizer.zig) An exercise that started about something simple but it ended up teaching me a lot about array and pointer sizes and optionals.
* [String Literals:](string_literals.zig) I wanted to understand better how string literals work and some interesting things about slices and arrays.
* [String concatenation:](strings_concatenation.zig) Some example to do string concatenation. It's probably better to use a library like https://github.com/JakubSzark/zig-string but it's good snippet to have around when I just want to do something simple

## Reading, writing files and/or console:
* [Read from StdIn:](stdin_read.zig)
* [Read from StdIn in loop:](stdin_while.zig)
* [Read a file:](file_read.zig)
* [Write into a file:](file_write.zig)

## Allocators
* [General purpose](allocators_general_purpose.zig)
* [Page allocator:](allocators_page.zig) According to some video, this and the one above are probaly the easiest but the slower to use.
* [Fixed Buffer:](allocators_fixed_buffer.zig) ~~Don't know why yet but I cannot make a "big" allocation with this one.~~ I could not make a big allocation with 
the fixed buffer because I was passing a buffer array created on the stack, not on the heap. See [this](https://zigforum.org/t/best-allocator-for-fixed-size-heap-allocation/789/3?u=sayden) conversation.
* [Arena](allocators_arena.zig)
* [Arena with fixed buffer](allocators_arena_with_fixed_buffer.zig)
* [Allocators and Syscalls](allocators_syscall.zig) An example of the syscalls made to the underlying OS Linux to request memory with the output of `strace`

## Generics
* [Generic Struct](generic_structs.zig)
* [Generic Sum function](generic_sum.zig)
* [Traits (sort of):](traits.zig) An exercise examining the use of io.Writer and the kind of structural typing to can do to have "traits".

## JSON
* [Parse JSON](json_parse.zig)
* [Stringify JSON](json_stringify.zig)

## Network
* [TCP client](tcp_client.zig) TCP client that sends a single message.
* [TCP server](tcp_server.zig) TCP Server that listens for incoming connections.
* [Redis client](redis_client.zig) Toy Redis client using [Redis protocol](https://redis.io/topics/protocol)
* [TCP Ping Pong](tcp_ping_pong.zig) TCP server that sends a message and listens for an incoming response.

## Async
* [Simple Async/Await](async_await_simple.zig) A simple async/await example with sleeps without external pieces like the example below.
* [Async/Await](async_await.zig) A clone of [TCP Ping Pong](tcp_ping_pong.zig) with async/await.

## Pointers
* [Pointer arithmetic](pointer_arithmetic.zig)
* [Dangling pointer](dangling_pointer.zig)
* [Linked List with self managed memory](linked_list.zig)

## Parsing
* [Parsing strings or bytes buffers](parsing.zig) Examples of parsing number in text `"1234"` into int `1234` and bytes arrays into known numbers.
* [Tokenizer](parsing_tokenizer.zig) Small tokenizing exercise that ended up as a nice memory allocation exercise.

## Data structures
* [Hash Table](hash_table.zig)
* [Iterator](iterator.zig)
* [Linked List with self managed memory](linked_list.zig)

## C interoperability
Files that start with `c-*.*`

### Very basic example
```sh
# messages like "Double of 4 is in C 8" should appear in stdout
make libfunction
```
* [c-main.c](c-main.c) A simple main function in C just to see how it is done in plain C
* [c-libfunction.c](c-libfunction.c) A very basic C library to load as a shared object `*.so`
* [c-libfunction](c-libfunction.zig) The zig code that calls the `*.so` shared object that I created in [c-libfunction.c](c-libfunction.c)

### cURL example
```sh
# a request is made and the plain HTML printed into stdout
make curl
```
* [c-curl.c](c-curl.c)
* [c-libcurl](c-libcurl.zig)

### Raylib example
```sh
# NOTE: I need to download raylib to make this work. I placed it in ${HOME}/software/raylib
# a window with a hello world message should open
make ray
```
* [c-ray](c-ray.zig) Interop with the [Raylib](https://www.raylib.com) library (https://github.com/raysan5/raylib)

### Calling Zig from C
At the moment of writing this README, the documentation is outdated and the header file is not generated as stated [in the docs](https://ziglang.org/documentation/master/#Exporting-a-C-Library). The workaround is to write the headers manually. Look at files `c-double_me*` for examples:
```sh
## Passing 8 in the c-double_me.c file
make c-double_me
16
```

## Misc
* [example.txt](example.txt) To use in the [file_read](file_read.zig) snippet
* [slow_server.go](slow_server.go) A TCP ping-pong server in Go that takes 2 seconds to respond (to play in [async](async.zig) and test the [Network](#network) snippets)