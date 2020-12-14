const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const token = @import("./token.zig");
const TokenKind = token.TokenKind;
const Token = token.Token;
const Tokenizer = @import("./Tokenizer.zig").Tokenizer;
const Passport = @import("./Passport.zig").Passport;

pub const PassportParser = struct {
    alloc: *Allocator,
    input: []const u8,
    tokenizer: Tokenizer,

    // Simplified AST
    passports: ArrayList(Passport),

    pub fn init(alloc: *Allocator, input: []const u8) !PassportParser {
        return PassportParser {
            .alloc = alloc,
            .input = input,
            .tokenizer = try Tokenizer.init(alloc, input),
            .passports = try ArrayList(Passport).init(alloc),
        };
    }

    pub fn deinit(self: *@This()) void {
        self.passports.deinit();
        self.tokenizer.deinit();
    }

    pub fn parse(self: *@This()) !void {
        try self.tokenizer.scan();

        var token_offset: usize = 0;
        var curr_token: Token = self.tokenizer.tokens.items[token_offset];
        while (curr_token.kind != TokenKind.eof and token_offset < self.tokenizer.token.items.len) {
            

            token_offset += 1;
            curr_token = self.tokenizer.tokens.items[token_offset];
        }
    }
};
