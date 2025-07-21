package test_core_avl

import "core:c"
// import "core:fmt"
import "core:mem"
import "core:testing"

import lb "../../lexbor"

avl_test_ctx_t :: struct {
	remove: c.size_t,
	result: [^]c.size_t,
	p:      [^]c.size_t,
}

avl_cb :: proc "c" (
	avl: ^lb.lexbor_avl_t,
	root: ^^lb.lexbor_avl_node_t,
	node: ^lb.lexbor_avl_node_t,
	ctx: rawptr,
) -> lb.lxb_status_t {
	test := (^avl_test_ctx_t)(ctx)

	test.p[0] = node.type
	test.p = &test.p[1]

	if node.type == test.remove {
		lb.lexbor_avl_remove_by_node(avl, root, node)
	}

	return lb.lxb_status_t(lb.lexbor_status_t.LXB_STATUS_OK)
}

test_for_three :: proc(t: ^testing.T, avl: ^lb.lexbor_avl_t, root: ^lb.lexbor_avl_node_t) {
	node: ^lb.lexbor_avl_node_t = ---

	testing.expect(t, root != nil)
	testing.expect_value(t, root.type, 2)

	// 1
	node = lb.lexbor_avl_search(avl, root, 1)
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 1)
	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 2)

	// 2
	node = node.parent
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 2)

	testing.expect(t, node.left != nil)
	testing.expect_value(t, node.left.type, 1)

	testing.expect(t, node.right != nil)
	testing.expect_value(t, node.right.type, 3)

	testing.expect_value(t, node.parent, nil)

	// 3
	node = node.right
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 3)
	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 2)
}

@(test)
init :: proc(t: ^testing.T) {
	avl := lb.lexbor_avl_create()
	status := lb.lexbor_avl_init(avl, 1024, 0)

	testing.expect_value(t, lb.lexbor_status_t(status), lb.lexbor_status_t.LXB_STATUS_OK)

	lb.lexbor_avl_destroy(avl, true)
}

@(test)
init_null :: proc(t: ^testing.T) {
	status := lb.lexbor_avl_init(nil, 1024, 0)
	testing.expect_value(
		t,
		lb.lexbor_status_t(status),
		lb.lexbor_status_t.LXB_STATUS_ERROR_OBJECT_IS_NULL,
	)
}

@(test)
init_stack :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	status := lb.lexbor_avl_init(&avl, 1024, 0)

	testing.expect_value(t, lb.lexbor_status_t(status), lb.lexbor_status_t.LXB_STATUS_OK)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
init_args :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t
	status := lb.lexbor_avl_init(&avl, 0, 0)

	testing.expect_value(
		t,
		lb.lexbor_status_t(status),
		lb.lexbor_status_t.LXB_STATUS_ERROR_WRONG_ARGS,
	)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
node_make :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	node := lb.lexbor_avl_node_make(&avl, 1, &avl)

	testing.expect(t, node != nil)

	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect_value(t, node.parent, nil)
	testing.expect_value(t, node.height, 0)
	testing.expect_value(t, node.type, 1)
	testing.expect_value(t, node.value, &avl)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
node_clean :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	node := lb.lexbor_avl_node_make(&avl, 1, &avl)

	testing.expect(t, node != nil)

	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect_value(t, node.parent, nil)
	testing.expect_value(t, node.height, 0)
	testing.expect_value(t, node.type, 1)
	testing.expect_value(t, node.value, &avl)

	lb.lexbor_avl_node_clean(node)

	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect_value(t, node.parent, nil)
	testing.expect_value(t, node.height, 0)
	testing.expect_value(t, node.type, 0)
	testing.expect_value(t, node.value, nil)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
node_destroy :: proc(t: ^testing.T) {
	avl := lb.lexbor_avl_create()
	lb.lexbor_avl_init(avl, 1024, 0)

	node := lb.lexbor_avl_node_make(avl, 1, &avl)

	testing.expect(t, node != nil)

	testing.expect_value(t, lb.lexbor_avl_node_destroy(avl, node, true), nil)

	node = lb.lexbor_avl_node_make(avl, 1, &avl)
	testing.expect(t, node != nil)

	testing.expect_value(t, lb.lexbor_avl_node_destroy(avl, node, false), node)
	testing.expect_value(t, lb.lexbor_avl_node_destroy(avl, nil, false), nil)

	lb.lexbor_avl_destroy(avl, true)
}

