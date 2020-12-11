const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const token = @import("./token.zig");
const Token = token.Token;
const TokenKind = token.TokenKind;

const TokenizerMode = enum {
    scanning_key,
    scanning_value,
};

pub const Tokenizer = struct {
    alloc: *Allocator,
    input: []const u8,
    tokens: ArrayList(Token),
    pos: usize,
    line: usize,
    column: usize,
    mode: TokenizerMode,

    pub fn init(allocator: *Allocator, input: []const u8) !Tokenizer {
        return Tokenizer {
            .alloc = allocator,
            .input = input,
            .tokens = try ArrayList(Token).initCapacity(allocator, 0.75 * input.len),
            .pos = 0,
            .line = 1,
            .column = 1,
            .mode = TokenizerMode.default,
        };
    }

    pub fn deinit(self: *@This()) void {
        self.tokens.deinit();
    }

    pub fn scan(self: *@This()) !void {
        while (!self.eof()) {
            switch (self.mode) {
                TokenizerMode.scanning_key => try self.scan_key(),
                TokenizerMode.scanning_value => try self.scan_value(),
            }
        }
    }

    pub fn scan_key(self: *@This()) !void {
        // skip whitespaces
        // match key
        // match ':'
        // mode scanning_value
    }

    pub fn scan_value(self: *@This()) !void {
        // match value
        // mode scanning_key
    }

    fn peek(self: *@This(), from: usize, n: usize) []const u8 {
        const begin = if (!self.overflows(from)) from else self.input.len;
        const end = if (!self.overflows(from + n)) from + n else self.input.len;
        return input[begin..end];
    }

    inline fn overflows(self: *@This(), offset: usize) bool {
        return offset >= self.input.len;
    }

    inline fn eof(self: *@This()) bool {
        return self.overflows(self.pos);
    }
};
