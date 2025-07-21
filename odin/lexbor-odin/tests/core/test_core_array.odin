package test_core_array

import "core:c"
import "core:testing"

import lb "../../lexbor"

@(test)
init :: proc(t: ^testing.T) {
	array := lb.lexbor_array_create()
	status := lb.lexbor_array_init(array, 32)

	testing.expect_value(t, lb.lexbor_status_t(status), lb.lexbor_status_t.LXB_STATUS_OK)

	lb.lexbor_array_destroy(array, true)
}

@(test)
init_null :: proc(t: ^testing.T) {
	status := lb.lexbor_array_init(nil, 32)
	testing.expect_value(
		t,
		lb.lexbor_status_t(status),
		lb.lexbor_status_t.LXB_STATUS_ERROR_OBJECT_IS_NULL,
	)
}

@(test)
init_stack :: proc(t: ^testing.T) {
	array: lb.lexbor_array_t = ---
	status := lb.lexbor_array_init(&array, 32)

	testing.expect_value(t, lb.lexbor_status_t(status), lb.lexbor_status_t.LXB_STATUS_OK)

	lb.lexbor_array_destroy(&array, false)
}

@(test)
clean :: proc(t: ^testing.T) {
	array: lb.lexbor_array_t = ---
	status := lb.lexbor_array_init(&array, 32)

	lb.lexbor_array_push(&array, rawptr(uintptr(1)))
	testing.expect_value(t, lb.lexbor_array_length(&array), 1)

	lb.lexbor_array_clean(&array)
	testing.expect_value(t, lb.lexbor_array_length(&array), 0)

	lb.lexbor_array_destroy(&array, false)
}

@(test)
push :: proc(t: ^testing.T) {
	array: lb.lexbor_array_t = ---
	status := lb.lexbor_array_init(&array, 32)

	testing.expect_value(t, lb.lexbor_array_length(&array), 0)

	lb.lexbor_array_push(&array, rawptr(uintptr(1)))

	testing.expect_value(t, lb.lexbor_array_length(&array), 1)
	testing.expect_value(t, lb.lexbor_array_get(&array, 0), rawptr(uintptr(1)))

	lb.lexbor_array_destroy(&array, false)
}

@(test)
push_null :: proc(t: ^testing.T) {
	array: lb.lexbor_array_t = ---
	status := lb.lexbor_array_init(&array, 32)

	lb.lexbor_array_push(&array, nil)

	testing.expect_value(t, lb.lexbor_array_length(&array), 1)
	testing.expect_value(t, lb.lexbor_array_get(&array, 0), nil)

	lb.lexbor_array_destroy(&array, false)
}

@(test)
pop :: proc(t: ^testing.T) {
	array: lb.lexbor_array_t = ---
	status := lb.lexbor_array_init(&array, 32)

	lb.lexbor_array_push(&array, rawptr(uintptr(123)))

	testing.expect_value(t, lb.lexbor_array_pop(&array), rawptr(uintptr(123)))
	testing.expect_value(t, lb.lexbor_array_length(&array), 0)

	lb.lexbor_array_destroy(&array, false)
}

@(test)
pop_if_empty :: proc(t: ^testing.T) {
	array: lb.lexbor_array_t = ---
	status := lb.lexbor_array_init(&array, 32)

	testing.expect_value(t, lb.lexbor_array_length(&array), 0)
	testing.expect_value(t, lb.lexbor_array_pop(&array), nil)
	testing.expect_value(t, lb.lexbor_array_length(&array), 0)

	lb.lexbor_array_destroy(&array, false)
}

@(test)
get :: proc(t: ^testing.T) {
	array: lb.lexbor_array_t = ---
	status := lb.lexbor_array_init(&array, 32)

	testing.expect_value(t, lb.lexbor_array_get(&array, 1), nil)
	testing.expect_value(t, lb.lexbor_array_get(&array, 0), nil)

	lb.lexbor_array_push(&array, rawptr(uintptr(123)))

	testing.expect_value(t, lb.lexbor_array_get(&array, 0), rawptr(uintptr(123)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 1), nil)
	testing.expect_value(t, lb.lexbor_array_get(&array, 1000), nil)

	lb.lexbor_array_destroy(&array, false)
}

