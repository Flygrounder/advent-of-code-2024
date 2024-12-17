const std = @import("std");
const utils = @import("utils.zig");

const State = struct {
    a: u64,
    b: u64,
    c: u64,

    current: usize,
    program: std.ArrayList(u64),
    output: std.ArrayList(u64),
    ignore_jump: bool,

    fn next(self: *State) bool {
        if (self.current >= self.program.items.len) {
            return false;
        }
        const opcode = self.program.items[self.current];
        const operand = self.program.items[self.current + 1];

        switch (opcode) {
            0 => {
                self.a = self.a / (@as(u64, 1) << @intCast(self.getCombo(operand)));
            },
            1 => {
                self.b = self.b ^ operand;
            },
            2 => {
                self.b = self.getCombo(operand) % 8;
            },
            3 => {
                if (!self.ignore_jump and self.a != 0) {
                    self.current = operand;
                    return true;
                }
            },
            4 => {
                self.b = self.b ^ self.c;
            },
            5 => {
                const res = self.getCombo(operand) % 8;
                self.output.append(res) catch @panic("");
            },
            6 => {
                self.b = self.a / (@as(u64, 1) << @intCast(self.getCombo(operand)));
            },
            7 => {
                self.c = self.a / (@as(u64, 1) << @intCast(self.getCombo(operand)));
            },
            else => @panic(""),
        }
        self.current += 2;
        return true;
    }

    fn deinit(self: State) void {
        self.program.deinit();
        self.output.deinit();
    }

    fn getCombo(self: State, operand: u64) u64 {
        return switch (operand) {
            0...3 => operand,
            4 => self.a,
            5 => self.b,
            6 => self.c,
            else => @panic(""),
        };
    }
};

pub fn part1(allocator: std.mem.Allocator) void {
    var state = readInput(allocator);
    defer state.deinit();

    while (state.next()) {}

    utils.printfStdout(allocator, "{}", .{state.output.items[0]});
    for (1..state.output.items.len) |i| {
        utils.printfStdout(allocator, ",{}", .{state.output.items[i]});
    }
    utils.printfStdout(allocator, "\n", .{});
}

pub fn part2(allocator: std.mem.Allocator) void {
    var state = readInput(allocator);
    defer state.deinit();

    const a = guessNext(allocator, 0, @intCast(state.program.items.len - 1), state.program).?;

    utils.printlnStdout(allocator, a);
}

fn guessNext(allocator: std.mem.Allocator, a: u64, i: i32, program: std.ArrayList(u64)) ?u64 {
    if (i < 0) {
        return a;
    }
    for (0..8) |j| {
        const next_a = (a << 3) + j;
        var state = State{
            .ignore_jump = true,
            .program = program,
            .a = next_a,
            .b = 0,
            .c = 0,
            .output = std.ArrayList(u64).init(allocator),
            .current = 0,
        };
        defer state.output.deinit();
        while (state.next()) {}
        const t = state.output.getLast();
        if (t == program.items[@intCast(i)]) {
            if (guessNext(allocator, next_a, i - 1, program)) |res| {
                return res;
            }
        }
    }
    return null;
}

fn readInput(allocator: std.mem.Allocator) State {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var buf = std.ArrayList(u64).init(allocator);
    readLine(lines.items[0].items, &buf);
    const a = buf.items[0];
    readLine(lines.items[1].items, &buf);
    const b = buf.items[0];
    readLine(lines.items[2].items, &buf);
    const c = buf.items[0];
    readLine(lines.items[4].items, &buf);

    return State{
        .current = 0,
        .a = a,
        .b = b,
        .c = c,
        .ignore_jump = false,
        .program = buf,
        .output = std.ArrayList(u64).init(allocator),
    };
}

fn readLine(line: []const u8, out: *std.ArrayList(u64)) void {
    out.resize(0) catch @panic("");
    var it = std.mem.split(u8, line, ": ");
    _ = it.next();
    const rhs = it.next().?;
    it = std.mem.split(u8, rhs, ",");
    while (it.next()) |operand| {
        const cur = std.fmt.parseInt(u64, operand, 10) catch @panic("");
        out.append(cur) catch @panic("");
    }
}
