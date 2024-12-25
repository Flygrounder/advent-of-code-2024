const std = @import("std");

const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");
const day4 = @import("day4.zig");
const day5 = @import("day5.zig");
const day6 = @import("day6.zig");
const day7 = @import("day7.zig");
const day8 = @import("day8.zig");
const day9 = @import("day9.zig");
const day10 = @import("day10.zig");
const day11 = @import("day11.zig");
const day12 = @import("day12.zig");
const day13 = @import("day13.zig");
const day14 = @import("day14.zig");
const day15 = @import("day15.zig");
const day16 = @import("day16.zig");
const day17 = @import("day17.zig");
const day18 = @import("day18.zig");
const day19 = @import("day19.zig");
const day20 = @import("day20.zig");
const day21 = @import("day21.zig");
const day22 = @import("day22.zig");
const day23 = @import("day23.zig");
const day24 = @import("day24.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    var args = std.process.args();
    _ = args.skip();

    const day_arg = args.next() orelse exitWithHelp();
    const day = std.fmt.parseInt(u64, day_arg, 10) catch exitWithHelp();

    const part_arg = args.next() orelse exitWithHelp();
    const part = std.fmt.parseInt(u64, part_arg, 10) catch exitWithHelp();

    const parts_per_day = 2;
    const index: u64 = (day - 1) * parts_per_day + part - 1;
    if (index >= solutions.len) {
        exitWithHelp();
    }

    solutions[index](gpa.allocator());
}

const solutions = [_]*const fn (allocator: std.mem.Allocator) void{
    day1.part1,
    day1.part2,
    day2.part1,
    day2.part2,
    day3.part1,
    day3.part2,
    day4.part1,
    day4.part2,
    day5.part1,
    day5.part2,
    day6.part1,
    day6.part2,
    day7.part1,
    day7.part2,
    day8.part1,
    day8.part2,
    day9.part1,
    day9.part2,
    day10.part1,
    day10.part2,
    day11.part1,
    day11.part2,
    day12.part1,
    day12.part2,
    day13.part1,
    day13.part2,
    day14.part1,
    day14.part2,
    day15.part1,
    day15.part2,
    day16.part1,
    day16.part2,
    day17.part1,
    day17.part2,
    day18.part1,
    day18.part2,
    day19.part1,
    day19.part2,
    day20.part1,
    day20.part2,
    day21.part1,
    day21.part2,
    day22.part1,
    day22.part2,
    day23.part1,
    day23.part2,
    day24.part1,
    day24.part2,
};

fn exitWithHelp() noreturn {
    std.debug.print("{s}", .{usage});
    std.process.exit(1);
}

const usage =
    \\Usage:
    \\aoc2024 <day> <part>
    \\
;
