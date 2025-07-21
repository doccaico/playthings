package test_core_mraw

import "core:c"
import "core:testing"

import lb "../../lexbor"

@(test)
init :: proc(t: ^testing.T) {
	mraw := lb.lexbor_mraw_create()
	status := lb.lexbor_mraw_init(mraw, 1024)

	testing.expect_value(t, lb.lexbor_status_t(status), lb.lexbor_status_t.LXB_STATUS_OK)

	lb.lexbor_mraw_destroy(mraw, true)
}

@(test)
init_null :: proc(t: ^testing.T) {
	status := lb.lexbor_mraw_init(nil, 1024)
	testing.expect_value(
		t,
		lb.lexbor_status_t(status),
		lb.lexbor_status_t.LXB_STATUS_ERROR_OBJECT_IS_NULL,
	)
}

@(test)
init_stack :: proc(t: ^testing.T) {
	mraw: lb.lexbor_mraw_t = ---
	status := lb.lexbor_mraw_init(&mraw, 1024)

	testing.expect_value(t, lb.lexbor_status_t(status), lb.lexbor_status_t.LXB_STATUS_OK)

	lb.lexbor_mraw_destroy(&mraw, false)
}

@(test)
init_args :: proc(t: ^testing.T) {
	mraw: lb.lexbor_mraw_t
	status: lb.lxb_status_t = ---

	status = lb.lexbor_mraw_init(&mraw, 0)
	testing.expect_value(
		t,
		lb.lexbor_status_t(status),
		lb.lexbor_status_t.LXB_STATUS_ERROR_WRONG_ARGS,
	)

	lb.lexbor_mraw_destroy(&mraw, false)
}

@(test)
mraw_alloc :: proc(t: ^testing.T) {
	mraw: lb.lexbor_mraw_t
	lb.lexbor_mraw_init(&mraw, 1024)

	data := lb.lexbor_mraw_alloc(&mraw, 127)
	testing.expect(t, data != nil)

	testing.expect_value(t, lb.lexbor_mraw_data_size(data), lb.lexbor_mem_align(127))

	testing.expect_value(t, mraw.mem.chunk_length, 1)
	testing.expect_value(
		t,
		mraw.mem.chunk.length,
		lb.lexbor_mem_align(127) + lb.lexbor_mraw_meta_size(),
	)

	testing.expect_value(
		t,
		mraw.mem.chunk.size,
		lb.lexbor_mem_align(1024) + lb.lexbor_mraw_meta_size(),
	)

	testing.expect_value(t, mraw.cache.tree_length, 0)

	testing.expect_value(t, mraw.mem.chunk, mraw.mem.chunk_first)

	lb.lexbor_mraw_destroy(&mraw, false)
}

@(test)
mraw_alloc_eq :: proc(t: ^testing.T) {
	mraw: lb.lexbor_mraw_t
	lb.lexbor_mraw_init(&mraw, 1024)

	data := lb.lexbor_mraw_alloc(&mraw, 1024)
	testing.expect(t, data != nil)

	testing.expect_value(t, lb.lexbor_mraw_data_size(data), 1024)

	testing.expect_value(t, mraw.mem.chunk_length, 1)
	testing.expect_value(t, mraw.mem.chunk.length, 1024 + lb.lexbor_mraw_meta_size())
	testing.expect_value(t, mraw.mem.chunk.size, 1024 + lb.lexbor_mraw_meta_size())

	testing.expect_value(t, mraw.cache.tree_length, 0)

	testing.expect_value(t, mraw.mem.chunk, mraw.mem.chunk_first)

	lb.lexbor_mraw_destroy(&mraw, false)
}

