const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const print = std.debug.print;

const Tokenizer = @import("./Tokenizer.zig").Tokenizer;
const PassportParser = @import("./PassportParser.zig").PassportParser;

pub fn main() !void {
    const solution: usize = blk: {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const global_allocator: *Allocator = &arena.allocator;

        const stdin = std.io.getStdIn().reader();

        const input: []const u8 = try stdin.readAllAlloc(global_allocator, 10 * 1024 * std.mem.page_size);

        break :blk try solve(global_allocator, input);
    };

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{}\n", .{solution});
}

fn solve(alloc: *Allocator, input: []const u8) !usize {
    var valid_count: usize = 0;

    var passport_parser = try PassportParser.init(alloc, input);
    defer passport_parser.deinit();

    try passport_parser.parse();

    for (passport_parser.passports.items) |passport| {
        if (passport.valid2()) {
            valid_count += 1;
        }
    }

    return valid_count;
}
