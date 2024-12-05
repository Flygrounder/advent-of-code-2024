const std = @import("std");
const utils = @import("utils.zig");

const Input = struct {
    rules: std.ArrayList(Pair),
    candidates: std.ArrayList(std.ArrayList(usize)),

    fn deinit(self: Input) void {
        self.rules.deinit();

        for (self.candidates.items) |row| {
            row.deinit();
        }
        self.candidates.deinit();
    }
};

const Pair = struct {
    first: usize,
    second: usize,
};

pub fn part1(allocator: std.mem.Allocator) void {
    var input = readInput(allocator);
    defer input.deinit();

    var result: usize = 0;
    for (input.candidates.items) |candidate| {
        if (findCounterexample(candidate.items, input.rules.items) == null) {
            result += candidate.items[candidate.items.len / 2];
        }
    }
    utils.printlnStdout(allocator, result);
}

pub fn part2(allocator: std.mem.Allocator) void {
    var input = readInput(allocator);
    defer input.deinit();

    var result: usize = 0;
    for (input.candidates.items) |candidate| {
        if (findCounterexample(candidate.items, input.rules.items) == null) {
            continue;
        }
        while (findCounterexample(candidate.items, input.rules.items)) |pair| {
            const t = candidate.items[pair.first];
            candidate.items[pair.first] = candidate.items[pair.second];
            candidate.items[pair.second] = t;
        }
        result += candidate.items[candidate.items.len / 2];
    }
    utils.printlnStdout(allocator, result);
}

fn findCounterexample(candidate: []usize, rules: []Pair) ?Pair {
    for (0..candidate.len) |i| {
        for (i + 1..candidate.len) |j| {
            for (rules) |rule| {
                if (rule.first == candidate[j] and rule.second == candidate[i]) {
                    return Pair{
                        .first = i,
                        .second = j,
                    };
                }
            }
        }
    }
    return null;
}

fn readInput(allocator: std.mem.Allocator) Input {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var rules = std.ArrayList(Pair).init(allocator);

    var candidates = std.ArrayList(std.ArrayList(usize)).init(allocator);

    var rules_mode = true;

    for (lines.items) |line| {
        if (std.mem.eql(u8, line.items, "")) {
            rules_mode = false;
            continue;
        }
        if (rules_mode) {
            var it = std.mem.split(u8, line.items, "|");
            const a = std.fmt.parseInt(usize, it.next().?, 10) catch @panic("");
            const b = std.fmt.parseInt(usize, it.next().?, 10) catch @panic("");
            rules.append(Pair{
                .first = a,
                .second = b,
            }) catch @panic("");
        } else {
            var it = std.mem.split(u8, line.items, ",");
            var cur = std.ArrayList(usize).init(allocator);
            while (it.next()) |number| {
                const parsed = std.fmt.parseInt(usize, number, 10) catch @panic("");
                cur.append(parsed) catch @panic("");
            }
            candidates.append(cur) catch @panic("");
        }
    }
    return .{
        .rules = rules,
        .candidates = candidates,
    };
}
