const std = @import("std");
const input = @embedFile("input/5.txt");

const Gpa = std.heap.GeneralPurposeAllocator(.{});

pub fn solve(part: u8) !void {
    if (part != 1 and part != 2) {
        return error.InvalidPart;
    }

    var gpa = Gpa{};
    const allocator = gpa.allocator();

    var sections = std.mem.tokenizeSequence(u8, input, "\n\n");
    const seeds = try makeSeeds(part, sections.next().?, allocator);
    defer allocator.free(seeds);

    var mappers = std.ArrayList(Mapper).init(allocator);
    defer mappers.deinit();

    while (sections.next()) |section| {
        try mappers.append(try sectionToMapper(section, allocator));
    }

    for (mappers.items) |*mapper| {
        for (seeds, 0..) |seed, i| {
            seeds[i] = mapper.mapToNext(seed);
        }
        mapper.deinit();
    }

    var lowest: u64 = std.math.maxInt(u64);
    for (seeds) |location| {
        if (location < lowest) {
            lowest = location;
        }
    }

    std.debug.print("lowest location for seed: {d}\n", .{lowest});
}

fn makeSeeds(part: u8, seedStr: []const u8, allocator: std.mem.Allocator) ![]u64 {
    var it = std.mem.tokenizeAny(u8, seedStr, " ");
    _ = it.next();

    var seedList = std.ArrayList(u64).init(allocator);
    while (it.next()) |s| {
        var seed = try std.fmt.parseUnsigned(u64, s, 10);
        if (part == 1) {
            try seedList.append(seed);
        } else {
            const limit = seed + try std.fmt.parseUnsigned(u64, it.next().?, 10);
            while (seed < limit) : (seed += 1) {
                try seedList.append(seed);
            }
        }
    }

    return seedList.toOwnedSlice();
}

fn sectionToMapper(section: []const u8, allocator: std.mem.Allocator) !Mapper {
    var lines = std.mem.tokenizeAny(u8, section, "\n");
    _ = lines.next();

    var mapper = try Mapper.init(allocator);
    while (lines.next()) |line| {
        var i: usize = 0;
        var nums = [_]u64{ 0, 0, 0 };

        var it = std.mem.tokenizeAny(u8, line, " ");
        while (it.next()) |num| : (i += 1) {
            nums[i] = try std.fmt.parseUnsigned(u64, num, 10);
        }

        try mapper.addRange(
            nums[0],
            nums[1],
            nums[2],
        );
    }

    return mapper;
}

const Mapper = struct {
    ranges: std.ArrayList(Range),

    const Range = struct {
        dst: u64,
        src: u64,
        len: u64,
    };

    fn init(allocator: std.mem.Allocator) !Mapper {
        return Mapper{
            .ranges = std.ArrayList(Range).init(allocator),
        };
    }

    fn deinit(m: *Mapper) void {
        m.ranges.deinit();
    }

    // descending order
    fn addRange(m: *Mapper, dst: u64, src: u64, len: u64) !void {
        const range = Range{
            .dst = dst,
            .src = src,
            .len = len,
        };

        for (m.ranges.items, 0..) |*r, i| {
            if (range.src > r.src) {
                try m.ranges.insert(i, range);
                return;
            }
        }

        return m.ranges.append(range);
    }

    fn mapToNext(m: *Mapper, src: u64) u64 {
        for (m.ranges.items) |*range| {
            if (src >= range.src) {
                const diff = src - range.src;
                if (diff < range.len) {
                    return range.dst + diff;
                }

                break;
            }
        }

        return src;
    }
};
