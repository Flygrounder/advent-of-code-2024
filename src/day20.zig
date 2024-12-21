const std = @import("std");
const utils = @import("utils.zig");

const save_threshold = 100;

const Input = struct {
    start: Position,
    finish: Position,
    field: std.ArrayList(std.ArrayList(bool)),

    fn deinit(self: Input) void {
        for (self.field.items) |row| {
            row.deinit();
        }
        self.field.deinit();
    }
};

const Position = struct {
    row: i32,
    column: i32,
};

pub fn part1(allocator: std.mem.Allocator) void {
    solve(allocator, 2);
}

pub fn part2(allocator: std.mem.Allocator) void {
    solve(allocator, 20);
}

fn solve(allocator: std.mem.Allocator, distance: i32) void {
    const input = readInput(allocator);
    defer input.deinit();

    var dist = std.AutoHashMap(Position, i32).init(allocator);
    defer dist.deinit();
    dist.put(input.start, 0) catch @panic("");
    dfs(input.start, input.field, &dist, input.start);

    var result: i32 = 0;
    for (0..input.field.items.len) |i| {
        for (0..input.field.items[i].items.len) |j| {
            if (!input.field.items[i].items[j]) {
                continue;
            }
            const cur = Position{
                .row = @intCast(i),
                .column = @intCast(j),
            };
            for (0..input.field.items.len) |k| {
                for (0..input.field.items[i].items.len) |l| {
                    if (!input.field.items[k].items[l]) {
                        continue;
                    }
                    const neighbour = Position{
                        .row = @intCast(k),
                        .column = @intCast(l),
                    };
                    const ndist: i32 = @intCast(@abs(cur.row - neighbour.row) + @abs(cur.column - neighbour.column));
                    if (ndist <= distance) {
                        const saved = (dist.get(neighbour) orelse @panic("")) - ((dist.get(cur) orelse @panic("")) + ndist);
                        if (saved >= save_threshold) {
                            result += 1;
                        }
                    }
                }
            }
        }
    }

    utils.printlnStdout(allocator, result);
}

fn dfs(cur: Position, field: std.ArrayList(std.ArrayList(bool)), dist: *std.AutoHashMap(Position, i32), prev: Position) void {
    const neighbours = [_]Position{
        .{ .row = cur.row - 1, .column = cur.column },
        .{ .row = cur.row + 1, .column = cur.column },
        .{ .row = cur.row, .column = cur.column - 1 },
        .{ .row = cur.row, .column = cur.column + 1 },
    };
    for (neighbours) |neighbour| {
        if (0 <= neighbour.row and neighbour.row < field.items.len and 0 <= neighbour.column and neighbour.column < field.items[0].items.len and (neighbour.row != prev.row or neighbour.column != prev.column) and field.items[@intCast(neighbour.row)].items[@intCast(neighbour.column)]) {
            dist.put(neighbour, (dist.get(cur) orelse @panic("")) + 1) catch @panic("");
            dfs(neighbour, field, dist, cur);
        }
    }
}

fn readInput(allocator: std.mem.Allocator) Input {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var start: ?Position = null;
    var finish: ?Position = null;
    var field = std.ArrayList(std.ArrayList(bool)).init(allocator);

    for (0..lines.items.len) |i| {
        var row = std.ArrayList(bool).init(allocator);
        for (0..lines.items[i].items.len) |j| {
            const cur = lines.items[i].items[j];
            row.append(cur != '#') catch @panic("");
            if (cur == 'S') {
                start = Position{
                    .row = @intCast(i),
                    .column = @intCast(j),
                };
            } else if (cur == 'E') {
                finish = Position{
                    .row = @intCast(i),
                    .column = @intCast(j),
                };
            }
        }
        field.append(row) catch @panic("");
    }

    return Input{
        .start = start.?,
        .finish = finish.?,
        .field = field,
    };
}