@(test)
tree_3_0 :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	root: ^lb.lexbor_avl_node_t = nil

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	lb.lexbor_avl_insert(&avl, &root, 1, (rawptr)((uintptr)(1)))
	lb.lexbor_avl_insert(&avl, &root, 2, (rawptr)((uintptr)(2)))
	lb.lexbor_avl_insert(&avl, &root, 3, (rawptr)((uintptr)(3)))

	test_for_three(t, &avl, root)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
tree_3_1 :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	root: ^lb.lexbor_avl_node_t = nil

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	lb.lexbor_avl_insert(&avl, &root, 3, (rawptr)((uintptr)(3)))
	lb.lexbor_avl_insert(&avl, &root, 2, (rawptr)((uintptr)(2)))
	lb.lexbor_avl_insert(&avl, &root, 1, (rawptr)((uintptr)(1)))

	test_for_three(t, &avl, root)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
tree_3_2 :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	root: ^lb.lexbor_avl_node_t = nil

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	lb.lexbor_avl_insert(&avl, &root, 2, (rawptr)((uintptr)(2)))
	lb.lexbor_avl_insert(&avl, &root, 1, (rawptr)((uintptr)(1)))
	lb.lexbor_avl_insert(&avl, &root, 3, (rawptr)((uintptr)(3)))

	test_for_three(t, &avl, root)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
tree_3_3 :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	root: ^lb.lexbor_avl_node_t = nil

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	lb.lexbor_avl_insert(&avl, &root, 2, (rawptr)((uintptr)(2)))
	lb.lexbor_avl_insert(&avl, &root, 3, (rawptr)((uintptr)(3)))
	lb.lexbor_avl_insert(&avl, &root, 1, (rawptr)((uintptr)(1)))

	test_for_three(t, &avl, root)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
tree_3_4 :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	root: ^lb.lexbor_avl_node_t = nil

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	lb.lexbor_avl_insert(&avl, &root, 3, (rawptr)((uintptr)(3)))
	lb.lexbor_avl_insert(&avl, &root, 1, (rawptr)((uintptr)(1)))
	lb.lexbor_avl_insert(&avl, &root, 2, (rawptr)((uintptr)(2)))

	test_for_three(t, &avl, root)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
tree_3_5 :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	root: ^lb.lexbor_avl_node_t = nil

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	lb.lexbor_avl_insert(&avl, &root, 1, (rawptr)((uintptr)(1)))
	lb.lexbor_avl_insert(&avl, &root, 3, (rawptr)((uintptr)(3)))
	lb.lexbor_avl_insert(&avl, &root, 2, (rawptr)((uintptr)(2)))

	test_for_three(t, &avl, root)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
tree_4 :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	root: ^lb.lexbor_avl_node_t = nil
	node: ^lb.lexbor_avl_node_t = ---

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	lb.lexbor_avl_insert(&avl, &root, 1, (rawptr)((uintptr)(1)))
	lb.lexbor_avl_insert(&avl, &root, 2, (rawptr)((uintptr)(2)))
	lb.lexbor_avl_insert(&avl, &root, 3, (rawptr)((uintptr)(3)))
	lb.lexbor_avl_insert(&avl, &root, 4, (rawptr)((uintptr)(4)))

	// 1
	node = lb.lexbor_avl_search(&avl, root, 1)
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 1)
	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 2)

	// 2
	node = node.parent
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 2)

	testing.expect(t, node.left != nil)
	testing.expect_value(t, node.left.type, 1)

	testing.expect(t, node.right != nil)
	testing.expect_value(t, node.right.type, 3)

	testing.expect_value(t, node.parent, nil)

	// 3
	node = node.right
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 3)
	testing.expect_value(t, node.left, nil)

	testing.expect(t, node.right != nil)
	testing.expect_value(t, node.right.type, 4)

	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 2)

	// 4
	node = node.right
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 4)
	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 3)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
