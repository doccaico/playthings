### (WIP) lexbor-zig-static (currently windows only)
Experimental Zig build package and wrapper for [Lexbor](https://github.com/lexbor/lexbor/) v2.4.0

#### Fetch
```
zig fetch --save=lexbor https://github.com/doccaico/lexbor-zig-static/archive/<git-commit-hash>.tar.gz
```

#### Using as a single static library (it included all modules)
```zig
// build.zig

// const exe = b.addExecutable(.{
// ...
const lexbor = b.dependency("lexbor", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("lexbor", lexbor.module("lexbor"));
exe.linkLibrary(lexbor.artifact("liblexbor"));

// src/main.zig

const std = @import("std");

const lb = @import("lexbor");

pub fn main() !void {
    var array = lb.core.Array.create().?;
    const status = array.init(32);

    try std.testing.expectEqual(status, @intFromEnum(lb.core.Status.ok));

    _ = array.destroy(true);
}
```

#### Using individual modules (e.g. html module)
```zig
// build.zig

// const exe = b.addExecutable(.{
// ...
const lexbor = b.dependency("lexbor", .{
    .target = target,
    .optimize = optimize,
    .html = true,
});

exe.root_module.addImport("lexbor", lexbor.module("lexbor"));
exe.linkLibrary(lexbor.artifact("liblexbor-html"));
```

See more options: [build.zig](https://github.com/doccaico/lexbor-zig-static/blob/main/build.zig)

#### How to build a static library (it included all modules)
```
git clone https://github.com/doccaico/lexbor-zig-static

zig build
```

#### How to build static libraries separately (e.g. html module)
```
git clone https://github.com/doccaico/lexbor-zig-static

zig build -Dhtml
```

#### Test (currently, it has only been tested on Windows)
```
zig run test
```
