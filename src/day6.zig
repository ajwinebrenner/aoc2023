const std = @import("std");
const input = @embedFile("input/6.txt");
const Gpa = std.heap.GeneralPurposeAllocator(.{});

pub fn solve(part: u8) !void {
    var gpa = Gpa{};
    const allocator = gpa.allocator();

    switch (part) {
        1 => try part1(allocator),
        2 => try part2(allocator),
        else => unreachable,
    }
}

fn part1(allocator: std.mem.Allocator) !void {
    var product: u64 = 1;

    const records = try parseRecords(allocator);
    for (records.items) |record| {
        product *= record.betterSolutionCount();
    }

    std.debug.print("product of all record solutions: {d}\n", .{product});
}

fn part2(allocator: std.mem.Allocator) !void {
    const record = try parseSingleRecord(allocator);
    std.debug.print("record solutions: {d}\n", .{record.betterSolutionCount()});
}

fn parseRecords(allocator: std.mem.Allocator) !std.ArrayList(Record) {
    var records = std.ArrayList(Record).init(allocator);

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var times = std.mem.tokenizeScalar(u8, lines.next().?, ' ');
    _ = times.next();
    while (times.next()) |time| {
        try records.append(Record{
            .time = try std.fmt.parseInt(u64, time, 10),
            .dist = undefined,
        });
    }

    var dists = std.mem.tokenizeScalar(u8, lines.next().?, ' ');
    _ = dists.next();

    var i: usize = 0;
    while (dists.next()) |dist| : (i += 1) {
        records.items[i].dist = try std.fmt.parseInt(u64, dist, 10);
    }

    if (i != records.items.len) {
        return error.IncompleteRecords;
    }

    return records;
}

fn parseSingleRecord(allocator: std.mem.Allocator) !Record {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var times = std.mem.tokenizeScalar(u8, lines.next().?, ':');
    _ = times.next();

    var timeStr = std.ArrayList(u8).init(allocator);
    defer timeStr.deinit();
    for (times.next().?) |c| if (std.ascii.isDigit(c)) try timeStr.append(c);

    var dists = std.mem.tokenizeScalar(u8, lines.next().?, ':');
    _ = dists.next();

    var distStr = std.ArrayList(u8).init(allocator);
    defer distStr.deinit();
    for (dists.next().?) |c| if (std.ascii.isDigit(c)) try distStr.append(c);

    return Record{
        .time = try std.fmt.parseInt(u64, timeStr.items, 10),
        .dist = try std.fmt.parseInt(u64, distStr.items, 10),
    };
}

const Record = struct {
    time: u64,
    dist: u64,

    fn betterSolutionCount(record: *const Record) u64 {
        const limit = std.math.divCeil(u64, record.time, 2) catch unreachable;
        for (1..limit) |btnTime| {
            const goTime = record.time - btnTime;
            if (btnTime * goTime > record.dist) {
                return 1 + (goTime - btnTime);
            }
        }

        return 0;
    }
};