@(test)
set :: proc(t: ^testing.T) {
	array: lb.lexbor_array_t = ---
	status := lb.lexbor_array_init(&array, 32)

	lb.lexbor_array_push(&array, rawptr(uintptr(123)))

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_array_set(&array, 0, rawptr(uintptr(456)))),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)
	testing.expect_value(t, lb.lexbor_array_get(&array, 0), rawptr(uintptr(456)))

	testing.expect_value(t, lb.lexbor_array_length(&array), 1)

	lb.lexbor_array_destroy(&array, false)
}

@(test)
set_not_exists :: proc(t: ^testing.T) {
	array: lb.lexbor_array_t = ---
	status := lb.lexbor_array_init(&array, 32)

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_array_set(&array, 10, rawptr(uintptr(123)))),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)
	testing.expect_value(t, lb.lexbor_array_get(&array, 10), rawptr(uintptr(123)))

	for i := c.size_t(0); i < 10; i += 1 {
		testing.expect_value(t, lb.lexbor_array_get(&array, i), nil)
	}

	testing.expect_value(t, lb.lexbor_array_length(&array), 11)

	lb.lexbor_array_destroy(&array, false)
}

@(test)
insert :: proc(t: ^testing.T) {
	status: lb.lxb_status_t = ---
	array: lb.lexbor_array_t = ---
	lb.lexbor_array_init(&array, 32)

	status = lb.lexbor_array_insert(&array, 0, rawptr(uintptr(456)))
	testing.expect_value(t, lb.lexbor_status_t(status), lb.lexbor_status_t.LXB_STATUS_OK)

	testing.expect_value(t, lb.lexbor_array_get(&array, 0), rawptr(uintptr(456)))

	testing.expect_value(t, lb.lexbor_array_length(&array), 1)
	testing.expect_value(t, lb.lexbor_array_size(&array), 32)

	lb.lexbor_array_destroy(&array, false)
}

@(test)
insert_end :: proc(t: ^testing.T) {
	status: lb.lxb_status_t = ---
	array: lb.lexbor_array_t = ---
	lb.lexbor_array_init(&array, 32)

	status = lb.lexbor_array_insert(&array, 32, rawptr(uintptr(457)))
	testing.expect_value(t, lb.lexbor_status_t(status), lb.lexbor_status_t.LXB_STATUS_OK)

	testing.expect_value(t, lb.lexbor_array_get(&array, 32), rawptr(uintptr(457)))

	testing.expect_value(t, lb.lexbor_array_length(&array), 33)
	testing.expect(t, lb.lexbor_array_size(&array) != 32)

	lb.lexbor_array_destroy(&array, false)
}

@(test)
insert_overflow :: proc(t: ^testing.T) {
	status: lb.lxb_status_t = ---
	array: lb.lexbor_array_t = ---
	lb.lexbor_array_init(&array, 32)

	status = lb.lexbor_array_insert(&array, 33, rawptr(uintptr(458)))
	testing.expect_value(t, lb.lexbor_status_t(status), lb.lexbor_status_t.LXB_STATUS_OK)

	testing.expect_value(t, lb.lexbor_array_get(&array, 33), rawptr(uintptr(458)))

	testing.expect_value(t, lb.lexbor_array_length(&array), 34)
	testing.expect(t, lb.lexbor_array_size(&array) != 32)

	lb.lexbor_array_destroy(&array, false)
}

