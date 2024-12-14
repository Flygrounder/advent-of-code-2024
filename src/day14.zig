const std = @import("std");
const utils = @import("utils.zig");

const field_x: i64 = 101;
const field_y: i64 = 103;

const Robot = struct {
    position: Pair,
    velocity: Pair,
};

const Pair = struct {
    x: i64,
    y: i64,
};

pub fn part1(allocator: std.mem.Allocator) void {
    const duration: i64 = 100;

    const robots = readInput(allocator);
    defer robots.deinit();

    var quadrants = [4]i64{ 0, 0, 0, 0 };
    for (robots.items) |robot| {
        const x = @mod(robot.position.x + robot.velocity.x * duration, field_x);
        const y = @mod(robot.position.y + robot.velocity.y * duration, field_y);
        const quadrant = detectQuadrant(x, y);
        if (quadrant) |i| {
            quadrants[i] += 1;
        }
    }

    const result = quadrants[0] * quadrants[1] * quadrants[2] * quadrants[3];
    utils.printlnStdout(allocator, result);
}

pub fn part2(allocator: std.mem.Allocator) void {
    const robots = readInput(allocator);
    defer robots.deinit();

    var time: i64 = 0;
    while (true) {
        var field = std.ArrayList(std.ArrayList(i64)).init(allocator);
        var used = std.ArrayList(std.ArrayList(bool)).init(allocator);
        for (0..field_x) |_| {
            var cur_field = std.ArrayList(i64).init(allocator);
            var cur_used = std.ArrayList(bool).init(allocator);
            for (0..field_y) |_| {
                cur_field.append(0) catch @panic("");
                cur_used.append(false) catch @panic("");
            }
            field.append(cur_field) catch @panic("");
            used.append(cur_used) catch @panic("");
        }
        for (robots.items) |robot| {
            const x = @mod(robot.position.x + robot.velocity.x * time, field_x);
            const y = @mod(robot.position.y + robot.velocity.y * time, field_y);
            field.items[@intCast(x)].items[@intCast(y)] += 1;
        }
        var max_component: i64 = 0;
        for (0..field_x) |i| {
            for (0..field_y) |j| {
                if (field.items[i].items[j] > 0 and !used.items[i].items[j]) {
                    const cur = dfs(@intCast(i), @intCast(j), field, used);
                    if (cur > max_component) {
                        max_component = cur;
                    }
                }
            }
        }
        time += 1;
        if (max_component <= robots.items.len / 4) {
            for (field.items) |line| {
                line.deinit();
            }
            field.deinit();
            for (used.items) |line| {
                line.deinit();
            }
            used.deinit();
            continue;
        }
        for (0..field_y) |j| {
            for (0..field_x) |i| {
                if (field.items[i].items[j] > 0) {
                    std.debug.print("#", .{});
                } else {
                    std.debug.print(".", .{});
                }
            }
            std.debug.print("\n", .{});
        }
        for (field.items) |line| {
            line.deinit();
        }
        field.deinit();
        for (used.items) |line| {
            line.deinit();
        }
        used.deinit();
        break;
    }

    utils.printlnStdout(allocator, time - 1);
}

fn detectQuadrant(x: i64, y: i64) ?usize {
    if (x == @divFloor(field_x, 2) or y == @divFloor(field_y, 2)) {
        return null;
    }
    const left = x > @divFloor(field_x, 2);
    const top = y > @divFloor(field_y, 2);

    if (!left and top) {
        return 0;
    } else if (left and top) {
        return 1;
    } else if (left and !top) {
        return 2;
    } else {
        return 3;
    }
}

fn readInput(allocator: std.mem.Allocator) std.ArrayList(Robot) {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var robots = std.ArrayList(Robot).init(allocator);
    for (lines.items) |line| {
        var parts = std.mem.split(u8, line.items, " ");
        const position = parsePair(parts.next().?);
        const velocity = parsePair(parts.next().?);
        robots.append(Robot{
            .position = position,
            .velocity = velocity,
        }) catch @panic("");
    }

    return robots;
}

fn parsePair(input: []const u8) Pair {
    var operands = std.mem.split(u8, input, "=");
    _ = operands.next();
    var numbers = std.mem.split(u8, operands.next().?, ",");
    const x = std.fmt.parseInt(i64, numbers.next().?, 10) catch @panic("");
    const y = std.fmt.parseInt(i64, numbers.next().?, 10) catch @panic("");
    return Pair{
        .x = x,
        .y = y,
    };
}

fn dfs(x: i64, y: i64, field: std.ArrayList(std.ArrayList(i64)), used: std.ArrayList(std.ArrayList(bool))) i64 {
    var res: i64 = field.items[@intCast(x)].items[@intCast(y)];
    used.items[@intCast(x)].items[@intCast(y)] = true;
    const candidates = [_]struct { i64, i64 }{
        .{ x - 1, y - 1 }, .{ x - 1, y },     .{ x - 1, y + 1 },
        .{ x, y - 1 },     .{ x, y + 1 },     .{ x + 1, y - 1 },
        .{ x + 1, y },     .{ x + 1, y + 1 },
    };
    for (candidates) |candidate| {
        if (0 <= candidate[0] and candidate[0] < field_x and 0 <= candidate[1] and candidate[1] < field_y and field.items[@intCast(candidate[0])].items[@intCast(candidate[1])] > 0 and !used.items[@intCast(candidate[0])].items[@intCast(candidate[1])]) {
            res += dfs(candidate[0], candidate[1], field, used);
        }
    }
    return res;
}
