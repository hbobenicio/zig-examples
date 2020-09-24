const std = @import("std");
const fmt = std.fmt;
const io = std.io;

const codes = @import("./codes.zig");

// TODO Is it ok to use global stdout (thread-safety)?
// TODO consider passing an file as argument (various possible sinks: stdout, stderr, membufs, etc)
const stdout = io.getStdOut();

pub fn move(buf: []u8, row: u32, col: u32) !void {
    // TODO assert min buf len?
    std.debug.assert(row <= 9999);
    std.debug.assert(col <= 9999);

    const escapeSequence = try fmt.bufPrint(buf, "{}{};{}{}", .{
        codes.EscapePrefix,
        row, col,
        codes.cursor.PositionSuffix1, // TODO Suffix1 or 2? what is the difference?!
    });

    _ = try stdout.write(escapeSequence);
}

pub fn up(buf: []u8, offset: u32) !void {
    // TODO assert min buf len?
    std.debug.assert(offset <= 9999);

    const escapeSequence = try fmt.bufPrint(buf, "{}{}{}", .{
        codes.EscapePrefix,
        offset,
        codes.cursor.UpSuffix,
    });

    _ = try stdout.write(escapeSequence);
}

pub fn down(buf: []u8, offset: u32) !void {
    // TODO assert min buf len?
    std.debug.assert(offset <= 9999);

    const escapeSequence = try fmt.bufPrint(buf, "{}{}{}", .{
        codes.EscapePrefix,
        offset,
        codes.cursor.DownSuffix,
    });

    _ = try stdout.write(escapeSequence);
}

pub fn forward(buf: []u8, offset: u32) !void {
    // TODO assert min buf len?
    std.debug.assert(offset <= 9999);

    const escapeSequence = try fmt.bufPrint(buf, "{}{}{}", .{
        codes.EscapePrefix,
        offset,
        codes.cursor.ForwardSuffix,
    });

    _ = try stdout.write(escapeSequence);
}

pub fn backward(buf: []u8, offset: u32) !void {
    // TODO assert min buf len?
    std.debug.assert(offset <= 9999);

    const escapeSequence = try fmt.bufPrint(buf, "{}{}{}", .{
        codes.EscapePrefix,
        offset,
        codes.cursor.UpSuffix,
    });

    _ = try stdout.write(escapeSequence);
}

pub fn savePosition(buf: []u8) !void {
    // TODO assert min buf len?

    const escapeSequence = try fmt.bufPrint(buf, "{}{}", .{
        codes.EscapePrefix,
        codes.cursor.SavePositionSuffix,
    });

    _ = try stdout.write(escapeSequence);
}

pub fn restorePosition(buf: []u8) !void {
    // TODO assert min buf len?

    const escapeSequence = try fmt.bufPrint(buf, "{}{}", .{
        codes.EscapePrefix,
        codes.cursor.RestorePositionSuffix,
    });

    _ = try stdout.write(escapeSequence);
}

pub fn eraseDisplay(buf: []u8) !void {
    // TODO assert min buf len?

    const escapeSequence = try fmt.bufPrint(buf, "{}{}", .{
        codes.EscapePrefix,
        codes.cursor.EraseDisplaySuffix,
    });

    _ = try stdout.write(escapeSequence);
}

pub fn eraseLine(buf: []u8) !void {
    // TODO assert min buf len?

    const escapeSequence = try fmt.bufPrint(buf, "{}{}", .{
        codes.EscapePrefix,
        codes.cursor.EraseLineSuffix,
    });

    _ = try stdout.write(escapeSequence);
}
