const std = @import("std");
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");

pub fn main() !void {
    var args = std.process.args();
    _ = args.next(); // program name

    const day = nextIntArg(&args) catch @panic("invalid day value");
    const part = nextIntArg(&args) catch @panic("invalid part value");

    switch (day) {
        1 => try day1.solve(part),
        2 => try day2.solve(part),
        else => std.debug.print("no day '{d}' found", .{day}),
    }
}

fn nextIntArg(it: *std.process.ArgIterator) !u8 {
    const arg = it.next() orelse "1";
    return std.fmt.parseInt(u8, arg, 10);
}
