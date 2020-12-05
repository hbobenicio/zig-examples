const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub fn main() !void {

    const solution: u32 = blk: {
        // var input_buffer: [4096 * @sizeOf(u32)]u8 = undefined;
        // var allocator: *Allocator = &std.heap.FixedBufferAllocator.init(&input_buffer).allocator;
        var allocator: *Allocator = std.heap.page_allocator;

        // Global allocator would be just a simple arena allocator
        // Considering a FixedBufferAllocator instead of a page_allocator if there're not many input numbers
        var arena = std.heap.ArenaAllocator.init(allocator);
        defer arena.deinit();
        const global_allocator: *Allocator = &arena.allocator;

        // Stdin handle and temporary buffer
        var work_buffer: [30]u8 = undefined;
        const stdin = std.io.getStdIn().reader();

        break :blk try solve(global_allocator, stdin, &work_buffer);
    };
    
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{}\n", .{ solution });
}

fn solve(alloc: *Allocator, reader: anytype, work_buffer: []u8) !u32 {
    var line_buffer = work_buffer;

    var numbers: ArrayList(u32) = ArrayList(u32).init(alloc);
    defer numbers.deinit();

    while (true) {
        const maybe_num: ?u32 = try nextInt(reader, line_buffer);
        if (maybe_num == null) {
            return error.NoSolutionFound;
        }

        const num: u32 = maybe_num.?;
        for (numbers.items) |x| {
            if (x + num == 2020) {
                return x * num;
            }
        }

        try numbers.append(num);
    }
}

fn nextInt(reader: anytype, workBuf: []u8) !?u32 {
    const line: ?[]u8 = try reader.readUntilDelimiterOrEof(workBuf, '\n');
    if (line == null) {
        return null;
    }

    return try std.fmt.parseInt(u32, line.?, 10);
}
