const std = @import("std");
const utils = @import("utils.zig");

const Expression = struct {
    variables: std.AutoHashMap([3]u8, u1),
    gates: std.AutoHashMap([3]u8, Gate),

    fn evaluate(self: *Expression, variable: [3]u8) ?u1 {
        if (self.variables.get(variable)) |value| {
            return value;
        }
        const gate = self.gates.get(variable) orelse return null;
        const left = self.evaluate(gate.left).?;
        const right = self.evaluate(gate.right).?;
        const result = switch (gate.operator) {
            .Xor => left ^ right,
            .Or => left | right,
            .And => left & right,
        };
        self.variables.put(variable, result) catch @panic("");
        return result;
    }

    fn deinit(self: *Expression) void {
        self.variables.deinit();
        self.gates.deinit();
    }
};

const Gate = struct {
    operator: Operator,
    left: [3]u8,
    right: [3]u8,
    output: [3]u8,
};

const Operator = enum {
    Xor,
    And,
    Or,
};

pub fn part1(allocator: std.mem.Allocator) void {
    var input = readInput(allocator);
    defer input.deinit();

    var i: u64 = 0;
    var result: u64 = 0;
    var power: u64 = 1;
    while (true) {
        const name = [3]u8{ 'z', @intCast('0' + (i / 10)), @intCast('0' + (i % 10)) };
        const cur = input.evaluate(name) orelse break;
        result = cur * power + result;
        power *= 2;
        i += 1;
    }

    utils.printlnStdout(allocator, result);
}

pub fn part2(allocator: std.mem.Allocator) void {
    var input = readInput(allocator);
    defer input.deinit();

    var it = input.gates.valueIterator();

    // Yes, I manually found the answer by looking at the graph
    std.debug.print("digraph G {{\n", .{});
    std.debug.print("rankdir = LR\n", .{});
    while (it.next()) |gate| {
        std.debug.print("{s} [label=\"{}({s})\"]\n", .{ gate.output, gate.operator, gate.output });
        std.debug.print("{s} -> {s}\n", .{ gate.left, gate.output });
        std.debug.print("{s} -> {s}\n", .{ gate.right, gate.output });
    }
    std.debug.print("}}\n", .{});
}

fn readInput(allocator: std.mem.Allocator) Expression {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var gates = std.AutoHashMap([3]u8, Gate).init(allocator);
    var variables = std.AutoHashMap([3]u8, u1).init(allocator);
    var variable_mode = true;
    for (lines.items) |line| {
        if (line.items.len == 0) {
            variable_mode = false;
            continue;
        }
        if (variable_mode) {
            var it = std.mem.split(u8, line.items, ": ");
            const name = getNameFromSlice(it.next().?);
            const value = std.fmt.parseInt(u1, it.next().?, 10) catch @panic("");
            variables.put(name, value) catch @panic("");
        } else {
            var it = std.mem.split(u8, line.items, " -> ");
            const lhs = it.next().?;
            const output = getNameFromSlice(it.next().?);
            it = std.mem.split(u8, lhs, " ");
            const left = getNameFromSlice(it.next().?);
            const operator = getOperatorFromName(it.next().?);
            const right = getNameFromSlice(it.next().?);
            gates.put(output, Gate{
                .left = left,
                .right = right,
                .operator = operator,
                .output = output,
            }) catch @panic("");
        }
    }
    return Expression{
        .variables = variables,
        .gates = gates,
    };
}

fn getNameFromSlice(slice: []const u8) [3]u8 {
    return [3]u8{ slice[0], slice[1], slice[2] };
}

fn getOperatorFromName(name: []const u8) Operator {
    if (std.mem.eql(u8, name, "XOR")) {
        return .Xor;
    } else if (std.mem.eql(u8, name, "OR")) {
        return .Or;
    } else if (std.mem.eql(u8, name, "AND")) {
        return .And;
    }
    @panic("");
}
