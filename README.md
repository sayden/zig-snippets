# zig-snippets

## Mandatory hello world
* [hello_world.zig](hello_world.zig)

## Arrays and Slices
* [parsing_tokenizer.zig](parsing_tokenizer.zig) An exercise that started about something simple but it ended up teaching me a lot about array and pointer sizes and optionals.

## Reading, writing files and/or console:
* [stdin_read.zig](stdin_read.zig)
* [stdin_while.zig](stdin_while.zig)
* [file_read.zig](file_read.zig)
* [file_write.zig](file_write.zig)

## Allocators
* [allocators_general_purpose.zig](allocators_general_purpose.zig)
* [allocators_page.zig](allocators_page.zig) According to some video, this and the one above are probaly the easiest but the slower to use.
* [allocators_fixed_buffer.zig](allocators_fixed_buffer.zig) Don't know why yet but I cannot make a "big" allocation with this one. I think I saw a video that explained this limitation.
* [allocators_arena.zig](allocators_arena.zig)
* [allocators_arena_with_fixed_buffer.zig](allocators_arena_with_fixed_buffer.zig)

## Generics
* [generic_structs.zig](generic_structs.zig)
* [generic_sum.zig](generic_sum.zig)
* [traits.zig](traits.zig) An exercise examining the use of io.Writer and the kind of structural typing to can do to have "traits".

## JSON
* [json_parse.zig](json_parse.zig)
* [json_stringify.zig](json_stringify.zig)

## Network
* [tcp_client.zig](tcp_client.zig) TCP client that sends a single message.
* [tcp_server.zig](tcp_server.zig) TCP Server that listens for incoming connections.
* [redis_client.zig](redis_client.zig) Toy Redis client using [Redis protocol](https://redis.io/topics/protocol)
* [tcp_ping_pong.zig](tcp_ping_pong.zig) TCP server that sends a message and listens for an incoming response.

## Async
* [async_await_simple.zig](async_await_simple.zig) A simple async/await example with sleeps without external pieces like the example below.
* [async_await.zig](async_await.zig) A clone of [tcp_ping_pong.zig](tcp_ping_pong.zig) with async/await.

## Pointers
* [pointer_arithmetic.zig](pointer_arithmetic.zig)
* [dangling_pointer.zig](dangling_pointer.zig)
* [linked_list.zig](linked_list.zig)

## Parsing
* [parsing.zig](parsing.zig) Examples of parsing number in text `"1234"` into int `1234` and bytes arrays into known numbers.
* [parsing_tokenizer.zig](parsing_tokenizer.zig) Small tokenizing exercise that ended up as a nice memory allocation exercise.

## Data structures
* [hash_table.zig](hash_table.zig)
* [iterator.zig](iterator.zig)

## C interoperability
Files that start with `c-*.*`

### Very basic example
```sh
# messages like "Double of 4 is in C 8" should appear in stdout
make libfunction
```
* [c-main.c](c-main.c) A simple main function in C just to see how it is done in plain C
* [c-libfunction.c](c-libfunction.c) A very basic C library to load as a shared object `*.so`
* [c-libfunction.zig](c-libfunction.zig) The zig code that calls the `*.so` shared object that I created in [c-libfunction.c](c-libfunction.c)

### cURL example
```sh
# a request is made and the plain HTML printed into stdout
make curl
```
* [c-curl.c](c-curl.c)
* [c-libcurl.zig](c-libcurl.zig)

### Raylib example
```sh
# NOTE: I need to download raylib to make this work. I placed it in ${HOME}/software/raylib
# a window with a hello world message should open
make ray
```
* [c-ray.zig](c-ray.zig) Interop with the [Raylib](https://www.raylib.com) library (https://github.com/raysan5/raylib)

## Misc
* [example.txt](example.txt) To use in the [file_read.zig](file_read.zig) snippet
* [slow_server.go](slow_server.go) A TCP ping-pong server in Go that takes 2 seconds to respond (to play in [async.zig](async.zig) and test the [Network](#network) snippets)