@(test)
mraw_alloc_overflow_if_len_0 :: proc(t: ^testing.T) {
	mraw: lb.lexbor_mraw_t
	lb.lexbor_mraw_init(&mraw, 1024)

	data := lb.lexbor_mraw_alloc(&mraw, 1025)
	testing.expect(t, data != nil)

	testing.expect_value(t, lb.lexbor_mraw_data_size(data), lb.lexbor_mem_align(1025))

	testing.expect_value(t, mraw.mem.chunk_length, 1)
	testing.expect_value(
		t,
		mraw.mem.chunk.length,
		lb.lexbor_mem_align(1025) + lb.lexbor_mraw_meta_size(),
	)

	testing.expect_value(
		t,
		mraw.mem.chunk.size,
		lb.lexbor_mem_align(1025) + lb.lexbor_mem_align(1024) + (2 * lb.lexbor_mraw_meta_size()),
	)

	testing.expect_value(t, mraw.cache.tree_length, 0)
	testing.expect_value(t, mraw.mem.chunk, mraw.mem.chunk_first)

	lb.lexbor_mraw_destroy(&mraw, false)
}

@(test)
mraw_alloc_overflow_if_len_not_0 :: proc(t: ^testing.T) {
	mraw: lb.lexbor_mraw_t
	lb.lexbor_mraw_init(&mraw, 1024)

	data := lb.lexbor_mraw_alloc(&mraw, 13)
	testing.expect(t, data != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(data), lb.lexbor_mem_align(13))

	data = lb.lexbor_mraw_alloc(&mraw, 1025)
	testing.expect(t, data != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(data), lb.lexbor_mem_align(1025))

	testing.expect_value(t, mraw.mem.chunk_first.length, 1024 + lb.lexbor_mraw_meta_size())
	testing.expect_value(t, mraw.mem.chunk_first.size, 1024 + lb.lexbor_mraw_meta_size())

	testing.expect_value(t, mraw.mem.chunk_length, 2)
	testing.expect_value(
		t,
		mraw.mem.chunk.length,
		lb.lexbor_mem_align(1025) + lb.lexbor_mraw_meta_size(),
	)

	testing.expect_value(
		t,
		mraw.mem.chunk.size,
		lb.lexbor_mem_align(1025) + lb.lexbor_mem_align(1024) + (2 * lb.lexbor_mraw_meta_size()),
	)

	testing.expect_value(t, mraw.cache.tree_length, 1)
	testing.expect_value(
		t,
		mraw.cache.root.size,
		(lb.lexbor_mem_align(1024) + lb.lexbor_mraw_meta_size()) -
		(lb.lexbor_mem_align(13) + lb.lexbor_mraw_meta_size()) -
		lb.lexbor_mraw_meta_size(),
	)

	testing.expect(t, mraw.mem.chunk != mraw.mem.chunk_first)

	lb.lexbor_mraw_destroy(&mraw, false)
}

@(test)
mraw_alloc_if_len_not_0 :: proc(t: ^testing.T) {
	mraw: lb.lexbor_mraw_t
	lb.lexbor_mraw_init(&mraw, 1024)

	data := lb.lexbor_mraw_alloc(&mraw, 8)
	testing.expect(t, data != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(data), lb.lexbor_mem_align(8))

	data = lb.lexbor_mraw_alloc(&mraw, 1016 - lb.lexbor_mraw_meta_size())
	testing.expect(t, data != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(data), 1016 - lb.lexbor_mraw_meta_size())

	testing.expect_value(t, mraw.mem.chunk_length, 1)
	testing.expect_value(t, mraw.mem.chunk.length, 1024 + lb.lexbor_mraw_meta_size())
	testing.expect_value(t, mraw.mem.chunk.size, mraw.mem.chunk.length)

	testing.expect_value(t, mraw.cache.tree_length, 0)
	testing.expect_value(t, mraw.mem.chunk, mraw.mem.chunk_first)

	lb.lexbor_mraw_destroy(&mraw, false)
}

