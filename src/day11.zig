const std = @import("std");
const utils = @import("utils.zig");

pub fn part1(allocator: std.mem.Allocator) void {
    solve(allocator, 25);
}

pub fn part2(allocator: std.mem.Allocator) void {
    solve(allocator, 75);
}

fn solve(allocator: std.mem.Allocator, iters: usize) void {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var input_splitted = std.mem.split(u8, lines.items[0].items, " ");
    var stones = std.AutoHashMap(u64, u64).init(allocator);
    defer stones.deinit();

    while (input_splitted.next()) |part| {
        const number = std.fmt.parseInt(u64, part, 10) catch @panic("");
        increment_count(&stones, number, 1);
    }

    for (0..iters) |_| {
        var new_stones = std.AutoHashMap(u64, u64).init(allocator);
        var stones_iterator = stones.keyIterator();
        while (stones_iterator.next()) |old_stone| {
            var buffer = std.ArrayList(u64).init(allocator);
            split(old_stone.*, &buffer);
            const old_count = stones.get(old_stone.*) orelse 0;
            for (buffer.items) |new_stone| {
                increment_count(&new_stones, new_stone, old_count);
            }
            buffer.deinit();
        }
        stones.deinit();
        stones = new_stones;
    }

    var result: u64 = 0;
    var stones_iterator = stones.keyIterator();
    while (stones_iterator.next()) |stone| {
        result += stones.get(stone.*) orelse 0;
    }

    utils.printlnStdout(allocator, result);
}

fn split(stone: u64, result: *std.ArrayList(u64)) void {
    if (stone == 0) {
        result.append(1) catch @panic("");
    } else {
        var digits: u64 = 0;
        var power: u64 = 1;
        while (power <= stone) {
            digits += 1;
            power *= 10;
        }
        if (digits % 2 == 0) {
            const half = digits / 2;
            power = 1;
            for (0..@intCast(half)) |_| {
                power *= 10;
            }
            result.append(stone / power) catch @panic("");
            result.append(stone % power) catch @panic("");
        } else {
            result.append(stone * 2024) catch @panic("");
        }
    }
}

fn increment_count(stones: *std.AutoHashMap(u64, u64), key: u64, increment: u64) void {
    const old = stones.get(key) orelse 0;
    stones.put(key, old + increment) catch @panic("");
}
