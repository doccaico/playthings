const std = @import("std");
const argsAlloc = std.process.argsAlloc;
const argsFree = std.process.argsFree;
const c_allocator = std.heap.c_allocator;
const exit = std.process.exit;
const print = std.debug.print;

const failed = @import("base.zig").failed;

const core = @import("lexbor").core;
const dom = @import("lexbor").dom;
const html = @import("lexbor").html;
const tag = @import("lexbor").tag;

fn usage() void {
    print("Usage:\n", .{});
    print("    zig build html-html2sexpr -- <file-path-to-html>\n", .{});
}

pub fn main() !void {
    var status: core.Status = undefined;
    var content_len: usize = undefined;

    var arena = std.heap.ArenaAllocator.init(c_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const args = try argsAlloc(allocator);
    defer argsFree(allocator, args);

    if (args.len != 2) {
        usage();
        exit(0);
    }

    const content = core.fs.fileEasyRead(args[1], &content_len) orelse {
        failed("Failed to read HTML file\n", .{});
    };
    defer core.free(content.ptr);

    // Initialization
    const document = html.document.create();
    defer _ = html.document.destroy(document);
    if (document == null) {
        print("Failed to create HTML Document", .{});
        // delete all allocated memory
        core.free(content.ptr);
        argsFree(allocator, args);
        arena.deinit();
        exit(1);
    }

    // Parse
    status = html.document.parse(document, content, content_len);
    if (status != .ok) {
        print("Failed to parse HTML", .{});
        // delete all allocated memory
        _ = html.document.destroy(document);
        core.free(content.ptr);
        argsFree(allocator, args);
        arena.deinit();
        exit(1);
    }

    status = treeWalker(dom.interface.node(document).?.first_child, serializeCb, null);
    if (status != .ok) {
        print("Failed to convert HTML to S-Expression", .{});
        // delete all allocated memory
        _ = html.document.destroy(document);
        core.free(content.ptr);
        argsFree(allocator, args);
        arena.deinit();
        exit(1);
    }
}

fn treeWalker(node_: ?*dom.Node, cb: html.serialize.CbF, ctx: ?*anyopaque) core.Status {
    var status: core.Status = undefined;
    var name_len: usize = undefined;
    var skip_it: bool = undefined;
    const root = node_.?.parent;
    var node = node_;

    while (node != null) {
        if (node.?.type == .element) {
            status = @enumFromInt(cb.?("(", 1, ctx));
            if (status != .ok) return status;

            const name = dom.element.qualifiedName(dom.interface.element(node), &name_len);

            status = @enumFromInt(cb.?(@ptrCast(name.?.ptr), name_len, ctx));
            if (status != .ok) return status;

            status = attributes(node, cb, ctx);
            if (status != .ok) return status;

            if (@as(tag.IdEnum, @enumFromInt(node.?.local_name)) == .template) {
                const temp = html.interface.template(node);

                if (temp.content != null) {
                    if (temp.content.?.node.first_child != null) {
                        status = treeWalker(&temp.content.?.node, cb, ctx);
                        if (status != .ok) return status;
                    }
                }
            }
            skip_it = false;
        } else {
            skip_it = true;
        }

        if (skip_it == false and node.?.first_child != null) {
            node = node.?.first_child;
        } else {
            while (node != root and node.?.next == null) {
                if (node.?.type == .element) {
                    status = @enumFromInt(cb.?(")", 1, ctx));
                    if (status != .ok) return status;
                }
                node = node.?.parent;
            }

            if (node.?.type == .element) {
                status = @enumFromInt(cb.?(")", 1, ctx));
                if (status != .ok) return status;
            }

            if (node == root) {
                break;
            }

            node = node.?.next;
        }
    }

    return .ok;
}

fn attributes(node: ?*dom.Node, cb: html.serialize.CbF, ctx: ?*anyopaque) core.Status {
    var status: core.Status = undefined;
    var data: ?[]const u8 = undefined;
    var data_len: usize = undefined;

    var attr = dom.element.firstAttribute(dom.interface.element(node));

    while (attr != null) {
        status = @enumFromInt(cb.?("(", 1, ctx));
        if (status != .ok) return status;

        data = dom.attr.qualifiedName(attr, &data_len);

        status = @enumFromInt(cb.?(@ptrCast(data.?.ptr), data_len, ctx));
        if (status != .ok) return status;

        data = dom.attr.value(attr, &data_len);

        if (data != null) {
            status = @enumFromInt(cb.?(" '", 2, ctx));
            if (status != .ok) return status;

            status = @enumFromInt(cb.?(@ptrCast(data.?.ptr), data_len, ctx));
            if (status != .ok) return status;

            status = @enumFromInt(cb.?("'", 1, ctx));
            if (status != .ok) return status;
        }

        status = @enumFromInt(cb.?(")", 1, ctx));
        if (status != .ok) return status;

        attr = dom.element.nextAttribute(attr);
    }

    return .ok;
}

fn serializeCb(data: ?[*]const core.CharType, len: usize, ctx: ?*anyopaque) callconv(.C) core.StatusType {
    _ = ctx;
    print("{s}", .{data.?[0..len]});
    return @intFromEnum(core.Status.ok);
}
