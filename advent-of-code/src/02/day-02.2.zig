const std = @import("std");

pub fn main() !void {
    const solution: usize = blk: {
        var work_buffer: [100]u8 = undefined;
        const stdin = std.io.getStdIn().reader();

        break :blk try solve(stdin, &work_buffer);
    };
    
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{}\n", .{ solution });
}

const InputData = struct {
    pos1: usize,
    pos2: usize,
    letter: u8,
    password: []const u8,
};

fn solve(reader: anytype, work_buffer: []u8) !usize {
    var line_buffer = work_buffer;

    var valid_password_count: usize = 0;

    while (true) {
        const maybe_line: ?[]u8 = try reader.readUntilDelimiterOrEof(line_buffer, '\n');
        if (maybe_line == null) {
            return valid_password_count;
        }

        const input_data: InputData = try parseLine(maybe_line.?);

        const c1: u8 = input_data.password[input_data.pos1 - 1];
        const c2: u8 = input_data.password[input_data.pos2 - 1];

        var match_count: usize = 0;
        if (c1 == input_data.letter) {
            match_count += 1;
        }
        if (c2 == input_data.letter) {
            match_count += 1;
        }

        if (match_count == 1) {
            valid_password_count += 1;
        }
    }
}

fn parseLine(line: []const u8) !InputData {
    var offset: usize = 0;

    const pos1: usize = try parseInt(usize, line, &offset);
    skip(1, line, &offset); // -

    const pos2: usize = try parseInt(usize, line, &offset);
    skip(1, line, &offset); // ' '

    const letter: u8 = try parseLetter(line, &offset);
    skip(2, line, &offset); // ': '

    // The rest of the line
    const password: []const u8 = line[offset..];

    return InputData {
        .pos1 = pos1,
        .pos2 = pos2,
        .letter = letter,
        .password = password,
    };
}

fn parseInt(comptime T: type, line: []const u8, offset: *usize) !T {
    const begin: usize = offset.*;

    while (true) {
        if (offset.* >= line.len) {
            break;
        }

        var c: u8 = line[offset.*];
        if (!isAsciiDigit(c)) {
            break;
        }

        offset.* += 1;
    }

    return std.fmt.parseInt(usize, line[begin..offset.*], 10);
}

fn parseLetter(line: []const u8, offset: *usize) !u8 {
    if (offset.* >= line.len) {
        return error.Overflow;
    }

    const c: u8 = line[offset.*];
    offset.* += 1;

    return c;
}

fn skip(count: usize, line: []const u8, offset: *usize) void {
    if (offset.* + count >= line.len) {
        offset.* += line.len - offset.*;
    } else {
        offset.* += count;
    }
}

inline fn isAsciiDigit(c: u8) bool {
    return 48 <= c and c <= 57;
}
