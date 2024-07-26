const std = @import("std");

const config = @import("./config.zig");

pub const log_level: std.log.Level = .debug;
const stdout = std.io.getStdOut().writer();

const ReadMode = enum {
    header,
    body,
};

pub fn main() !void {
    //log_level = std.log.Level.info;
    const cfg = try config.Config.from_env("APP_");
    std.log.debug("config: {}", .{cfg});

    try stdout.print("listening to address {s}\n",  .{cfg.server.address});

    var server = std.net.StreamServer.init(.{
        .kernel_backlog = cfg.server.tcp_backlog,
        .reuse_address = true
    });
    defer server.deinit();

    try server.listen(cfg.server.address);
    while (true) {
        const conn: std.net.StreamServer.Connection = try server.accept();

        handleConnection(conn) catch |err| {
            std.log.err("server: {}", .{err});
        };
    }
}

fn handleConnection(conn: std.net.StreamServer.Connection) !void {
    defer conn.stream.close();

    // TODO Paralelize this function
    std.log.info("server: new client connection.", .{});
    defer std.log.info("server: end of client connection.", .{});

    // TODO Maybe there is a better allocator combo other then using a page_allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const w = conn.stream.writer();
    const r = conn.stream.reader();

    var read_mode = ReadMode.header;

    // TODO After we fix the reading process, put this below the reading header block
    try w.writeAll("HTTP/1.1 200 OK\r\n");
    try w.writeAll("Server: echo-server 0.0.0\r\n");
    try w.writeAll("Content-type: text/plain; charset=utf-8\r\n");
    try w.writeAll("\r\n");

    var reading_buf: []u8 = try arena.allocator.alloc(u8, 4 * std.mem.page_size);
    while (true) {
        const bytes_read: usize = try r.read(reading_buf);
        std.log.debug("server: read {d} bytes from client.", .{bytes_read});

        // EOF (connection closed)
        if (bytes_read == 0) {
            break;
        }

        const input: []const u8 = reading_buf[0..bytes_read];
        try stdout.print("{s}", .{input});

        if (read_mode == ReadMode.header) {
            var headers = std.mem.tokenize(input, "\r\n");
            while (headers.next()) |header| {
                if (std.mem.eql(u8, header, "")) {
                    read_mode = ReadMode.body;
                }
                std.log.debug("{s}", .{header});
            }
        }
        try w.writeAll(input);
    }
    // Also print it to the stdout!
    // try stdout.print("{s}", .{buf});
}
