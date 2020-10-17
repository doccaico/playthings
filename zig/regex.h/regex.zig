pub const REG_EXTENDED = 1;
pub const __re_long_size_t = c_ulong;
pub const reg_syntax_t = c_ulong;

// struct
pub const re_pattern_buffer = struct {
    buffer: ?*opaque {},
    allocated: __re_long_size_t,
    used: __re_long_size_t,
    syntax: reg_syntax_t,
    fastmap: [*c]const u8,
    translate: [*c]const u8,
    re_nsub: c_uint,
    can_be_null: u1,
    regs_allocated: u2,
    fastmap_accurate: u1,
    no_sub: u1,
    not_bol: u1,
    not_eol: u1,
    newline_anchor: u1,
};
pub const regex_t = re_pattern_buffer;

pub const regoff_t = c_int;
pub const regmatch_t = extern struct {
    rm_so: regoff_t,
    rm_eo: regoff_t,
};

// function
pub extern fn regcomp(noalias __preg: ?*regex_t, noalias __pattern: [*c]const u8, __cflags: c_int) c_int;
pub extern fn regexec(noalias __preg: ?*const regex_t, noalias __String: [*c]const u8, __nmatch: usize, noalias __pmatch: [*c]regmatch_t, __eflags: c_int) c_int;
pub extern fn regfree(__preg: ?*regex_t) void;
