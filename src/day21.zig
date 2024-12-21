const std = @import("std");
const utils = @import("utils.zig");

const max_depth = 27;
const cache_buffer_bytes = 1_000_000;

const CachedKeypressCalculator = struct {
    cache: [max_depth]std.StringHashMap(usize),
    allocator: std.mem.Allocator,

    fn calculateLeastKeypresses(self: *CachedKeypressCalculator, input: []const u8, depth: i32, is_numeric: bool) usize {
        if (self.cache[@intCast(depth)].get(input)) |res| {
            return res;
        }
        if (depth == 0) {
            return input.len;
        }
        var result: usize = 0;
        var prev = switch (is_numeric) {
            true => getNumericKeyPosition('A'),
            false => getDirectionalKeyPosition('A'),
        };
        for (input) |char| {
            var best: usize = std.math.maxInt(usize);
            const cur = switch (is_numeric) {
                true => getNumericKeyPosition(char),
                false => getDirectionalKeyPosition(char),
            };
            const diff = Position{
                .row = cur.row - prev.row,
                .column = cur.column - prev.column,
            };

            const row_first = Position{
                .row = cur.row,
                .column = prev.column,
            };
            if (is_numeric and isValidNumeric(row_first) or !is_numeric and isValidDirectional(row_first)) {
                const serialized = serialize_diff(self.allocator, diff, true);
                best = @min(best, self.calculateLeastKeypresses(serialized.items, depth - 1, false));
            }

            const column_first = Position{
                .row = prev.row,
                .column = cur.column,
            };
            if (is_numeric and isValidNumeric(column_first) or !is_numeric and isValidDirectional(column_first)) {
                const serialized = serialize_diff(self.allocator, diff, false);
                best = @min(best, self.calculateLeastKeypresses(serialized.items, depth - 1, false));
            }

            result += best;
            prev = cur;
        }
        self.cache[@intCast(depth)].put(input, result) catch @panic("");
        return result;
    }

    fn init(self: *CachedKeypressCalculator) void {
        for (0..self.cache.len) |i| {
            self.cache[i] = std.StringHashMap(usize).init(self.allocator);
        }
    }

    fn deinit(self: *CachedKeypressCalculator) void {
        for (0..self.cache.len) |i| {
            self.cache[i].deinit();
        }
    }
};

pub fn part1(allocator: std.mem.Allocator) void {
    solve(allocator, 3);
}

pub fn part2(allocator: std.mem.Allocator) void {
    solve(allocator, 26);
}

fn solve(allocator: std.mem.Allocator, robots: i32) void {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var buffer: [cache_buffer_bytes]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const fba_allocator = fba.allocator();

    var calculator = CachedKeypressCalculator{
        .cache = [_]std.StringHashMap(usize){undefined} ** max_depth,
        .allocator = fba_allocator,
    };
    calculator.init();
    defer calculator.deinit();

    var result: i64 = 0;
    for (lines.items) |line| {
        const length: i64 = @intCast(calculator.calculateLeastKeypresses(line.items, robots, true));
        const number = std.fmt.parseInt(i64, line.items[0 .. line.items.len - 1], 10) catch @panic("");
        result += length * number;
    }
    utils.printlnStdout(allocator, result);
}

fn getNumericKeyPosition(key: u8) Position {
    const keypad = [_][3]u8{
        .{ '7', '8', '9' },
        .{ '4', '5', '6' },
        .{ '1', '2', '3' },
        .{ ' ', '0', 'A' },
    };
    return getKeyPosition(key, &keypad);
}

fn getDirectionalKeyPosition(key: u8) Position {
    const keypad = [_][3]u8{
        .{ ' ', '^', 'A' },
        .{ '<', 'v', '>' },
    };
    return getKeyPosition(key, &keypad);
}

fn getKeyPosition(key: u8, keypad: []const [3]u8) Position {
    for (0..keypad.len) |i| {
        for (0..keypad[i].len) |j| {
            if (keypad[i][j] == key) {
                return Position{
                    .row = @intCast(i),
                    .column = @intCast(j),
                };
            }
        }
    }
    @panic("");
}

fn isValidNumeric(position: Position) bool {
    return 0 <= position.row and position.row < 4 and 0 <= position.column and position.column < 3 and !(position.row == 3 and position.column == 0);
}

fn isValidDirectional(position: Position) bool {
    return 0 <= position.row and position.row < 2 and 0 <= position.column and position.column < 3 and !(position.row == 0 and position.column == 0);
}

fn serialize_diff(allocator: std.mem.Allocator, diff: Position, row_first: bool) std.ArrayList(u8) {
    var serialized = std.ArrayList(u8).init(allocator);

    const row_char: u8 = if (diff.row > 0) blk: {
        break :blk 'v';
    } else blk: {
        break :blk '^';
    };

    const column_char: u8 = if (diff.column > 0) blk: {
        break :blk '>';
    } else blk: {
        break :blk '<';
    };

    if (row_first) {
        for (0..@intCast(@abs(diff.row))) |_| {
            serialized.append(row_char) catch @panic("");
        }
        for (0..@intCast(@abs((diff.column)))) |_| {
            serialized.append(column_char) catch @panic("");
        }
    } else {
        for (0..@intCast(@abs((diff.column)))) |_| {
            serialized.append(column_char) catch @panic("");
        }
        for (0..@intCast(@abs(diff.row))) |_| {
            serialized.append(row_char) catch @panic("");
        }
    }
    serialized.append('A') catch @panic("");

    return serialized;
}

const Position = struct {
    row: i64,
    column: i64,
};
