const std = @import("std");
const utils = @import("utils.zig");

const Machine = struct {
    button_a: Coordinate,
    button_b: Coordinate,
    prize: Coordinate,
};

const Coordinate = struct {
    x: i64,
    y: i64,
};

pub fn part1(allocator: std.mem.Allocator) void {
    solve(allocator, 0);
}

pub fn part2(allocator: std.mem.Allocator) void {
    solve(allocator, 10000000000000);
}

fn solve(allocator: std.mem.Allocator, add: i64) void {
    const machines = readInput(allocator, add);
    defer machines.deinit();

    var result: i64 = 0;
    for (machines.items) |machine| {
        const di = machine.prize.x * machine.button_b.y - machine.prize.y * machine.button_b.x;
        const dj = machine.prize.y * machine.button_a.x - machine.prize.x * machine.button_a.y;
        const d = machine.button_a.x * machine.button_b.y - machine.button_a.y * machine.button_b.x;
        if (d == 0 or @mod(di, d) != 0 or @mod(dj, d) != 0) {
            continue;
        }
        const i = @divFloor(di, d);
        const j = @divFloor(dj, d);
        if (i < 0 or j < 0) {
            continue;
        }
        result += 3 * i + j;
    }
    utils.printlnStdout(allocator, result);
}

fn readInput(allocator: std.mem.Allocator, add: i64) std.ArrayList(Machine) {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var machines = std.ArrayList(Machine).init(allocator);

    var k: usize = 0;
    while (k < lines.items.len) {
        var machine = Machine{
            .button_a = readLine(lines.items[k].items, "+"),
            .button_b = readLine(lines.items[k + 1].items, "+"),
            .prize = readLine(lines.items[k + 2].items, "="),
        };
        machine.prize.x += add;
        machine.prize.y += add;
        machines.append(machine) catch @panic("");
        k += 4;
    }
    return machines;
}

fn readLine(line: []u8, delimeter: []const u8) Coordinate {
    var it_a = std.mem.split(u8, line, ": ");
    _ = it_a.next();
    const second = it_a.next().?;
    var it_a_r = std.mem.split(u8, second, ", ");

    const a_x = it_a_r.next().?;
    var a_xx = std.mem.split(u8, a_x, delimeter);
    _ = a_xx.next();
    const a_xxx = a_xx.next().?;
    const x = std.fmt.parseInt(i64, a_xxx, 10) catch @panic("");

    const a_y = it_a_r.next().?;
    var a_yy = std.mem.split(u8, a_y, delimeter);
    _ = a_yy.next();
    const a_yyy = a_yy.next().?;
    const y = std.fmt.parseInt(i64, a_yyy, 10) catch @panic("");

    return Coordinate{
        .x = x,
        .y = y,
    };
}
