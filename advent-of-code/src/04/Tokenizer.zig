const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const print = std.debug.print;

const token = @import("./token.zig");
const Token = token.Token;
const TokenKind = token.TokenKind;

const TokenizerMode = enum {
    scanning_key,
    scanning_value,
    finish,
};

fn is_number(c: u8) bool {
    return switch (c) {
        '0'...'9' => true,
        else => false
    };
}

fn is_ascii_alpha(c: u8) bool {
    return switch (c) {
        'a'...'z' => true,
        'A'...'Z' => true,
        else => false,
    };
}

pub const Tokenizer = struct {
    alloc: *Allocator,
    input: []const u8,
    tokens: ArrayList(Token),
    pos: usize,
    line: usize,
    column: usize,
    mode: TokenizerMode,

    pub fn init(allocator: *Allocator, input: []const u8) !Tokenizer {
        const initial_array_capacity: usize = @floatToInt(usize, 0.75 * @intToFloat(f32, input.len));
        return Tokenizer {
            .alloc = allocator,
            .input = input,
            .tokens = try ArrayList(Token).initCapacity(allocator, initial_array_capacity),
            .pos = 0,
            .line = 1,
            .column = 1,
            .mode = TokenizerMode.scanning_key,
        };
    }

    pub fn deinit(self: *@This()) void {
        self.tokens.deinit();
    }

    pub fn printTokens(self: *@This()) void {
        for (self.tokens.items) |tok| {
            switch (tok.kind) {
                TokenKind.key => print("KEY({}) ", .{tok.lexeme}),
                TokenKind.comma => print("COMMA ", .{}),
                TokenKind.value => print("VALUE({}) ", .{tok.lexeme}),
                TokenKind.eol => print("EOL\n", .{}),
                TokenKind.eof => print("EOF", .{}),
            }
        }
        print("\n", .{});
    }

    pub fn scan(self: *@This()) !void {
        while (!self.eof()) {
            switch (self.mode) {
                TokenizerMode.scanning_key => try self.scan_key(),
                TokenizerMode.scanning_value => try self.scan_value(),
                TokenizerMode.finish => break,
            }
        }
        self.mode = TokenizerMode.finish;
        try self.tokens.append(Token.eof(self.line, self.column));
    }

    fn scan_key(self: *@This()) !void {
        const lookahead: []const u8 = self.peek(self.pos, 1);
        if (lookahead.len == 0) {
            return;
        }
        const c: u8 = lookahead[0];

        if (c == '\n') {
            const tok = Token.eol(lookahead, self.line, self.column);
            try self.tokens.append(tok);
            self.line += 1;
            self.column = 1;
            self.pos += tok.len;
        } else if (c == ':') {
            const tok = Token.comma(lookahead, self.line, self.column);
            try self.tokens.append(tok);
            self.column += tok.len;
            self.pos += tok.len;
            self.mode = TokenizerMode.scanning_value;
        } else if (is_ascii_alpha(c)) {
            const key_end: usize = std.mem.indexOf(u8, self.input[self.pos..], ":") orelse 0;
            const lexeme: []const u8 = self.input[self.pos..self.pos + key_end];
            const tok = Token.key(lexeme, self.line, self.column);
            try self.tokens.append(tok);
            self.column += tok.len;
            self.pos += tok.len;
        } else if (c == ' ') {
            // skip it
            self.column += 1;
            self.pos += 1;
        } else {
            std.log.err("unexpected token at line {}, column {}: {}", .{self.line, self.column, lookahead});
            return error.UnexpectedToken;
        }
    }

    fn scan_value(self: *@This()) !void {
        const lookahead: []const u8 = self.peek(self.pos, 1);
        if (lookahead.len == 0) {
            return;
        }
        var c: u8 = lookahead[0];
        var value_end: usize = self.pos;
        while (!self.overflows(value_end) and c != ' ' and c != '\n') {
            value_end += 1;
            const next = self.peek(value_end, 1);
            if (next.len == 0) break;
            c = next[0];
        }
        // end of input or c == ' ' or c == '\n'
        const lexeme: []const u8 = self.peek(self.pos, value_end - self.pos);
        std.debug.assert(lexeme.len > 0);
        const tok = Token.value(lexeme, self.line, self.column);
        try self.tokens.append(tok);
        self.column += tok.len;
        self.pos += tok.len;
        self.mode = TokenizerMode.scanning_key;
    }

    fn peek(self: *@This(), from: usize, n: usize) []const u8 {
        const begin = if (!self.overflows(from)) from else self.input.len;
        const end = if (!self.overflows(from + n)) from + n else self.input.len;
        return self.input[begin..end];
    }

    inline fn overflows(self: *@This(), offset: usize) bool {
        return offset >= self.input.len;
    }

    inline fn eof(self: *@This()) bool {
        return self.overflows(self.pos);
    }
};

const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

test "basics" {
    var tokenizer = try Tokenizer.init(std.testing.allocator, "ecl:gry");
    defer tokenizer.deinit();

    try tokenizer.scan();

    expectEqual(@as(usize, 4), tokenizer.tokens.items.len);
}

test "basics" {
    var tokenizer = try Tokenizer.init(std.testing.allocator, "ecl:gry pid:860033327");
    defer tokenizer.deinit();

    try tokenizer.scan();
    expectEqual(@as(usize, 7), tokenizer.tokens.items.len);
}
