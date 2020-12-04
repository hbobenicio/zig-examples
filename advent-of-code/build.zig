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

    const day_one_exe = b.addExecutable("day-01", "src/01/main.zig");
    day_one_exe.setTarget(target);
    day_one_exe.setBuildMode(mode);
    day_one_exe.install();

    const run_cmd = day_one_exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const day_two_exe = b.addExecutable("day-02", "src/02/main.zig");
    day_two_exe.setTarget(target);
    day_two_exe.setBuildMode(mode);
    day_two_exe.install();

    // const run_step = b.step("run", "Run the app");
    // run_step.dependOn(&run_cmd.step);
}