@(test)
insert_to :: proc(t: ^testing.T) {
	status: lb.lxb_status_t = ---
	array: lb.lexbor_array_t = ---
	lb.lexbor_array_init(&array, 32)

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_array_push(&array, rawptr(uintptr(1)))),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)
	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_array_push(&array, rawptr(uintptr(2)))),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)
	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_array_push(&array, rawptr(uintptr(3)))),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)
	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_array_push(&array, rawptr(uintptr(4)))),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)
	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_array_push(&array, rawptr(uintptr(5)))),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)
	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_array_push(&array, rawptr(uintptr(6)))),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)
	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_array_push(&array, rawptr(uintptr(7)))),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)
	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_array_push(&array, rawptr(uintptr(8)))),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)
	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_array_push(&array, rawptr(uintptr(9)))),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	status = lb.lexbor_array_insert(&array, 4, rawptr(uintptr(459)))
	testing.expect_value(t, lb.lexbor_status_t(status), lb.lexbor_status_t.LXB_STATUS_OK)

	testing.expect_value(t, lb.lexbor_array_get(&array, 0), rawptr(uintptr(1)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 1), rawptr(uintptr(2)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 2), rawptr(uintptr(3)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 3), rawptr(uintptr(4)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 4), rawptr(uintptr(459)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 5), rawptr(uintptr(5)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 6), rawptr(uintptr(6)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 7), rawptr(uintptr(7)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 8), rawptr(uintptr(8)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 9), rawptr(uintptr(9)))

	testing.expect_value(t, lb.lexbor_array_length(&array), 10)

	lb.lexbor_array_destroy(&array, false)
}

@(test)
insert_to_end :: proc(t: ^testing.T) {
	status: lb.lxb_status_t = ---
	array: lb.lexbor_array_t = ---
	lb.lexbor_array_init(&array, 9)

	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_array_push(&array, rawptr(uintptr(1)))),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)
	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_array_push(&array, rawptr(uintptr(2)))),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)
	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_array_push(&array, rawptr(uintptr(3)))),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)
	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_array_push(&array, rawptr(uintptr(4)))),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)
	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_array_push(&array, rawptr(uintptr(5)))),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)
	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_array_push(&array, rawptr(uintptr(6)))),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)
	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_array_push(&array, rawptr(uintptr(7)))),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)
	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_array_push(&array, rawptr(uintptr(8)))),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)
	testing.expect_value(
		t,
		lb.lexbor_status_t(lb.lexbor_array_push(&array, rawptr(uintptr(9)))),
		lb.lexbor_status_t.LXB_STATUS_OK,
	)

	testing.expect_value(t, lb.lexbor_array_length(&array), 9)
	testing.expect_value(t, lb.lexbor_array_size(&array), 9)

	status = lb.lexbor_array_insert(&array, 4, rawptr(uintptr(459)))
	testing.expect_value(t, lb.lexbor_status_t(status), lb.lexbor_status_t.LXB_STATUS_OK)

	testing.expect_value(t, lb.lexbor_array_get(&array, 0), rawptr(uintptr(1)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 1), rawptr(uintptr(2)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 2), rawptr(uintptr(3)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 3), rawptr(uintptr(4)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 4), rawptr(uintptr(459)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 5), rawptr(uintptr(5)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 6), rawptr(uintptr(6)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 7), rawptr(uintptr(7)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 8), rawptr(uintptr(8)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 9), rawptr(uintptr(9)))

	testing.expect_value(t, lb.lexbor_array_length(&array), 10)
	testing.expect(t, lb.lexbor_array_size(&array) != 9)

	lb.lexbor_array_destroy(&array, false)
}

