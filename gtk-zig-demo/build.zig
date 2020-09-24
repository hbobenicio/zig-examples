const std = @import("std");
const Builder = std.build.Builder;
const LibExeObjStep = std.build.LibExeObjStep;

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("gtk-zig-demo", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();
    exe.linkSystemLibrary("c");

    gtk_setup(exe);

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

fn gtk_setup(exe: *LibExeObjStep) void {
    gtk_setup_include_dirs(exe);
    gtk_setup_link_libraries(exe);
}

fn gtk_setup_include_dirs(exe: *LibExeObjStep) void {
    // pkg-config --cflags gtk+-3.0
    // improvement: spawn pkg-config as a child process and get its output
    const gtk_include_dirs: []const []const u8 = &[_][]const u8{
        "/usr/include/gtk-3.0",
        "/usr/include/at-spi2-atk/2.0",
        "/usr/include/at-spi-2.0",
        "/usr/include/dbus-1.0",
        "/usr/lib/x86_64-linux-gnu/dbus-1.0/include",
        "/usr/include/gtk-3.0",
        "/usr/include/gio-unix-2.0/",
        "/usr/include/cairo",
        "/usr/include/pango-1.0",
        "/usr/include/harfbuzz",
        "/usr/include/pango-1.0",
        "/usr/include/atk-1.0",
        "/usr/include/cairo",
        "/usr/include/pixman-1",
        "/usr/include/freetype2",
        "/usr/include/libpng16",
        "/usr/include/freetype2",
        "/usr/include/libpng16",
        "/usr/include/gdk-pixbuf-2.0",
        "/usr/include/libpng16",
        "/usr/include/glib-2.0",
        "/usr/lib/x86_64-linux-gnu/glib-2.0/include",
    };
    for (gtk_include_dirs) |dir| {
        exe.addIncludeDir(dir);
    }
}

fn gtk_setup_link_libraries(exe: *LibExeObjStep) void  {
    // pkg-config --libs gtk+-3.0
    // improvement: spawn pkg-config as a child process and get its output
    const gtk_libraries: []const []const u8 = &[_][]const u8 {
        "gtk-3",
        "gdk-3",
        "pangocairo-1.0",
        "pango-1.0",
        "atk-1.0",
        "cairo-gobject",
        "cairo",
        "gdk_pixbuf-2.0",
        "gio-2.0",
        "gobject-2.0",
        "glib-2.0",
    };
    for (gtk_libraries) |lib| {
        exe.linkSystemLibrary(lib);
    }
}
