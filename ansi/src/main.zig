const std = @import("std");
const mem = std.mem;
const heap = std.heap;

const ansi = @import("./ansi.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut();
    const w = stdout.writer();

    if (!stdout.isTty()) {
        std.log.err("error: your console is not a tty", .{});
        return error.DeviceIsNotTTY;
    }

    if (!stdout.supportsAnsiEscapeCodes()) {
        std.log.err("error: your console doesn't support ansi escape codes", .{});
        return error.DeviceDoesNotSupportAnsiEscapeCodes;
    }

    // TODO add some API to set options for color mode: NoColor | 8bit | 256bit

    // first API (imperative style / multiple writes)
    try ansi.setForegroundColor(ansi.Color.Red);
    _ = try stdout.write("red");
    try ansi.resetGraphics();

    // TODO if this buffer is shared between an expression (for example: one w.print with multuple formats),
    // then this will break.
    var tmpBuf: [100]u8 = undefined;

    try w.print(" {}", .{ try ansi.green(&tmpBuf, "green") });
    try w.print(" {}", .{ try ansi.yellow(&tmpBuf, "yellow") });
    try w.print(" {}", .{ try ansi.blue(&tmpBuf, "blue") });
    try w.print(" {}", .{ try ansi.magenta(&tmpBuf, "magenta") });
    try w.print(" {}", .{ try ansi.cyan(&tmpBuf, "cyan") });
    try w.print(" {}", .{ try ansi.white(&tmpBuf, "white") });
    // TODO grey
    try w.print(" {}", .{ try ansi.black(&tmpBuf, "black") });

    _ = try w.write("\n");

    try ansi.setBackgroundColor(ansi.Color.Red);
    _ = try stdout.write("red");
    try ansi.resetGraphics();

    try w.print(" {}", .{ try ansi.bgGreen(&tmpBuf, "bgGreen") });
    try w.print(" {}", .{ try ansi.bgYellow(&tmpBuf, "bgYellow") });
    try w.print(" {}", .{ try ansi.bgBlue(&tmpBuf, "bgBlue") });
    try w.print(" {}", .{ try ansi.bgMagenta(&tmpBuf, "bgMagenta") });
    try w.print(" {}", .{ try ansi.bgCyan(&tmpBuf, "bgCyan") });
    try w.print(" {}", .{ try ansi.bgWhite(&tmpBuf, "bgWhite") });
    // TODO grey
    try w.print(" {}", .{ try ansi.bgBlack(&tmpBuf, "bgBlack") });

    // Full customization declarative API
    const ibmStyle = ansi.Style{
        .fgColor = ansi.Color.Yellow,
        .bgColor = ansi.Color.Blue,
        .attrs = ansi.StyleAttr{
            .bold = true,
        },
    };
    try w.print("\n{}", .{ try ansi.applyStyle(&tmpBuf, ibmStyle, "IBM Style") });

    // TODO full customization fluent/builder style

    // TODO finish cursor implementation
    // try ansi.cursor.move(tmpBuf[0..], 0, 0);
    // try ansi.cursor.up(tmpBuf[0..], 1);

    try ansi.resetGraphics();
    std.log.info("\nResetting works", .{});
}
