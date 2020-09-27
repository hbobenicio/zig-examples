//! Ansi support for zig.
//!
//! ## References:
//! https://www.lihaoyi.com/post/BuildyourownCommandLinewithANSIescapecodes.html
//! http://ascii-table.com/ansi-escape-sequences.php

const std = @import("std");
const os = std.os;
const fmt = std.fmt;
const Writer = std.fs.File.Writer;

pub const codes = @import("./codes.zig");
pub const cursor = @import("./cursor.zig");

// TODO is it ok to have a global stdout?
// TODO should'nt it be buffered? Is it already?
const stdout = std.io.getStdOut();

/// Color enumerates all suported colors.
/// TODO add 256 true color support
pub const Color = enum {
    Black,
    Red,
    Green,
    Yellow,
    Blue,
    Magenta,
    Cyan,
    White,
};

pub const Style = struct {
    fgColor: ?Color = null,
    bgColor: ?Color = null,
    bold: bool = false,
    dim: bool = false,
    italic: bool = false,
    underline: bool = false,
    inverse: bool = false,
    hidden: bool = false,
    strikethrough: bool = false,
    // TODO builder API
};

// TODO fgStyle and bgStyle may become just one function with an enum parameter for Fg vs Bg
pub fn fmtStyle(buf: []u8, style: Style, str: []const u8) std.fmt.BufPrintError![]u8 {
    var offset: usize = 0;

    if (style.fgColor) |fgColor| {
        const fgColorEscaping = try fmtGraphicsCode(buf[offset..], foregroundColorEscapeCode(fgColor));
        offset += fgColorEscaping.len;
    }
    
    if (style.bgColor) |bgColor| {
        const bgColorEscaping = try fmtGraphicsCode(buf[offset..], backgroundColorEscapeCode(bgColor));
        offset += bgColorEscaping.len;
    }

    var hasAttr: bool = false;
    if (style.bold or style.dim or style.italic or style.inverse or style.hidden or style.underline or style.strikethrough) {
        hasAttr = true;
        buf[offset] = codes.EscapePrefix[0];
        offset += 1;
        buf[offset] = codes.EscapePrefix[1];
        offset += 1;
    }

    var firstAttr: bool = true;
    if (style.bold) {
        if (firstAttr) {
            firstAttr = false;
        } else {
            buf[offset] = ';';
            offset += 1;
        }
        buf[offset] = codes.graphics.attr.Bold[0];
        offset += 1;
    }
    if (style.dim) {
        if (firstAttr) {
            firstAttr = false;
        } else {
            buf[offset] = ';';
            offset += 1;
        }
        buf[offset] = codes.graphics.attr.Dim[0];
        offset += 1;
    }
    if (style.italic) {
        if (firstAttr) {
            firstAttr = false;
        } else {
            buf[offset] = ';';
            offset += 1;
        }
        buf[offset] = codes.graphics.attr.Italic[0];
        offset += 1;
    }
    if (style.underline) {
        if (firstAttr) {
            firstAttr = false;
        } else {
            buf[offset] = ';';
            offset += 1;
        }
        buf[offset] = codes.graphics.attr.Underline[0];
        offset += 1;
    }
    if (style.inverse) {
        if (firstAttr) {
            firstAttr = false;
        } else {
            buf[offset] = ';';
            offset += 1;
        }
        buf[offset] = codes.graphics.attr.Inverse[0];
        offset += 1;
    }
    if (style.hidden) {
        if (firstAttr) {
            firstAttr = false;
        } else {
            buf[offset] = ';';
            offset += 1;
        }
        buf[offset] = codes.graphics.attr.Hidden[0];
        offset += 1;
    }
    if (style.strikethrough) {
        if (firstAttr) {
            firstAttr = false;
        } else {
            buf[offset] = ';';
            offset += 1;
        }
        buf[offset] = codes.graphics.attr.Strikethrough[0];
        offset += 1;
    }
    if (hasAttr) {
        buf[offset] = codes.graphics.SetModeSuffix[0];
        offset += 1;
    }
    
    // offset += attrEscaping.len;

    const strFmt = try fmt.bufPrint(buf[offset..], "{}", .{str});
    offset += strFmt.len;

    const resetEscaping = try fmtGraphicsCode(buf[offset..], codes.Reset);
    offset += resetEscaping.len;

    return buf[0..offset];
}

