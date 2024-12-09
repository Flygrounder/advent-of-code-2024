const std = @import("std");
const utils = @import("utils.zig");

const State = struct {
    blocks: std.ArrayList(?u64),
    files: std.ArrayList(BlockArray),
    spaces: std.ArrayList(BlockArray),

    fn deinit(self: State) void {
        self.blocks.deinit();
        self.files.deinit();
        self.spaces.deinit();
    }

    fn getChecksum(self: State) u64 {
        var result: u64 = 0;
        for (0..self.blocks.items.len) |i| {
            const cur_file_id = self.blocks.items[i] orelse 0;
            result += i * cur_file_id;
        }
        return result;
    }
};

const BlockArray = struct {
    start: u64,
    length: u64,
};

pub fn part1(allocator: std.mem.Allocator) void {
    var state = readInput(allocator);
    defer state.deinit();

    var left = state.spaces.items[0].start;
    const last_file = state.files.items.len - 1;
    var right = state.files.items[last_file].start + state.files.items[last_file].length - 1;

    while (left < right) {
        state.blocks.items[left] = state.blocks.items[right];
        state.blocks.items[right] = null;
        while (state.blocks.items[left] != null) {
            left += 1;
        }
        while (state.blocks.items[right] == null) {
            right -= 1;
        }
    }

    utils.printlnStdout(allocator, state.getChecksum());
}

pub fn part2(allocator: std.mem.Allocator) void {
    var state = readInput(allocator);
    defer state.deinit();

    var cur_file = state.files.items.len;
    while (cur_file > 0) {
        cur_file -= 1;
        const cur_length = state.files.items[cur_file].length;
        for (0..state.spaces.items.len) |cur_space| {
            if (state.spaces.items[cur_space].length >= cur_length and state.spaces.items[cur_space].start < state.files.items[cur_file].start) {
                for (0..cur_length) |i| {
                    state.blocks.items[state.spaces.items[cur_space].start + i] = cur_file;
                    state.blocks.items[state.files.items[cur_file].start + i] = null;
                }
                state.spaces.items[cur_space].start += cur_length;
                state.spaces.items[cur_space].length -= cur_length;
                break;
            }
        }
    }

    utils.printlnStdout(allocator, state.getChecksum());
}

fn readInput(allocator: std.mem.Allocator) State {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var is_file = true;
    var blocks = std.ArrayList(?u64).init(allocator);
    var files = std.ArrayList(BlockArray).init(allocator);
    var spaces = std.ArrayList(BlockArray).init(allocator);
    for (lines.items[0].items) |space| {
        const length = space - '0';
        const start = blocks.items.len;
        for (0..length) |_| {
            if (is_file) {
                blocks.append(files.items.len) catch @panic("");
            } else {
                blocks.append(null) catch @panic("");
            }
        }
        const array = BlockArray{
            .start = start,
            .length = length,
        };
        if (is_file) {
            files.append(array) catch @panic("");
        } else {
            spaces.append(array) catch @panic("");
        }
        is_file = !is_file;
    }

    return State{
        .blocks = blocks,
        .files = files,
        .spaces = spaces,
    };
}
