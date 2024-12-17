const std = @import("std");

pub fn readLines(
    allocator: std.mem.Allocator,
) std.ArrayList(std.ArrayList(u8)) {
    const stdin = std.io.getStdIn();
    var stdin_buffered_reader = std.io.bufferedReader(stdin.reader());
    const stdin_reader = stdin_buffered_reader.reader();
    var lines = std.ArrayList(std.ArrayList(u8)).init(allocator);
    while (true) {
        var line = std.ArrayList(u8).init(allocator);
        const line_writer = line.writer();
        stdin_reader.streamUntilDelimiter(line_writer, '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => @panic("unknown error"),
        };
        lines.append(line) catch {
            @panic("unknwon error");
        };
    }
    return lines;
}

pub fn deinitLines(lines: std.ArrayList(std.ArrayList(u8))) void {
    for (lines.items) |line| {
        line.deinit();
    }
    lines.deinit();
}

pub fn printlnStdout(allocator: std.mem.Allocator, value: anytype) void {
    printfStdout(allocator, "{}\n", .{value});
}

pub fn printfStdout(allocator: std.mem.Allocator, comptime fmt: []const u8, args: anytype) void {
    const stdout = std.io.getStdOut();
    const output = std.fmt.allocPrint(allocator, fmt, args) catch @panic("");
    defer allocator.free(output);

    stdout.writeAll(output) catch @panic("");
}