@(test)
mraw_realloc :: proc(t: ^testing.T) {
	mraw: lb.lexbor_mraw_t
	lb.lexbor_mraw_init(&mraw, 1024)

	data := ([^]c.uint8_t)(lb.lexbor_mraw_alloc(&mraw, 128))
	testing.expect(t, data != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(data), 128)

	new_data := ([^]c.uint8_t)(lb.lexbor_mraw_realloc(&mraw, data, 256))
	testing.expect(t, new_data != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(data), 256)

	testing.expect_value(t, data, new_data)

	testing.expect_value(t, mraw.mem.chunk_length, 1)
	testing.expect_value(t, mraw.mem.chunk.length, 256 + lb.lexbor_mraw_meta_size())
	testing.expect_value(t, mraw.mem.chunk.size, 1024 + lb.lexbor_mraw_meta_size())

	testing.expect_value(t, mraw.cache.tree_length, 0)
	testing.expect_value(t, mraw.mem.chunk, mraw.mem.chunk_first)

	lb.lexbor_mraw_destroy(&mraw, false)
}

@(test)
mraw_realloc_eq :: proc(t: ^testing.T) {
	mraw: lb.lexbor_mraw_t
	lb.lexbor_mraw_init(&mraw, 1024)

	data := ([^]c.uint8_t)(lb.lexbor_mraw_alloc(&mraw, 128))
	testing.expect(t, data != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(data), 128)

	new_data := ([^]c.uint8_t)(lb.lexbor_mraw_realloc(&mraw, data, 128))
	testing.expect(t, new_data != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(data), 128)

	testing.expect_value(t, data, new_data)

	testing.expect_value(t, mraw.mem.chunk_length, 1)
	testing.expect_value(t, mraw.mem.chunk.length, 128 + lb.lexbor_mraw_meta_size())
	testing.expect_value(t, mraw.mem.chunk.size, 1024 + lb.lexbor_mraw_meta_size())

	testing.expect_value(t, mraw.cache.tree_length, 0)
	testing.expect_value(t, mraw.mem.chunk, mraw.mem.chunk_first)

	lb.lexbor_mraw_destroy(&mraw, false)
}

@(test)
mraw_realloc_tail_0 :: proc(t: ^testing.T) {
	mraw: lb.lexbor_mraw_t
	lb.lexbor_mraw_init(&mraw, 1024)

	data := ([^]c.uint8_t)(lb.lexbor_mraw_alloc(&mraw, 128))
	testing.expect(t, data != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(data), 128)

	new_data := ([^]c.uint8_t)(lb.lexbor_mraw_realloc(&mraw, data, 0))
	testing.expect(t, new_data == nil)

	testing.expect_value(t, mraw.mem.chunk_length, 1)
	testing.expect_value(t, mraw.mem.chunk.length, 0)
	testing.expect_value(t, mraw.mem.chunk.size, 1024 + lb.lexbor_mraw_meta_size())

	testing.expect_value(t, mraw.cache.tree_length, 0)
	testing.expect_value(t, mraw.mem.chunk, mraw.mem.chunk_first)

	lb.lexbor_mraw_destroy(&mraw, false)
}

@(test)
mraw_realloc_tail_n :: proc(t: ^testing.T) {
	mraw: lb.lexbor_mraw_t
	lb.lexbor_mraw_init(&mraw, 1024)

	data := ([^]c.uint8_t)(lb.lexbor_mraw_alloc(&mraw, 128))
	testing.expect(t, data != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(data), 128)

	data = ([^]c.uint8_t)(lb.lexbor_mraw_alloc(&mraw, 128))
	testing.expect(t, data != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(data), 128)

	new_data := ([^]c.uint8_t)(lb.lexbor_mraw_realloc(&mraw, data, 1024))
	testing.expect(t, new_data != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(new_data), 1024)

	testing.expect(t, data != new_data)

	testing.expect_value(t, mraw.mem.chunk_length, 2)
	testing.expect_value(t, mraw.mem.chunk.length, 1024 + lb.lexbor_mraw_meta_size())
	testing.expect_value(t, mraw.mem.chunk.size, 1024 + lb.lexbor_mraw_meta_size())

	testing.expect_value(t, mraw.cache.tree_length, 1)
	testing.expect_value(
		t,
		mraw.cache.root.size,
		(1024 + lb.lexbor_mraw_meta_size()) -
		(128 + lb.lexbor_mraw_meta_size()) -
		lb.lexbor_mraw_meta_size(),
	)

	testing.expect(t, mraw.mem.chunk != mraw.mem.chunk_first)

	lb.lexbor_mraw_destroy(&mraw, false)
}

