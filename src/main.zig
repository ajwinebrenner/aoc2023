const std = @import("std");
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");
const day4 = @import("day4.zig");
const day5 = @import("day5.zig");
const day6 = @import("day6.zig");
const day7 = @import("day7.zig");

pub fn main() !void {
    var args = std.process.args();
    _ = args.next(); // program name

    const day = nextIntArg(&args) catch @panic("invalid day value");
    const part = nextIntArg(&args) catch @panic("invalid part value");

    switch (day) {
        1 => try day1.solve(part),
        2 => try day2.solve(part),
        3 => try day3.solve(part),
        4 => try day4.solve(part),
        5 => try day5.solve(part),
        6 => try day6.solve(part),
        7 => try day7.solve(part),
        else => std.debug.print("no day '{d}' found\n", .{day}),
    }
}

fn nextIntArg(it: *std.process.ArgIterator) !u8 {
    const arg = it.next() orelse "1";
    return std.fmt.parseInt(u8, arg, 10);
}
