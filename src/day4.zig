const std = @import("std");
const utils = @import("utils.zig");

pub fn part1(allocator: std.mem.Allocator) void {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var result: i32 = 0;
    for (0..lines.items.len) |i| {
        for (0..lines.items[0].items.len) |j| {
            const directions = [_]struct { i32, i32 }{
                .{ -1, -1 },
                .{ -1, 0 },
                .{ -1, 1 },
                .{ 0, -1 },
                .{ 0, 1 },
                .{ 1, -1 },
                .{ 1, 0 },
                .{ 1, 1 },
            };
            for (directions) |direction| {
                if (search(@intCast(i), @intCast(j), lines, "XMAS", direction[0], direction[1])) {
                    result += 1;
                }
            }
        }
    }

    utils.printlnStdout(allocator, result);
}

pub fn part2(allocator: std.mem.Allocator) void {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var result: i32 = 0;
    for (0..lines.items.len) |i| {
        for (0..lines.items[0].items.len) |j| {
            const x: i32 = @intCast(i);
            const y: i32 = @intCast(j);
            const directions = [_]struct { i32, i32 }{
                .{ -1, -1 },
                .{ -1, 1 },
                .{ 1, -1 },
                .{ 1, 1 },
            };
            var count: i32 = 0;
            for (directions) |direction| {
                const dx = direction[0];
                const dy = direction[1];
                if (search(x - dx, y - dy, lines, "MAS", dx, dy)) {
                    count += 1;
                }
            }
            if (count == 2) {
                result += 1;
            }
        }
    }

    utils.printlnStdout(allocator, result);
}

fn search(x: i32, y: i32, lines: std.ArrayList(std.ArrayList(u8)), pattern: []const u8, dx: i32, dy: i32) bool {
    var i: usize = 0;
    var cx = x;
    var cy = y;
    while (0 <= cx and cx < lines.items.len and 0 <= cy and cy < lines.items[0].items.len and i < pattern.len and lines.items[@intCast(cx)].items[@intCast(cy)] == pattern[i]) {
        i += 1;
        cx += dx;
        cy += dy;
    }
    return i == pattern.len;
}
