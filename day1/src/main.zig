const std = @import("std");
const args = @import("args");
const input = @embedFile("1.txt");

pub fn main() !void {
    const lineFunc: LineFunc = switch (args.getPart()) {
        1 => part1,
        2 => part2,
        else => unreachable,
    };

    var sum: u32 = 0;
    var it = std.mem.tokenizeAny(u8, input, "\n");

    while (it.next()) |line| {
        var lc = LineChars{};
        lineFunc(line, &lc);

        sum += try std.fmt.parseInt(u32, &lc.pair, 10);
    }

    std.debug.print("calibration sum: {d}\n", .{sum});
}

const LineChars = struct {
    pair: [2]u8 = .{ '0', '0' },

    fn update(lc: *LineChars, char: u8) void {
        lc.pair[1] = char;
        if (lc.pair[0] == '0') {
            lc.pair[0] = char;
        }
    }
};

const LineFunc = *const fn ([]const u8, *LineChars) void;

fn part1(line: []const u8, lc: *LineChars) void {
    for (line) |c| {
        if (c >= '1' and c <= '9') {
            lc.update(c);
        }
    }
}

fn part2(line: []const u8, lc: *LineChars) void {
    for (line, 0..) |c, i| {
        const char = if (c >= '1' and c <= '9') c else blk: {
            for (digits, 0..) |d, n| {
                if (i + d.len > line.len) continue;

                if (std.mem.eql(u8, line[i .. i + d.len], d)) {
                    break :blk std.fmt.digitToChar(@intCast(n + 1), .lower);
                }
            }

            continue;
        };

        lc.update(char);
    }
}

const digits = [_][]const u8{
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
};
