//! Ansi support for zig.
//!
//! ## References:
//! https://www.lihaoyi.com/post/BuildyourownCommandLinewithANSIescapecodes.html
//! http://ascii-table.com/ansi-escape-sequences.php

const std = @import("std");
const os = std.os;
const fmt = std.fmt;

pub const codes = @import("./codes.zig");
pub const cursor = @import("./cursor.zig");

const stdout = std.io.getStdOut();

/// Color enumerates all suported colors.
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

pub fn blue(buf: []u8, str: []const u8) std.fmt.BufPrintError![]u8 {
    return fmt.bufPrint(buf, "{}{}{}", .{
        escapeSequenceGraphics(codes.color.fg.Blue),
        str,
        escapeSequenceGraphicsReset(),
    });
}

/// maybe replace this to a static table from Color enum to Color codes
pub fn foregroundColorEscapeCode(comptime color: Color) []const u8 {
    return switch(color) {
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
pub fn backgroundColorEscapeCode(comptime color: Color) []const u8 {
    return switch(color) {
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

pub fn setForegroundColor(comptime color: Color) os.WriteError!void {
    const escapeCode = comptime foregroundColorEscapeCode(color);
    const escapeSequence = comptime escapeSequenceGraphics(escapeCode);
    _ = try stdout.write(escapeSequence);
}

pub fn setBackgroundColor(comptime color: Color) os.WriteError!void {
    const escapeCode = comptime backgroundColorEscapeCode(color);
    const escapeSequence = comptime escapeSequenceGraphics(escapeCode);
    _ = try stdout.write(escapeSequence);
}

// TODO writer anytype
pub fn resetGraphics() os.WriteError!void {
    const escapeSequence = comptime escapeSequenceGraphicsReset();
    _ = try stdout.write(escapeSequence);
}

// pub fn resetForegroundGraphics() os.WriteError!void {
//     const escapeSequence = comptime escapeSequenceForeground
// }

pub inline fn escapeSequencePrefix(comptime code: []const u8) []const u8 {
    return codes.Esc ++ "[" ++ code;
}

pub inline fn escapeSequenceGraphics(comptime code: []const u8) []const u8 {
    return escapeSequencePrefix(code) ++ codes.graphics.SetModeSuffix;
}

pub inline fn escapeSequenceGraphicsReset() []const u8 {
    return escapeSequenceGraphics(codes.Reset);
}

// TODO add more escape sequences
// http://ascii-table.com/ansi-escape-sequences.php
