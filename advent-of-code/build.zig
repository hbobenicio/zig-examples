const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const dayOneExe = b.addExecutable("day-01", "src/01/main.zig");
    dayOneExe.setTarget(target);
    dayOneExe.setBuildMode(mode);

    const dayTwoExe = b.addExecutable("day-02", "src/02/main.zig");
    dayTwoExe.setTarget(target);
    dayTwoExe.setBuildMode(mode);

    
}
