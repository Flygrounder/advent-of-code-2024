const std = @import("std");
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");
const day4 = @import("day4.zig");

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
