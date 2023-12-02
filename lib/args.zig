const std = @import("std");
const panic = std.debug.panic;

pub fn getPart() u8 {
    var args = std.process.args();
    _ = args.next();

    if (args.next()) |part| {
        return std.fmt.parseInt(u8, part, 10) catch panic("invalid part arg: {s}", .{part});
    }
    return 1;
}
