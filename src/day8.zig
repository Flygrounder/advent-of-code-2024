const std = @import("std");
const utils = @import("utils.zig");

const max_freq = 256;

const Field = struct {
    n: usize,
    m: usize,
    antennas: std.ArrayList(std.ArrayList(Pair)),

    fn deinit(self: Field) void {
        for (0..max_freq) |freq| {
            self.antennas.items[freq].deinit();
        }
        self.antennas.deinit();
    }
};

const Pair = struct {
    x: i32,
    y: i32,
};

pub fn part1(allocator: std.mem.Allocator) void {
    var field = readInput(allocator);
    defer field.deinit();

    var antinodes = std.ArrayList(std.ArrayList(bool)).init(allocator);

    for (0..field.n) |_| {
        var cur = std.ArrayList(bool).init(allocator);
        for (0..field.m) |_| {
            cur.append(false) catch @panic("");
        }
        antinodes.append(cur) catch @panic("");
    }

    for (0..max_freq) |freq| {
        for (0..field.antennas.items[freq].items.len) |i| {
            const x1 = field.antennas.items[freq].items[i].x;
            const y1 = field.antennas.items[freq].items[i].y;
            for (i + 1..field.antennas.items[freq].items.len) |j| {
                const x2 = field.antennas.items[freq].items[j].x;
                const y2 = field.antennas.items[freq].items[j].y;
                const dx = x2 - x1;
                const dy = y2 - y1;

                const a1 = x1 - dx;
                const b1 = y1 - dy;
                if (0 <= a1 and a1 < field.n and 0 <= b1 and b1 < field.m) {
                    antinodes.items[@intCast(a1)].items[@intCast(b1)] = true;
                }

                const a2 = x2 + dx;
                const b2 = y2 + dy;
                if (0 <= a2 and a2 < field.n and 0 <= b2 and b2 < field.m) {
                    antinodes.items[@intCast(a2)].items[@intCast(b2)] = true;
                }
            }
        }
    }

    var result: i32 = 0;

    for (0..field.n) |i| {
        for (0..field.m) |j| {
            if (antinodes.items[i].items[j]) {
                result += 1;
            }
        }
    }

    utils.printlnStdout(allocator, result);

    defer {
        for (0..field.n) |i| {
            antinodes.items[i].deinit();
        }
        antinodes.deinit();
    }
}

pub fn part2(allocator: std.mem.Allocator) void {
    var field = readInput(allocator);
    defer field.deinit();

    var antinodes = std.ArrayList(std.ArrayList(bool)).init(allocator);

    for (0..field.n) |_| {
        var cur = std.ArrayList(bool).init(allocator);
        for (0..field.m) |_| {
            cur.append(false) catch @panic("");
        }
        antinodes.append(cur) catch @panic("");
    }

    for (0..max_freq) |freq| {
        for (0..field.antennas.items[freq].items.len) |i| {
            const x1 = field.antennas.items[freq].items[i].x;
            const y1 = field.antennas.items[freq].items[i].y;
            for (i + 1..field.antennas.items[freq].items.len) |j| {
                const x2 = field.antennas.items[freq].items[j].x;
                const y2 = field.antennas.items[freq].items[j].y;
                var dx = x2 - x1;
                var dy = y2 - y1;
                const g: i32 = @intCast(gcd(@abs(dx), @abs(dy)));
                dx = @divFloor(dx, g);
                dy = @divFloor(dy, g);
                var cx = x1;
                var cy = y1;
                while (0 <= cx and cx < field.n and 0 <= cy and cy < field.m) {
                    antinodes.items[@intCast(cx)].items[@intCast(cy)] = true;
                    cx += dx;
                    cy += dy;
                }
                cx = x1;
                cy = y1;
                while (0 <= cx and cx < field.n and 0 <= cy and cy < field.m) {
                    antinodes.items[@intCast(cx)].items[@intCast(cy)] = true;
                    cx -= dx;
                    cy -= dy;
                }
            }
        }
    }

    var result: i32 = 0;

    for (0..field.n) |i| {
        for (0..field.m) |j| {
            if (antinodes.items[i].items[j]) {
                result += 1;
            }
        }
    }

    utils.printlnStdout(allocator, result);

    defer {
        for (0..field.n) |i| {
            antinodes.items[i].deinit();
        }
        antinodes.deinit();
    }
}

fn gcd(a: u32, b: u32) u32 {
    if (a == 0) {
        return b;
    }
    return gcd(b % a, a);
}

fn readInput(allocator: std.mem.Allocator) Field {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var antennas = std.ArrayList(std.ArrayList(Pair)).init(allocator);

    for (0..max_freq) |_| {
        antennas.append(std.ArrayList(Pair).init(allocator)) catch @panic("");
    }

    for (0..lines.items.len) |i| {
        for (0..lines.items[i].items.len) |j| {
            const freq = lines.items[i].items[j];
            if (freq != '.') {
                antennas.items[freq].append(Pair{
                    .x = @intCast(i),
                    .y = @intCast(j),
                }) catch @panic("");
            }
        }
    }

    return Field{
        .n = lines.items.len,
        .m = lines.items[0].items.len,
        .antennas = antennas,
    };
}
