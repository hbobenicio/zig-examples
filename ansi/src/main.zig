const std = @import("std");
const mem = std.mem;
const heap = std.heap;

const ansi = @import("./ansi.zig");

const Allocator = mem.Allocator;
const FixedBufferAllocator = std.heap.FixedBufferAllocator;

pub fn main() !void {
    const stdout = std.io.getStdOut();

    // var buffer: [1000]u8 = undefined;
    // var fba = FixedBufferAllocator.init(&buffer);
    // const allocator: *Allocator = &std.heap.loggingAllocator(&fba.allocator, stdout.outStream()).allocator;

    if (!stdout.isTty()) {
        std.log.err("your console is not a tty", .{});
        return error.DeviceIsNotTTY;
    }

    if (!stdout.supportsAnsiEscapeCodes()) {
        std.log.err("your console doesn't support ansi escape codes", .{});
        return error.DeviceDoesNotSupportAnsiEscapeCodes;
    }

    // TODO add some API to set options for color mode: NoColor | 8bit | 256bit

    // first API (imperative style)
    try ansi.setForegroundColor(ansi.Color.Red);
    std.log.info("Hello, World!", .{});
    try ansi.resetGraphics();

    // second API (formatting style)
    std.log.info("{}Hello, World!{}", .{
        ansi.escapeSequenceGraphics(ansi.codes.color.fg.Magenta),
        ansi.escapeSequenceGraphicsReset(),
    });

    var tmpBuf: [100]u8 = undefined;

    // try ansi.setBackgroundColor(ansi.Color.White);
    // const hello_blue: []const u8 = try ansi.blue(&tmpBuf, "Hello, World!\n");
    // _ = try stdout.write(hello_blue);
    // try ansi.resetGraphics();
    // // std.log.info("Hello, World!", .{});
    // _ = try stdout.write("Hello, World!\n\n\n");

    // try ansi.cursor.move(tmpBuf[0..], 0, 0);
    // try ansi.cursor.up(tmpBuf[0..], 1);

    std.log.info("Resetting works", .{});
}
