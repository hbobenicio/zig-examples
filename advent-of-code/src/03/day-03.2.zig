const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

// pub const log_level: std.log.Level = if (std.os.getenv("LOG")) |lvl| {
//     switch
// };

pub fn main() !void {
    const solution: usize = blk: {
        const allocator: *Allocator = std.heap.page_allocator;

        var arena = std.heap.ArenaAllocator.init(allocator);
        defer arena.deinit();

        const global_allocator: *Allocator = &arena.allocator;

        const map: ArrayList([]const u8) = inp: {
            var line_buffer: [100]u8 = undefined;

            var map: ArrayList([]const u8) = ArrayList([]const u8).init(allocator);
            
            const reader = std.io.getStdIn().reader();
            while (true) {
                const maybe_line: ?[]u8 = try reader.readUntilDelimiterOrEof(&line_buffer, '\n');
                if (maybe_line == null) {
                    break;
                }
                const new_line: []u8 = try global_allocator.alloc(u8, maybe_line.?.len);
                std.mem.copy(u8, new_line, maybe_line.?);
                try map.append(new_line);
            }

            break :inp map;
        };
        defer map.deinit();

        const solution_1: usize = solve(&map, 1, 1);
        const solution_2: usize = solve(&map, 3, 1);
        const solution_3: usize = solve(&map, 5, 1);
        const solution_4: usize = solve(&map, 7, 1);
        const solution_5: usize = solve(&map, 1, 2);

        break :blk solution_1 * solution_2 * solution_3 * solution_4 * solution_5;
    };
    
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{}\n", .{ solution });
}

fn solve(map: *const ArrayList([]const u8), slope_right: usize, slope_down: usize) usize {
    var tree_count: usize = 0;
    var row: usize = 0;
    var col: usize = 0;

    while (row < map.items.len) {
        //std.log.debug("c: {}, row: {}, col: {}", .{map.items[row][col], row, col});
        if (map.items[row][col] == '#') {
            tree_count += 1;
        }

        col = (col + slope_right) % map.items[0].len;
        row += slope_down;
    }
    std.log.debug("slope(right: {}, down: {}) = {}", .{slope_right, slope_down, tree_count});
    return tree_count;
}
