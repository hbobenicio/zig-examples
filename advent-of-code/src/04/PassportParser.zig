const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const Tokenizer = @import("./Tokenizer.zig").Tokenizer;
const Passport = @import("./Passport.zig").Passport;

pub const PassportParser = struct {
    alloc: *Allocator,
    input: []const u8,
    tokenizer: Tokenizer,

    // AST
    passports: ArrayList(Passport),
};
