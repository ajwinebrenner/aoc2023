const std = @import("std");

pub fn main() !void {
    var args = std.process.args();
    _ = args.next(); // program name

    const day = nextIntArg(&args) catch @panic("invalid day value");
    const part = nextIntArg(&args) catch @panic("invalid part value");

    switch (day) {
        1 => try @import("day1.zig").solve(part),
        2 => try @import("day2.zig").solve(part),
        3 => try @import("day3.zig").solve(part),
        4 => try @import("day4.zig").solve(part),
        5 => try @import("day5.zig").solve(part),
        6 => try @import("day6.zig").solve(part),
        7 => try @import("day7.zig").solve(part),
        else => std.debug.print("no day '{d}' found\n", .{day}),
    }
}

fn nextIntArg(it: *std.process.ArgIterator) !u8 {
    const arg = it.next() orelse "1";
    return std.fmt.parseInt(u8, arg, 10);
}