fn fmtGraphicsCode(buf: []u8, code: []const u8) std.fmt.BufPrintError![]u8 {
    return fmt.bufPrint(buf, "{}{}{}", .{
        codes.EscapePrefix,
        code,
        codes.graphics.SetModeSuffix,
    });
}

// TODO fgStyle and bgStyle may become just one function with an enum parameter for Fg vs Bg
pub fn fgStyle(buf: []u8, colorCode: []const u8, str: []const u8) std.fmt.BufPrintError![]u8 {
    return fmt.bufPrint(buf, "{}{}{}{}{}{}{}", .{
        codes.EscapePrefix,
        colorCode,
        codes.graphics.SetModeSuffix,
        str,
        codes.EscapePrefix,
        codes.color.fg.FgReset,
        codes.graphics.SetModeSuffix,
    });
}

pub fn bgStyle(buf: []u8, colorCode: []const u8, str: []const u8) std.fmt.BufPrintError![]u8 {
    return fmt.bufPrint(buf, "{}{}{}{}{}{}{}", .{
        codes.EscapePrefix,
        colorCode,
        codes.graphics.SetModeSuffix,
        str,
        codes.EscapePrefix,
        codes.color.bg.BgReset,
        codes.graphics.SetModeSuffix,
    });
}

pub fn black(buf: []u8, str: []const u8) std.fmt.BufPrintError![]u8 {
    return fgStyle(buf, codes.color.fg.Black, str);
}

pub fn bgBlack(buf: []u8, str: []const u8) std.fmt.BufPrintError![]u8 {
    return bgStyle(buf, codes.color.bg.Black, str);
}

pub fn red(buf: []u8, str: []const u8) std.fmt.BufPrintError![]u8 {
    return fgStyle(buf, codes.color.fg.Red, str);
}

pub fn bgRed(buf: []u8, str: []const u8) std.fmt.BufPrintError![]u8 {
    return bgStyle(buf, codes.color.bg.Red, str);
}

pub fn green(buf: []u8, str: []const u8) std.fmt.BufPrintError![]u8 {
    return fgStyle(buf, codes.color.fg.Green, str);
}

pub fn bgGreen(buf: []u8, str: []const u8) std.fmt.BufPrintError![]u8 {
    return bgStyle(buf, codes.color.bg.Green, str);
}

pub fn yellow(buf: []u8, str: []const u8) std.fmt.BufPrintError![]u8 {
    return fgStyle(buf, codes.color.fg.Yellow, str);
}

pub fn bgYellow(buf: []u8, str: []const u8) std.fmt.BufPrintError![]u8 {
    return bgStyle(buf, codes.color.bg.Yellow, str);
}

pub fn blue(buf: []u8, str: []const u8) std.fmt.BufPrintError![]u8 {
    return fgStyle(buf, codes.color.fg.Blue, str);
}

pub fn bgBlue(buf: []u8, str: []const u8) std.fmt.BufPrintError![]u8 {
    return bgStyle(buf, codes.color.bg.Blue, str);
}

pub fn magenta(buf: []u8, str: []const u8) std.fmt.BufPrintError![]u8 {
    return fgStyle(buf, codes.color.fg.Magenta, str);
}

pub fn bgMagenta(buf: []u8, str: []const u8) std.fmt.BufPrintError![]u8 {
    return bgStyle(buf, codes.color.bg.Magenta, str);
}

pub fn cyan(buf: []u8, str: []const u8) std.fmt.BufPrintError![]u8 {
    return fgStyle(buf, codes.color.fg.Cyan, str);
}

pub fn bgCyan(buf: []u8, str: []const u8) std.fmt.BufPrintError![]u8 {
    return bgStyle(buf, codes.color.bg.Cyan, str);
}

pub fn white(buf: []u8, str: []const u8) std.fmt.BufPrintError![]u8 {
    return fgStyle(buf, codes.color.fg.White, str);
}

pub fn bgWhite(buf: []u8, str: []const u8) std.fmt.BufPrintError![]u8 {
    return bgStyle(buf, codes.color.bg.White, str);
}

// pub fn dim(buf: []u8, str: []const u8) std.fmt.BufPrintError![]u8 {
//     return fmt.bufPrint(buf, "{}{};{}{}", .{
//         escapeSequenceGraphics(codes.graphics.attr.)
//     });
// }

