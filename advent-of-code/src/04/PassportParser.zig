const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const print = std.debug.print;

const token = @import("./token.zig");
const TokenKind = token.TokenKind;
const Token = token.Token;
const Tokenizer = @import("./Tokenizer.zig").Tokenizer;
const Passport = @import("./Passport.zig").Passport;

pub const PassportParser = struct {
    alloc: *Allocator,
    input: []const u8,
    tokenizer: Tokenizer,
    token_offset: usize,

    // Simplified AST
    passports: ArrayList(Passport),

    pub fn init(alloc: *Allocator, input: []const u8) !PassportParser {
        return PassportParser {
            .alloc = alloc,
            .input = input,
            .tokenizer = try Tokenizer.init(alloc, input),
            .passports = ArrayList(Passport).init(alloc),
            .token_offset = 0,
        };
    }

    pub fn deinit(self: *@This()) void {
        self.tokenizer.deinit();
        //self.passports.deinit();
    }

    pub fn parse(self: *@This()) !void {
        try self.tokenizer.scan();

        var passport_tokens = ArrayList(Token).init(self.alloc);
        defer passport_tokens.deinit();

        var p = Passport{};
        var k: []const u8 = undefined;

        var prev_token: ?Token = null;
        var curr: Token = self.curr_token();
        while (!curr.is_eof()) {
            if (prev_token) |prev| {
                if (prev.kind == TokenKind.eol and curr.kind == TokenKind.eol) {
                    // end of register
                    try self.passports.append(p);
                }
            }
            switch (curr.kind) {
                TokenKind.key => k = curr.lexeme,
                TokenKind.value => {
                    const v: []const u8 = curr.lexeme;
                    if (std.mem.eql(u8, k, "byr")) {
                        p.byr = v;
                    } else if (std.mem.eql(u8, k, "iyr")) {
                        p.iyr = v;
                    } else if (std.mem.eql(u8, k, "eyr")) {
                        p.eyr = v;
                    } else if (std.mem.eql(u8, k, "hgt")) {
                        p.hgt = v;
                    } else if (std.mem.eql(u8, k, "hcl")) {
                        p.hcl = v;
                    } else if (std.mem.eql(u8, k, "ecl")) {
                        p.ecl = v;
                    } else if (std.mem.eql(u8, k, "pid")) {
                        p.pid = v;
                    } else if (std.mem.eql(u8, k, "cid")) {
                        p.cid = v;
                    } else {
                        @panic("unexpected key");
                    }
                },
                else => {},
            }
            prev_token = curr;
            self.token_offset += 1;
            curr = self.curr_token();
        }
        try self.passports.append(p);
    }

    inline fn curr_token(self: *@This()) Token {
        return self.tokenizer.tokens.items[self.token_offset];
    }
};
