const std = @import("std");
const utils = @import("utils.zig");

const Equation = struct {
    lhs: u64,
    rhs: std.ArrayList(u64),
};

pub fn part1(allocator: std.mem.Allocator) void {
    const equations = readInput(allocator);
    defer deinitEquations(equations);

    var result: u64 = 0;
    for (equations.items) |equation| {
        if (check(equation, false)) {
            result += equation.lhs;
        }
    }

    utils.printlnStdout(allocator, result);
}

pub fn part2(allocator: std.mem.Allocator) void {
    const equations = readInput(allocator);
    defer deinitEquations(equations);

    var result: u64 = 0;
    for (equations.items) |equation| {
        if (check(equation, true)) {
            result += equation.lhs;
        }
    }

    utils.printlnStdout(allocator, result);
}

fn check(equation: Equation, enable_concat: bool) bool {
    return checkRec(equation, 1, equation.rhs.items[0], enable_concat);
}

fn checkRec(equation: Equation, i: usize, acc: u64, enable_concat: bool) bool {
    if (i == equation.rhs.items.len) {
        return acc == equation.lhs;
    }
    const next = equation.rhs.items[i];
    const add = acc + next;
    const mul = acc * next;
    var power: u64 = 1;
    while (power <= next) {
        power *= 10;
    }
    const concat = acc * power + next;
    return checkRec(equation, i + 1, add, enable_concat) or checkRec(equation, i + 1, mul, enable_concat) or (enable_concat and checkRec(equation, i + 1, concat, enable_concat));
}

fn readInput(allocator: std.mem.Allocator) std.ArrayList(Equation) {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);
    var equations = std.ArrayList(Equation).init(allocator);
    for (lines.items) |line| {
        var it = std.mem.split(u8, line.items, ": ");
        const lhs_raw = it.next().?;
        const lhs = std.fmt.parseInt(u64, lhs_raw, 10) catch @panic("");
        var it2 = std.mem.split(u8, it.next().?, " ");
        var rhs = std.ArrayList(u64).init(allocator);
        while (it2.next()) |value| {
            const parsed: u64 = std.fmt.parseInt(u64, value, 10) catch @panic("");
            rhs.append(parsed) catch @panic("");
        }
        equations.append(Equation{
            .lhs = lhs,
            .rhs = rhs,
        }) catch @panic("");
    }
    return equations;
}

fn deinitEquations(equations: std.ArrayList(Equation)) void {
    for (equations.items) |equation| {
        equation.rhs.deinit();
    }
    equations.deinit();
}