tree_5 :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	root: ^lb.lexbor_avl_node_t = nil
	node: ^lb.lexbor_avl_node_t = ---

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	lb.lexbor_avl_insert(&avl, &root, 1, (rawptr)((uintptr)(1)))
	lb.lexbor_avl_insert(&avl, &root, 2, (rawptr)((uintptr)(2)))
	lb.lexbor_avl_insert(&avl, &root, 3, (rawptr)((uintptr)(3)))
	lb.lexbor_avl_insert(&avl, &root, 4, (rawptr)((uintptr)(4)))
	lb.lexbor_avl_insert(&avl, &root, 5, (rawptr)((uintptr)(5)))

	// 1
	node = lb.lexbor_avl_search(&avl, root, 1)
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 1)
	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 2)

	// 2
	node = node.parent
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 2)

	testing.expect(t, node.left != nil)
	testing.expect_value(t, node.left.type, 1)

	testing.expect(t, node.right != nil)
	testing.expect_value(t, node.right.type, 4)

	testing.expect_value(t, node.parent, nil)

	// 4
	node = node.right
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 4)

	testing.expect(t, node.left != nil)
	testing.expect_value(t, node.left.type, 3)

	testing.expect(t, node.right != nil)
	testing.expect_value(t, node.right.type, 5)

	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 2)

	// 3
	node = node.left
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 3)
	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 4)

	// 5
	node = node.parent.right
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 5)
	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 4)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
delete_1L :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	root: ^lb.lexbor_avl_node_t = nil
	node: ^lb.lexbor_avl_node_t = ---

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	lb.lexbor_avl_insert(&avl, &root, 1, (rawptr)((uintptr)(1)))
	lb.lexbor_avl_insert(&avl, &root, 2, (rawptr)((uintptr)(2)))
	lb.lexbor_avl_insert(&avl, &root, 3, (rawptr)((uintptr)(3)))
	lb.lexbor_avl_insert(&avl, &root, 4, (rawptr)((uintptr)(4)))

	testing.expect(t, root != nil)

	testing.expect(t, lb.lexbor_avl_remove(&avl, &root, 1) != nil)
	testing.expect(t, root != nil)

	// 2
	node = lb.lexbor_avl_search(&avl, root, 2)
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 2)
	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 3)

	// 3
	node = node.parent
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 3)

	testing.expect(t, node.left != nil)
	testing.expect_value(t, node.left.type, 2)

	testing.expect(t, node.right != nil)
	testing.expect_value(t, node.right.type, 4)

	testing.expect_value(t, node.parent, nil)

	// 4
	node = node.right
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 4)
	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 3)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
delete_1R :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	root: ^lb.lexbor_avl_node_t = nil
	node: ^lb.lexbor_avl_node_t = ---

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	lb.lexbor_avl_insert(&avl, &root, 3, (rawptr)((uintptr)(3)))
	lb.lexbor_avl_insert(&avl, &root, 2, (rawptr)((uintptr)(2)))
	lb.lexbor_avl_insert(&avl, &root, 1, (rawptr)((uintptr)(1)))
	lb.lexbor_avl_insert(&avl, &root, 4, (rawptr)((uintptr)(4)))

	testing.expect(t, root != nil)

	testing.expect(t, lb.lexbor_avl_remove(&avl, &root, 4) != nil)
	testing.expect(t, root != nil)

	// 1
	node = lb.lexbor_avl_search(&avl, root, 1)
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 1)
	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 2)

	// 2
	node = node.parent
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 2)

	testing.expect(t, node.left != nil)
	testing.expect_value(t, node.left.type, 1)

	testing.expect(t, node.right != nil)
	testing.expect_value(t, node.right.type, 3)

	testing.expect_value(t, node.parent, nil)

	// 3
	node = node.right
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 3)
	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 2)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
delete_2L :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	root: ^lb.lexbor_avl_node_t = nil
	node: ^lb.lexbor_avl_node_t = ---

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	lb.lexbor_avl_insert(&avl, &root, 2, (rawptr)((uintptr)(2)))
	lb.lexbor_avl_insert(&avl, &root, 1, (rawptr)((uintptr)(1)))
	lb.lexbor_avl_insert(&avl, &root, 4, (rawptr)((uintptr)(4)))
	lb.lexbor_avl_insert(&avl, &root, 3, (rawptr)((uintptr)(3)))

	testing.expect(t, root != nil)

	testing.expect(t, lb.lexbor_avl_remove(&avl, &root, 1) != nil)
	testing.expect(t, root != nil)

	// 2
	node = lb.lexbor_avl_search(&avl, root, 2)
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 2)
	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 3)

	// 3
	node = node.parent
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 3)

	testing.expect(t, node.left != nil)
	testing.expect_value(t, node.left.type, 2)

	testing.expect(t, node.right != nil)
	testing.expect_value(t, node.right.type, 4)

	testing.expect_value(t, node.parent, nil)

	// 4
	node = node.right
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 4)
	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 3)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
