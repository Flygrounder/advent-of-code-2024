const std = @import("std");
const utils = @import("utils.zig");

const State = struct {
    cx: i32,
    cy: i32,
    direction: Direction,
    visited: i32,
    history: std.ArrayList(GuardState),
    field: std.ArrayList(std.ArrayList(PositionState)),
    loop: bool,

    fn deepCopy(self: State, allocator: std.mem.Allocator) State {
        var history = std.ArrayList(GuardState).init(allocator);
        for (self.history.items) |entry| {
            history.append(entry) catch @panic("");
        }
        var field = std.ArrayList(std.ArrayList(PositionState)).init(allocator);
        for (self.field.items) |row| {
            var cur = std.ArrayList(PositionState).init(allocator);
            for (row.items) |state| {
                cur.append(state) catch @panic("");
            }
            field.append(cur) catch @panic("");
        }
        return State{
            .cx = self.cx,
            .cy = self.cy,
            .direction = self.direction,
            .visited = self.visited,
            .history = history,
            .field = field,
            .loop = self.loop,
        };
    }

    fn moveNext(self: *State) bool {
        const dx: i32 = switch (self.direction) {
            .up => -1,
            .down => 1,
            else => 0,
        };
        const dy: i32 = switch (self.direction) {
            .left => -1,
            .right => 1,
            else => 0,
        };

        const nx = self.cx + dx;
        const ny = self.cy + dy;

        if (0 <= nx and nx < self.field.items.len and 0 <= ny and ny < self.field.items[0].items.len) {
            switch (self.field.items[@intCast(nx)].items[@intCast(ny)]) {
                .blocked => {
                    self.direction = switch (self.direction) {
                        .up => .right,
                        .right => .down,
                        .down => .left,
                        .left => .up,
                    };
                    return true;
                },
                .unvisited => {
                    self.field.items[@intCast(nx)].items[@intCast(ny)] = .visited;
                    self.visited += 1;
                },
                .visited => {
                    for (self.history.items) |entry| {
                        if (entry.cx == nx and entry.cy == ny and self.direction == entry.direction) {
                            self.loop = true;
                            return false;
                        }
                    }
                },
            }
            self.cx = nx;
            self.cy = ny;
            self.history.append(GuardState{
                .cx = nx,
                .cy = ny,
                .direction = self.direction,
            }) catch @panic("");
            return true;
        } else {
            return false;
        }
    }

    fn deinit(self: State) void {
        for (self.field.items) |line| {
            line.deinit();
        }
        self.field.deinit();
        self.history.deinit();
    }
};

const GuardState = struct {
    cx: i32,
    cy: i32,
    direction: Direction,
};

const PositionState = enum {
    unvisited,
    visited,
    blocked,
};

const Direction = enum {
    up,
    right,
    down,
    left,
};

pub fn part1(allocator: std.mem.Allocator) void {
    var state = readInput(allocator);
    defer state.deinit();

    while (state.moveNext()) {}

    utils.printlnStdout(allocator, state.visited);
}

pub fn part2(allocator: std.mem.Allocator) void {
    const init_state = readInput(allocator);
    defer init_state.deinit();

    var state = init_state.deepCopy(allocator);
    defer state.deinit();

    while (state.moveNext()) {}

    var history = state.history;

    var result: i32 = 0;
    outer: for (1..history.items.len) |k| {
        const entry = history.items[k];
        for (history.items[0..k]) |prev| {
            if (prev.cx == entry.cx and prev.cy == entry.cy) {
                continue :outer;
            }
        }
        var cur = init_state.deepCopy(allocator);
        defer cur.deinit();

        cur.field.items[@intCast(entry.cx)].items[@intCast(entry.cy)] = .blocked;

        while (cur.moveNext()) {}

        if (cur.loop) {
            result += 1;
        }
    }

    utils.printlnStdout(allocator, result);
}

fn readInput(allocator: std.mem.Allocator) State {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var field = std.ArrayList(std.ArrayList(PositionState)).init(allocator);

    var cx: i32 = undefined;
    var cy: i32 = undefined;

    for (0..lines.items.len) |i| {
        var cur = std.ArrayList(PositionState).init(allocator);
        for (0..lines.items[i].items.len) |j| {
            const char = lines.items[i].items[j];
            if (char == '^') {
                cx = @intCast(i);
                cy = @intCast(j);
                cur.append(.visited) catch @panic("");
            } else if (char == '.') {
                cur.append(.unvisited) catch @panic("");
            } else {
                cur.append(.blocked) catch @panic("");
            }
        }
        field.append(cur) catch @panic("");
    }

    var history = std.ArrayList(GuardState).init(allocator);
    history.append(GuardState{
        .cx = cx,
        .cy = cy,
        .direction = .up,
    }) catch @panic("");

    return State{
        .cx = cx,
        .cy = cy,
        .direction = .up,
        .field = field,
        .visited = 1,
        .loop = false,
        .history = history,
    };
}
