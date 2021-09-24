/// Zig doesn't have out of the box "traits". But it turns out that
/// I have seen lots of uses for "writer" and "reader" so, how they
/// work?
const std = @import("std");
const fs = std.fs;
const io = std.io;

pub fn main() !void {
    // Files has readers and writers, so I'll use a file to investigate
    var file = try fs.createFileAbsolute("/tmp/test", fs.File.CreateFlags{});
    defer file.close();

    // writer() returns a io.Writer struct which uses a similar layout
    // than the "generic" examples, something like:
    //      io.Writer(C, WE, fn (C, []const u8) WE!usize)
    // And the key thing is the third parameter, which "implements" the
    // function to write the data on the concrete type
    var writer = file.writer();

    // Then I can just use the "write" method of io.Writer
    var bytes = try writer.write("hello 1\n");
    try std.testing.expect(bytes == 8);

    // The point here is to provide "io.Writer"s to callers as a way
    // to transparently deal with writes into my "system"
    // (for example "my memory toy db", or "a file I own").
    // It's some kind of structural typing that the compiler will
    // check once it's used.

    var stdout = std.io.getStdOut();
    defer stdout.close();
    var newline_writer = NewlineWriter.init(stdout.writer());

    const mywriter = newline_writer.writer();
    _ = try mywriter.write("hello 2");

    // But how much can you abuse of this? Returning an anonymous struct
    // that mimics the structure of a known one.
    var my_struct = StructWithMsg{ .msg = "mario" };
    sayHelloSomehow(my_struct);
    sayHelloSomehow(.{.msg = "'this looks like a hack'"});

    // It looks like you can actually abuse a lot. But type coercion is
    // happening under the hood. So the anonymous struct is type casted
    // into a StructWithMsg. I checked this when I tried the following:
    //      sayHelloSomehow(.{.msg = "'this looks like a hack'", a:"should not be here"});
    // and it failed with
    //      error: no member named 'a' in struct 'StructWithMsg'
}

const StructWithMsg = struct {
    msg: []const u8,
};

fn sayHelloSomehow(s: StructWithMsg) void {
    std.debug.print("hello {s}\n", .{s.msg});
}

// Get a writer that appends a new line to every message writes it to
// the provided writer too. So it's like
//
//      hey io.Writer, this is the method (fn writeWithNewline) you must 
//      execute. The first argument of the method is a type NewLineWriter 
//      but don't worry, I'll store in your .context field for you. And in
//      case of error, MyErrors is the type you'll receive.
//
// So, because NewlineWriter.writeWithNewline method requires a NewLineWriter
// as first argument, I store it in the context field of the io.Writer. Many
// languages don't allow this, to use an instance method you must call it with
// dot notation or similar (whatever is called, frankly I don't remember now)
const NewlineWriter = struct {
    const MyErrors = error{
        BadError,
        VeryBadError,
        UnexpectedError,
    };

    // io.Writer returns a type. A TYPE! not function, not a struct
    const Writer = io.Writer(*NewlineWriter, NewlineWriter.MyErrors, NewlineWriter.writeWithNewline);

    out: fs.File.Writer,

    pub fn init(o: fs.File.Writer) NewlineWriter {
        return NewlineWriter{
            .out = o,
        };
    }

    // This is the method that will be executed by io.Writer" every time I write
    pub fn writeWithNewline(self: *NewlineWriter, bytes: []const u8) NewlineWriter.MyErrors!usize {
        var written = self.out.write(bytes) catch return MyErrors.UnexpectedError;
        _ = self.out.write("\n") catch return MyErrors.UnexpectedError;
        return written + 1;
    }

    pub fn writer(self: *NewlineWriter) Writer {
        // THIS IS WERE MAGIC HAPPENS. This anonymous struct has the same
        // "structure" than the type returned by io.Writer(). Which is not
        // exactly true because it only represents the field `.context`
        // and no methods
        return .{ .context = self };
    }
};
