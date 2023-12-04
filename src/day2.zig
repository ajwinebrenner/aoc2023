const std = @import("std");
const input = @embedFile("input/2.txt");

pub fn solve(part: u8) !void {
    switch (part) {
        1 => try part1(),
        2 => try part2(),
        else => std.debug.panic("no part '{d}' found", .{part}),
    }
}

fn part1() !void {
    var pool = DrawPool{
        .red = 12,
        .green = 13,
        .blue = 14,
    };

    var valid_games: u32 = 0;
    var lines = std.mem.tokenizeAny(u8, input, "\n");

    while (lines.next()) |line| {
        var draws = std.mem.tokenizeAny(u8, line, ":;");

        var game = try std.fmt.parseInt(u32, draws.next().?[5..], 10);
        while (draws.next()) |draw| {
            if (!try pool.isValid(draw)) {
                game = 0;
                break;
            }
        }

        valid_games += game;
    }

    std.debug.print("valid games total: {d}\n", .{valid_games});
}

fn part2() !void {
    var power_sum: u32 = 0;
    var lines = std.mem.tokenizeAny(u8, input, "\n");

    while (lines.next()) |line| {
        var draws = std.mem.tokenizeAny(u8, line, ":;");
        _ = draws.next(); // game num

        var pool = DrawPool{
            .red = 0,
            .green = 0,
            .blue = 0,
        };

        while (draws.next()) |draw| {
            try pool.update(draw);
        }

        power_sum += pool.red * pool.green * pool.blue;
    }

    std.debug.print("total power: {d}\n", .{power_sum});
}

const DrawPool = struct {
    red: u32,
    green: u32,
    blue: u32,

    fn isValid(self: *DrawPool, draw: []const u8) !bool {
        var colours = std.mem.tokenizeAny(u8, draw, ",");

        while (colours.next()) |c| {
            if (!switch (c[c.len - 1]) {
                'd' => self.red >= try std.fmt.parseInt(u8, c[1 .. c.len - 4], 10),
                'n' => self.green >= try std.fmt.parseInt(u8, c[1 .. c.len - 6], 10),
                'e' => self.blue >= try std.fmt.parseInt(u8, c[1 .. c.len - 5], 10),
                else => unreachable,
            }) return false;
        }

        return true;
    }

    fn update(self: *DrawPool, draw: []const u8) !void {
        var colours = std.mem.tokenizeAny(u8, draw, ",");

        while (colours.next()) |c| {
            switch (c[c.len - 1]) {
                'd' => self.red = @max(self.red, try std.fmt.parseInt(u8, c[1 .. c.len - 4], 10)),
                'n' => self.green = @max(self.green, try std.fmt.parseInt(u8, c[1 .. c.len - 6], 10)),
                'e' => self.blue = @max(self.blue, try std.fmt.parseInt(u8, c[1 .. c.len - 5], 10)),
                else => unreachable,
            }
        }
    }
};
