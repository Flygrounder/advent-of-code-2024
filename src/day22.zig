const std = @import("std");
const utils = @import("utils.zig");

pub fn part1(allocator: std.mem.Allocator) void {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var result: u64 = 0;
    for (lines.items) |line| {
        var secret = std.fmt.parseInt(u64, line.items, 10) catch @panic("");
        for (0..2000) |_| {
            secret = getNextSecret(secret);
        }
        result += secret;
    }

    utils.printlnStdout(allocator, result);
}

pub fn part2(allocator: std.mem.Allocator) void {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var prices = [_][2001]i32{undefined} ** 2000;

    for (0..lines.items.len) |i| {
        var secret = std.fmt.parseInt(u64, lines.items[i].items, 10) catch @panic("");
        prices[i][0] = @intCast(secret % 10);

        for (1..2001) |j| {
            secret = getNextSecret(secret);
            prices[i][j] = @intCast(secret % 10);
        }
    }

    var profits = std.AutoHashMap([4]i32, i32).init(allocator);
    defer profits.deinit();

    var result: i32 = 0;

    for (0..lines.items.len) |m| {
        var profits_from_buyer = std.AutoHashMap([4]i32, i32).init(allocator);
        defer profits_from_buyer.deinit();

        for (4..2001) |n| {
            const sequence = [4]i32{
                prices[m][n - 3] - prices[m][n - 4],
                prices[m][n - 2] - prices[m][n - 3],
                prices[m][n - 1] - prices[m][n - 2],
                prices[m][n] - prices[m][n - 1],
            };
            if (!profits_from_buyer.contains(sequence)) {
                profits_from_buyer.put(sequence, prices[m][n]) catch @panic("");
            }
        }
        var it = profits_from_buyer.keyIterator();
        while (it.next()) |sequence_ptr| {
            const sequence = sequence_ptr.*;
            const prev = profits.get(sequence) orelse 0;
            const cur = prev + (profits_from_buyer.get(sequence) orelse @panic(""));
            profits.put(sequence, cur) catch @panic("");
            result = @max(result, cur);
        }
    }

    utils.printlnStdout(allocator, result);
}

fn getNextSecret(current: u64) u64 {
    const modulo = 16777216;

    var result = current;
    result = ((result * 64) ^ result) % modulo;
    result = ((result / 32) ^ result) % modulo;
    result = ((result * 2048) ^ result) % modulo;
    return result;
}
