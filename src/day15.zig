const std = @import("std");
const utils = @import("utils.zig");

pub fn part1(allocator: std.mem.Allocator) void {
    solve(allocator, false);
}

pub fn part2(allocator: std.mem.Allocator) void {
    solve(allocator, true);
}

fn solve(allocator: std.mem.Allocator, wide: bool) void {
    var state = readInput(allocator, wide);
    defer state.deinit();

    while (state.move()) {}

    var result: usize = 0;
    for (0..state.field.items.len) |i| {
        const row = state.field.items[i];
        for (0..row.items.len) |j| {
            const pos = row.items[j];
            if (pos == .Box or pos == .Lbox) {
                result += 100 * i + j;
            }
        }
    }

    utils.printlnStdout(allocator, result);
}

const State = struct {
    field: std.ArrayList(std.ArrayList(PositionState)),
    moves: std.ArrayList(Direction),
    position: Position,
    cur: usize,

    fn move(self: *State) bool {
        if (self.cur == self.moves.items.len) {
            return false;
        }
        const direction = self.moves.items[self.cur];
        const next = apply(self.position, direction);
        const success = self.moveRec(next, direction, false, false);
        if (success) {
            self.position = next;
        }
        self.cur += 1;
        return true;
    }

    fn moveRec(self: *State, position: Position, direction: Direction, check: bool, single_box: bool) bool {
        const cur = self.getState(position);
        if (cur == .Free) {
            return true;
        }
        if (cur == .Blocked) {
            return false;
        }
        if (cur == .Box or single_box or direction == .Left or direction == .Right) {
            const next = apply(position, direction);
            const success = self.moveRec(next, direction, check, false);
            if (success and !check) {
                self.setState(position, .Free);
                self.setState(next, cur);
            }
            return success;
        }
        if (cur == .Lbox) {
            const rbox = apply(position, .Right);
            const next = apply(position, direction);
            const success = self.moveRec(next, direction, true, false) and self.moveRec(rbox, direction, true, true);
            if (success and !check) {
                _ = self.moveRec(position, direction, false, true);
                _ = self.moveRec(rbox, direction, false, true);
            }
            return success;
        }
        if (cur == .Rbox) {
            return self.moveRec(apply(position, .Left), direction, check, false);
        }
        @panic("");
    }

    fn getState(self: *State, position: Position) PositionState {
        return self.field.items[@intCast(position.x)].items[@intCast(position.y)];
    }

    fn setState(self: *State, position: Position, state: PositionState) void {
        self.field.items[@intCast(position.x)].items[@intCast(position.y)] = state;
    }

    fn deinit(self: State) void {
        for (self.field.items) |line| {
            line.deinit();
        }
        self.field.deinit();
        self.moves.deinit();
    }
};

fn apply(position: Position, direction: Direction) Position {
    return switch (direction) {
        .Up => Position{
            .x = position.x - 1,
            .y = position.y,
        },
        .Right => Position{
            .x = position.x,
            .y = position.y + 1,
        },
        .Down => Position{
            .x = position.x + 1,
            .y = position.y,
        },
        .Left => Position{
            .x = position.x,
            .y = position.y - 1,
        },
    };
}

const Position = struct {
    x: i32,
    y: i32,
};

const PositionState = enum {
    Free,
    Box,
    Lbox,
    Rbox,
    Blocked,
};

const Direction = enum {
    Up,
    Right,
    Down,
    Left,
};

fn readInput(allocator: std.mem.Allocator, wide: bool) State {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var moves_mode = false;
    var moves = std.ArrayList(Direction).init(allocator);
    var field = std.ArrayList(std.ArrayList(PositionState)).init(allocator);
    var x: ?i32 = null;
    var y: ?i32 = null;
    for (0..lines.items.len) |i| {
        const line = lines.items[i];
        if (line.items.len == 0) {
            moves_mode = true;
            continue;
        }
        if (moves_mode) {
            for (line.items) |cell| {
                const direction: Direction = switch (cell) {
                    '^' => .Up,
                    '>' => .Right,
                    'v' => .Down,
                    '<' => .Left,
                    else => @panic(""),
                };
                moves.append(direction) catch @panic("");
            }
        } else {
            var cur = std.ArrayList(PositionState).init(allocator);
            for (0..line.items.len) |j| {
                const cell = line.items[j];
                const position: PositionState = switch (cell) {
                    '.' => .Free,
                    '@' => .Free,
                    'O' => .Box,
                    '#' => .Blocked,
                    else => {
                        @panic("");
                    },
                };
                cur.append(position) catch @panic("");
                if (wide) {
                    cur.append(position) catch @panic("");
                    if (position == .Box) {
                        cur.items[cur.items.len - 2] = .Lbox;
                        cur.items[cur.items.len - 1] = .Rbox;
                    }
                }
                if (cell == '@') {
                    if (wide) {
                        x = @intCast(i);
                        y = @intCast(j * 2);
                    } else {
                        x = @intCast(i);
                        y = @intCast(j);
                    }
                }
            }
            field.append(cur) catch @panic("");
        }
    }

    return State{
        .cur = 0,
        .field = field,
        .moves = moves,
        .position = Position{
            .x = x.?,
            .y = y.?,
        },
    };
}
