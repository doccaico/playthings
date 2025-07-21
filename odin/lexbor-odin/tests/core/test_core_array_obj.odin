package test_core_array_obj

import "core:c"
import "core:testing"

import lb "../../lexbor"

test_struct_t :: struct {
	data: [^]c.schar,
	len:  c.size_t,
}

@(test)
init :: proc(t: ^testing.T) {
	array := lb.lexbor_array_obj_create()
	status := lb.lexbor_array_obj_init(array, 32, size_of(test_struct_t))

	testing.expect_value(t, lb.lexbor_status_t(status), lb.lexbor_status_t.LXB_STATUS_OK)

	lb.lexbor_array_obj_destroy(array, true)
}

@(test)
init_null :: proc(t: ^testing.T) {
	status: lb.lxb_status_t = ---
	array: lb.lexbor_array_obj_t = ---

	status = lb.lexbor_array_obj_init(&array, 32, size_of(test_struct_t))
	testing.expect_value(t, lb.lexbor_status_t(status), lb.lexbor_status_t.LXB_STATUS_OK)

	lb.lexbor_array_obj_destroy(&array, false)
}

@(test)
clean :: proc(t: ^testing.T) {
	array: lb.lexbor_array_obj_t = ---
	lb.lexbor_array_obj_init(&array, 32, size_of(test_struct_t))

	lb.lexbor_array_obj_push(&array)
	testing.expect_value(t, lb.lexbor_array_obj_length(&array), 1)

	lb.lexbor_array_obj_clean(&array)
	testing.expect_value(t, lb.lexbor_array_obj_length(&array), 0)

	lb.lexbor_array_obj_destroy(&array, false)
}

@(test)
push :: proc(t: ^testing.T) {
	array: lb.lexbor_array_obj_t = ---
	lb.lexbor_array_obj_init(&array, 32, size_of(test_struct_t))

	testing.expect_value(t, lb.lexbor_array_obj_length(&array), 0)

	entry := lb.lexbor_array_obj_push(&array)
	testing.expect(t, entry != nil)

	testing.expect_value(t, lb.lexbor_array_obj_length(&array), 1)
	testing.expect_value(t, lb.lexbor_array_obj_get(&array, 0), entry)

	lb.lexbor_array_obj_destroy(&array, false)
}

@(test)
pop :: proc(t: ^testing.T) {
	array: lb.lexbor_array_obj_t = ---
	lb.lexbor_array_obj_init(&array, 32, size_of(test_struct_t))

	entry := lb.lexbor_array_obj_push(&array)
	testing.expect(t, entry != nil)

	testing.expect_value(t, lb.lexbor_array_obj_pop(&array), entry)
	testing.expect_value(t, lb.lexbor_array_obj_length(&array), 0)

	lb.lexbor_array_obj_destroy(&array, false)
}

@(test)
pop_if_empty :: proc(t: ^testing.T) {
	array: lb.lexbor_array_obj_t = ---
	lb.lexbor_array_obj_init(&array, 32, size_of(test_struct_t))

	testing.expect_value(t, lb.lexbor_array_obj_length(&array), 0)
	testing.expect_value(t, lb.lexbor_array_obj_pop(&array), nil)
	testing.expect_value(t, lb.lexbor_array_obj_length(&array), 0)

	lb.lexbor_array_obj_destroy(&array, false)
}

@(test)
get :: proc(t: ^testing.T) {
	array: lb.lexbor_array_obj_t = ---
	lb.lexbor_array_obj_init(&array, 32, size_of(test_struct_t))

	testing.expect_value(t, lb.lexbor_array_obj_get(&array, 1), nil)
	testing.expect_value(t, lb.lexbor_array_obj_get(&array, 0), nil)

	entry := lb.lexbor_array_obj_push(&array)
	testing.expect(t, entry != nil)

	testing.expect_value(t, lb.lexbor_array_obj_get(&array, 0), entry)
	testing.expect_value(t, lb.lexbor_array_obj_get(&array, 1), nil)
	testing.expect_value(t, lb.lexbor_array_obj_get(&array, 1000), nil)

	lb.lexbor_array_obj_destroy(&array, false)
}

