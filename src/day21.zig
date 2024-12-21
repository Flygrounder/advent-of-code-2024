const std = @import("std");
const utils = @import("utils.zig");

const State = struct {
    robot1: Position,
    robot2: Position,
    robot3: Position,
    position: usize,
};

const Position = struct {
    row: i32,
    column: i32,

    fn equals(self: Position, other: Position) bool {
        return self.row == other.row and self.column == other.column;
    }
};

pub fn part1(allocator: std.mem.Allocator) void {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var result: i32 = 0;
    for (lines.items) |line| {
        const length = bfs(allocator, line.items);
        const number = std.fmt.parseInt(i32, line.items[0 .. line.items.len - 1], 10) catch @panic("");
        std.debug.print("{s} {} {}\n", .{ line.items, length, number });
        result += length * number;
    }

    utils.printlnStdout(allocator, result);
}

pub fn part2(allocator: std.mem.Allocator) void {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);
}

fn bfs(allocator: std.mem.Allocator, code: []const u8) i32 {
    const start = State{
        .robot1 = Position{
            .row = 0,
            .column = 2,
        },
        .robot2 = Position{
            .row = 0,
            .column = 2,
        },
        .robot3 = Position{
            .row = 3,
            .column = 2,
        },
        .position = 0,
    };

    var queue = std.ArrayList(State).init(allocator);
    defer queue.deinit();

    queue.append(start) catch @panic("");

    var dist = std.AutoHashMap(State, i32).init(allocator);
    defer dist.deinit();

    dist.put(start, 0) catch @panic("");

    var neighbours = std.ArrayList(State).init(allocator);
    defer neighbours.deinit();

    var i: usize = 0;
    while (i < queue.items.len) {
        const cur = queue.items[i];
        i += 1;
        if (cur.position == code.len) {
            return dist.get(cur) orelse @panic("");
        }
        const cur_dist = dist.get(cur) orelse @panic("");
        neighbours.resize(0) catch @panic("");
        getNeighbours(cur, code, &neighbours);
        for (neighbours.items) |neighbour| {
            if (!dist.contains(neighbour)) {
                dist.put(neighbour, cur_dist + 1) catch @panic("");
                queue.append(neighbour) catch @panic("");
            }
        }
    }
    @panic("");
}

fn getNeighbours(state: State, code: []const u8, out: *std.ArrayList(State)) void {
    const directional = state.robot1;
    const candidates = [_]Position{
        .{ .row = directional.row - 1, .column = directional.column },
        .{ .row = directional.row + 1, .column = directional.column },
        .{ .row = directional.row, .column = directional.column - 1 },
        .{ .row = directional.row, .column = directional.column + 1 },
    };
    for (candidates) |candidate| {
        if (isValidDirectional(candidate)) {
            out.append(State{
                .robot1 = candidate,
                .robot2 = state.robot2,
                .robot3 = state.robot3,
                .position = state.position,
            }) catch @panic("");
        }
    }
    if (state.robot1.row == 0 and state.robot1.column == 2) {
        if (state.robot2.row == 0 and state.robot2.column == 2) {
            if (state.position < code.len and getNumericChar(state.robot3) == code[state.position]) {
                const position = State{
                    .robot1 = state.robot1,
                    .robot2 = state.robot2,
                    .robot3 = state.robot3,
                    .position = state.position + 1,
                };
                out.append(position) catch @panic("");
            }
            return;
        }
        const candidate = applyDirectional(state.robot2, state.robot3);
        if (isValidNumeric(candidate)) {
            out.append(State{
                .robot1 = state.robot1,
                .robot2 = state.robot2,
                .robot3 = candidate,
                .position = state.position,
            }) catch @panic("");
        }
        return;
    }
    const candidate = applyDirectional(state.robot1, state.robot2);
    if (isValidDirectional(candidate)) {
        out.append(State{
            .robot1 = state.robot1,
            .robot2 = candidate,
            .robot3 = state.robot3,
            .position = state.position,
        }) catch @panic("");
    }
}

fn applyDirectional(directional: Position, position: Position) Position {
    if (directional.row == 0 and directional.column == 1) {
        return Position{
            .row = position.row - 1,
            .column = position.column,
        };
    } else if (directional.row == 1 and directional.column == 0) {
        return Position{
            .row = position.row,
            .column = position.column - 1,
        };
    } else if (directional.row == 1 and directional.column == 1) {
        return Position{
            .row = position.row + 1,
            .column = position.column,
        };
    } else {
        return Position{
            .row = position.row,
            .column = position.column + 1,
        };
    }
}

fn isValidNumeric(candidate: Position) bool {
    return (0 <= candidate.row and candidate.row < 4 and 0 <= candidate.column and candidate.column < 3 and !(candidate.row == 3 and candidate.column == 0));
}

fn isValidDirectional(candidate: Position) bool {
    return (0 <= candidate.row and candidate.row < 2 and 0 <= candidate.column and candidate.column < 3 and !(candidate.row == 0 and candidate.column == 0));
}

fn getNumericChar(position: Position) u8 {
    const positions = [_][3]u8{
        .{ '7', '8', '9' },
        .{ '4', '5', '6' },
        .{ '1', '2', '3' },
        .{ ' ', '0', 'A' },
    };
    return positions[@intCast(position.row)][@intCast(position.column)];
}
