const std = @import("std");
const utils = @import("utils.zig");

pub fn part1(allocator: std.mem.Allocator) void {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var line: usize = 0;
    var keys = std.ArrayList([5]usize).init(allocator);
    defer keys.deinit();

    var locks = std.ArrayList([5]usize).init(allocator);
    defer locks.deinit();

    while (line < lines.items.len) {
        if (std.mem.allEqual(u8, lines.items[line].items, '#')) {
            var heights = [_]usize{0} ** 5;
            for (0..5) |j| {
                var k: usize = 1;
                while (lines.items[line + k].items[j] != '.') {
                    heights[j] += 1;
                    k += 1;
                }
            }
            locks.append(heights) catch @panic("");
        } else {
            var heights = [_]usize{6} ** 5;
            for (0..5) |j| {
                var k: usize = 0;
                while (lines.items[line + k].items[j] != '#') {
                    heights[j] -= 1;
                    k += 1;
                }
            }
            keys.append(heights) catch @panic("");
        }
        line += 8;
    }

    var result: i32 = 0;
    for (0..locks.items.len) |i| {
        for (0..keys.items.len) |j| {
            for (0..5) |k| {
                if (locks.items[i][k] + keys.items[j][k] > 5) {
                    break;
                }
            } else {
                result += 1;
            }
        }
    }

    utils.printlnStdout(allocator, result);
}
