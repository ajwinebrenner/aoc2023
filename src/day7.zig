const std = @import("std");
const Gpa = std.heap.GeneralPurposeAllocator(.{});
const input = @embedFile("input/7.txt");
const stdout = std.io.getStdOut().writer();

pub fn solve(part: u8) !void {
    var gpa = Gpa{};
    const allocator = gpa.allocator();

    var hand_map = std.AutoHashMap(HandType, HandList).init(allocator);
    defer {
        var it = hand_map.valueIterator();
        while (it.next()) |list| {
            list.deinit();
        }
        hand_map.deinit();
    }

    const jokers = (part == 2);

    var lines = std.mem.tokenizeAny(u8, input, "\n");
    var line_count: usize = 0;
    while (lines.next()) |line| {
        const hand = try lineToHand(line);

        var res = try hand_map.getOrPut(try hand.getType(jokers));
        if (!res.found_existing) {
            res.value_ptr.* = HandList.init(allocator);
        }

        try res.value_ptr.append(hand);
        line_count += 1;
    }

    var winnings: u64 = 0;
    for (std.enums.values(HandType)) |t| {
        var list = hand_map.get(t) orelse continue;
        std.mem.sortUnstable(Hand, list.items, jokers, rankDesc);

        for (list.items) |hand| {
            winnings += hand.bid * line_count;
            line_count -= 1;
        }
    }

    try stdout.print("winnings: {d}\n", .{winnings});
}

const HandList = std.ArrayList(Hand);

fn lineToHand(line: []const u8) !Hand {
    var hand = Hand{
        .cards = undefined,
        .bid = undefined,
    };

    var parts = std.mem.tokenizeAny(u8, line, &std.ascii.whitespace);
    hand.cards = parts.next() orelse return HandError.NoCards;
    const bid = parts.next() orelse return HandError.NoBid;
    hand.bid = try std.fmt.parseInt(u64, bid, 10);

    return if (hand.cards.len == 5) hand else HandError.TooBig;
}

const Hand = struct {
    cards: []const u8,
    bid: u64,

    const Card = struct {
        face: u8 = 0,
        qty: usize = 0,
    };

    fn cardsDesc(context: void, lhs: Card, rhs: Card) bool {
        _ = context;
        return (lhs.qty > rhs.qty);
    }

    fn getType(hand: *const Hand, jokers: bool) !HandType {
        var j: usize = 0;
        var arr: [5]Card = .{Card{}} ** 5;
        var len: usize = 0;

        hand: for (hand.cards) |v| {
            if (jokers and v == 'J') {
                j += 1;
                continue;
            }

            var i: usize = 0;
            while (arr[i].face != 0) : (i += 1) {
                if (arr[i].face == v) {
                    arr[i].qty += 1;
                    continue :hand;
                }
            }

            if (i >= 5) return HandError.TooBig;

            len += 1;
            arr[i] = Card{
                .face = v,
                .qty = 1,
            };
        }

        std.mem.sortUnstable(Card, arr[0..len], {}, cardsDesc);
        arr[0].qty += j;

        return switch (arr[0].qty) {
            5 => .FiveKind,
            4 => .FourKind,
            3 => if (arr[1].qty >= 2) .FullHouse else .ThreeKind,
            2 => if (arr[1].qty == 2) .TwoPair else .OnePair,
            1 => .HighCard,
            else => HandError.NoCards,
        };
    }
};

const HandError = error{
    NoCards,
    NoBid,
    TooBig,
};

const HandType = enum {
    FiveKind,
    FourKind,
    FullHouse,
    ThreeKind,
    TwoPair,
    OnePair,
    HighCard,
};

fn rankDesc(jokers: bool, lhs: Hand, rhs: Hand) bool {
    const r = if (jokers) ranksJ else ranks;

    for (lhs.cards, 0..) |v, i| {
        const lhr = containsIdx(u8, &r, v).?;
        const rhr = containsIdx(u8, &r, rhs.cards[i]).?;
        if (lhr == rhr) continue;

        return (lhr < rhr);
    }

    unreachable;
}

fn containsIdx(comptime T: type, items: []const T, find: T) ?usize {
    for (items, 0..) |item, i| {
        if (item == find) return i;
    }
    return null;
}

const ranks = [_]u8{
    'A',
    'K',
    'Q',
    'J',
    'T',
    '9',
    '8',
    '7',
    '6',
    '5',
    '4',
    '3',
    '2',
};

const ranksJ = [_]u8{
    'A',
    'K',
    'Q',
    'T',
    '9',
    '8',
    '7',
    '6',
    '5',
    '4',
    '3',
    '2',
    'J',
};
