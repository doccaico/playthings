### (WIP) lexbor-zig
Experimental Zig build package and wrapper for [Lexbor](https://github.com/lexbor/lexbor/) v2.4.0  
Currently, it has only been tested on Windows.

#### Fetch
```
zig fetch --save=lexbor https://github.com/doccaico/lexbor-zig/archive/<git-commit-hash>.tar.gz
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

// src/main.zig

const std = @import("std");

const core = @import("lexbor").core;

pub fn main() !void {
    const array = core.array.create();
    const status = core.array.init(array, 32);

    try std.testing.expectEqual(status, .ok);

    _ = core.array.destroy(array, true);
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
```

See more options: [build.zig](https://github.com/doccaico/lexbor-zig/blob/main/build.zig)

#### How to build a static library (it included all modules)
```
git clone https://github.com/doccaico/lexbor-zig

zig build
```

#### How to build static libraries separately (e.g. html module)
```
git clone https://github.com/doccaico/lexbor-zig

zig build -Dhtml
```
