const std = @import("std");
const input = @embedFile("input/4.txt");

pub fn solve(part: u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const check = gpa.deinit();
        if (check == .leak) @panic("leaked");
    }

    switch (part) {
        1 => try part1(allocator),
        2 => try part2(allocator),
        else => unreachable,
    }
}

fn part1(allocator: std.mem.Allocator) !void {
    var points: usize = 0;
    var lines = std.mem.tokenizeAny(u8, input, "\n");

    while (lines.next()) |line| {
        var sections = std.mem.tokenizeAny(u8, line, ":|");
        std.debug.print("{s}: ", .{sections.next().?});

        const matching = try commonStrings(sections.next().?, sections.next().?, allocator);
        if (matching > 0) {
            const p = std.math.pow(usize, 2, matching - 1);
            points += p;

            std.debug.print("{d}\n", .{p});
        } else std.debug.print("0\n", .{});
    }

    std.debug.print("total points: {d}\n", .{points});
}

fn part2(allocator: std.mem.Allocator) !void {
    var card_map = std.AutoArrayHashMap(usize, usize).init(allocator);
    defer card_map.deinit();

    var card_idx: usize = 0;
    var lines = std.mem.tokenizeAny(u8, input, "\n");

    while (lines.next()) |line| : (card_idx += 1) {
        var sections = std.mem.tokenizeAny(u8, line, ":|");
        _ = sections.next();

        var res = try card_map.getOrPut(card_idx);
        if (res.found_existing) {
            res.value_ptr.* += 1;
        } else res.value_ptr.* = 1;

        const card_qty = res.value_ptr.*;

        var matching = try commonStrings(sections.next().?, sections.next().?, allocator);
        var add_idx: usize = 1;
        while (add_idx <= matching) : (add_idx += 1) {
            var add = try card_map.getOrPut(card_idx + add_idx);
            if (add.found_existing) {
                add.value_ptr.* += card_qty;
            } else add.value_ptr.* = card_qty;
        }
    }

    var card_count: usize = 0;

    card_map.shrinkAndFree(card_idx);
    var cards = card_map.iterator();
    while (cards.next()) |qty| {
        card_count += qty.value_ptr.*;
    }

    std.debug.print("total scratch cards: {d}\n", .{card_count});
}

const StringSet = std.StringHashMap(void);

fn commonStrings(first: []const u8, second: []const u8, allocator: std.mem.Allocator) !usize {
    var win_map = StringSet.init(allocator);
    defer win_map.deinit();

    var winners = std.mem.tokenizeAny(u8, first, " ");
    while (winners.next()) |num| {
        try win_map.put(num, {});
    }

    var matching: usize = 0;
    var possibles = std.mem.tokenizeAny(u8, second, " ");
    while (possibles.next()) |possible| {
        if (win_map.contains(possible)) matching += 1;
    }

    return matching;
}
