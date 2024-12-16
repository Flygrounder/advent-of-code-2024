const std = @import("std");
const utils = @import("utils.zig");

const Input = struct {
    start: Position,
    finish: Position,
    field: std.ArrayList(std.ArrayList(PositionState)),

    fn deinit(self: Input) void {
        for (self.field.items) |row| {
            row.deinit();
        }
        self.field.deinit();
    }
};

const PositionState = enum {
    Blocked,
    Free,
};

const WeightedCharacterState = struct {
    weight: i32,
    state: CharacterState,
};

const CharacterState = struct {
    direction: Direction,
    position: Position,

    fn rotateClockwise(self: CharacterState) CharacterState {
        const direction: Direction = switch (self.direction) {
            .North => .East,
            .East => .South,
            .South => .West,
            .West => .North,
        };
        return CharacterState{
            .direction = direction,
            .position = self.position,
        };
    }

    fn rotateCounterClockwise(self: CharacterState) CharacterState {
        const direction: Direction = switch (self.direction) {
            .North => .West,
            .West => .South,
            .South => .East,
            .East => .North,
        };
        return CharacterState{
            .direction = direction,
            .position = self.position,
        };
    }

    fn forward(self: CharacterState) CharacterState {
        const position = switch (self.direction) {
            .North => Position{ .x = self.position.x - 1, .y = self.position.y },
            .East => Position{ .x = self.position.x, .y = self.position.y + 1 },
            .South => Position{ .x = self.position.x + 1, .y = self.position.y },
            .West => Position{ .x = self.position.x, .y = self.position.y - 1 },
        };
        return CharacterState{
            .direction = self.direction,
            .position = position,
        };
    }
};

const Position = struct {
    x: i32,
    y: i32,
};

const Direction = enum {
    North,
    East,
    South,
    West,
};

pub fn part1(allocator: std.mem.Allocator) void {
    const input = readInput(allocator);
    defer input.deinit();

    var dist = dijkstra(allocator, input, CharacterState{
        .position = input.start,
        .direction = .East,
    });
    defer dist.deinit();

    var result: i32 = std.math.maxInt(i32);

    for ([_]Direction{ .North, .East, .South, .West }) |direction| {
        result = @min(result, dist.get(CharacterState{
            .direction = direction,
            .position = input.finish,
        }) orelse std.math.maxInt(i32));
    }

    utils.printlnStdout(allocator, result);
}

pub fn part2(allocator: std.mem.Allocator) void {
    const input = readInput(allocator);
    defer input.deinit();

    var dist_start = dijkstra(allocator, input, CharacterState{
        .position = input.start,
        .direction = .East,
    });
    defer dist_start.deinit();

    var best: i32 = std.math.maxInt(i32);

    for ([_]Direction{ .North, .East, .South, .West }) |direction| {
        best = @min(best, dist_start.get(CharacterState{
            .direction = direction,
            .position = input.finish,
        }) orelse std.math.maxInt(i32));
    }

    const directions = [_]Direction{ .North, .East, .South, .West };
    var dist_finish = std.ArrayList(std.AutoHashMap(CharacterState, i32)).init(allocator);
    defer {
        for (0..dist_finish.items.len) |i| {
            dist_finish.items[i].deinit();
        }
        dist_finish.deinit();
    }

    for (0..directions.len) |i| {
        dist_finish.append(dijkstra(allocator, input, CharacterState{
            .direction = directions[i],
            .position = input.finish,
        })) catch @panic("");
    }

    var result: i32 = 0;
    for (0..input.field.items.len) |i| {
        for (0..input.field.items[0].items.len) |j| {
            if (input.field.items[i].items[j] == .Blocked) {
                continue;
            }
            var found: i32 = std.math.maxInt(i32);
            for (0..directions.len) |k| {
                const position = Position{
                    .x = @intCast(i),
                    .y = @intCast(j),
                };
                for (0..directions.len) |p| {
                    found = @min(found, dist_start.get(CharacterState{
                        .direction = directions[k],
                        .position = position,
                    }).? + dist_finish.items[p].get(CharacterState{ .direction = directions[@mod(k + 2, directions.len)], .position = position }).?);
                }
            }
            if (found == best) {
                result += 1;
            }
        }
    }

    utils.printlnStdout(allocator, result);
}

fn dijkstra(allocator: std.mem.Allocator, input: Input, start: CharacterState) std.AutoHashMap(CharacterState, i32) {
    var dist = std.AutoHashMap(CharacterState, i32).init(allocator);

    var queue = std.AutoHashMap(WeightedCharacterState, void).init(allocator);
    defer queue.deinit();

    queue.put(WeightedCharacterState{ .weight = 0, .state = start }, {}) catch @panic("");

    dist.put(start, 0) catch @panic("");

    while (queue.count() > 0) {
        var it = queue.keyIterator();
        const entry = it.next().?.*;
        std.debug.assert(queue.remove(entry));
        const neighbours = [_]WeightedCharacterState{
            WeightedCharacterState{ .weight = 1000, .state = entry.state.rotateClockwise() },
            WeightedCharacterState{ .weight = 1000, .state = entry.state.rotateCounterClockwise() },
            WeightedCharacterState{ .weight = 1, .state = entry.state.forward() },
        };
        for (neighbours) |neighbour| {
            const x = neighbour.state.position.x;
            const y = neighbour.state.position.y;
            if (0 <= x and x < input.field.items.len and 0 <= y and y < input.field.items[0].items.len and input.field.items[@intCast(x)].items[@intCast(y)] == .Free) {
                const weight = entry.weight + neighbour.weight;
                const cur = dist.get(neighbour.state) orelse std.math.maxInt(i32);
                if (weight < cur) {
                    _ = queue.remove(WeightedCharacterState{
                        .weight = cur,
                        .state = neighbour.state,
                    });
                    queue.put(WeightedCharacterState{
                        .weight = weight,
                        .state = neighbour.state,
                    }, {}) catch @panic("");
                    dist.put(neighbour.state, weight) catch @panic("");
                }
            }
        }
    }

    return dist;
}

fn readInput(allocator: std.mem.Allocator) Input {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var start: ?Position = null;
    var finish: ?Position = null;

    var field = std.ArrayList(std.ArrayList(PositionState)).init(allocator);
    for (0..lines.items.len) |i| {
        const line = lines.items[i];
        var cur = std.ArrayList(PositionState).init(allocator);
        for (0..line.items.len) |j| {
            const pos = line.items[j];
            if (pos == '#') {
                cur.append(.Blocked) catch @panic("");
            } else {
                cur.append(.Free) catch @panic("");
            }
            if (pos == 'S') {
                start = Position{
                    .x = @intCast(i),
                    .y = @intCast(j),
                };
            }
            if (pos == 'E') {
                finish = Position{
                    .x = @intCast(i),
                    .y = @intCast(j),
                };
            }
        }
        field.append(cur) catch @panic("");
    }

    return Input{
        .start = start.?,
        .finish = finish.?,
        .field = field,
    };
}