/// maybe replace this to a static table from Color enum to Color codes
pub fn foregroundColorEscapeCode(color: Color) []const u8 {
    return switch (color) {
        Color.Black => codes.color.fg.Black,
        Color.Red => codes.color.fg.Red,
        Color.Green => codes.color.fg.Green,
        Color.Yellow => codes.color.fg.Yellow,
        Color.Blue => codes.color.fg.Blue,
        Color.Magenta => codes.color.fg.Magenta,
        Color.Cyan => codes.color.fg.Cyan,
        Color.White => codes.color.fg.White,
    };
}

/// maybe replace this to a static table from Color enum to Color codes
pub fn backgroundColorEscapeCode(color: Color) []const u8 {
    return switch (color) {
        Color.Black => codes.color.bg.Black,
        Color.Red => codes.color.bg.Red,
        Color.Green => codes.color.bg.Green,
        Color.Yellow => codes.color.bg.Yellow,
        Color.Blue => codes.color.bg.Blue,
        Color.Magenta => codes.color.bg.Magenta,
        Color.Cyan => codes.color.bg.Cyan,
        Color.White => codes.color.bg.White,
    };
}

pub fn setForegroundColor(color: Color) !void {
    const colorCode: []const u8 = foregroundColorEscapeCode(color);
    const w = stdout.writer();
    try w.print("{}{}{}", .{
        codes.EscapePrefix,
        colorCode,
        codes.graphics.SetModeSuffix,
    });
}

pub fn setBackgroundColor(color: Color) !void {
    const colorCode: []const u8 = backgroundColorEscapeCode(color);
    const w = stdout.writer();
    try w.print("{}{}{}", .{
        codes.EscapePrefix,
        colorCode,
        codes.graphics.SetModeSuffix,
    });
}

// TODO writer anytype
pub fn resetGraphics() !void {
    const escapeSequence: []const u8 = comptime escapeSequenceGraphicsReset();
    try writeSequence(escapeSequence);
}

fn writeSequence(escapeSequence: []const u8) !void {
    const writtenBytes: usize = try stdout.write(escapeSequence);
    if (writtenBytes != escapeSequence.len) {
        return error.WriteError;
    }
}

// pub fn resetForegroundGraphics() os.WriteError!void {
//     const escapeSequence = comptime escapeSequenceForeground
// }

pub inline fn escapeSequencePrefix(comptime code: []const u8) []const u8 {
    return codes.EscapePrefix ++ code;
}

pub inline fn escapeSequenceGraphics(comptime code: []const u8) []const u8 {
    return escapeSequencePrefix(code) ++ codes.graphics.SetModeSuffix;
}

pub inline fn escapeSequenceGraphicsReset() []const u8 {
    return escapeSequenceGraphics(codes.Reset);
}

test "foreground colors" {
    const w = std.io.getStdErr().writer();

    try setForegroundColor(Color.Red);
    _ = try stdout.write("red");
    try resetGraphics();

    // TODO if this buffer is shared between an expression (for example: one w.print with multuple formats),
    // then this will break.
    var tmpBuf: [100]u8 = undefined;

    try w.print(" {}", .{ try green(&tmpBuf, "green") });
    try w.print(" {}", .{ try yellow(&tmpBuf, "yellow") });
    try w.print(" {}", .{ try blue(&tmpBuf, "blue") });
    try w.print(" {}", .{ try magenta(&tmpBuf, "magenta") });
    try w.print(" {}", .{ try cyan(&tmpBuf, "cyan") });
    try w.print(" {}", .{ try white(&tmpBuf, "white") });
    // TODO grey
    try w.print(" {}", .{ try black(&tmpBuf, "black") });
}

test "background colors" {
    const w = std.io.getStdErr().writer();

    try setBackgroundColor(Color.Red);
    _ = try stdout.write("red");
    try resetGraphics();

    // TODO if this buffer is shared between an expression (for example: one w.print with multuple formats),
    // then this will break.
    var tmpBuf: [100]u8 = undefined;

    try w.print(" {}", .{ try bgGreen(&tmpBuf, "bgGreen") });
    try w.print(" {}", .{ try bgYellow(&tmpBuf, "bgYellow") });
    try w.print(" {}", .{ try bgBlue(&tmpBuf, "bgBlue") });
    try w.print(" {}", .{ try bgMagenta(&tmpBuf, "bgMagenta") });
    try w.print(" {}", .{ try bgCyan(&tmpBuf, "bgCyan") });
    try w.print(" {}", .{ try bgWhite(&tmpBuf, "bgWhite") });
    // TODO grey
    try w.print(" {}", .{ try bgBlack(&tmpBuf, "bgBlack") });
}
