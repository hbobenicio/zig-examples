const std = @import("std");
const Builder = std.build.Builder;
const LibExeObjStep = std.build.LibExeObjStep;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    _ = addDay(b, target, mode, "day-01.1", "src/01/day-01.1.zig");
    _ = addDay(b, target, mode, "day-01.2", "src/01/day-01.2.zig");
    _ = addDay(b, target, mode, "day-02.1", "src/02/day-02.1.zig");
    _ = addDay(b, target, mode, "day-02.2", "src/02/day-02.2.zig");
    _ = addDay(b, target, mode, "day-03.1", "src/03/day-03.1.zig");
    _ = addDay(b, target, mode, "day-03.2", "src/03/day-03.2.zig");
}

fn addDay(b: *Builder, target: anytype, mode: std.builtin.Mode, target_name: []const u8, source: []const u8) *LibExeObjStep {
    var exe = b.addExecutable(target_name, source);
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    return exe;
}
