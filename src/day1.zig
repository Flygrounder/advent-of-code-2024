const std = @import("std");
const utils = @import("utils.zig");

pub fn part1(allocator: std.mem.Allocator) void {
    const arrays = readArrays(allocator);
    defer allocator.free(arrays[0]);
    defer allocator.free(arrays[1]);

    std.mem.sort(i64, arrays[0], {}, comptime std.sort.asc(i64));
    std.mem.sort(i64, arrays[1], {}, comptime std.sort.asc(i64));

    var result: u64 = 0;
    for (0..arrays[0].len) |i| {
        result += @abs(arrays[0][i] - arrays[1][i]);
    }

    utils.printlnStdout(allocator, result);
}

pub fn part2(allocator: std.mem.Allocator) void {
    const arrays = readArrays(allocator);
    defer allocator.free(arrays[0]);
    defer allocator.free(arrays[1]);

    var result: i64 = 0;
    for (arrays[0]) |i| {
        var times: i64 = 0;
        for (arrays[1]) |j| {
            if (i == j) {
                times += 1;
            }
        }
        result += i * times;
    }

    utils.printlnStdout(allocator, result);
}

fn readArrays(allocator: std.mem.Allocator) struct { []i64, []i64 } {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var first = std.ArrayList(i64).init(allocator);
    var second = std.ArrayList(i64).init(allocator);

    for (lines.items) |line| {
        var iter = std.mem.split(u8, line.items, "   ");
        const a = iter.next().?;
        const b = iter.next().?;
        first.append(std.fmt.parseInt(i64, a, 10) catch @panic("")) catch @panic("");
        second.append(std.fmt.parseInt(i64, b, 10) catch @panic("")) catch @panic("");
    }

    const first_slice = first.toOwnedSlice() catch @panic("");
    const second_slice = second.toOwnedSlice() catch @panic("");

    return .{ first_slice, second_slice };
}
