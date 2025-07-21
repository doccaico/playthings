### (WIP) lexbor-zig
Experimental Zig build package and wrapper for [Lexbor v2.4.0](https://github.com/lexbor/lexbor/tree/v2.4.0).  
Currently, it has only been tested on Windows.

#### Fetch
```sh
$ zig fetch --save=lexbor https://github.com/doccaico/lexbor-zig/archive/<git-commit-hash>.tar.gz

# or master branch

$ zig fetch --save=lexbor git+https://github.com/doccaico/lexbor-zig
```

#### Using as a single static library (it included all modules)
```zig
// build.zig

// const exe = b.addExecutable(.{
// ...
// lexbor
const lexbor = b.dependency("lexbor", .{
    .target = target,
    .optimize = optimize,
});
exe.addIncludePath(lexbor.path("lib"));
exe.linkLibrary(lexbor.artifact("liblexbor"));

// src/main.zig

const std = @import("std");

const c = @cImport({
    @cInclude("lexbor/core/array.h");
});

pub fn main() !void {
    const array = c.lexbor_array_create();
    _ = c.lexbor_array_destroy(array, true);
}
```

#### Using individual modules (e.g. html module)
```zig
// build.zig

// const exe = b.addExecutable(.{
// ...
// lexbor
const lexbor = b.dependency("lexbor", .{
    .target = target,
    .optimize = optimize,
    .html = true,
});

exe.addIncludePath(lexbor.path("lib"));
exe.linkLibrary(lexbor.artifact("liblexbor-html"));
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
