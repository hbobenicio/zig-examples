const std = @import("std");

usingnamespace @cImport({
    @cInclude("gtk/gtk.h");
});
// const c = @cImport({
//     @cInclude("gtk/gtk.h");
// });

pub export fn main(argc: c_int, argv: [*c][*c]u8) i32 {
// pub fn main() !void {
    const app_id: [*c]const gchar = "br.com.hugobenicio.zigexamples.gtkzigdemo";
    const app_flags: GApplicationFlags = @intToEnum(GApplicationFlags, G_APPLICATION_FLAGS_NONE);

    var app: [*c]GtkApplication = gtk_application_new(app_id, app_flags);
    defer g_object_unref(app);

    // pub inline fn g_signal_connect(instance: var, detailed_signal: var, c_handler: var, data: var) @TypeOf(g_signal_connect_data(instance, detailed_signal, c_handler, data, NULL, @intToPtr(GConnectFlags, 0))) {
    // return g_signal_connect_data(instance, detailed_signal, c_handler, data, NULL, @intToPtr(GConnectFlags, 0));
    // }
    // pub extern fn g_signal_connect_closure_by_id(instance: gpointer, signal_id: guint, detail: GQuark, closure: ?*GClosure, after: gboolean) gulong;
    // pub extern fn g_signal_connect_closure(instance: gpointer, detailed_signal: [*c]const gchar, closure: ?*GClosure, after: gboolean) gulong;
    // pub extern fn g_signal_connect_data(instance: gpointer, detailed_signal: [*c]const gchar, c_handler: GCallback, data: gpointer, destroy_data: GClosureNotify, connect_flags: GConnectFlags) gulong;

    //g_signal_connect (app, "activate", G_CALLBACK (activate), NULL);
    // g_signal_connect(app, "activate", @ptrCast(fn() callconv(.C) void, activate), null);

    // G_APPLICATION(@ptrCast([*c]GApplication, app)),
    // @truncate(c_int, @bitCast(i64, std.os.argv.len)),
    // @as([*c][*c]u8, std.os.argv),
    return g_application_run(@ptrCast([*c]GApplication, app), argc, argv);
}

export fn activate(app: [*c]GtkApplication, user_data: [*c]gpointer) callconv(.C) void {
    std.debug.warn("activate called!\n", .{});
}

// static void
// activate (GtkApplication* app,
//           gpointer        user_data)
// {
//   GtkWidget *window;

//   window = gtk_application_window_new (app);
//   gtk_window_set_title (GTK_WINDOW (window), "Window");
//   gtk_window_set_default_size (GTK_WINDOW (window), 200, 200);
//   gtk_widget_show_all (window);
// }

// {
//   GtkApplication *app;
//   int status;

//   app = gtk_application_new ("org.gtk.example", G_APPLICATION_FLAGS_NONE);
//   g_signal_connect (app, "activate", G_CALLBACK (activate), NULL);
//   status = g_application_run (G_APPLICATION (app), argc, argv);
//   g_object_unref (app);

//   return status;
// }