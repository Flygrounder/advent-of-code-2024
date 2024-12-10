const std = @import("std");
const utils = @import("utils.zig");

pub fn part1(allocator: std.mem.Allocator) void {
    solve(allocator, true);
}

pub fn part2(allocator: std.mem.Allocator) void {
    solve(allocator, false);
}

fn solve(allocator: std.mem.Allocator, is_part1: bool) void {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var result: i32 = 0;
    for (0..lines.items.len) |i| {
        for (0..lines.items[0].items.len) |j| {
            var used = std.ArrayList(Pair).init(allocator);
            score(@intCast(i), @intCast(j), '0', lines, &used, is_part1);
            result += @intCast(used.items.len);
            used.deinit();
        }
    }

    utils.printlnStdout(allocator, result);
}

fn score(x: i32, y: i32, cur: i32, lines: std.ArrayList(std.ArrayList(u8)), used: *std.ArrayList(Pair), is_part1: bool) void {
    if (x < 0 or x >= lines.items.len or y < 0 or y >= lines.items[0].items.len or lines.items[@intCast(x)].items[@intCast(y)] != cur) {
        return;
    }
    if (cur == '9') {
        if (is_part1) {
            for (used.items) |pair| {
                if (pair.x == x and pair.y == y) {
                    return;
                }
            }
        }
        used.append(Pair{
            .x = x,
            .y = y,
        }) catch @panic("");
    }
    score(x - 1, y, cur + 1, lines, used, is_part1);
    score(x, y - 1, cur + 1, lines, used, is_part1);
    score(x + 1, y, cur + 1, lines, used, is_part1);
    score(x, y + 1, cur + 1, lines, used, is_part1);
}

const Pair = struct {
    x: i32,
    y: i32,
};
