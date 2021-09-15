# zig-snippets

## Mandatory hello world
* [hello_world.zig](hello_world.zig)

## Reading, writing files and/or console:
* [stdin_read.zig](stdin_read.zig)
* [stdin_while.zig](stdin_while.zig)
* [file_read.zig](file_read.zig)
* [file_write.zig](file_write.zig)

## Allocators
* [allocators_arena_with_fixed_buffer.zig](allocators_arena_with_fixed_buffer.zig)
* [allocators_arena.zig](allocators_arena.zig)
* [allocators_fixed_buffer.zig](allocators_fixed_buffer.zig)
* [allocators_general_purpose.zig](allocators_general_purpose.zig)
* [allocators_page.zig](allocators_page.zig)

## Generics
* [generic_structs.zig](generic_structs.zig)
* [generic_sum.zig](generic_sum.zig)

## JSON
* [json_parse.zig](json_parse.zig)
* [json_stringify.zig](json_stringify.zig)

## Network
* [tcp_client.zig](tcp_client.zig) TCP client that sends a single message.
* [tcp_server.zig](tcp_server.zig) TCP Server that listens for incoming connections.
* [redis_client.zig](redis_client.zig) Toy Redis client using [Redis protocol](https://redis.io/topics/protocol)
* [tcp_ping_pong.zig](tcp_ping_pong.zig) TCP server that sends a message and listens for an incoming response.

## Async
* [async.zig](async.zig) A clone of [tcp_ping_pong.zig](tcp_ping_pong.zig) with async/await

## Pointers
* [pointer_arithmetic.zig](pointer_arithmetic.zig)

## Parsing
* [parsing.zig](parsing.zig) Examples of parsing number in text `"1234"` into int `1234` and bytes arrays into known numbers.

## Misc
* [example.txt](example.txt) To use in the [file_read.zig](file_read.zig) snippet
* [slow_server.go](slow_server.go) A TCP ping-pong server in Go that takes 2 seconds to respond (to play in [async.zig](async.zig) and test the [Network](#network) snippets)