delete_2R :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	root: ^lb.lexbor_avl_node_t = nil
	node: ^lb.lexbor_avl_node_t = ---

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	lb.lexbor_avl_insert(&avl, &root, 3, (rawptr)((uintptr)(3)))
	lb.lexbor_avl_insert(&avl, &root, 1, (rawptr)((uintptr)(1)))
	lb.lexbor_avl_insert(&avl, &root, 2, (rawptr)((uintptr)(2)))
	lb.lexbor_avl_insert(&avl, &root, 4, (rawptr)((uintptr)(4)))

	testing.expect(t, root != nil)

	testing.expect(t, lb.lexbor_avl_remove(&avl, &root, 4) != nil)
	testing.expect(t, root != nil)

	// 1
	node = lb.lexbor_avl_search(&avl, root, 1)
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 1)
	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 2)

	// 2
	node = node.parent
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 2)

	testing.expect(t, node.left != nil)
	testing.expect_value(t, node.left.type, 1)

	testing.expect(t, node.right != nil)
	testing.expect_value(t, node.right.type, 3)

	testing.expect_value(t, node.parent, nil)

	// 3
	node = node.right
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 3)
	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 2)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
delete_sub_1L :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	root: ^lb.lexbor_avl_node_t = nil
	node: ^lb.lexbor_avl_node_t = ---

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	lb.lexbor_avl_insert(&avl, &root, 3, (rawptr)((uintptr)(3)))
	lb.lexbor_avl_insert(&avl, &root, 2, (rawptr)((uintptr)(2)))
	lb.lexbor_avl_insert(&avl, &root, 5, (rawptr)((uintptr)(5)))
	lb.lexbor_avl_insert(&avl, &root, 1, (rawptr)((uintptr)(1)))
	lb.lexbor_avl_insert(&avl, &root, 4, (rawptr)((uintptr)(4)))
	lb.lexbor_avl_insert(&avl, &root, 6, (rawptr)((uintptr)(6)))
	lb.lexbor_avl_insert(&avl, &root, 7, (rawptr)((uintptr)(7)))

	testing.expect(t, root != nil)

	testing.expect(t, lb.lexbor_avl_remove(&avl, &root, 1) != nil)
	testing.expect(t, root != nil)

	// 2
	node = lb.lexbor_avl_search(&avl, root, 2)
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 2)
	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 3)

	// 3
	node = node.parent
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 3)

	testing.expect(t, node.left != nil)
	testing.expect_value(t, node.left.type, 2)

	testing.expect(t, node.right != nil)
	testing.expect_value(t, node.right.type, 4)

	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 5)

	// 4
	node = node.right
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 4)
	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 3)

	// 5
	node = node.parent.parent
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 5)

	testing.expect(t, node.left != nil)
	testing.expect_value(t, node.left.type, 3)

	testing.expect(t, node.right != nil)
	testing.expect_value(t, node.right.type, 6)

	testing.expect_value(t, node.parent, nil)

	// 6
	node = node.right
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 6)
	testing.expect_value(t, node.left, nil)

	testing.expect(t, node.right != nil)
	testing.expect_value(t, node.right.type, 7)

	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 5)

	// 7
	node = node.right
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 7)
	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 6)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
delete_sub_1R :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	root: ^lb.lexbor_avl_node_t = nil
	node: ^lb.lexbor_avl_node_t = ---

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	lb.lexbor_avl_insert(&avl, &root, 5, (rawptr)((uintptr)(5)))
	lb.lexbor_avl_insert(&avl, &root, 3, (rawptr)((uintptr)(3)))
	lb.lexbor_avl_insert(&avl, &root, 6, (rawptr)((uintptr)(6)))
	lb.lexbor_avl_insert(&avl, &root, 2, (rawptr)((uintptr)(2)))
	lb.lexbor_avl_insert(&avl, &root, 4, (rawptr)((uintptr)(4)))
	lb.lexbor_avl_insert(&avl, &root, 7, (rawptr)((uintptr)(7)))
	lb.lexbor_avl_insert(&avl, &root, 1, (rawptr)((uintptr)(1)))

	testing.expect(t, root != nil)

	testing.expect(t, lb.lexbor_avl_remove(&avl, &root, 7) != nil)
	testing.expect(t, root != nil)

	// 1
	node = lb.lexbor_avl_search(&avl, root, 1)
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 1)
	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 2)

	// 2
	node = node.parent
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 2)

	testing.expect(t, node.left != nil)
	testing.expect_value(t, node.left.type, 1)

	testing.expect_value(t, node.right, nil)

	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 3)

	// 3
	node = node.parent
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 3)

	testing.expect(t, node.left != nil)
	testing.expect_value(t, node.left.type, 2)

	testing.expect(t, node.right != nil)
	testing.expect_value(t, node.right.type, 5)

	testing.expect_value(t, node.parent, nil)

	// 5
	node = node.right
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 5)

	testing.expect(t, node.left != nil)
	testing.expect_value(t, node.left.type, 4)

	testing.expect(t, node.right != nil)
	testing.expect_value(t, node.right.type, 6)

	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 3)

	// 4
	node = node.left
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 4)
	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 5)

	// 6
	node = node.parent.right
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 6)
	testing.expect_value(t, node.left, nil)
	testing.expect_value(t, node.right, nil)
	testing.expect(t, node.parent != nil)
	testing.expect_value(t, node.parent.type, 5)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
