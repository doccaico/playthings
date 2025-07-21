### (WIP) lexbor-zig-dynamic (currently windows only)
Experimental Zig wrapper for [Lexbor](https://github.com/lexbor/lexbor/) v2.4.0

#### Fetch
```
zig fetch --save=lexbor https://github.com/doccaico/lexbor-zig-dynamic/archive/<git-commit-hash>.tar.gz
```

#### Usage
```zig
// build.zig

// const exe = b.addExecutable(.{
// ...
const lexbor_dep = b.dependency("lexbor", .{ .target = target, .optimize = optimize });
exe.root_module.addImport("lexbor", lexbor_dep.module("lexbor"));

const install_lib = b.addInstallBinFile(lexbor_dep.path("lib/lexbor.dll"), "lexbor.dll");
b.default_step.dependOn(&install_lib.step);

// src/main.zig

const std = @import("std");

const lb = @import("lexbor");

pub fn main() !void {
    var array = lb.core.array.create().?;
    const status = array.init(32);

    try std.testing.expectEqual(status, @intFromEnum(lb.core.Status.ok));

    _ = array.destroy(true);
}
```
