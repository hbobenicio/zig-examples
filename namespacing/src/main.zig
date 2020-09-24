const Foo = struct {
    const Bar = struct {
        name: []const u8 = "Foo Bar",
    };
};

// const Caz = struct {
    const Bar = struct {
        name: []const u8 = "Just Bar",
    };
// };

pub fn main() void {
    const foo_bar = Foo.Bar{};
    const caz_bar = Bar{};
}