delete_10_0 :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	root: ^lb.lexbor_avl_node_t = nil
	node: ^lb.lexbor_avl_node_t = ---

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	lb.lexbor_avl_insert(&avl, &root, 1, (rawptr)((uintptr)(1)))
	lb.lexbor_avl_insert(&avl, &root, 2, (rawptr)((uintptr)(2)))
	lb.lexbor_avl_insert(&avl, &root, 3, (rawptr)((uintptr)(3)))
	lb.lexbor_avl_insert(&avl, &root, 4, (rawptr)((uintptr)(4)))
	lb.lexbor_avl_insert(&avl, &root, 5, (rawptr)((uintptr)(5)))
	lb.lexbor_avl_insert(&avl, &root, 6, (rawptr)((uintptr)(6)))
	lb.lexbor_avl_insert(&avl, &root, 7, (rawptr)((uintptr)(7)))
	lb.lexbor_avl_insert(&avl, &root, 8, (rawptr)((uintptr)(8)))
	lb.lexbor_avl_insert(&avl, &root, 9, (rawptr)((uintptr)(9)))
	lb.lexbor_avl_insert(&avl, &root, 10, (rawptr)((uintptr)(10)))

	testing.expect(t, root != nil)

	testing.expect(t, lb.lexbor_avl_remove(&avl, &root, 8) != nil)
	testing.expect(t, root != nil)

	// 4
	node = lb.lexbor_avl_search(&avl, root, 4)
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 4)

	testing.expect(t, node.left != nil)
	testing.expect(t, node.right != nil)
	testing.expect_value(t, node.parent, nil)

	testing.expect_value(t, node.left.type, 2)
	testing.expect_value(t, node.left.left.type, 1)
	testing.expect_value(t, node.left.right.type, 3)


	testing.expect_value(t, node.right.type, 7)
	testing.expect_value(t, node.right.left.type, 6)
	testing.expect_value(t, node.right.right.type, 9)
	testing.expect_value(t, node.right.left.left.type, 5)
	testing.expect_value(t, node.right.right.right.type, 10)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
delete_10_1 :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	root: ^lb.lexbor_avl_node_t = nil
	node: ^lb.lexbor_avl_node_t = ---

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	lb.lexbor_avl_insert(&avl, &root, 1, (rawptr)((uintptr)(1)))
	lb.lexbor_avl_insert(&avl, &root, 2, (rawptr)((uintptr)(2)))
	lb.lexbor_avl_insert(&avl, &root, 3, (rawptr)((uintptr)(3)))
	lb.lexbor_avl_insert(&avl, &root, 4, (rawptr)((uintptr)(4)))
	lb.lexbor_avl_insert(&avl, &root, 5, (rawptr)((uintptr)(5)))
	lb.lexbor_avl_insert(&avl, &root, 6, (rawptr)((uintptr)(6)))
	lb.lexbor_avl_insert(&avl, &root, 7, (rawptr)((uintptr)(7)))
	lb.lexbor_avl_insert(&avl, &root, 8, (rawptr)((uintptr)(8)))
	lb.lexbor_avl_insert(&avl, &root, 9, (rawptr)((uintptr)(9)))
	lb.lexbor_avl_insert(&avl, &root, 10, (rawptr)((uintptr)(10)))

	testing.expect(t, root != nil)

	testing.expect(t, lb.lexbor_avl_remove(&avl, &root, 8) != nil)
	testing.expect(t, root != nil)
	testing.expect(t, lb.lexbor_avl_remove(&avl, &root, 5) != nil)
	testing.expect(t, root != nil)

	// 4
	node = lb.lexbor_avl_search(&avl, root, 4)
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 4)

	testing.expect(t, node.left != nil)
	testing.expect(t, node.right != nil)
	testing.expect_value(t, node.parent, nil)

	testing.expect_value(t, node.left.type, 2)
	testing.expect_value(t, node.left.left.type, 1)
	testing.expect_value(t, node.left.right.type, 3)


	testing.expect_value(t, node.right.type, 7)
	testing.expect_value(t, node.right.left.type, 6)
	testing.expect_value(t, node.right.right.type, 9)
	testing.expect_value(t, node.right.right.right.type, 10)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