@(test)
mraw_realloc_tail_less :: proc(t: ^testing.T) {
	mraw: lb.lexbor_mraw_t
	lb.lexbor_mraw_init(&mraw, 1024)

	data := ([^]c.uint8_t)(lb.lexbor_mraw_alloc(&mraw, 128))
	testing.expect(t, data != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(data), 128)

	new_data := ([^]c.uint8_t)(lb.lexbor_mraw_realloc(&mraw, data, 16))
	testing.expect(t, new_data != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(new_data), 16)

	testing.expect_value(t, data, new_data)

	testing.expect_value(t, mraw.mem.chunk_length, 1)
	testing.expect_value(t, mraw.mem.chunk.length, 16 + lb.lexbor_mraw_meta_size())
	testing.expect_value(t, mraw.mem.chunk.size, 1024 + lb.lexbor_mraw_meta_size())

	testing.expect_value(t, mraw.cache.tree_length, 0)
	testing.expect_value(t, mraw.mem.chunk, mraw.mem.chunk_first)

	lb.lexbor_mraw_destroy(&mraw, false)
}

@(test)
mraw_realloc_tail_great :: proc(t: ^testing.T) {
	mraw: lb.lexbor_mraw_t
	lb.lexbor_mraw_init(&mraw, 1024)

	data := ([^]c.uint8_t)(lb.lexbor_mraw_alloc(&mraw, 128))
	testing.expect(t, data != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(data), 128)

	new_data := ([^]c.uint8_t)(lb.lexbor_mraw_realloc(&mraw, data, 2046))
	testing.expect(t, new_data != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(new_data), lb.lexbor_mem_align(2046))

	testing.expect_value(t, mraw.mem.chunk_length, 1)
	testing.expect_value(
		t,
		mraw.mem.chunk.length,
		lb.lexbor_mem_align(2046) + lb.lexbor_mraw_meta_size(),
	)
	testing.expect_value(
		t,
		mraw.mem.chunk.size,
		lb.lexbor_mem_align(2046) + 1024 + (2 * lb.lexbor_mraw_meta_size()),
	)
	testing.expect_value(t, mraw.cache.tree_length, 0)
	testing.expect_value(t, mraw.mem.chunk, mraw.mem.chunk_first)

	lb.lexbor_mraw_destroy(&mraw, false)
}

@(test)
mraw_realloc_n :: proc(t: ^testing.T) {
	mraw: lb.lexbor_mraw_t
	lb.lexbor_mraw_init(&mraw, 1024)

	one := ([^]c.uint8_t)(lb.lexbor_mraw_alloc(&mraw, 128))
	testing.expect(t, one != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(one), 128)

	two := ([^]c.uint8_t)(lb.lexbor_mraw_alloc(&mraw, 13))
	testing.expect(t, two != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(two), lb.lexbor_mem_align(13))

	three := ([^]c.uint8_t)(lb.lexbor_mraw_realloc(&mraw, one, 256))
	testing.expect(t, three != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(three), 256)

	testing.expect(t, one != three)

	testing.expect_value(t, mraw.mem.chunk_length, 1)
	testing.expect_value(
		t,
		mraw.mem.chunk.length,
		128 +
		lb.lexbor_mraw_meta_size() +
		lb.lexbor_mem_align(13) +
		lb.lexbor_mraw_meta_size() +
		256 +
		lb.lexbor_mraw_meta_size(),
	)

	testing.expect_value(t, mraw.mem.chunk.size, 1024 + lb.lexbor_mraw_meta_size())

	testing.expect_value(t, mraw.cache.tree_length, 1)
	testing.expect_value(t, mraw.mem.chunk, mraw.mem.chunk_first)

	testing.expect(t, mraw.cache.root != nil)
	testing.expect_value(t, mraw.cache.root.size, 128)

	lb.lexbor_mraw_destroy(&mraw, false)
}

