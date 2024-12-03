const std = @import("std");
const utils = @import("utils.zig");

pub fn part1(allocator: std.mem.Allocator) void {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var result: u32 = 0;
    for (lines.items) |line| {
        var scanner = Scanner{
            .position = 0,
            .line = line.items,
        };
        while (!scanner.isEof()) {
            if (scanner.peek() == 'm') {
                const mul = scanMul(&scanner) catch 0;
                result += mul;
            } else {
                scanner.next();
            }
        }
    }
    utils.printlnStdout(allocator, result);
}

pub fn part2(allocator: std.mem.Allocator) void {
    const lines = utils.readLines(allocator);
    defer utils.deinitLines(lines);

    var result: u32 = 0;
    var enabled: bool = true;
    for (lines.items) |line| {
        var scanner = Scanner{
            .position = 0,
            .line = line.items,
        };
        while (!scanner.isEof()) {
            const cur = scanner.peek();
            if (cur == 'm') {
                const mul = scanMul(&scanner) catch 0;
                if (enabled) {
                    result += mul;
                }
            } else if (cur == 'd') {
                if (scanSwithInstruction(&scanner)) |enable| {
                    enabled = enable;
                } else |_| {}
            } else {
                scanner.next();
            }
        }
    }
    utils.printlnStdout(allocator, result);
}

const Scanner = struct {
    position: u32,
    line: []u8,

    fn expectString(self: *Scanner, string: []const u8) ScanError![]const u8 {
        for (string) |char| {
            _ = try self.expect(char);
        }
        return string;
    }

    fn expectRange(self: *Scanner, charMin: u8, charMax: u8) ScanError!u8 {
        const char = self.peek() orelse return ScanError.UnexpectedChar;
        if (charMin <= char and char <= charMax) {
            self.next();
            return char;
        } else {
            return ScanError.UnexpectedChar;
        }
    }

    fn expect(self: *Scanner, char: u8) ScanError!u8 {
        if (self.peek() == char) {
            self.next();
            return char;
        } else {
            return ScanError.UnexpectedChar;
        }
    }

    fn peek(self: *Scanner) ?u8 {
        if (self.isEof()) {
            return null;
        }
        return self.line[self.position];
    }

    fn next(self: *Scanner) void {
        if (!self.isEof()) {
            self.position += 1;
        }
    }

    fn isEof(self: *Scanner) bool {
        return self.position == self.line.len;
    }
};

fn scanSwithInstruction(scanner: *Scanner) ScanError!bool {
    _ = try scanner.expectString("do");
    if (scanner.peek() == '(') {
        _ = try scanner.expectString("()");
        return true;
    } else if (scanner.peek() == 'n') {
        _ = try scanner.expectString("n't");
        return false;
    } else {
        return ScanError.UnexpectedChar;
    }
}

fn scanMul(scanner: *Scanner) ScanError!u32 {
    _ = try scanner.expectString("mul(");
    const first = try scanNumber(scanner);
    _ = try scanner.expect(',');
    const second = try scanNumber(scanner);
    _ = try scanner.expect(')');
    return first * second;
}

fn scanNumber(scanner: *Scanner) ScanError!u32 {
    var number: u32 = try scanner.expectRange('0', '9') - '0';
    var digits: u32 = 1;
    while (scanner.expectRange('0', '9')) |digit| {
        number = number * 10 + (digit - '0');
        digits += 1;
        if (digits == 3) {
            break;
        }
    } else |_| {}
    return number;
}

const ScanError = error{
    UnexpectedChar,
};
