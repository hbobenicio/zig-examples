const std = @import("std");
const assert = std.debug.assert;

pub const TokenKind = enum {
    key,
    comma,
    value,
    eol,
    eof,
};

pub const Token = struct {
    kind: TokenKind,
    lexeme: []const u8,
    line: usize,
    column: usize,
    len: usize,

    pub fn eof(line: usize, column: usize) Token {
        return Token {
            .kind = TokenKind.eof,
            .lexeme = "",
            .line = line,
            .column = column,
            .len = 0,
        };
    }
    pub fn eol(lexeme: []const u8, line: usize, column: usize) Token {
        assert(lexeme.len == 1);
        assert(lexeme[0] == '\n');

        return Token {
            .kind = TokenKind.eol,
            .lexeme = lexeme,
            .line = line,
            .column = column,
            .len = 1,
        };
    }
    pub fn comma(lexeme: []const u8, line: usize, column: usize) Token {
        assert(lexeme.len == 1);
        assert(lexeme[0] == ':');

        return Token {
            .kind = TokenKind.comma,
            .lexeme = lexeme,
            .line = line,
            .column = column,
            .len = 1,
        };
    }
    pub fn key(lexeme: []const u8, line: usize, column: usize) Token {
        return Token {
            .kind = TokenKind.key,
            .lexeme = lexeme,
            .line = line,
            .column = column,
            .len = lexeme.len,
        };
    }
    pub fn value(lexeme: []const u8, line: usize, column: usize) Token {
        return Token {
            .kind = TokenKind.value,
            .lexeme = lexeme,
            .line = line,
            .column = column,
            .len = lexeme.len,
        };
    }
};
