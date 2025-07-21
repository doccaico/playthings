const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_mod = b.addModule("lexbor", .{
        .root_source_file = b.path("src/lexbor.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    lib_mod.addLibraryPath(b.path("lib"));
    lib_mod.linkSystemLibrary("lexbor", .{});

    // tests

    const tests = b.addTest(.{
        .root_source_file = b.path("test/tests.zig"),
    });

    tests.root_module.addImport("lexbor", lib_mod);

    tests.addLibraryPath(b.path("lib"));
    tests.linkSystemLibrary("lexbor");

    const install_exe_test = b.addInstallArtifact(tests, .{});
    install_exe_test.step.dependOn(b.getInstallStep());

    const run_exe_tests = b.addRunArtifact(tests);
    run_exe_tests.step.dependOn(&install_exe_test.step);

    const test_all_step = b.step("test", "Run all tests");
    test_all_step.dependOn(&run_exe_tests.step);

    b.installBinFile("lib/lexbor.dll", "lexbor.dll");
}
