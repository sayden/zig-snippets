const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const lib = b.addStaticLibrary("c-double_me", "c-double_me.zig");

    const exe = b.addExecutable("test", null);
    exe.addCSourceFile("c-double_me.c", &[_][]const u8{"-std=c99"});
    exe.linkLibrary(lib);
    exe.linkLibC();

    b.default_step.dependOn(&exe.step);

    const run_cmd = exe.run();

    const test_step = b.step("test", "Test the program");
    test_step.dependOn(&run_cmd.step);
}