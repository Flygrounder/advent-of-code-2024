const std = @import("std");
const utils = @import("utils.zig");

const Region = struct {
    area: u32,
    perimeter: u32,
};

const Pair = struct {
    first: i32,
    second: i32,
};

pub fn part1(allocator: std.mem.Allocator) void {
    solve(allocator, true);
}

pub fn part2(allocator: std.mem.Allocator) void {
    solve(allocator, false);
}

fn solve(allocator: std.mem.Allocator, is_part1: bool) void {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    const n = lines.items.len;
    const m = lines.items[0].items.len;

    var used = std.ArrayList(std.ArrayList(bool)).init(allocator);
    for (0..n) |_| {
        var cur = std.ArrayList(bool).init(allocator);
        for (0..m) |_| {
            cur.append(false) catch @panic("");
        }
        used.append(cur) catch @panic("");
    }

    defer {
        for (used.items) |cur| {
            cur.deinit();
        }
        used.deinit();
    }

    var result: u32 = 0;
    for (0..n) |i| {
        for (0..m) |j| {
            if (!used.items[i].items[j]) {
                const region = processRegion(@intCast(i), @intCast(j), lines, used, is_part1);
                result += region.perimeter * region.area;
            }
        }
    }

    utils.printlnStdout(allocator, result);
}

fn processRegion(x: i32, y: i32, map: std.ArrayList(std.ArrayList(u8)), used: std.ArrayList(std.ArrayList(bool)), is_part1: bool) Region {
    used.items[@intCast(x)].items[@intCast(y)] = true;
    var current = Region{
        .area = 1,
        .perimeter = 0,
    };
    const candidates = getCandidates(x, y);
    const free_sides = getFreeSides(x, y, map);
    var new_free_sides = free_sides;
    for (0..4) |i| {
        const candidate = candidates[i];
        const nx = candidate.first;
        const ny = candidate.second;
        if (!free_sides[i]) {
            if (!used.items[@intCast(nx)].items[@intCast(ny)]) {
                const next = processRegion(@intCast(nx), @intCast(ny), map, used, is_part1);
                current.area += next.area;
                current.perimeter += next.perimeter;
            }
            for (0..4) |j| {
                const blocks = nx < x or nx == x and ny < y;
                const other_free_sides = getFreeSides(nx, ny, map);
                new_free_sides[j] = new_free_sides[j] and (is_part1 or !blocks or !other_free_sides[j]);
            }
        }
    }
    for (0..4) |i| {
        if (new_free_sides[i]) {
            current.perimeter += 1;
        }
    }
    return current;
}

fn getFreeSides(x: i32, y: i32, map: std.ArrayList(std.ArrayList(u8))) [4]bool {
    const candidates = getCandidates(x, y);
    var result = [4]bool{ false, false, false, false };
    for (0..4) |i| {
        const candidate = candidates[i];
        const nx = candidate.first;
        const ny = candidate.second;
        result[i] = nx < 0 or nx >= map.items.len or ny < 0 or ny >= map.items[0].items.len or map.items[@intCast(nx)].items[@intCast(ny)] != map.items[@intCast(x)].items[@intCast(y)];
    }
    return result;
}

fn getCandidates(x: i32, y: i32) [4]Pair {
    return [4]Pair{
        .{ .first = x - 1, .second = y },
        .{ .first = x, .second = y - 1 },
        .{ .first = x + 1, .second = y },
        .{ .first = x, .second = y + 1 },
    };
}
