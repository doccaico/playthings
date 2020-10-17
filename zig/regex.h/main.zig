const std = @import("std");
const r = @import("./regex.zig");

const max_matches = 1;

fn match(pexp: *r.regex_t, sz: [*c]const u8) void {
    var matches: [max_matches]r.regmatch_t = undefined;

    if (r.regexec(pexp, sz, max_matches, &matches, 0) == 0) {
        std.debug.print("\"{s}\" matches characters {d} - {d}\n", .{ sz, matches[0].rm_so, matches[0].rm_eo });
    } else {
        std.debug.print("\"{s}\" does not match\n", .{sz});
    }
}

pub fn main() void {
    var rv: c_int = undefined;
    var exp: r.regex_t = undefined;

    std.debug.print("{}\n", .{@sizeOf(r.regex_t)});

    rv = r.regcomp(&exp, "-?[0-9]+(\\.[0-9]+)?", r.REG_EXTENDED);

    match(&exp, "0");
    match(&exp, "0.");
    match(&exp, "0.0");
    match(&exp, "10.1");
    match(&exp, "-10.1");
    match(&exp, "a");
    match(&exp, "a.1");
    match(&exp, "0.a");
    match(&exp, "0.1a");
    match(&exp, "hello");

    r.regfree(&exp);
}
