const std = @import("std");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    //std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    const stdin_file = std.io.getStdIn().reader();
    var br = std.io.bufferedReader(stdin_file);
    const stdin = br.reader();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();


    var data_buf: [1024*1024]u8 = undefined;
    var sparse_adj = std.hash_map.StringHashMap(std.hash_map.StringHashMap(void)).init(allocator);
    while (try stdin.readUntilDelimiterOrEof(&data_buf, '\n')) |data| {
        const lefts: []u8 = try allocator.alloc(u8, 2);
        const rights: []u8 = try allocator.alloc(u8, 2);
        @memcpy(lefts, data[0..2]);
        @memcpy(rights, data[3..5]);
        var entry = try sparse_adj.getOrPut(lefts);
        if (!entry.found_existing) {
            entry.value_ptr.* = std.hash_map.StringHashMap(void).init(allocator);
        }
        try entry.value_ptr.put(rights, undefined);
        entry = try sparse_adj.getOrPut(rights);
        if (!entry.found_existing) {
            entry.value_ptr.* = std.hash_map.StringHashMap(void).init(allocator);
        }
        try entry.value_ptr.put(lefts, undefined);
    }

    try stdout.print("Contains {}\n", .{sparse_adj.get("kh").?.contains("tz")});

    var first_it = sparse_adj.iterator();
    var count: u64 = 0;
    while (first_it.next()) |first_entry| {
        const has_t = first_entry.key_ptr.*[0] == 't';
        var second_it = first_entry.value_ptr.iterator();
        while (second_it.next()) |inner_entry| {
            const has_t_2 = has_t or inner_entry.key_ptr.*[0] == 't';
            if (std.mem.order(u8, inner_entry.key_ptr.*, first_entry.key_ptr.*) != .gt) { continue; }
            if (sparse_adj.getEntry(inner_entry.key_ptr.*)) |second_entry| {
                var third_it = second_entry.value_ptr.iterator();
                while (third_it.next()) |second_inner_entry| {
                    const has_t_3 = has_t_2 or second_inner_entry.key_ptr.*[0] == 't';
                    if (std.mem.order(u8, second_inner_entry.key_ptr.*, inner_entry.key_ptr.*) != .gt) { continue; }
                    if (has_t_3 and first_entry.value_ptr.contains(second_inner_entry.key_ptr.*)) {
                        //try stdout.print("Inner {s} {s} {s}\n", .{first_entry.key_ptr.*, second_entry.key_ptr.*, second_inner_entry.key_ptr.*});
                        count += 1; 
                    }
                }
            }
        }
    }

    try stdout.print("Part 1 {}\n", .{count});
    try bw.flush(); // don't forget to flush!

    var best: usize = 0;
    var best_set: std.hash_map.StringHashMap(std.hash_map.StringHashMap(void)) = undefined;
    var test_it = sparse_adj.iterator();
    while (test_it.next()) |test_key| {
        var filtered_connections = std.hash_map.StringHashMap(std.hash_map.StringHashMap(void)).init(allocator);
        var test_it2 = sparse_adj.iterator();
        while (test_it2.next()) |entry| {
            if (!entry.value_ptr.*.contains(test_key.key_ptr.*)) { continue; }
            //try stdout.print("{s} is in the set\n", .{entry.key_ptr.*});
            try filtered_connections.put(entry.key_ptr.*, entry.value_ptr.*);
        }
        try filtered_connections.put(test_key.key_ptr.*, test_key.value_ptr.*);
        for (0..10) |i| {
            const min_size = 13 - i;
            //try stdout.print("Under test: {s} size={}\n", .{test_key.key_ptr.*, min_size});
            var current_connections = filtered_connections;
            while(true) {
                var new_connections = std.hash_map.StringHashMap(std.hash_map.StringHashMap(void)).init(allocator);
                var it = current_connections.iterator();
                while (it.next()) |entry| {
                    var inner_hash = std.hash_map.StringHashMap(void).init(allocator);
                    //try new_connections.put(entry.key_ptr.*, inner_hash);
                    var it2 = entry.value_ptr.*.iterator();
                    while (it2.next()) |entry2| {
                        if (!current_connections.contains(entry2.key_ptr.*)) {
                            //try stdout.print("Dropping {s} to {s} as not connected\n", .{entry.key_ptr.*, entry2.key_ptr.*});
                            continue;
                        }
                        //try stdout.print("Keeping {s} to {s} as connected\n", .{entry.key_ptr.*, entry2.key_ptr.*});
                        try inner_hash.put(entry2.key_ptr.*, undefined);
                    }
                    //try stdout.print("Key {s} has size {}\n", .{entry.key_ptr.*, inner_hash.count()});
                    try new_connections.put(entry.key_ptr.*, inner_hash);
                    //var inner_hash_maybe = new_connections.get(entry.key_ptr.*).?;
                    //try stdout.print("Key {s} has size {}\n", .{entry.key_ptr.*, inner_hash_maybe.count()});
                }
                //try stdout.print("new_connections size is {}\n", .{new_connections.count()});
                var bad_set = std.hash_map.StringHashMap(void).init(allocator);
                it = new_connections.iterator();
                while (it.next()) |entry| {
                    //try stdout.print("Conn size key={s} is {}\n", .{entry.key_ptr.*, entry.value_ptr.*.count()});
                    if (entry.value_ptr.*.count() < min_size) {
                        //try stdout.print("Dropping {s} because count is {}\n", .{entry.key_ptr.*, entry.value_ptr.*.count()});
                        try bad_set.put(entry.key_ptr.*, undefined);
                    }
                }
                var it2 = bad_set.iterator();
                while (it2.next()) |entry| {
                    _ = new_connections.remove(entry.key_ptr.*);
                }
                if (current_connections.count() == new_connections.count()) { break; }
                current_connections = new_connections;
            }
            //try stdout.print("Graph size key={s} n={} is {}\n", .{test_key.key_ptr.*, min_size, current_connections.count()});
            try bw.flush(); // don't forget to flush!
            if (current_connections.count() > 0 and min_size > best) {
                best = min_size;
                best_set = current_connections;
            }
        }
    }
    var winners: [][]const u8 = try allocator.alloc([]const u8, best+1);
    var idx: usize = 0;
    var best_it = best_set.iterator();
    while (best_it.next()) |best_key| {
        winners[idx] = best_key.key_ptr.*;
        idx += 1;
    }
    std.sort.insertion([]const u8, winners, {}, struct {pub fn x(_: void, a: []const u8, b: []const u8) bool {
        return std.mem.order(u8, a, b) == .lt;
    }}.x);
    try stdout.print("{s}\n", .{winners});
    for (winners) |best_key| {
        try stdout.print("{s},", .{best_key});
    }
    try stdout.print("\n", .{});
    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
