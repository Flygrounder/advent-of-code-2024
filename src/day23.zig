const std = @import("std");
const utils = @import("utils.zig");

pub fn part1(allocator: std.mem.Allocator) void {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const arena_allocator = arena.allocator();

    const graph = readInput(arena_allocator);

    var result: i32 = 0;

    var used = std.AutoHashMap([3]u32, void).init(allocator);
    defer used.deinit();

    var it = graph.keyIterator();

    while (it.next()) |u| {
        if (!startsWithLetter(u.*, 't')) {
            continue;
        }
        var it2 = graph.get(u.*).?.keyIterator();
        while (it2.next()) |v| {
            var it3 = graph.get(v.*).?.keyIterator();
            while (it3.next()) |w| {
                if (graph.get(w.*).?.contains(u.*)) {
                    var set = [3]u32{ u.*, v.*, w.* };
                    std.mem.sort(u32, &set, {}, comptime std.sort.asc(u32));
                    if (!used.contains(set)) {
                        used.put(set, {}) catch @panic("");
                        result += 1;
                    }
                }
            }
        }
    }

    utils.printlnStdout(allocator, result);
}

pub fn part2(allocator: std.mem.Allocator) void {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const arena_allocator = arena.allocator();

    const graph = readInput(arena_allocator);

    var sets = std.ArrayList(std.ArrayList(u32)).init(arena_allocator);
    var it = graph.keyIterator();
    while (it.next()) |element| {
        var set = std.ArrayList(u32).init(arena_allocator);
        set.append(element.*) catch @panic("");
        sets.append(set) catch @panic("");
    }

    while (sets.items.len > 1) {
        var next = std.ArrayList(std.ArrayList(u32)).init(arena_allocator);
        for (sets.items) |cur| {
            it = graph.keyIterator();
            while (it.next()) |candidate| {
                var ok = true;
                for (cur.items) |computer| {
                    ok = ok and graph.get(candidate.*).?.contains(computer);
                }
                if (!ok) {
                    continue;
                }
                var next_set = std.ArrayList(u32).init(arena_allocator);
                next_set.appendSlice(cur.items) catch @panic("");
                next_set.append(candidate.*) catch @panic("");
                std.mem.sort(u32, next_set.items, {}, comptime std.sort.asc(u32));
                for (next.items) |set| {
                    var equal = true;
                    for (0..set.items.len) |i| {
                        equal = equal and set.items[i] == next_set.items[i];
                    }
                    if (equal) {
                        break;
                    }
                } else {
                    next.append(next_set) catch @panic("");
                }
            }
        }
        sets = next;
    }
    const result = sets.items[0];
    utils.printfStdout(allocator, "{s}", .{decode(result.items[0])});
    for (result.items[1..result.items.len]) |i| {
        utils.printfStdout(allocator, ",{s}", .{decode(i)});
    }
    utils.printfStdout(allocator, "\n", .{});
}

fn readInput(allocator: std.mem.Allocator) std.AutoHashMap(u32, std.AutoHashMap(u32, void)) {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var graph = std.AutoHashMap(u32, std.AutoHashMap(u32, void)).init(allocator);

    for (lines.items) |line| {
        var it = std.mem.split(u8, line.items, "-");
        const first = it.next().?;
        const second = it.next().?;
        insertEdge(&graph, first, second);
    }

    return graph;
}

fn insertEdge(graph: *std.AutoHashMap(u32, std.AutoHashMap(u32, void)), first: []const u8, second: []const u8) void {
    const u = getComputerCode(first);
    const v = getComputerCode(second);
    if (!graph.contains(u)) {
        graph.put(u, std.AutoHashMap(u32, void).init(graph.allocator)) catch @panic("");
    }
    var umap = graph.getPtr(u).?;
    umap.put(v, {}) catch @panic("");
    if (!graph.contains(v)) {
        graph.put(v, std.AutoHashMap(u32, void).init(graph.allocator)) catch @panic("");
    }
    var vmap = graph.getPtr(v).?;
    vmap.put(u, {}) catch @panic("");
}

fn getComputerCode(name: []const u8) u32 {
    const first: u32 = name[0] - 'a';
    const second: u32 = name[1] - 'a';
    return first * 26 + second;
}

fn decode(code: u32) [2]u8 {
    return .{ @intCast(code / 26 + 'a'), @intCast(code % 26 + 'a') };
}

fn startsWithLetter(code: u32, letter: u8) bool {
    return code / 26 == letter - 'a';
}