@(test)
delete :: proc(t: ^testing.T) {
	entry: ^test_struct_t = ---
	array: lb.lexbor_array_obj_t = ---

	lb.lexbor_array_obj_init(&array, 32, size_of(test_struct_t))

	for i := c.size_t(0); i < 10; i += 1 {
		entry = (^test_struct_t)(lb.lexbor_array_obj_push(&array))
		entry.data = ([^]c.schar)((uintptr)(i))
		entry.len = i
	}

	testing.expect_value(t, lb.lexbor_array_obj_length(&array), 10)

	lb.lexbor_array_obj_delete(&array, 10, 100)
	testing.expect_value(t, lb.lexbor_array_obj_length(&array), 10)

	lb.lexbor_array_obj_delete(&array, 100, 1)
	testing.expect_value(t, lb.lexbor_array_obj_length(&array), 10)

	lb.lexbor_array_obj_delete(&array, 100, 0)
	testing.expect_value(t, lb.lexbor_array_obj_length(&array), 10)

	for i := c.size_t(0); i < 10; i += 1 {
		entry = (^test_struct_t)(lb.lexbor_array_obj_get(&array, i))
		testing.expect_value(t, entry.data, ([^]c.schar)((uintptr)(i)))
		testing.expect_value(t, entry.len, i)
	}

	lb.lexbor_array_obj_delete(&array, 4, 4)
	testing.expect_value(t, lb.lexbor_array_obj_length(&array), 6)

	lb.lexbor_array_obj_delete(&array, 4, 0)
	testing.expect_value(t, lb.lexbor_array_obj_length(&array), 6)

	lb.lexbor_array_obj_delete(&array, 0, 0)
	testing.expect_value(t, lb.lexbor_array_obj_length(&array), 6)

	entry = (^test_struct_t)((lb.lexbor_array_obj_get(&array, 0)))
	testing.expect_value(t, entry.data, ([^]c.schar)((uintptr)(0)))
	testing.expect_value(t, entry.len, 0)

	entry = (^test_struct_t)((lb.lexbor_array_obj_get(&array, 1)))
	testing.expect_value(t, entry.data, ([^]c.schar)((uintptr)(1)))
	testing.expect_value(t, entry.len, 1)

	entry = (^test_struct_t)((lb.lexbor_array_obj_get(&array, 2)))
	testing.expect_value(t, entry.data, ([^]c.schar)((uintptr)(2)))
	testing.expect_value(t, entry.len, 2)

	entry = (^test_struct_t)((lb.lexbor_array_obj_get(&array, 3)))
	testing.expect_value(t, entry.data, ([^]c.schar)((uintptr)(3)))
	testing.expect_value(t, entry.len, 3)

	entry = (^test_struct_t)((lb.lexbor_array_obj_get(&array, 4)))
	testing.expect_value(t, entry.data, ([^]c.schar)((uintptr)(8)))
	testing.expect_value(t, entry.len, 8)

	entry = (^test_struct_t)((lb.lexbor_array_obj_get(&array, 5)))
	testing.expect_value(t, entry.data, ([^]c.schar)((uintptr)(9)))
	testing.expect_value(t, entry.len, 9)

	lb.lexbor_array_obj_delete(&array, 0, 1)
	testing.expect_value(t, lb.lexbor_array_obj_length(&array), 5)

	entry = (^test_struct_t)((lb.lexbor_array_obj_get(&array, 0)))
	testing.expect_value(t, entry.data, ([^]c.schar)((uintptr)(1)))
	testing.expect_value(t, entry.len, 1)

	entry = (^test_struct_t)((lb.lexbor_array_obj_get(&array, 1)))
	testing.expect_value(t, entry.data, ([^]c.schar)((uintptr)(2)))
	testing.expect_value(t, entry.len, 2)

	entry = (^test_struct_t)((lb.lexbor_array_obj_get(&array, 2)))
	testing.expect_value(t, entry.data, ([^]c.schar)((uintptr)(3)))
	testing.expect_value(t, entry.len, 3)

	entry = (^test_struct_t)((lb.lexbor_array_obj_get(&array, 3)))
	testing.expect_value(t, entry.data, ([^]c.schar)((uintptr)(8)))
	testing.expect_value(t, entry.len, 8)

	entry = (^test_struct_t)((lb.lexbor_array_obj_get(&array, 4)))
	testing.expect_value(t, entry.data, ([^]c.schar)((uintptr)(9)))
	testing.expect_value(t, entry.len, 9)

	lb.lexbor_array_obj_delete(&array, 1, 1000)
	testing.expect_value(t, lb.lexbor_array_obj_length(&array), 1)

	entry = (^test_struct_t)((lb.lexbor_array_obj_get(&array, 0)))
	testing.expect_value(t, entry.data, ([^]c.schar)((uintptr)(1)))
	testing.expect_value(t, entry.len, 1)

	lb.lexbor_array_obj_destroy(&array, false)
}

@(test)
delete_if_empty :: proc(t: ^testing.T) {
	array: lb.lexbor_array_obj_t = ---
	lb.lexbor_array_obj_init(&array, 32, size_of(test_struct_t))

	lb.lexbor_array_obj_delete(&array, 0, 0)
	testing.expect_value(t, lb.lexbor_array_obj_length(&array), 0)

	lb.lexbor_array_obj_delete(&array, 1, 0)
	testing.expect_value(t, lb.lexbor_array_obj_length(&array), 0)

	lb.lexbor_array_obj_delete(&array, 1, 1)
	testing.expect_value(t, lb.lexbor_array_obj_length(&array), 0)

	lb.lexbor_array_obj_delete(&array, 100, 0)
	testing.expect_value(t, lb.lexbor_array_obj_length(&array), 0)

	lb.lexbor_array_obj_delete(&array, 10, 100)
	testing.expect_value(t, lb.lexbor_array_obj_length(&array), 0)

	lb.lexbor_array_obj_destroy(&array, false)
}

@(test)
expand :: proc(t: ^testing.T) {
	array: lb.lexbor_array_obj_t = ---
	lb.lexbor_array_obj_init(&array, 32, size_of(test_struct_t))

	testing.expect(t, lb.lexbor_array_obj_expand(&array, 128) != nil)
	testing.expect_value(t, lb.lexbor_array_obj_size(&array), 128)

	lb.lexbor_array_obj_destroy(&array, false)
}

@(test)
destroy :: proc(t: ^testing.T) {
	array := lb.lexbor_array_obj_create()
	lb.lexbor_array_obj_init(array, 32, size_of(test_struct_t))

	testing.expect_value(t, lb.lexbor_array_obj_destroy(array, true), nil)

	array = lb.lexbor_array_obj_create()
	lb.lexbor_array_obj_init(array, 32, size_of(test_struct_t))

	testing.expect_value(t, lb.lexbor_array_obj_destroy(array, false), array)
	testing.expect_value(t, lb.lexbor_array_obj_destroy(array, true), nil)
	testing.expect_value(t, lb.lexbor_array_obj_destroy(nil, false), nil)
}

@(test)
destroy_stack :: proc(t: ^testing.T) {
	array: lb.lexbor_array_obj_t = ---
	lb.lexbor_array_obj_init(&array, 32, size_of(test_struct_t))

	testing.expect_value(t, lb.lexbor_array_obj_destroy(&array, false), &array)
}