@(test)
mraw_realloc_n_0 :: proc(t: ^testing.T) {
	mraw: lb.lexbor_mraw_t
	lb.lexbor_mraw_init(&mraw, 1024)

	one := ([^]c.uint8_t)(lb.lexbor_mraw_alloc(&mraw, 128))
	testing.expect(t, one != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(one), 128)

	two := ([^]c.uint8_t)(lb.lexbor_mraw_alloc(&mraw, 13))
	testing.expect(t, two != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(two), lb.lexbor_mem_align(13))

	three := ([^]c.uint8_t)(lb.lexbor_mraw_realloc(&mraw, one, 0))
	testing.expect_value(t, three, nil)

	testing.expect_value(t, mraw.mem.chunk_length, 1)
	testing.expect_value(
		t,
		mraw.mem.chunk.length,
		128 + lb.lexbor_mraw_meta_size() + lb.lexbor_mem_align(13) + lb.lexbor_mraw_meta_size(),
	)

	testing.expect_value(t, mraw.mem.chunk.size, 1024 + lb.lexbor_mraw_meta_size())

	testing.expect_value(t, mraw.cache.tree_length, 1)
	testing.expect_value(t, mraw.mem.chunk, mraw.mem.chunk_first)

	testing.expect(t, mraw.cache.root != nil)
	testing.expect_value(t, mraw.cache.root.size, 128)

	lb.lexbor_mraw_destroy(&mraw, false)
}

@(test)
mraw_realloc_n_less :: proc(t: ^testing.T) {
	mraw: lb.lexbor_mraw_t
	lb.lexbor_mraw_init(&mraw, 1024)

	one := ([^]c.uint8_t)(lb.lexbor_mraw_alloc(&mraw, 128))
	testing.expect(t, one != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(one), 128)

	two := ([^]c.uint8_t)(lb.lexbor_mraw_alloc(&mraw, 256))
	testing.expect(t, two != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(two), lb.lexbor_mem_align(256))

	three := ([^]c.uint8_t)(lb.lexbor_mraw_realloc(&mraw, one, 51))
	testing.expect(t, three != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(three), lb.lexbor_mem_align(51))

	testing.expect_value(t, one, three)

	testing.expect_value(t, mraw.cache.tree_length, 1)
	testing.expect(t, mraw.cache.root != nil)

	testing.expect_value(
		t,
		mraw.cache.root.size,
		(128 + lb.lexbor_mraw_meta_size()) -
		(lb.lexbor_mem_align(51) + lb.lexbor_mraw_meta_size()) -
		lb.lexbor_mraw_meta_size(),
	)

	testing.expect_value(t, mraw.mem.chunk_length, 1)
	testing.expect_value(t, mraw.mem.chunk.size, 1024 + lb.lexbor_mraw_meta_size())
	testing.expect_value(
		t,
		mraw.mem.chunk.length,
		128 + lb.lexbor_mraw_meta_size() + 256 + lb.lexbor_mraw_meta_size(),
	)

	testing.expect_value(t, mraw.mem.chunk, mraw.mem.chunk_first)

	lb.lexbor_mraw_destroy(&mraw, false)
}

