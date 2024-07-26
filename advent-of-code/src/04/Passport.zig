const std = @import("std");

pub const Height = struct {
    value: u16,
    unit: []const u8,

    pub fn parse(input: ?[]const u8) !Height {
        const s: []const u8 = input orelse return error.ParseError;
        const unit_offset = std.mem.indexOfAny(u8, s, "ci") orelse return error.ParseError;
        const num_slice = s[0..unit_offset];
        const unit_slice = s[unit_offset..];

        const value: u16 = try std.fmt.parseInt(u16, num_slice, 10);
        
        if (! (std.mem.eql(u8, unit_slice, "cm") or (std.mem.eql(u8, unit_slice, "in"))))
            return error.ParseError;        

        return Height{.value = value, .unit = unit_slice};
    }
};

fn parseYear(input: ?[]const u8) !u16 {
    if (input == null)
        return error.ParseError;

    const s: []const u8 = input.?;

    if (s.len != 4)
        return error.ParseError;

    return std.fmt.parseInt(u16, s, 10);
}

fn is_digit(c: u8) bool {
    switch (c) {
        '0'...'9' => return true,
        else => return false,
    }
}

fn is_hex_digit(c: u8) bool {
    switch (c) {
        '0'...'9' => return true,
        'a'...'f' => return true,
        else => return false,
    }
}

pub const Passport = struct {
    byr: ?[]const u8 = null,
    iyr: ?[]const u8 = null,
    eyr: ?[]const u8 = null,
    hgt: ?[]const u8 = null,
    hcl: ?[]const u8 = null,
    ecl: ?[]const u8 = null,
    pid: ?[]const u8 = null,
    cid: ?[]const u8 = null,
    
    pub inline fn valid(self: *const @This()) bool {
        return self.byr != null
           and self.iyr != null
           and self.eyr != null
           and self.hgt != null
           and self.hcl != null
           and self.ecl != null
           and self.pid != null;
    }
    pub inline fn valid2(self: *const @This()) bool {
        return self.byr_valid()
           and self.iyr_valid()
           and self.eyr_valid()
           and self.hgt_valid()
           and self.hcl_valid()
           and self.ecl_valid()
           and self.pid_valid();
    }
    fn byr_valid(self: *const @This()) bool {
        const num: u16 = parseYear(self.byr) catch |err| return false;
        return 1920 <= num and num <= 2002;
    }
    fn iyr_valid(self: *const @This()) bool {
        const num: u16 = parseYear(self.iyr) catch |err| return false;
        return 2010 <= num and num <= 2020;
    }
    fn eyr_valid(self: *const @This()) bool {
        const num: u16 = parseYear(self.eyr) catch |err| return false;
        return 2020 <= num and num <= 2030;
    }
    fn hgt_valid(self: *const @This()) bool {
        const height: Height = Height.parse(self.hgt) catch |err| return false;

        if (std.mem.eql(u8, height.unit, "cm"))
            return 150 <= height.value and height.value <= 193;
        if (std.mem.eql(u8, height.unit, "in"))
            return 59 <= height.value and height.value <= 76;
        unreachable;
    }
    fn hcl_valid(self: *const @This()) bool {
        const hcl: []const u8 = self.hcl orelse return false;
        if (hcl.len != 7)
            return false;
        if (hcl[0] != '#')
            return false;

        const digits: []const u8 = hcl[1..];
        for (digits) |d| {
            if (!is_hex_digit(d)) {
                return false;
            }
        }
        return true;
    }
    fn ecl_valid(self: *const @This()) bool {
        const ecl: []const u8 = self.ecl orelse return false;
        return std.mem.eql(u8, ecl, "amb")
            or std.mem.eql(u8, ecl, "blu")
            or std.mem.eql(u8, ecl, "brn")
            or std.mem.eql(u8, ecl, "gry")
            or std.mem.eql(u8, ecl, "grn")
            or std.mem.eql(u8, ecl, "hzl")
            or std.mem.eql(u8, ecl, "oth");
    }
    fn pid_valid(self: *const @This()) bool {
        const pid: []const u8 = self.pid orelse return false;
        if (pid.len != 9)
            return false;
        const num: u64 = std.fmt.parseInt(u64, pid, 10) catch |err| return false;
        return true;
    }
    // TODO add others
};
