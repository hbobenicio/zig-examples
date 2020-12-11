const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const print = std.debug.print;

const Tokenizer = @import("./Tokenizer.zig").Tokenizer;

pub fn main() !void {
    const solution: usize = blk: {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();

        const global_allocator: *Allocator = &arena.allocator;

        const stdin = std.io.getStdIn().reader();

        const input: []const u8 = try stdin.readAllAlloc(global_allocator, 10 * 1024 * std.mem.page_size);

        //break :blk solve(global_allocator, &lines);
        break :blk try solve(global_allocator, input);
    };
    
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{}\n", .{ solution });
}

fn solve(alloc: *Allocator, input: []const u8) !usize {
    var valid_count: usize = 0;

    var record_lines = try ArrayList([]const u8).initCapacity(alloc, 4);
    defer record_lines.deinit();

    var lines = std.mem.split(input, "\n");
    while (lines.next()) |line| {

        // end of passport lines
        if (std.mem.trim(u8, line, " \t").len == 0) {
            if (passport_valid(&record_lines)) {
                valid_count += 1;
            }
            
            record_lines.shrink(0);

        } else {
            const new_line: []u8 = try alloc.alloc(u8, line.len);
            std.mem.copy(u8, new_line, line);
            try record_lines.append(new_line);
        }
    }

    return valid_count;
}

fn passport_valid(lines: *ArrayList([]const u8)) bool {
    var has_byr: bool = false;
    var has_iyr: bool = false;
    var has_eyr: bool = false;
    var has_hgt: bool = false;
    var has_hcl: bool = false;
    var has_ecl: bool = false;
    var has_pid: bool = false;
    var has_cid: bool = false;

    for (lines.items) |line| {
        var field_it = std.mem.tokenize(line, ": ");
        
        var key: bool = true;
        while (field_it.next()) |field| {
            if (key) {
                //print("key: {}\n", .{field});
                if (std.mem.eql(u8, field, "byr")) {
                    has_byr = true;
                } else if (std.mem.eql(u8, field, "iyr")) {
                    has_iyr = true;
                } else if (std.mem.eql(u8, field, "eyr")) {
                    has_eyr = true;
                } else if (std.mem.eql(u8, field, "hgt")) {
                    has_hgt = true;
                } else if (std.mem.eql(u8, field, "hcl")) {
                    has_hcl = true;
                } else if (std.mem.eql(u8, field, "ecl")) {
                    has_ecl = true;
                } else if (std.mem.eql(u8, field, "pid")) {
                    has_pid = true;
                } else if (std.mem.eql(u8, field, "cid")) {
                    has_cid = true;
                } else {
                    //print("key? {}\n", .{field});
                    @panic("wops! what is this key?");
                }
                
            } else {
                // value noop
            }

            key = !key;
        }
    }

    return has_byr and has_iyr and has_eyr and has_hgt and has_hcl and has_ecl and has_pid;
}
