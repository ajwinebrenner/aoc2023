const std = @import("std");
const Allocator = std.mem.Allocator;
const input = @embedFile("input/3.txt");

pub fn solve(part: u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const check = gpa.deinit();
        if (check == .leak) @panic("leaked");
    }

    const matrix = try createMatrix(allocator);
    defer allocator.free(matrix);

    switch (part) {
        1 => try part1(matrix),
        2 => try part2(matrix, allocator),
        else => unreachable,
    }
}

fn part1(matrix: [][]const u8) !void {
    var buffer: [16]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    var part_sum: u32 = 0;

    for (matrix, 0..) |line, y| {
        var x: usize = 0;
        while (x < line.len) : (x += 1) {
            if (!std.ascii.isDigit(line[x])) continue;

            const start = Point.init(x, y);

            const digits = try extractNum(matrix, start, allocator);
            defer {
                x += digits.len;
                allocator.free(digits);
            }

            if (digits.len == 0) @panic("extractNum failed");
            if (touchingSymbol(matrix, start, digits.len)) {
                part_sum += try std.fmt.parseInt(u32, digits, 10);
            }
        }
    }

    std.debug.print("sum of part numbers touching a symbol: {d}\n", .{part_sum});
}

fn part2(matrix: [][]const u8, allocator: Allocator) !void {
    var gear_ratio: u32 = 0;

    for (matrix, 0..) |line, y| {
        var x: usize = 0;
        while (x < line.len) : (x += 1) {
            if (line[x] != '*') continue;

            const gear = Point.init(x, y);

            const strs = try extractGearNums(matrix, gear, allocator);
            defer {
                for (strs) |str| allocator.free(str);
                allocator.free(strs);
            }

            if (strs.len == 2) {
                gear_ratio += try std.fmt.parseInt(u32, strs[0], 10) * try std.fmt.parseInt(u32, strs[1], 10);
            }
        }
    }

    std.debug.print("sum of part numbers touching a symbol: {d}\n", .{gear_ratio});
}

const CharList = std.ArrayList(u8);

const StrList = std.ArrayList([]const u8);

const Point = struct {
    x: usize,
    y: usize,

    fn init(x: usize, y: usize) Point {
        return Point{ .x = x, .y = y };
    }
};

fn extractGearNums(matrix: [][]const u8, gear: Point, allocator: Allocator) ![][]const u8 {
    var str_list = StrList.init(allocator);
    var last_start: Point = undefined;

    for (
        [_]i64{ -1, 0, 1, -1, 1, -1, 0, 1 },
        [_]i64{ -1, -1, -1, 0, 0, 1, 1, 1 },
    ) |x, y| {
        if ((gear.x == 0 and x < 1) or (gear.y == 0 and y < 1)) continue;

        const p = Point.init(@intCast(@as(i64, @intCast(gear.x)) + x), @intCast(@as(i64, @intCast(gear.y)) + y));
        if (charAt(matrix, p)) |c| if (std.ascii.isDigit(c)) {
            const start = findStart(matrix, p);
            if (start.x == last_start.x and start.y == last_start.y) continue;

            try str_list.append(try extractNum(matrix, start, allocator));
            last_start = start;
        };
    }

    return str_list.toOwnedSlice();
}

fn findStart(matrix: [][]const u8, p: Point) Point {
    var start = p;

    while (start.x > 0) {
        if (start.x == 0) break;
        const before = Point.init(start.x - 1, p.y);
        const char = charAt(matrix, before);
        if (char == null or !std.ascii.isDigit(char.?)) break;
        start = before;
    }

    return start;
}

fn extractNum(matrix: [][]const u8, start: Point, allocator: Allocator) ![]const u8 {
    if (charAt(matrix, start) == null) return error.NoNumFound;
    var digits = CharList.init(allocator);

    var x = start.x;
    while (x < matrix[start.y].len and std.ascii.isDigit(matrix[start.y][x])) : (x += 1) {
        try digits.append(matrix[start.y][x]);
    }

    return digits.toOwnedSlice();
}

fn touchingSymbol(matrix: [][]const u8, start: Point, len: usize) bool {
    var track = Point.init(
        if (start.x <= 0) 0 else start.x - 1,
        if (start.y <= 0) 1 else start.y - 1,
    );

    while (track.y <= start.y + 1) : (track.y += 2) {
        while (track.x <= start.x + len) : (track.x += 1) {
            if (charAt(matrix, track)) |c| if (symbol(c)) return true;
        }
        track.x = if (start.x <= 0) 0 else start.x - 1;
    }

    if (charAt(matrix, Point.init(track.x, start.y))) |c| if (symbol(c)) return true;
    if (charAt(matrix, Point.init(start.x + len, start.y))) |c| if (symbol(c)) return true;

    return false;
}

fn symbol(c: u8) bool {
    return (c != '.' and !std.ascii.isDigit(c));
}

fn charAt(matrix: [][]const u8, p: Point) ?u8 {
    if (p.y < 0 or p.y >= matrix.len) return null;
    if (p.x < 0 or p.x >= matrix[p.y].len) return null;

    return matrix[p.y][p.x];
}

fn createMatrix(allocator: Allocator) ![][]const u8 {
    var strList = StrList.init(allocator);
    var it = std.mem.tokenizeAny(u8, input, "\n");

    var i: usize = 0;
    while (it.next()) |line| : (i += 1) {
        try strList.append(line);
    }

    return strList.toOwnedSlice();
}
