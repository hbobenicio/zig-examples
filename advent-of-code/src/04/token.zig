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

    pub fn eol(lexeme: []const u8, line: usize, column: usize) Token {
        return Token {
            .kind = TokenKind.eol,
            .lexeme = lexeme,
            .line = line,
            .column = column,
            .len = 1,
        };
    }
};
