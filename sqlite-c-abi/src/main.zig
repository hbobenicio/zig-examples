const std = @import("std");
const c = @cImport({
    @cInclude("sqlite3.h");
});

const db_file_path: [*c]const u8 = "banco-de-questoes.db";

// fn (?*c_void, c_int, [*c][*c]u8, [*c][*c]u8) callconv(.C) c_int
fn callback(not_used: ?*c_void, argc: c_int, argv: [*c][*c]u8, col_names: [*c][*c]u8) callconv(.C) c_int {
    std.log.info("callback called", .{});
    return 0;
}

pub fn main() !void {
    var db: ?*c.sqlite3 = null;
    var rc: c_int = c.sqlite3_open(db_file_path, &db);
    if (rc != c.SQLITE_OK) {
        std.log.err("error: sqlite: open: could not open database \"{}\": {}", .{
            db_file_path,
            c.sqlite3_errmsg(db)
        });
        // TODO do we really need to close the db here?
        _ = c.sqlite3_close(db);
        return error.DBError;
    }

    var sql: [*c]const u8 =
        \\CREATE TABLE IF NOT EXISTS questao (
        \\    id INTEGER PRIMARY KEY AUTOINCREMENT,
        \\    title text NOT NULL
        \\);
    ;
    var err_msg: [*c]u8 = undefined;
    rc = c.sqlite3_exec(db, sql, callback, null, &err_msg);
    if (rc != c.SQLITE_OK) {
        std.log.err("error: sqlite: exec: [{}] could not execute query: {}: {}\n", .{rc, err_msg, c.sqlite3_errmsg(db)});
        _ = c.sqlite3_close(db);
        return error.DBError;
    }

    std.log.info("all good.", .{});
}