@(test)
delete :: proc(t: ^testing.T) {
	array: lb.lexbor_array_t = ---
	lb.lexbor_array_init(&array, 32)

	for i := c.size_t(0); i < 10; i += 1 {
		lb.lexbor_array_push(&array, rawptr(uintptr(i)))
	}

	lb.lexbor_array_delete(&array, 10, 100)
	testing.expect_value(t, lb.lexbor_array_length(&array), 10)

	lb.lexbor_array_delete(&array, 100, 1)
	testing.expect_value(t, lb.lexbor_array_length(&array), 10)

	lb.lexbor_array_delete(&array, 100, 0)
	testing.expect_value(t, lb.lexbor_array_length(&array), 10)

	for i := c.size_t(0); i < 10; i += 1 {
		testing.expect_value(t, lb.lexbor_array_get(&array, i), rawptr(uintptr(i)))
	}

	lb.lexbor_array_delete(&array, 4, 4)
	testing.expect_value(t, lb.lexbor_array_length(&array), 6)

	lb.lexbor_array_delete(&array, 4, 0)
	testing.expect_value(t, lb.lexbor_array_length(&array), 6)

	lb.lexbor_array_delete(&array, 0, 0)
	testing.expect_value(t, lb.lexbor_array_length(&array), 6)

	testing.expect_value(t, lb.lexbor_array_get(&array, 0), rawptr(uintptr(0)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 1), rawptr(uintptr(1)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 2), rawptr(uintptr(2)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 3), rawptr(uintptr(3)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 4), rawptr(uintptr(8)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 5), rawptr(uintptr(9)))

	lb.lexbor_array_delete(&array, 0, 1)
	testing.expect_value(t, lb.lexbor_array_length(&array), 5)

	testing.expect_value(t, lb.lexbor_array_get(&array, 0), rawptr(uintptr(1)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 1), rawptr(uintptr(2)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 2), rawptr(uintptr(3)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 3), rawptr(uintptr(8)))
	testing.expect_value(t, lb.lexbor_array_get(&array, 4), rawptr(uintptr(9)))

	lb.lexbor_array_delete(&array, 1, 1000)
	testing.expect_value(t, lb.lexbor_array_length(&array), 1)

	testing.expect_value(t, lb.lexbor_array_get(&array, 0), rawptr(uintptr(1)))

	lb.lexbor_array_destroy(&array, false)
}

@(test)
delete_if_empty :: proc(t: ^testing.T) {
	array: lb.lexbor_array_t = ---
	lb.lexbor_array_init(&array, 32)

	lb.lexbor_array_delete(&array, 0, 0)
	testing.expect_value(t, lb.lexbor_array_length(&array), 0)

	lb.lexbor_array_delete(&array, 1, 0)
	testing.expect_value(t, lb.lexbor_array_length(&array), 0)

	lb.lexbor_array_delete(&array, 1, 1)
	testing.expect_value(t, lb.lexbor_array_length(&array), 0)

	lb.lexbor_array_delete(&array, 100, 1)
	testing.expect_value(t, lb.lexbor_array_length(&array), 0)

	lb.lexbor_array_destroy(&array, false)
}

@(test)
expand :: proc(t: ^testing.T) {
	array: lb.lexbor_array_t = ---
	lb.lexbor_array_init(&array, 32)

	testing.expect(t, lb.lexbor_array_expand(&array, 128) != nil)
	testing.expect_value(t, lb.lexbor_array_size(&array), 128)

	lb.lexbor_array_destroy(&array, false)
}

@(test)
destroy :: proc(t: ^testing.T) {
	array := lb.lexbor_array_create()
	lb.lexbor_array_init(array, 32)

	testing.expect_value(t, lb.lexbor_array_destroy(array, true), nil)

	array = lb.lexbor_array_create()
	lb.lexbor_array_init(array, 32)

	testing.expect_value(t, lb.lexbor_array_destroy(array, false), array)
	testing.expect_value(t, lb.lexbor_array_destroy(array, true), nil)
	testing.expect_value(t, lb.lexbor_array_destroy(nil, false), nil)
}

@(test)
destroy_stack :: proc(t: ^testing.T) {
	array: lb.lexbor_array_t = ---
	lb.lexbor_array_init(&array, 32)

	testing.expect_value(t, lb.lexbor_array_destroy(&array, false), &array)
}
