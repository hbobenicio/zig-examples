const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub fn main() !void {
    const solution: usize = blk: {
        const allocator: *Allocator = std.heap.page_allocator;

        var arena = std.heap.ArenaAllocator.init(allocator);
        defer arena.deinit();

        const global_allocator: *Allocator = &arena.allocator;

        var work_buffer: [100]u8 = undefined;
        const stdin = std.io.getStdIn().reader();

        break :blk try solve(global_allocator, stdin, &work_buffer);
    };
    
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{}\n", .{ solution });
}

fn solve(allocator: *Allocator, reader: anytype, work_buffer: []u8) !usize {
    var line_buffer = work_buffer;

    const offset_x: usize = 3;
    const offset_y: usize = 1;

    var tree_count: usize = 0;
    var curr_x: usize = 0;

    var first_line: bool = true;
    while (true) {
        const maybe_line: ?[]u8 = try reader.readUntilDelimiterOrEof(line_buffer, '\n');
        if (maybe_line == null) {
            return tree_count;
        }
        const line = maybe_line.?;

        if (!first_line) {
            if (line[curr_x] == '#') {
                tree_count += 1;
            }
        }

        curr_x = (curr_x + offset_x) % line.len;
        first_line = false;
    }
    return tree_count;
}