delete_10_2 :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	root: ^lb.lexbor_avl_node_t = nil
	node: ^lb.lexbor_avl_node_t = ---

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	lb.lexbor_avl_insert(&avl, &root, 1, (rawptr)((uintptr)(1)))
	lb.lexbor_avl_insert(&avl, &root, 2, (rawptr)((uintptr)(2)))
	lb.lexbor_avl_insert(&avl, &root, 3, (rawptr)((uintptr)(3)))
	lb.lexbor_avl_insert(&avl, &root, 4, (rawptr)((uintptr)(4)))
	lb.lexbor_avl_insert(&avl, &root, 5, (rawptr)((uintptr)(5)))
	lb.lexbor_avl_insert(&avl, &root, 6, (rawptr)((uintptr)(6)))
	lb.lexbor_avl_insert(&avl, &root, 7, (rawptr)((uintptr)(7)))
	lb.lexbor_avl_insert(&avl, &root, 8, (rawptr)((uintptr)(8)))
	lb.lexbor_avl_insert(&avl, &root, 9, (rawptr)((uintptr)(9)))
	lb.lexbor_avl_insert(&avl, &root, 10, (rawptr)((uintptr)(10)))

	testing.expect(t, root != nil)

	testing.expect(t, lb.lexbor_avl_remove(&avl, &root, 8) != nil)
	testing.expect(t, root != nil)
	testing.expect(t, lb.lexbor_avl_remove(&avl, &root, 6) != nil)
	testing.expect(t, root != nil)

	// 4
	node = lb.lexbor_avl_search(&avl, root, 4)
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 4)

	testing.expect(t, node.left != nil)
	testing.expect(t, node.right != nil)
	testing.expect_value(t, node.parent, nil)

	testing.expect_value(t, node.left.type, 2)
	testing.expect_value(t, node.left.left.type, 1)
	testing.expect_value(t, node.left.right.type, 3)


	testing.expect_value(t, node.right.type, 7)
	testing.expect_value(t, node.right.left.type, 5)
	testing.expect_value(t, node.right.right.type, 9)
	testing.expect_value(t, node.right.right.right.type, 10)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
delete_10_3 :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	root: ^lb.lexbor_avl_node_t = nil
	node: ^lb.lexbor_avl_node_t = ---

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	lb.lexbor_avl_insert(&avl, &root, 1, (rawptr)((uintptr)(1)))
	lb.lexbor_avl_insert(&avl, &root, 2, (rawptr)((uintptr)(2)))
	lb.lexbor_avl_insert(&avl, &root, 3, (rawptr)((uintptr)(3)))
	lb.lexbor_avl_insert(&avl, &root, 4, (rawptr)((uintptr)(4)))
	lb.lexbor_avl_insert(&avl, &root, 5, (rawptr)((uintptr)(5)))
	lb.lexbor_avl_insert(&avl, &root, 6, (rawptr)((uintptr)(6)))
	lb.lexbor_avl_insert(&avl, &root, 7, (rawptr)((uintptr)(7)))
	lb.lexbor_avl_insert(&avl, &root, 8, (rawptr)((uintptr)(8)))
	lb.lexbor_avl_insert(&avl, &root, 9, (rawptr)((uintptr)(9)))
	lb.lexbor_avl_insert(&avl, &root, 10, (rawptr)((uintptr)(10)))

	testing.expect(t, root != nil)

	testing.expect(t, lb.lexbor_avl_remove(&avl, &root, 9) != nil)
	testing.expect(t, root != nil)

	// 4
	node = lb.lexbor_avl_search(&avl, root, 4)
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 4)

	testing.expect(t, node.left != nil)
	testing.expect(t, node.right != nil)
	testing.expect_value(t, node.parent, nil)

	testing.expect_value(t, node.left.type, 2)
	testing.expect_value(t, node.left.left.type, 1)
	testing.expect_value(t, node.left.right.type, 3)


	testing.expect_value(t, node.right.type, 8)
	testing.expect_value(t, node.right.left.type, 6)
	testing.expect_value(t, node.right.right.type, 10)
	testing.expect_value(t, node.right.left.left.type, 5)
	testing.expect_value(t, node.right.left.right.type, 7)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
