const std = @import("std");
const utils = @import("utils.zig");

const length = 71;
const bytes = 1024;

const Position = struct {
    x: i32,
    y: i32,
};

pub fn part1(allocator: std.mem.Allocator) void {
    const input = readInput(allocator);
    defer input.deinit();

    var field = std.ArrayList(std.ArrayList(bool)).init(allocator);
    defer {
        for (field.items) |row| {
            row.deinit();
        }
        field.deinit();
    }

    for (0..length) |_| {
        var cur = std.ArrayList(bool).init(allocator);
        for (0..length) |_| {
            cur.append(true) catch @panic("");
        }
        field.append(cur) catch @panic("");
    }

    for (0..bytes) |i| {
        const cur = input.items[i];
        field.items[@intCast(cur.y)].items[@intCast(cur.x)] = false;
    }

    const result = bfs(allocator, field).?;

    utils.printlnStdout(allocator, result);
}

pub fn part2(allocator: std.mem.Allocator) void {
    const input = readInput(allocator);
    defer input.deinit();

    var field = std.ArrayList(std.ArrayList(bool)).init(allocator);
    defer {
        for (field.items) |row| {
            row.deinit();
        }
        field.deinit();
    }

    for (0..length) |_| {
        var cur = std.ArrayList(bool).init(allocator);
        for (0..length) |_| {
            cur.append(true) catch @panic("");
        }
        field.append(cur) catch @panic("");
    }

    for (input.items) |cur| {
        field.items[@intCast(cur.y)].items[@intCast(cur.x)] = false;
        const result = bfs(allocator, field);
        if (result == null) {
            utils.printfStdout(allocator, "{},{}\n", .{ cur.x, cur.y });
            break;
        }
    }
}

fn bfs(allocator: std.mem.Allocator, field: std.ArrayList(std.ArrayList(bool))) ?i32 {
    var i: usize = 0;
    var dist = std.AutoHashMap(Position, i32).init(allocator);
    defer dist.deinit();

    var queue = std.ArrayList(Position).init(allocator);
    defer queue.deinit();

    const start = Position{
        .x = 0,
        .y = 0,
    };
    queue.append(start) catch @panic("");
    dist.put(start, 0) catch @panic("");
    while (i < queue.items.len) {
        const cur = queue.items[i];
        i += 1;
        const neighbours = [_]Position{
            .{
                .x = cur.x - 1,
                .y = cur.y,
            },
            .{
                .x = cur.x,
                .y = cur.y - 1,
            },
            .{
                .x = cur.x + 1,
                .y = cur.y,
            },
            .{
                .x = cur.x,
                .y = cur.y + 1,
            },
        };
        for (neighbours) |neighbour| {
            if (0 <= neighbour.x and neighbour.x < length and 0 <= neighbour.y and neighbour.y < length and field.items[@intCast(neighbour.y)].items[@intCast(neighbour.x)] and !dist.contains(neighbour)) {
                dist.put(neighbour, dist.get(cur).? + 1) catch @panic("");
                queue.append(neighbour) catch @panic("");
            }
        }
    }

    const finish = Position{
        .x = length - 1,
        .y = length - 1,
    };
    return dist.get(finish);
}

fn readInput(allocator: std.mem.Allocator) std.ArrayList(Position) {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var result = std.ArrayList(Position).init(allocator);
    for (lines.items) |line| {
        var it = std.mem.split(u8, line.items, ",");
        const x = std.fmt.parseInt(i32, it.next().?, 10) catch @panic("");
        const y = std.fmt.parseInt(i32, it.next().?, 10) catch @panic("");
        result.append(Position{
            .x = x,
            .y = y,
        }) catch @panic("");
    }
    return result;
}
