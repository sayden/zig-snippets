const std = @import("std");

pub fn main() !void {
    const dir = try std.fs.openDirAbsolute("/tmp", std.fs.Dir.OpenDirOptions{});
    const file = try dir.createFile("hello.txt", std.fs.File.CreateFlags{});
    defer file.close();

    try file.writeAll("Hello world\n");
}