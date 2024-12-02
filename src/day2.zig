const std = @import("std");
const utils = @import("utils.zig");

pub fn part1(allocator: std.mem.Allocator) void {
    const reports = readReports(allocator);
    defer deinitReports(reports);

    var result: i64 = 0;
    for (reports.items) |report| {
        if (isReportSafe(report.items, null)) {
            result += 1;
        }
    }
    utils.printlnStdout(allocator, result);
}

pub fn part2(allocator: std.mem.Allocator) void {
    const reports = readReports(allocator);
    defer deinitReports(reports);

    var result: i64 = 0;
    for (reports.items) |report| {
        if (isReportSafe(report.items, null)) {
            result += 1;
        } else {
            for (0..reports.items.len) |i| {
                if (isReportSafe(report.items, i)) {
                    result += 1;
                    break;
                }
            }
        }
    }
    utils.printlnStdout(allocator, result);
}

fn isReportSafe(report: []i64, ignore_level_opt: ?usize) bool {
    const ignore_level = ignore_level_opt orelse report.len;
    const inc: bool = switch (ignore_level) {
        0 => report[1] < report[2],
        1 => report[0] < report[2],
        else => report[0] < report[1],
    };
    const start: usize = switch (ignore_level) {
        0 => 2,
        else => 1,
    };
    var prev: i64 = switch (ignore_level) {
        0 => report[1],
        else => report[0],
    };
    for (start..report.len) |i| {
        if (i == ignore_level) {
            continue;
        }
        const level = report[i];
        const dist = @abs(prev - level);
        const ok = (inc == (prev < level)) and (1 <= dist and dist <= 3);
        if (!ok) {
            return false;
        }
        prev = level;
    }
    return true;
}

fn readReports(allocator: std.mem.Allocator) std.ArrayList(std.ArrayList(i64)) {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var reports: std.ArrayList(std.ArrayList(i64)) = std.ArrayList(std.ArrayList(i64)).init(allocator);
    for (lines.items) |line| {
        var iter = std.mem.split(u8, line.items, " ");
        var levels: std.ArrayList(i64) = std.ArrayList(i64).init(allocator);
        while (iter.next()) |level| {
            levels.append(std.fmt.parseInt(i64, level, 10) catch @panic("")) catch @panic("");
        }
        reports.append(levels) catch @panic("");
    }
    return reports;
}

fn deinitReports(reports: std.ArrayList(std.ArrayList(i64))) void {
    for (reports.items) |report| {
        report.deinit();
    }
    reports.deinit();
}