delete_10_4 :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	root: ^lb.lexbor_avl_node_t = nil
	node: ^lb.lexbor_avl_node_t = ---

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	lb.lexbor_avl_insert(&avl, &root, 1, (rawptr)((uintptr)(1)))
	lb.lexbor_avl_insert(&avl, &root, 2, (rawptr)((uintptr)(2)))
	lb.lexbor_avl_insert(&avl, &root, 3, (rawptr)((uintptr)(3)))
	lb.lexbor_avl_insert(&avl, &root, 4, (rawptr)((uintptr)(4)))
	lb.lexbor_avl_insert(&avl, &root, 5, (rawptr)((uintptr)(5)))
	lb.lexbor_avl_insert(&avl, &root, 6, (rawptr)((uintptr)(6)))
	lb.lexbor_avl_insert(&avl, &root, 7, (rawptr)((uintptr)(7)))
	lb.lexbor_avl_insert(&avl, &root, 8, (rawptr)((uintptr)(8)))
	lb.lexbor_avl_insert(&avl, &root, 9, (rawptr)((uintptr)(9)))
	lb.lexbor_avl_insert(&avl, &root, 10, (rawptr)((uintptr)(10)))

	testing.expect(t, root != nil)

	testing.expect(t, lb.lexbor_avl_remove(&avl, &root, 4) != nil)
	testing.expect(t, root != nil)

	// 3
	node = lb.lexbor_avl_search(&avl, root, 3)
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 3)

	testing.expect(t, node.left != nil)
	testing.expect(t, node.right != nil)
	testing.expect_value(t, node.parent, nil)

	testing.expect_value(t, node.left.type, 2)
	testing.expect_value(t, node.left.left.type, 1)

	testing.expect_value(t, node.right.type, 8)
	testing.expect_value(t, node.right.left.type, 6)
	testing.expect_value(t, node.right.right.type, 9)
	testing.expect_value(t, node.right.left.left.type, 5)
	testing.expect_value(t, node.right.left.right.type, 7)
	testing.expect_value(t, node.right.right.right.type, 10)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
delete_10_5 :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	root: ^lb.lexbor_avl_node_t = nil
	node: ^lb.lexbor_avl_node_t = ---

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	lb.lexbor_avl_insert(&avl, &root, 1, (rawptr)((uintptr)(1)))
	lb.lexbor_avl_insert(&avl, &root, 2, (rawptr)((uintptr)(2)))
	lb.lexbor_avl_insert(&avl, &root, 3, (rawptr)((uintptr)(3)))
	lb.lexbor_avl_insert(&avl, &root, 4, (rawptr)((uintptr)(4)))
	lb.lexbor_avl_insert(&avl, &root, 5, (rawptr)((uintptr)(5)))
	lb.lexbor_avl_insert(&avl, &root, 6, (rawptr)((uintptr)(6)))
	lb.lexbor_avl_insert(&avl, &root, 7, (rawptr)((uintptr)(7)))
	lb.lexbor_avl_insert(&avl, &root, 8, (rawptr)((uintptr)(8)))
	lb.lexbor_avl_insert(&avl, &root, 9, (rawptr)((uintptr)(9)))
	lb.lexbor_avl_insert(&avl, &root, 10, (rawptr)((uintptr)(10)))

	testing.expect(t, root != nil)

	testing.expect(t, lb.lexbor_avl_remove(&avl, &root, 6) != nil)
	testing.expect(t, root != nil)

	// 4
	node = lb.lexbor_avl_search(&avl, root, 4)
	testing.expect(t, node != nil)

	testing.expect_value(t, node.type, 4)

	testing.expect(t, node.left != nil)
	testing.expect(t, node.right != nil)
	testing.expect_value(t, node.parent, nil)

	testing.expect_value(t, node.left.type, 2)
	testing.expect_value(t, node.left.left.type, 1)
	testing.expect_value(t, node.left.right.type, 3)

	testing.expect_value(t, node.right.type, 8)
	testing.expect_value(t, node.right.left.type, 5)
	testing.expect_value(t, node.right.right.type, 9)
	testing.expect_value(t, node.right.left.right.type, 7)
	testing.expect_value(t, node.right.right.right.type, 10)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
