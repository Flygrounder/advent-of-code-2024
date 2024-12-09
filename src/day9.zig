const std = @import("std");
const utils = @import("utils.zig");

const BlockArray = struct {
    start: u64,
    length: u64,
};

pub fn part1(allocator: std.mem.Allocator) void {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var is_file = true;
    var blocks = std.ArrayList(?u64).init(allocator);
    defer blocks.deinit();

    var file_id: usize = 0;
    var left: usize = 0;
    var right: usize = 0;
    for (lines.items[0].items) |space| {
        const length = space - '0';
        for (0..length) |_| {
            if (is_file) {
                right = blocks.items.len;
                blocks.append(file_id) catch @panic("");
            } else {
                if (left == 0) {
                    left = blocks.items.len;
                }
                blocks.append(null) catch @panic("");
            }
        }
        if (is_file) {
            file_id += 1;
        }
        is_file = !is_file;
    }

    while (left < right) {
        blocks.items[left] = blocks.items[right];
        blocks.items[right] = null;
        while (blocks.items[left] != null) {
            left += 1;
        }
        while (blocks.items[right] == null) {
            right -= 1;
        }
    }

    var result: u64 = 0;

    for (0..blocks.items.len) |i| {
        const cur_file_id = blocks.items[i] orelse 0;
        result += i * cur_file_id;
    }

    utils.printlnStdout(allocator, result);
}

pub fn part2(allocator: std.mem.Allocator) void {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var is_file = true;
    var blocks = std.ArrayList(?u64).init(allocator);
    defer blocks.deinit();

    var files = std.ArrayList(BlockArray).init(allocator);
    defer files.deinit();

    var spaces = std.ArrayList(BlockArray).init(allocator);
    defer spaces.deinit();

    var file_id: usize = 0;
    for (lines.items[0].items) |space| {
        const length = space - '0';
        const start = blocks.items.len;
        for (0..length) |_| {
            if (is_file) {
                blocks.append(file_id) catch @panic("");
            } else {
                blocks.append(null) catch @panic("");
            }
        }
        if (is_file) {
            file_id += 1;
            files.append(BlockArray{
                .start = start,
                .length = length,
            }) catch @panic("");
        } else {
            spaces.append(BlockArray{
                .start = start,
                .length = length,
            }) catch @panic("");
        }
        is_file = !is_file;
    }

    var cur_file = files.items.len;
    while (cur_file > 0) {
        cur_file -= 1;
        const cur_length = files.items[cur_file].length;
        for (0..spaces.items.len) |cur_space| {
            if (spaces.items[cur_space].length >= cur_length and spaces.items[cur_space].start < files.items[cur_file].start) {
                for (0..cur_length) |i| {
                    blocks.items[spaces.items[cur_space].start + i] = cur_file;
                    blocks.items[files.items[cur_file].start + i] = null;
                }
                spaces.items[cur_space].start += cur_length;
                spaces.items[cur_space].length -= cur_length;
                break;
            }
        }
    }

    var result: u64 = 0;

    for (0..blocks.items.len) |i| {
        const cur_file_id = blocks.items[i] orelse 0;
        result += i * cur_file_id;
    }

    utils.printlnStdout(allocator, result);
}
