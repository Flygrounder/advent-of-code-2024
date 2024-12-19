const std = @import("std");
const utils = @import("utils.zig");

const Input = struct {
    towels: std.ArrayList(std.ArrayList(u8)),
    patterns: std.ArrayList(std.ArrayList(u8)),

    fn deinit(self: Input) void {
        for (self.towels.items) |towel| {
            towel.deinit();
        }
        self.towels.deinit();
        for (self.patterns.items) |pattern| {
            pattern.deinit();
        }
        self.patterns.deinit();
    }
};

pub fn part1(allocator: std.mem.Allocator) void {
    solve(allocator, false);
}

pub fn part2(allocator: std.mem.Allocator) void {
    solve(allocator, true);
}

fn solve(allocator: std.mem.Allocator, is_part2: bool) void {
    const input = readInput(allocator);
    defer input.deinit();

    var cache = std.StringHashMap(i64).init(allocator);
    defer cache.deinit();

    var result: i64 = 0;
    for (input.patterns.items) |pattern| {
        const permutations = countPermutations(pattern.items, input.towels, &cache);
        if (is_part2) {
            result += permutations;
        } else if (permutations > 0) {
            result += 1;
        }
    }

    utils.printlnStdout(allocator, result);
}

fn readInput(allocator: std.mem.Allocator) Input {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var it = std.mem.split(u8, lines.items[0].items, ", ");
    var towels = std.ArrayList(std.ArrayList(u8)).init(allocator);
    while (it.next()) |towel| {
        var cur = std.ArrayList(u8).init(allocator);
        for (towel) |color| {
            cur.append(color) catch @panic("");
        }
        towels.append(cur) catch @panic("");
    }

    var patterns = std.ArrayList(std.ArrayList(u8)).init(allocator);
    for (lines.items[2..]) |line| {
        var cur = std.ArrayList(u8).init(allocator);
        for (line.items) |color| {
            cur.append(color) catch @panic("");
        }
        patterns.append(cur) catch @panic("");
    }

    return Input{
        .towels = towels,
        .patterns = patterns,
    };
}

fn countPermutations(pattern: []const u8, towels: std.ArrayList(std.ArrayList(u8)), cache: *std.StringHashMap(i64)) i64 {
    if (cache.get(pattern)) |value| {
        return value;
    }
    if (pattern.len == 0) {
        cache.put(pattern, 1) catch @panic("");
        return 1;
    }
    var result: i64 = 0;
    for (towels.items) |towel| {
        if (std.mem.startsWith(u8, pattern, towel.items)) {
            result += countPermutations(pattern[towel.items.len..], towels, cache);
        }
    }
    cache.put(pattern, result) catch @panic("");
    return result;
}
