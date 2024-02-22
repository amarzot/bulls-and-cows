const std = @import("std");
pub const default_log_level: std.log.Level = .info;

pub fn contentsOfFile(allocator: std.mem.Allocator, filename: []const u8) ![]const u8 {
    var file = try std.fs.cwd().openFile(filename, .{});
    return try file.readToEndAlloc(allocator, 1 << 32);
}

const BullsCows = struct {
    bulls: u8,
    cows: u8,
};

fn getBullsCows(secret: [4]u8, guess: []u8) BullsCows {
    var bulls: u8 = 0;
    var cows: u8 = 0;
    for (secret, guess) |s, g| {
        if (s == g) {
            bulls += 1;
            continue;
        }
        for (secret) |n| {
            if (n == g) {
                cows += 1;
                break;
            }
        }
    }
    return BullsCows{ .bulls = bulls, .cows = cows };
}

fn answer(secret: [4]u8, in: std.fs.File, out: std.fs.File) !void {
    var buf: [256]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);
    const buf_writer = fbs.writer();
    const reader = in.reader();
    const writer = out.writer();
    while (true) {
        try writer.print("Guess: ", .{});

        try reader.streamUntilDelimiter(buf_writer, '\n', buf.len);

        const written = fbs.getWritten();

        std.log.debug("{} {s}", .{ written.len, written });
        if (written.len != secret.len) {
            try writer.print("Guess must be {} characters\n", .{secret.len});
            try fbs.seekTo(0);
            continue;
        }

        const bc = getBullsCows(secret, written);
        if (bc.bulls == secret.len) {
            try writer.print("You Win! Secret was {s}\n", .{secret});
            return;
        } else {
            try writer.print("Bulls: {}, Cows: {}\n", .{ bc.bulls, bc.cows });
        }

        try fbs.seekTo(0);
    }
}

pub fn ask() void {}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();

    var args = try std.process.argsWithAllocator(alloc);
    defer args.deinit();

    const prog = args.next().?;
    _ = prog;

    const seed: u64 = @truncate(@as(u128, @bitCast(std.time.nanoTimestamp())));
    var rng = std.rand.DefaultPrng.init(seed);

    var secret_digits: [4]u8 = undefined;
    for (0..4) |i| {
        secret_digits[i] = rng.random().intRangeAtMost(u8, '0', '9');
    }
    std.log.debug("Secret: {s}", .{secret_digits});
    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut();
    try answer(secret_digits, stdin, stdout);
}