@(test)
mraw_realloc_n_great :: proc(t: ^testing.T) {
	mraw: lb.lexbor_mraw_t
	cache_entry: ^lb.lexbor_bst_entry_t = ---

	lb.lexbor_mraw_init(&mraw, 1024)

	one := ([^]c.uint8_t)(lb.lexbor_mraw_alloc(&mraw, 128))
	testing.expect(t, one != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(one), 128)

	two := ([^]c.uint8_t)(lb.lexbor_mraw_alloc(&mraw, 256))
	testing.expect(t, two != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(two), 256)

	three := ([^]c.uint8_t)(lb.lexbor_mraw_realloc(&mraw, one, 1000))
	testing.expect(t, three != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(three), 1000)

	testing.expect(t, one != three)

	testing.expect_value(t, mraw.cache.tree_length, 2)
	testing.expect(t, mraw.cache.root != nil)

	cache_entry = lb.lexbor_bst_search(mraw.cache, mraw.cache.root, 128)
	testing.expect(t, cache_entry != nil)

	size :=
		(1024 + lb.lexbor_mraw_meta_size()) -
		(128 + lb.lexbor_mraw_meta_size()) -
		(256 + lb.lexbor_mraw_meta_size()) -
		lb.lexbor_mraw_meta_size()

	cache_entry = lb.lexbor_bst_search(mraw.cache, mraw.cache.root, size)
	testing.expect(t, cache_entry != nil)

	testing.expect_value(t, mraw.mem.chunk_length, 2)
	testing.expect_value(t, mraw.mem.chunk_first.size, 1024 + lb.lexbor_mraw_meta_size())
	testing.expect_value(t, mraw.mem.chunk_first.length, 1024 + lb.lexbor_mraw_meta_size())

	testing.expect_value(t, mraw.mem.chunk.size, 1024 + lb.lexbor_mraw_meta_size())
	testing.expect_value(t, mraw.mem.chunk.length, 1000 + lb.lexbor_mraw_meta_size())

	testing.expect(t, mraw.mem.chunk != mraw.mem.chunk_first)

	testing.expect_value(t, mraw.mem.chunk_first.next, mraw.mem.chunk)
	testing.expect_value(t, mraw.mem.chunk.prev, mraw.mem.chunk_first)

	lb.lexbor_mraw_destroy(&mraw, false)
}

@(test)
mraw_free :: proc(t: ^testing.T) {
	mraw: lb.lexbor_mraw_t
	cache_entry: ^lb.lexbor_bst_entry_t = ---

	lb.lexbor_mraw_init(&mraw, 1024)

	data := ([^]c.uint8_t)(lb.lexbor_mraw_alloc(&mraw, 23))
	testing.expect(t, data != nil)

	lb.lexbor_mraw_free(&mraw, data)

	cache_entry = lb.lexbor_bst_search(mraw.cache, mraw.cache.root, lb.lexbor_mem_align(23))
	testing.expect(t, cache_entry != nil)

	cache_entry = lb.lexbor_bst_search_close(mraw.cache, mraw.cache.root, 23)
	testing.expect(t, cache_entry != nil)
	testing.expect_value(t, cache_entry.size, lb.lexbor_mem_align(23))

	lb.lexbor_mraw_destroy(&mraw, false)
}

@(test)
mraw_calloc :: proc(t: ^testing.T) {
	mraw: lb.lexbor_mraw_t
	lb.lexbor_mraw_init(&mraw, 1024)

	data := ([^]c.uint8_t)(lb.lexbor_mraw_calloc(&mraw, 1024))
	testing.expect(t, data != nil)
	testing.expect_value(t, lb.lexbor_mraw_data_size(data), 1024)

	for i := c.size_t(0); i < 1024; i += 1 {
		testing.expect_value(t, data[i], 0x00)
	}

	lb.lexbor_mraw_destroy(&mraw, false)
}

@(test)
clean :: proc(t: ^testing.T) {
	mraw: lb.lexbor_mraw_t
	lb.lexbor_mraw_init(&mraw, 1024)

	lb.lexbor_mraw_clean(&mraw)

	lb.lexbor_mraw_destroy(&mraw, false)
}

@(test)
destroy :: proc(t: ^testing.T) {
	mraw := lb.lexbor_mraw_create()
	lb.lexbor_mraw_init(mraw, 1024)

	testing.expect_value(t, lb.lexbor_mraw_destroy(mraw, true), nil)

	mraw = lb.lexbor_mraw_create()
	lb.lexbor_mraw_init(mraw, 1021)

	testing.expect_value(t, lb.lexbor_mraw_destroy(mraw, false), mraw)
	testing.expect_value(t, lb.lexbor_mraw_destroy(mraw, true), nil)
	testing.expect_value(t, lb.lexbor_mraw_destroy(nil, false), nil)
}

@(test)
destroy_stack :: proc(t: ^testing.T) {
	mraw: lb.lexbor_mraw_t = ---
	lb.lexbor_mraw_init(&mraw, 1023)

	testing.expect_value(t, lb.lexbor_mraw_destroy(&mraw, false), &mraw)
}
