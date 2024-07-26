const std = @import("std");

fn getenv_or(comptime prefix: ?[]const u8, comptime key: []const u8, default: []const u8) []const u8 {
    const full_key = (prefix orelse "") ++ key;
    return std.os.getenv(key) orelse default;
}

const ServerConfig = struct {
    host: []const u8,
    port: u16,
    address: std.net.Address,
    tcp_backlog: u31,

    pub fn fromEnv(comptime prefix: ?[]const u8) !ServerConfig {
        const host: []const u8 = getenv_or(prefix, "SERVER_HOST", "127.0.0.1");
        std.log.debug("config: server.host = \"{s}\"", .{host});

        const port: u16 = blk: {
            const key = (prefix orelse "") ++ "SERVER_PORT";
            const value = std.os.getenv(key) orelse "8080";
            break :blk try std.fmt.parseInt(u16, value, 10);
        };
        std.log.debug("config: server.port = \"{d}\"", .{port});

        const address = try std.net.Address.parseIp(host, port);
        std.log.debug("config: server.address = \"{s}\"", .{address});

        const tcp_backlog = blk: {
            const key = (prefix orelse "") ++ "TCP_BACKLOG";
            const value = std.os.getenv(key) orelse "512";
            break :blk try std.fmt.parseInt(u31, value, 10);
        };
        std.log.debug("config: server.tcp_backlog = \"{d}\"", .{tcp_backlog});

        return ServerConfig{
            .host = host,
            .port = port,
            .address = address,
            .tcp_backlog = tcp_backlog,
        };
    }
};

pub const Config = struct {
    server: ServerConfig,

    pub fn from_env(comptime prefix: ?[]const u8) !Config {
        const server = try ServerConfig.fromEnv(prefix);

        return Config{
            .server = server,
        };
    }
};
