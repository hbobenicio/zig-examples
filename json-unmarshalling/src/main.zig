// $ zig build-exe --release-safe src/main.zig 
// $ zig build -Drelease-safe=true run

const std = @import("std");
const json = std.json;

const Allocator = std.mem.Allocator;
const global_allocator = std.heap.c_allocator;

const Photo = @import("./photo.zig").Photo;

pub fn main() !void {
    try run();
}

fn run() !void {
    const file_content: []const u8 = try read_json_file(global_allocator, "photos.json");
    defer global_allocator.free(file_content);

    const parsingOptions = json.ParseOptions{
        .allocator = global_allocator
    };

    var i: usize = 0;
    while (i < 100) : (i += 1) {
        const photos: []Photo = try json.parse([]Photo, &json.TokenStream.init(file_content), parsingOptions);
        std.debug.warn("{}\n", .{photos[i].title});
    }
}

fn read_json_file(alloc: *Allocator, file_path: []const u8) ![]u8 {
    const file: std.fs.File = try std.fs.cwd().openFile(file_path, std.fs.File.OpenFlags{
        .read = true,
        .write = false,
    });
    defer file.close();

    const file_size: usize = try file.getEndPos();

    var file_content: []u8 = try alloc.alloc(u8, file_size + 1);
    errdefer alloc.free(file_content);

    const bytes_read: usize = try file.read(file_content[0..]);
    if (bytes_read != file_size) {
        std.debug.warn("error: file size ({}) and bytes read ({}) didn't match", .{file_size, bytes_read});
        return error.FileReadError;
    }

    return file_content;
}