clean :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	lb.lexbor_avl_init(&avl, 1024, 0)

	lb.lexbor_avl_clean(&avl)

	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
destroy :: proc(t: ^testing.T) {
	avl := lb.lexbor_avl_create()
	lb.lexbor_avl_init(avl, 1024, 0)

	testing.expect_value(t, lb.lexbor_avl_destroy(avl, true), nil)

	avl = lb.lexbor_avl_create()
	lb.lexbor_avl_init(avl, 1021, 0)

	testing.expect_value(t, lb.lexbor_avl_destroy(avl, false), avl)
	testing.expect_value(t, lb.lexbor_avl_destroy(avl, true), nil)
	testing.expect_value(t, lb.lexbor_avl_destroy(nil, false), nil)
}

@(test)
destroy_stack :: proc(t: ^testing.T) {
	avl: lb.lexbor_avl_t = ---
	lb.lexbor_avl_init(&avl, 1023, 0)

	testing.expect_value(t, lb.lexbor_avl_destroy(&avl, false), &avl)
}

@(test)
foreach_4 :: proc(t: ^testing.T) {
	i: c.size_t = ---
	p: [^]c.size_t = ---
	avl: lb.lexbor_avl_t = ---
	test: avl_test_ctx_t = ---
	root: ^lb.lexbor_avl_node_t = nil

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	for i := c.size_t(5); i > 1; i -= 1 {
		lb.lexbor_avl_insert(&avl, &root, i, nil)
	}

	test.result = (^c.size_t)(lb.lexbor_malloc(10 * size_of(c.size_t)))
	testing.expect(t, test.result != nil)

	test.remove = 4
	test.p = test.result

	lb.lexbor_avl_foreach(&avl, &root, avl_cb, &test)

	p = test.result

	j := 0
	for i := c.size_t(2); i < 6; i += 1 {
		testing.expect(t, &p[j] != &test.p[j])
		testing.expect_value(t, i, p[j])
		j += 1
	}

	lb.lexbor_free(test.result)
	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
foreach_6 :: proc(t: ^testing.T) {
	i: c.size_t = ---
	p: [^]c.size_t = ---
	avl: lb.lexbor_avl_t = ---
	test: avl_test_ctx_t = ---
	root: ^lb.lexbor_avl_node_t = nil

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	for i := c.size_t(5); i < 9; i += 1 {
		lb.lexbor_avl_insert(&avl, &root, i, nil)
	}

	test.result = (^c.size_t)(lb.lexbor_malloc(10 * size_of(c.size_t)))
	testing.expect(t, test.result != nil)

	test.remove = 6
	test.p = test.result

	lb.lexbor_avl_foreach(&avl, &root, avl_cb, &test)

	p = test.result

	j := 0
	for i := c.size_t(5); i < 9; i += 1 {
		testing.expect(t, &p[j] != &test.p[j])
		testing.expect_value(t, i, p[j])
		j += 1
	}

	lb.lexbor_free(test.result)
	lb.lexbor_avl_destroy(&avl, false)
}

@(test)
foreach_10 :: proc(t: ^testing.T) {
	i: c.size_t = ---
	p: [^]c.size_t = ---
	avl: lb.lexbor_avl_t = ---
	test: avl_test_ctx_t = ---
	root: ^lb.lexbor_avl_node_t = nil

	total: c.size_t : 101

	test.result = (^c.size_t)(lb.lexbor_malloc(total * size_of(c.size_t)))
	testing.expect(t, test.result != nil)

	for r := c.size_t(1); r < total; r += 1 {
		testing.expect_value(
			t,
			lb.lexbor_status_t(lb.lexbor_avl_init(&avl, 1024, 0)),
			lb.lexbor_status_t.LXB_STATUS_OK,
		)

		root = nil

		for i := c.size_t(1); i < total; i += 1 {
			lb.lexbor_avl_insert(&avl, &root, i, nil)
		}

		test.remove = r
		test.p = test.result

		lb.lexbor_avl_foreach(&avl, &root, avl_cb, &test)

		p = test.result

		j := 0
		for i := c.size_t(1); i < total; i += 1 {
			testing.expect(t, &p[j] != &test.p[j])
			testing.expect_value(t, i, p[j])
			j += 1
		}
		lb.lexbor_avl_destroy(&avl, false)
	}

	lb.lexbor_free(test.result)
}
