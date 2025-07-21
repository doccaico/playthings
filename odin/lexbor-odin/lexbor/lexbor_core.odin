package lexbor

import "core:c"
import "core:c/libc"
import "core:fmt"
import "core:mem"

// lexbor/core/array.h

lexbor_array_t :: struct {
	list:   [^]rawptr,
	size:   c.size_t,
	length: c.size_t,
}

@(default_calling_convention = "c")
foreign lib {
	lexbor_array_create :: proc() -> ^lexbor_array_t ---
	lexbor_array_init :: proc(array: ^lexbor_array_t, size: c.size_t) -> lxb_status_t ---
	lexbor_array_clean :: proc(array: ^lexbor_array_t) ---
	lexbor_array_destroy :: proc(array: ^lexbor_array_t, self_destroy: bool) -> ^lexbor_array_t ---
	lexbor_array_expand :: proc(array: ^lexbor_array_t, up_to: c.size_t) -> ^rawptr ---
	lexbor_array_push :: proc(array: ^lexbor_array_t, value: rawptr) -> lxb_status_t ---
	lexbor_array_pop :: proc(array: ^lexbor_array_t) -> rawptr ---
	lexbor_array_insert :: proc(array: ^lexbor_array_t, idx: c.size_t, value: rawptr) -> lxb_status_t ---
	lexbor_array_set :: proc(array: ^lexbor_array_t, idx: c.size_t, value: rawptr) -> lxb_status_t ---
	lexbor_array_delete :: proc(array: ^lexbor_array_t, begin: c.size_t, length: c.size_t) ---
}

@(require_results)
lexbor_array_get :: proc "c" (array: ^lexbor_array_t, idx: c.size_t) -> rawptr {
	if (idx >= array.length) {
		return nil
	}
	return array.list[idx]
}

@(require_results)
lexbor_array_length :: proc "c" (array: ^lexbor_array_t) -> c.size_t {
	return array.length
}

@(require_results)
lexbor_array_size :: proc "c" (array: ^lexbor_array_t) -> c.size_t {
	return array.size
}

@(default_calling_convention = "c")
foreign lib {
	lexbor_array_get_noi :: proc(array: ^lexbor_array_t, idx: c.size_t) -> rawptr ---
	lexbor_array_length_noi :: proc(array: ^lexbor_array_t) -> c.size_t ---
	lexbor_array_size_noi :: proc(array: ^lexbor_array_t) -> c.size_t ---
}

// lexbor/core/array_obj.h

lexbor_array_obj_t :: struct {
	list:        [^]c.uint8_t,
	size:        c.size_t,
	length:      c.size_t,
	struct_size: c.size_t,
}

@(default_calling_convention = "c")
foreign lib {
	lexbor_array_obj_create :: proc() -> ^lexbor_array_obj_t ---
	lexbor_array_obj_init :: proc(array: ^lexbor_array_obj_t, size: c.size_t, struct_size: c.size_t) -> lxb_status_t ---
	lexbor_array_obj_clean :: proc(array: ^lexbor_array_obj_t) ---
	lexbor_array_obj_destroy :: proc(array: ^lexbor_array_obj_t, self_destroy: bool) -> ^lexbor_array_obj_t ---
	lexbor_array_obj_expand :: proc(array: ^lexbor_array_obj_t, up_to: c.size_t) -> ^c.uint8_t ---
	lexbor_array_obj_push :: proc(array: ^lexbor_array_obj_t) -> rawptr ---
	lexbor_array_obj_push_wo_cls :: proc(array: ^lexbor_array_obj_t) -> rawptr ---
	lexbor_array_obj_push_n :: proc(array: ^lexbor_array_obj_t, count: c.size_t) -> rawptr ---
	lexbor_array_obj_pop :: proc(array: ^lexbor_array_obj_t) -> rawptr ---
	lexbor_array_obj_delete :: proc(array: ^lexbor_array_obj_t, begin: c.size_t, length: c.size_t) ---
}

lexbor_array_obj_erase :: proc "c" (array: ^lexbor_array_obj_t) {
	libc.memset(array, 0, size_of(lexbor_array_obj_t))
}

@(require_results)
lexbor_array_obj_get :: proc "c" (array: ^lexbor_array_obj_t, idx: c.size_t) -> rawptr {
	if (idx >= array.length) {
		return nil
	}
	return &array.list[idx * array.struct_size]
}

@(require_results)
lexbor_array_obj_length :: proc "c" (array: ^lexbor_array_obj_t) -> c.size_t {
	return array.length
}

@(require_results)
lexbor_array_obj_size :: proc "c" (array: ^lexbor_array_obj_t) -> c.size_t {
	return array.size
}

@(require_results)
lexbor_array_obj_struct_size :: proc "c" (array: ^lexbor_array_obj_t) -> c.size_t {
	return array.struct_size
}

@(require_results)
lexbor_array_obj_last :: proc "c" (array: ^lexbor_array_obj_t) -> rawptr {
	if (array.length == 0) {
		return nil
	}
	return &array.list[(array.length - 1) * array.struct_size]
}

@(default_calling_convention = "c")
foreign lib {
	lexbor_array_obj_erase_noi :: proc() ---
	lexbor_array_obj_get_noi :: proc(array: ^lexbor_array_obj_t, idx: c.size_t) -> rawptr ---
	lexbor_array_obj_length_noi :: proc(array: ^lexbor_array_obj_t) -> c.size_t ---
	lexbor_array_obj_size_noi :: proc(array: ^lexbor_array_obj_t) -> c.size_t ---
	lexbor_array_obj_struct_size_noi :: proc(array: ^lexbor_array_obj_t) -> c.size_t ---
	lexbor_array_obj_last_noi :: proc(array: ^lexbor_array_obj_t) -> rawptr ---
}

// lexbor/core/avl.h

lexbor_avl_t :: lexbor_avl
lexbor_avl_node_t :: lexbor_avl_node

lexbor_avl_node_f :: #type proc "c" (
	avl: ^lexbor_avl_t,
	root: ^^lexbor_avl_node_t,
	node: ^lexbor_avl_node_t,
	ctx: rawptr,
) -> lxb_status_t

lexbor_avl_node :: struct {
	type:   c.size_t,
	height: c.short,
	value:  rawptr,
	left:   ^lexbor_avl_node_t,
	right:  ^lexbor_avl_node_t,
	parent: ^lexbor_avl_node_t,
}

lexbor_avl :: struct {
	nodes:      ^lexbor_dobject_t,
	last_right: ^lexbor_avl_node_t,
}

@(default_calling_convention = "c")
foreign lib {
	lexbor_avl_create :: proc() -> ^lexbor_avl_t ---
	lexbor_avl_init :: proc(avl: ^lexbor_avl_t, chunk_len: c.size_t, struct_size: c.size_t) -> lxb_status_t ---
	lexbor_avl_clean :: proc(avl: ^lexbor_avl_t) ---
	lexbor_avl_destroy :: proc(avl: ^lexbor_avl_t, self_destroy: bool) -> ^lexbor_avl_t ---
	lexbor_avl_node_make :: proc(avl: ^lexbor_avl_t, type: c.size_t, value: rawptr) -> ^lexbor_avl_node_t ---
	lexbor_avl_node_clean :: proc(avl: ^lexbor_avl_node_t) ---
	lexbor_avl_node_destroy :: proc(avl: ^lexbor_avl_t, node: ^lexbor_avl_node_t, self_destroy: bool) -> ^lexbor_avl_node_t ---
	lexbor_avl_insert :: proc(avl: ^lexbor_avl_t, scope: ^^lexbor_avl_node_t, type: c.size_t, value: rawptr) -> ^lexbor_avl_node_t ---
	lexbor_avl_search :: proc(avl: ^lexbor_avl_t, scope: ^lexbor_avl_node_t, type: c.size_t) -> ^lexbor_avl_node_t ---
	lexbor_avl_remove :: proc(avl: ^lexbor_avl_t, scope: ^^lexbor_avl_node_t, type: c.size_t) -> rawptr ---
	lexbor_avl_remove_by_node :: proc(avl: ^lexbor_avl_t, root: ^^lexbor_avl_node_t, node: ^lexbor_avl_node_t) ---
	lexbor_avl_foreach :: proc(avl: ^lexbor_avl_t, scope: ^^lexbor_avl_node_t, cb: lexbor_avl_node_f, ctx: rawptr) -> lxb_status_t ---
	lexbor_avl_foreach_recursion :: proc(avl: ^lexbor_avl_t, scope: ^lexbor_avl_node_t, callback: lexbor_avl_node_f, ctx: rawptr) ---
}

// lexbor/core/base.h

LEXBOR_VERSION_MAJOR :: 1
LEXBOR_VERSION_MINOR :: 8
LEXBOR_VERSION_PATCH :: 0

LEXBOR_VERSION_STRING :: "1.8.0"

lexbor_max :: max
lexbor_min :: min

lexbor_status_t :: enum c.int {
	LXB_STATUS_OK = 0x0000,
	LXB_STATUS_ERROR = 0x0001,
	LXB_STATUS_ERROR_MEMORY_ALLOCATION,
	LXB_STATUS_ERROR_OBJECT_IS_NULL,
	LXB_STATUS_ERROR_SMALL_BUFFER,
	LXB_STATUS_ERROR_INCOMPLETE_OBJECT,
	LXB_STATUS_ERROR_NO_FREE_SLOT,
	LXB_STATUS_ERROR_TOO_SMALL_SIZE,
	LXB_STATUS_ERROR_NOT_EXISTS,
	LXB_STATUS_ERROR_WRONG_ARGS,
	LXB_STATUS_ERROR_WRONG_STAGE,
	LXB_STATUS_ERROR_UNEXPECTED_RESULT,
	LXB_STATUS_ERROR_UNEXPECTED_DATA,
	LXB_STATUS_ERROR_OVERFLOW,
	LXB_STATUS_CONTINUE,
	LXB_STATUS_SMALL_BUFFER,
	LXB_STATUS_ABORTED,
	LXB_STATUS_STOPPED,
	LXB_STATUS_NEXT,
	LXB_STATUS_STOP,
	LXB_STATUS_WARNING,
}

lexbor_action_t :: enum c.int {
	LEXBOR_ACTION_OK   = 0x00,
	LEXBOR_ACTION_STOP = 0x01,
	LEXBOR_ACTION_NEXT = 0x02,
}

lexbor_serialize_cb_f :: #type proc "c" (data: [^]lxb_char_t, ctx: rawptr) -> lxb_status_t

lexbor_serialize_cb_cp_f :: #type proc "c" (
	cps: ^lxb_codepoint_t,
	len: c.size_t,
	ctx: rawptr,
) -> lxb_status_t

lexbor_serialize_ctx_t :: struct {
	cb:    lexbor_serialize_cb_f,
	ctx:   rawptr,
	opt:   c.intptr_t,
	count: c.size_t,
}

// lexbor/core/bst.h

@(require_results)
lxb_bst_root :: #force_inline proc "c" (bst: ^lexbor_bst) -> ^lexbor_bst_entry_t {
	return bst.root
}

@(require_results)
lxb_bst_root_ref :: #force_inline proc "c" (bst: ^lexbor_bst) -> ^^lexbor_bst_entry_t {
	return &bst.root
}

lexbor_bst_entry_t :: lexbor_bst_entry
lexbor_bst_t :: lexbor_bst

lexbor_bst_entry_f :: #type proc "c" (
	bst: ^lexbor_bst_t,
	entry: lexbor_bst_entry_t,
	ctx: rawptr,
) -> bool

lexbor_bst_entry :: struct {
	value:  rawptr,
	right:  ^lexbor_bst_entry_t,
	left:   ^lexbor_bst_entry_t,
	next:   ^lexbor_bst_entry_t,
	parent: ^lexbor_bst_entry_t,
	size:   c.size_t,
}

lexbor_bst :: struct {
	dobject:     ^lexbor_dobject_t,
	root:        ^lexbor_bst_entry_t,
	tree_length: c.size_t,
}

@(default_calling_convention = "c")
foreign lib {
	lexbor_bst_create :: proc() -> ^lexbor_bst_t ---
	lexbor_bst_init :: proc(bst: ^lexbor_bst_t, size: c.size_t) -> lxb_status_t ---
	lexbor_bst_clean :: proc(bst: ^lexbor_bst_t) ---
	lexbor_bst_destroy :: proc(bst: ^lexbor_bst_t, self_destroy: bool) -> ^lexbor_bst_t ---
	lexbor_bst_entry_make :: proc(bst: ^lexbor_bst_t, size: c.size_t) -> ^lexbor_bst_entry_t ---
	lexbor_bst_insert :: proc(bst: ^lexbor_bst_t, scope: ^^lexbor_bst_entry_t, size: c.size_t, value: rawptr) -> ^lexbor_bst_entry_t ---
	lexbor_bst_insert_not_exists :: proc(bst: ^lexbor_bst_t, scope: ^^lexbor_bst_entry_t, size: c.size_t) -> ^lexbor_bst_entry_t ---
	lexbor_bst_search :: proc(bst: ^lexbor_bst_t, scope: ^lexbor_bst_entry_t, size: c.size_t) -> ^lexbor_bst_entry_t ---
	lexbor_bst_search_close :: proc(bst: ^lexbor_bst_t, scope: ^lexbor_bst_entry_t, size: c.size_t) -> ^lexbor_bst_entry_t ---
	lexbor_bst_remove :: proc(bst: ^lexbor_bst_t, root: ^^lexbor_bst_entry_t, size: c.size_t) -> rawptr ---
	lexbor_bst_remove_close :: proc(bst: ^lexbor_bst_t, root: ^^lexbor_bst_entry_t, size: c.size_t, found_size: ^c.size_t) -> rawptr ---
	lexbor_bst_remove_by_pointer :: proc(bst: ^lexbor_bst_t, entry: ^lexbor_bst_entry_t, root: ^^lexbor_bst_entry_t) -> rawptr ---
	lexbor_bst_serialize :: proc(bst: ^lexbor_bst_t, callback: lexbor_callback_f, ctx: rawptr) ---
	lexbor_bst_serialize_entry :: proc(entry: ^lexbor_bst_entry_t, callback: lexbor_callback_f, ctx: rawptr, tabs: c.size_t) ---
}

// lexbor/core/bst_map.h

lexbor_bst_map_entry_t :: struct {
	str:   lexbor_str_t,
	value: rawptr,
}

lexbor_bst_map_t :: struct {
	bst:     ^lexbor_bst_t,
	mraw:    ^lexbor_mraw_t,
	entries: ^lexbor_dobject_t,
}

@(default_calling_convention = "c")
foreign lib {
	lexbor_bst_map_create :: proc() -> lexbor_bst_map_t ---
	lexbor_bst_map_init :: proc(bst_map: ^lexbor_bst_map_t, size: c.size_t) -> lxb_status_t ---
	lexbor_bst_map_clean :: proc(bst_map: ^lexbor_bst_map_t, size: c.size_t) ---
	lexbor_bst_map_destroy :: proc(bst_map: ^lexbor_bst_map_t, self_destroy: bool) -> ^lexbor_bst_map_t ---
	lexbor_bst_map_search :: proc(bst_map: ^lexbor_bst_map_t, scope: ^lexbor_bst_entry_t, key: [^]lxb_char_t, key_len: c.size_t) -> ^lexbor_bst_map_entry_t ---
	lexbor_bst_map_insert :: proc(bst_map: ^lexbor_bst_map_t, scope: ^^lexbor_bst_entry_t, key: [^]lxb_char_t, key_len: c.size_t, value: rawptr) -> ^lexbor_bst_map_entry_t ---
	lexbor_bst_map_insert_not_exists :: proc(bst_map: ^lexbor_bst_map_t, scope: ^^lexbor_bst_entry_t, key: [^]lxb_char_t, key_len: c.size_t) -> ^lexbor_bst_map_entry_t ---
	lexbor_bst_map_remove :: proc(bst_map: ^lexbor_bst_map_t, scope: ^^lexbor_bst_entry_t, key: [^]lxb_char_t, key_len: c.size_t) -> rawptr ---
}

@(require_results)
lexbor_bst_map_mraw :: proc "c" (bst_map: ^lexbor_bst_map_t) -> ^lexbor_mraw_t {
	return bst_map.mraw
}

@(default_calling_convention = "c")
foreign lib {
	lexbor_bst_map_mraw_noi :: proc(bst_map: ^lexbor_bst_map_t) -> ^lexbor_mraw_t ---
}

// lexbor/core/conv.h

@(default_calling_convention = "c")
foreign lib {
	lexbor_conv_float_to_data :: proc(num: c.double, buf: [^]lxb_char_t, len: c.size_t) -> c.size_t ---
	lexbor_conv_log_to_data :: proc(num: c.long, buf: [^]lxb_char_t, len: c.size_t) -> c.size_t ---
	lexbor_conv_int64_to_data :: proc(num: c.int64_t, buf: [^]lxb_char_t, len: c.size_t) -> c.size_t ---
	lexbor_conv_data_to_double :: proc(start: ^[^]lxb_char_t, len: c.size_t) -> c.double ---
	lexbor_conv_data_to_ulong :: proc(data: ^[^]lxb_char_t, length: c.size_t) -> c.ulong ---
	lexbor_conv_data_to_long :: proc(data: ^[^]lxb_char_t, length: c.size_t) -> c.long ---
	lexbor_conv_data_to_uint :: proc(data: ^[^]lxb_char_t, length: c.size_t) -> c.uint ---
	lexbor_conv_dec_to_hex :: proc(number: c.uint32_t, out: [^]lxb_char_t, length: c.size_t) -> c.size_t ---
}

@(require_results)
lexbor_conv_double_to_long :: proc "c" (number: c.double) -> c.long {
	if (number > c.double(max(c.long))) {
		return max(c.long)
	}
	if (number < c.double(min(c.long))) {
		return -max(c.long)
	}
	return c.long(number)
}

// lexbor/core/core.h

// lexbor/core/def.h

LEXBOR_MEM_ALIGN_STEP :: size_of(rawptr)

// lexbor/core/diyfp.h

lexbor_diyfp :: #force_inline proc "c" (_s: c.uint64_t, _e: c.int) -> lexbor_diyfp_t {
	return lexbor_diyfp_t{_s, _e}
}
lexbor_uint64_hl :: #force_inline proc "c" (h: c.uint64_t, l: c.uint64_t) -> c.uint64_t {
	return (h << 32) + l
}

LEXBOR_DBL_SIGNIFICAND_SIZE :: 52
LEXBOR_DBL_EXPONENT_BIAS :: (0x3FF + LEXBOR_DBL_SIGNIFICAND_SIZE)
LEXBOR_DBL_EXPONENT_MIN :: (-LEXBOR_DBL_EXPONENT_BIAS)
LEXBOR_DBL_EXPONENT_MAX :: (0x7FF - LEXBOR_DBL_EXPONENT_BIAS)
LEXBOR_DBL_EXPONENT_DENORMAL :: (-LEXBOR_DBL_EXPONENT_BIAS + 1)

LEXBOR_DBL_SIGNIFICAND_MASK :: (0x000FFFFF << 32) + 0xFFFFFFFF
LEXBOR_DBL_HIDDEN_BIT :: (0x00100000 << 32) + 0x00000000
LEXBOR_DBL_EXPONENT_MASK :: (0x7FF00000 << 32) + 0x00000000

LEXBOR_DIYFP_SIGNIFICAND_SIZE :: 64

LEXBOR_SIGNIFICAND_SIZE :: 53
LEXBOR_SIGNIFICAND_SHIFT :: (LEXBOR_DIYFP_SIGNIFICAND_SIZE - LEXBOR_DBL_SIGNIFICAND_SIZE)

LEXBOR_DECIMAL_EXPONENT_OFF :: 348
LEXBOR_DECIMAL_EXPONENT_MIN :: (-348)
LEXBOR_DECIMAL_EXPONENT_MAX :: 340
LEXBOR_DECIMAL_EXPONENT_DIST :: 8

lexbor_diyfp_t :: struct {
	significand: c.uint64_t,
	exp:         c.int,
}

@(default_calling_convention = "c")
foreign lib {
	lexbor_cached_power_dec :: proc(exp: c.int, dec_exp: ^c.int) -> lexbor_diyfp_t ---
	lexbor_cached_power_bin :: proc(exp: c.int, dec_exp: ^c.int) -> lexbor_diyfp_t ---
}

@(require_results)
lexbor_diyfp_leading_zeros64 :: proc "c" (x: c.uint64_t) -> c.uint64_t {
	n: c.uint64_t = ---

	if (x == 0) {
		return 64
	}

	n = 0
	x := x // explicit mutation

	for (x & 0x8000000000000000) == 0 {
		n += 1
		x <<= 1
	}

	return n
}

@(require_results)
lexbor_diyfp_from_d2 :: proc "c" (d: c.double) -> lexbor_diyfp_t {
	biased_exp: c.int = ---
	significand: c.uint64_t = ---
	r: lexbor_diyfp_t = ---

	u: struct #raw_union {
		d:    c.double,
		u64_: c.uint64_t,
	} = ---

	u.d = d

	biased_exp = c.int((u.u64_ & LEXBOR_DBL_EXPONENT_MASK) >> LEXBOR_DBL_SIGNIFICAND_SIZE)
	significand = u.u64_ & LEXBOR_DBL_SIGNIFICAND_MASK

	if (biased_exp != 0) {
		r.significand = significand + LEXBOR_DBL_HIDDEN_BIT
		r.exp = biased_exp - LEXBOR_DBL_EXPONENT_BIAS
	} else {
		r.significand = significand
		r.exp = LEXBOR_DBL_EXPONENT_MIN + 1
	}

	return r
}

@(require_results)
lexbor_diyfp_2d :: proc "c" (v: lexbor_diyfp_t) -> c.double {
	exp: c.int = ---
	significand: c.uint64_t = ---
	biased_exp: c.uint64_t = ---

	u: struct #raw_union {
		d:    c.double,
		u64_: c.uint64_t,
	} = ---

	exp = v.exp
	significand = v.significand

	for significand > LEXBOR_DBL_HIDDEN_BIT + LEXBOR_DBL_SIGNIFICAND_MASK {
		significand >>= 1
		exp += 1
	}

	if exp >= LEXBOR_DBL_EXPONENT_MAX {
		return libc.INFINITY
	}

	if exp < LEXBOR_DBL_EXPONENT_DENORMAL {
		return 0.0
	}

	for exp > LEXBOR_DBL_EXPONENT_DENORMAL && (significand & LEXBOR_DBL_HIDDEN_BIT) == 0 {
		significand <<= 1
		exp -= 1
	}

	if exp == LEXBOR_DBL_EXPONENT_DENORMAL && (significand & LEXBOR_DBL_HIDDEN_BIT) == 0 {
		biased_exp = 0
	} else {
		biased_exp = c.uint64_t(exp + LEXBOR_DBL_EXPONENT_BIAS)
	}

	u.u64_ =
		(significand & LEXBOR_DBL_SIGNIFICAND_MASK) | (biased_exp << LEXBOR_DBL_SIGNIFICAND_SIZE)

	return u.d
}

@(require_results)
lexbor_diyfp_shift_left :: proc "c" (v: lexbor_diyfp_t, shift: c.uint) -> lexbor_diyfp_t {
	return lexbor_diyfp(v.significand << shift, v.exp - c.int(shift))
}

@(require_results)
lexbor_diyfp_shift_right :: proc "c" (v: lexbor_diyfp_t, shift: c.uint) -> lexbor_diyfp_t {
	return lexbor_diyfp(v.significand >> shift, v.exp + c.int(shift))
}

@(require_results)
lexbor_diyfp_sub :: proc "c" (lhs: lexbor_diyfp_t, rhs: lexbor_diyfp_t) -> lexbor_diyfp_t {
	return lexbor_diyfp(lhs.significand - rhs.significand, lhs.exp)
}

@(require_results)
lexbor_diyfp_mul :: proc "c" (lhs: lexbor_diyfp_t, rhs: lexbor_diyfp_t) -> lexbor_diyfp_t {
	a: c.uint64_t = ---
	b: c.uint64_t = ---
	c_: c.uint64_t = ---
	d: c.uint64_t = ---
	ac: c.uint64_t = ---
	bc: c.uint64_t = ---
	ad: c.uint64_t = ---
	bd: c.uint64_t = ---
	tmp: c.uint64_t = ---

	a = lhs.significand >> 32
	b = lhs.significand & 0xffffffff
	c_ = rhs.significand >> 32
	d = rhs.significand & 0xffffffff

	ac = a * c_
	bc = b * c_
	ad = a * d
	bd = b * d

	tmp = (bd >> 32) + (ad & 0xffffffff) + (bc & 0xffffffff)

	tmp += 1 << 31

	return lexbor_diyfp(ac + (ad >> 32) + (bc >> 32) + (tmp >> 32), lhs.exp + rhs.exp + 64)
}

@(require_results)
lexbor_diyfp_normalize :: proc "c" (v: lexbor_diyfp_t) -> lexbor_diyfp_t {
	return lexbor_diyfp_shift_left(v, c.uint(lexbor_diyfp_leading_zeros64(v.significand)))
}

// lexbor/core/dobject.h

lexbor_dobject_t :: struct {
	mem:         ^lexbor_mem_t,
	cache:       ^lexbor_array_t,
	allocated:   c.size_t,
	struct_size: c.size_t,
}

@(default_calling_convention = "c")
foreign lib {
	lexbor_dobject_create :: proc() -> ^lexbor_dobject_t ---
	lexbor_dobject_init :: proc(dobject: ^lexbor_dobject_t, chunk_size: c.size_t, struct_size: c.size_t) -> lxb_status_t ---
	lexbor_dobject_clean :: proc(dobject: ^lexbor_dobject_t) ---
	lexbor_dobject_init_list_entries :: proc(dobject: ^lexbor_dobject_t, pos: c.size_t) -> ^c.uint8_t ---
	lexbor_dobject_alloc :: proc(dobject: ^lexbor_dobject_t) -> rawptr ---
	lexbor_dobject_calloc :: proc(dobject: ^lexbor_dobject_t) -> rawptr ---
	lexbor_dobject_free :: proc(dobject: ^lexbor_dobject_t, data: rawptr) -> rawptr ---
	lexbor_dobject_absolute_position :: proc(dobject: ^lexbor_dobject_t, pos: c.size_t) -> rawptr ---
}

@(require_results)
lexbor_dobject_allocated :: proc "c" (dobject: ^lexbor_dobject_t) -> c.size_t {
	return dobject.allocated
}

@(require_results)
lexbor_dobject_cache_length :: proc "c" (dobject: ^lexbor_dobject_t) -> c.size_t {
	return lexbor_array_length(dobject.cache)
}

@(default_calling_convention = "c")
foreign lib {
	lexbor_dobject_allocated_noi :: proc(dobject: ^lexbor_dobject_t) -> c.size_t ---
	lexbor_dobject_cache_length_noi :: proc(dobject: ^lexbor_dobject_t) -> c.size_t ---
}

// lexbor/core/dtoa.h

@(default_calling_convention = "c")
foreign lib {
	lexbor_dtoa :: proc(value: c.double, begin: [^]lxb_char_t, len: c.size_t) -> c.size_t ---
}

// lexbor/core/fs.h

lexbor_fs_dir_file_f :: #type proc "c" (
	fullpath: [^]lxb_char_t,
	fullpath_len: c.size_t,
	filename: [^]lxb_char_t,
	filename_len: c.size_t,
	ctx: rawptr,
) -> lexbor_action_t

lexbor_fs_dir_opt_t :: c.int

lexbor_fs_dir_opt :: enum c.int {
	LEXBOR_FS_DIR_OPT_UNDEF          = 0x00,
	LEXBOR_FS_DIR_OPT_WITHOUT_DIR    = 0x01,
	LEXBOR_FS_DIR_OPT_WITHOUT_FILE   = 0x02,
	LEXBOR_FS_DIR_OPT_WITHOUT_HIDDEN = 0x04,
}

lexbor_fs_file_type_t :: enum c.int {
	LEXBOR_FS_FILE_TYPE_UNDEF            = 0x00,
	LEXBOR_FS_FILE_TYPE_FILE             = 0x01,
	LEXBOR_FS_FILE_TYPE_DIRECTORY        = 0x02,
	LEXBOR_FS_FILE_TYPE_BLOCK_DEVICE     = 0x03,
	LEXBOR_FS_FILE_TYPE_CHARACTER_DEVICE = 0x04,
	LEXBOR_FS_FILE_TYPE_PIPE             = 0x05,
	LEXBOR_FS_FILE_TYPE_SYMLINK          = 0x06,
	LEXBOR_FS_FILE_TYPE_SOCKET           = 0x07,
}

@(default_calling_convention = "c")
foreign lib {
	lexbor_fs_dir_read :: proc(dirpath: [^]lxb_char_t, opt: lexbor_fs_dir_opt_t, callback: lexbor_fs_dir_file_f, ctx: rawptr) -> lxb_status_t ---
	lexbor_fs_file_type :: proc(full_path: [^]lxb_char_t) -> lexbor_fs_file_type_t ---
	lexbor_fs_file_easy_read :: proc(full_path: [^]lxb_char_t, len: ^c.size_t) -> [^]lxb_char_t ---
}

// lexbor/core/hash.h

LEXBOR_HASH_SHORT_SIZE :: 16
LEXBOR_HASH_TABLE_MIN_SIZE :: 32

lexbor_hash_search_t :: lexbor_hash_search_
lexbor_hash_insert_t :: lexbor_hash_insert_

lexbor_hash_t :: lexbor_hash
lexbor_hash_entry_t :: lexbor_hash_entry

lexbor_hash_id_f :: #type proc "c" (key: [^]lxb_char_t, size: c.size_t) -> c.uint32_t

lexbor_hash_copy_f :: #type proc "c" (
	hash: ^lexbor_hash_t,
	entry: ^lexbor_hash_entry_t,
	key: [^]lxb_char_t,
	size: c.size_t,
) -> lxb_status_t

lexbor_hash_cmp_f :: #type proc "c" (
	first: [^]lxb_char_t,
	second: [^]lxb_char_t,
	size: c.size_t,
) -> bool

lexbor_hash_entry :: struct {
	u:      struct #raw_union {
		long_str:  [^]lxb_char_t,
		short_str: [LEXBOR_HASH_SHORT_SIZE + 1]lxb_char_t,
	},
	length: c.size_t,
	next:   ^lexbor_hash_entry_t,
}

lexbor_hash :: struct {
	entries:     ^lexbor_dobject_t,
	mraw:        ^lexbor_mraw_t,
	table:       ^^lexbor_hash_entry_t,
	table_size:  c.size_t,
	struct_size: c.size_t,
}

lexbor_hash_insert_ :: struct {
	hash: lexbor_hash_id_f,
	cmp:  lexbor_hash_cmp_f,
	copy: lexbor_hash_copy_f,
}

lexbor_hash_search_ :: struct {
	hash: lexbor_hash_id_f,
	cmp:  lexbor_hash_cmp_f,
}

@(default_calling_convention = "c")
foreign lib {
	lexbor_hash_create :: proc() -> ^lexbor_hash_t ---
	lexbor_hash_init :: proc(hash: ^lexbor_hash_t, table_size: c.size_t, struct_size: c.size_t) -> lxb_status_t ---
	lexbor_hash_clean :: proc(hash: ^lexbor_hash_t) ---
	lexbor_hash_destroy :: proc(hash: ^lexbor_hash_t, destroy_obj: bool) -> ^lexbor_hash_t ---
	lexbor_hash_insert :: proc(hash: ^lexbor_hash_t, insert: ^lexbor_hash_insert_t, key: [^]lxb_char_t, length: c.size_t) -> rawptr ---
	lexbor_hash_insert_by_entry :: proc(hash: ^lexbor_hash_t, entry: ^lexbor_hash_entry_t, search: ^lexbor_hash_search_t, key: [^]lxb_char_t, length: c.size_t) -> rawptr ---
	lexbor_hash_remove :: proc(hash: ^lexbor_hash_t, search: ^lexbor_hash_search_t, key: [^]lxb_char_t, length: c.size_t) ---
	lexbor_hash_search :: proc(hash: ^lexbor_hash_t, search: ^lexbor_hash_search_t, key: [^]lxb_char_t, length: c.size_t) -> rawptr ---
	lexbor_hash_remove_by_hash_id :: proc(hash: ^lexbor_hash_t, hash_id: c.uint32_t, key: [^]lxb_char_t, length: c.size_t, cmp_func: lexbor_hash_cmp_f) ---
	lexbor_hash_search_by_hash_id :: proc(hash: ^lexbor_hash_t, hash_id: c.uint32_t, key: [^]lxb_char_t, length: c.size_t, cmp_func: lexbor_hash_cmp_f) -> rawptr ---
	lexbor_hash_make_id :: proc(key: [^]lxb_char_t, length: c.size_t) -> c.uint32_t ---
	lexbor_hash_make_id_lower :: proc(key: [^]lxb_char_t, length: c.size_t) -> c.uint32_t ---
	lexbor_hash_make_id_upper :: proc(key: [^]lxb_char_t, length: c.size_t) -> c.uint32_t ---
	lexbor_hash_copy :: proc(hash: ^lexbor_hash_t, entry: ^lexbor_hash_entry_t, key: [^]lxb_char_t, length: c.size_t) -> lxb_status_t ---
	lexbor_hash_copy_lower :: proc(hash: ^lexbor_hash_t, entry: ^lexbor_hash_entry_t, key: [^]lxb_char_t, length: c.size_t) -> lxb_status_t ---
	lexbor_hash_copy_upper :: proc(hash: ^lexbor_hash_t, entry: ^lexbor_hash_entry_t, key: [^]lxb_char_t, length: c.size_t) -> lxb_status_t ---
}

@(require_results)
lexbor_hash_mraw :: proc "c" (hash: ^lexbor_hash_t) -> ^lexbor_mraw_t {
	return hash.mraw
}

@(require_results)
lexbor_hash_entry_str :: proc "c" (entry: ^lexbor_hash_entry_t) -> [^]lxb_char_t {
	if entry.length <= LEXBOR_HASH_SHORT_SIZE {
		return &entry.u.short_str[0]
	}

	return entry.u.long_str
}

@(require_results)
lexbor_hash_entry_str_set :: proc "c" (
	entry: ^lexbor_hash_entry_t,
	data: [^]lxb_char_t,
	length: c.size_t,
) -> [^]lxb_char_t {
	entry.length = length

	if length <= LEXBOR_HASH_SHORT_SIZE {
		libc.memcpy(&entry.u.short_str[0], data, length)
		return &entry.u.short_str[0]
	}

	entry.u.long_str = data
	return entry.u.long_str
}

lexbor_hash_entry_str_free :: proc "c" (hash: ^lexbor_hash_t, entry: ^lexbor_hash_entry_t) {
	if entry.length > LEXBOR_HASH_SHORT_SIZE {
		lexbor_mraw_free(hash.mraw, entry.u.long_str)
	}

	entry.length = 0
}

@(require_results)
lexbor_hash_entry_create :: proc "c" (hash: ^lexbor_hash_t) -> ^lexbor_hash_entry_t {
	return (^lexbor_hash_entry_t)(lexbor_dobject_calloc(hash.entries))
}

@(require_results)
lexbor_hash_entry_destroy :: proc "c" (
	hash: ^lexbor_hash_t,
	entry: ^lexbor_hash_entry_t,
) -> ^lexbor_hash_entry_t {
	return (^lexbor_hash_entry_t)(lexbor_dobject_free(hash.entries, entry))
}

@(require_results)
lexbor_hash_entries_count :: proc "c" (hash: ^lexbor_hash_t) -> c.size_t {
	return lexbor_dobject_allocated(hash.entries)
}

// lexbor/core/in.h

lexbor_in_node_t :: lexbor_in_node
lexbor_in_opt_t :: c.int

lexbor_in_opt :: enum c.int {
	LEXBOR_IN_OPT_UNDEF    = 0x00,
	LEXBOR_IN_OPT_READONLY = 0x01,
	LEXBOR_IN_OPT_DONE     = 0x02,
	LEXBOR_IN_OPT_FAKE     = 0x04,
	LEXBOR_IN_OPT_ALLOC    = 0x08,
}

lexbor_in_t :: struct {
	nodes: ^lexbor_dobject_t,
}

lexbor_in_node :: struct {
	offset:   c.size_t,
	opt:      lexbor_in_opt_t,
	begin:    [^]lxb_char_t,
	end:      [^]lxb_char_t,
	use:      [^]lxb_char_t,
	next:     ^lexbor_in_node_t,
	prev:     ^lexbor_in_node_t,
	incoming: ^lexbor_in_t,
}

@(default_calling_convention = "c")
foreign lib {
	lexbor_in_create :: proc() -> ^lexbor_in_t ---
	lexbor_in_init :: proc(incoming: ^lexbor_in_t, chunk_size: c.size_t) -> lxb_status_t ---
	lexbor_in_clean :: proc(incoming: ^lexbor_in_t) ---
	lexbor_in_destroy :: proc(incoming: ^lexbor_in_t, self_destroy: bool) -> ^lexbor_in_t ---
	lexbor_in_node_make :: proc(incoming: ^lexbor_in_t, last_node: ^lexbor_in_node_t, buf: [^]lxb_char_t, buf_size: c.size_t) -> ^lexbor_in_node_t ---
	lexbor_in_node_clean :: proc(node: ^lexbor_in_node_t) ---
	lexbor_in_node_destroy :: proc(incoming: ^lexbor_in_t, node: ^lexbor_in_node_t, self_destroy: bool) -> ^lexbor_in_node_t ---
	lexbor_in_node_split :: proc(node: ^lexbor_in_node_t, pos: [^]lxb_char_t) -> ^lexbor_in_node_t ---
	lexbor_in_node_find :: proc(node: ^lexbor_in_node_t, pos: [^]lxb_char_t) -> ^lexbor_in_node_t ---
	lexbor_in_node_pos_up :: proc(node: ^lexbor_in_node_t, return_node: ^^lexbor_in_node_t, pos: [^]lxb_char_t, offset: c.size_t) -> [^]lxb_char_t ---
	lexbor_in_node_pos_down :: proc(node: ^lexbor_in_node_t, return_node: ^^lexbor_in_node_t, pos: [^]lxb_char_t, offset: c.size_t) -> [^]lxb_char_t ---
}

@(require_results)
lexbor_in_node_begin :: proc "c" (node: ^lexbor_in_node_t) -> [^]lxb_char_t {
	return node.begin
}

@(require_results)
lexbor_in_node_end :: proc "c" (node: ^lexbor_in_node_t) -> [^]lxb_char_t {
	return node.end
}

@(require_results)
lexbor_in_node_offset :: proc "c" (node: ^lexbor_in_node_t) -> c.size_t {
	return node.offset
}

@(require_results)
lexbor_in_node_next :: proc "c" (node: ^lexbor_in_node_t) -> ^lexbor_in_node_t {
	return node.next
}

@(require_results)
lexbor_in_node_prev :: proc "c" (node: ^lexbor_in_node_t) -> ^lexbor_in_node_t {
	return node.prev
}

@(require_results)
lexbor_in_node_in :: proc "c" (node: ^lexbor_in_node_t) -> ^lexbor_in_t {
	return node.incoming
}

@(require_results)
lexbor_in_segment :: proc "c" (node: ^lexbor_in_node_t, data: [^]lxb_char_t) -> bool {
	return node.begin <= data && node.end >= data
}

@(default_calling_convention = "c")
foreign lib {
	lexbor_in_node_begin_noi :: proc(node: ^lexbor_in_node_t) -> [^]lxb_char_t ---
	lexbor_in_node_end_noi :: proc(node: ^lexbor_in_node_t) -> [^]lxb_char_t ---
	lexbor_in_node_offset_noi :: proc(node: ^lexbor_in_node_t) -> c.size_t ---
	lexbor_in_node_next_noi :: proc(node: ^lexbor_in_node_t) -> ^lexbor_in_node_t ---
	lexbor_in_node_prev_noi :: proc(node: ^lexbor_in_node_t) -> ^lexbor_in_node_t ---
	lexbor_in_node_in_noi :: proc(node: ^lexbor_in_node_t) -> ^lexbor_in_t ---
	lexbor_in_segment_noi :: proc(node: ^lexbor_in_node_t, data: [^]lxb_char_t) -> bool ---
}

// lexbor/core/lexbor.h

lexbor_memory_malloc_f :: #type proc "c" (size: c.size_t) -> rawptr
lexbor_memory_realloc_f :: #type proc "c" (dst: rawptr, size: c.size_t) -> rawptr
lexbor_memory_calloc_f :: #type proc "c" (num: c.size_t, size: c.size_t) -> rawptr
lexbor_memory_free_f :: #type proc "c" (dst: rawptr)

@(default_calling_convention = "c")
foreign lib {
	lexbor_malloc :: proc(size: c.size_t) -> rawptr ---
	lexbor_realloc :: proc(dst: rawptr, size: c.size_t) -> rawptr ---
	lexbor_calloc :: proc(num: c.size_t, size: c.size_t) -> rawptr ---
	lexbor_free :: proc(dst: rawptr) -> rawptr ---
	lexbor_memory_setup :: proc(new_malloc: lexbor_memory_malloc_f, new_realloc: lexbor_memory_realloc_f, new_calloc: lexbor_memory_calloc_f, new_free: lexbor_memory_free_f) -> lxb_status_t ---
}

// lexbor/core/mem.h

lexbor_mem_chunk_t :: lexbor_mem_chunk
lexbor_mem_t :: lexbor_mem

lexbor_mem_chunk :: struct {
	data:   [^]c.uint8_t,
	length: c.size_t,
	size:   c.size_t,
	next:   ^lexbor_mem_chunk_t,
	prev:   ^lexbor_mem_chunk_t,
}

lexbor_mem :: struct {
	chunk:          ^lexbor_mem_chunk_t,
	chunk_first:    ^lexbor_mem_chunk_t,
	chunk_min_size: c.size_t,
	chunk_length:   c.size_t,
}

@(default_calling_convention = "c")
foreign lib {
	lexbor_mem_create :: proc() -> ^lexbor_mem_t ---
	lexbor_mem_init :: proc(mem: ^lexbor_mem_t, min_chunk_size: c.size_t) -> lxb_status_t ---
	lexbor_mem_clean :: proc(mem: ^lexbor_mem_t) ---
	lexbor_mem_destroy :: proc(mem: ^lexbor_mem_t, destroy_self: bool) -> ^lexbor_mem_t ---
	lexbor_mem_chunk_init :: proc(mem: ^lexbor_mem_t, chunk: ^lexbor_mem_chunk_t, length: c.size_t) -> [^]c.int8_t ---
	lexbor_mem_chunk_make :: proc(mem: ^lexbor_mem_t, length: c.size_t) -> ^lexbor_mem_chunk_t ---
	lexbor_mem_chunk_destroy :: proc(mem: ^lexbor_mem_t, chunk: ^lexbor_mem_chunk_t, self_destroy: bool) -> ^lexbor_mem_chunk_t ---
	lexbor_mem_alloc :: proc(mem: ^lexbor_mem_t, length: c.size_t) -> rawptr ---
	lexbor_mem_calloc :: proc(mem: ^lexbor_mem_t, length: c.size_t) -> rawptr ---
}

@(require_results)
lexbor_mem_current_length :: proc "c" (mem: ^lexbor_mem_t) -> c.size_t {
	return mem.chunk.length
}

@(require_results)
lexbor_mem_current_size :: proc "c" (mem: ^lexbor_mem_t) -> c.size_t {
	return mem.chunk.size
}

@(require_results)
lexbor_mem_chunk_length :: proc "c" (mem: ^lexbor_mem_t) -> c.size_t {
	return mem.chunk_length
}

@(require_results)
lexbor_mem_align :: proc "c" (size: c.size_t) -> c.size_t {
	if (size % LEXBOR_MEM_ALIGN_STEP) != 0 {
		return size + (LEXBOR_MEM_ALIGN_STEP - (size % LEXBOR_MEM_ALIGN_STEP))
	}
	return size
}

@(require_results)
lexbor_mem_align_floor :: proc "c" (size: c.size_t) -> c.size_t {
	if (size % LEXBOR_MEM_ALIGN_STEP) != 0 {
		return size - (size % LEXBOR_MEM_ALIGN_STEP)
	}
	return size

}

@(default_calling_convention = "c")
foreign lib {
	lexbor_mem_current_length_noi :: proc(mem: ^lexbor_mem_t) -> c.size_t ---
	lexbor_mem_current_size_noi :: proc(mem: ^lexbor_mem_t) -> c.size_t ---
	lexbor_mem_chunk_length_noi :: proc(mem: ^lexbor_mem_t) -> c.size_t ---
	lexbor_mem_align_noi :: proc(size: c.size_t) -> c.size_t ---
	lexbor_mem_align_floor_noi :: proc(size: c.size_t) -> c.size_t ---
}

// lexbor/core/mraw.h

@(require_results)
lexbor_mraw_meta_size :: #force_inline proc "c" () -> c.size_t {
	if (size_of(c.size_t) % LEXBOR_MEM_ALIGN_STEP) != 0 {
		return(
			size_of(c.size_t) +
			(LEXBOR_MEM_ALIGN_STEP - (size_of(c.size_t) % LEXBOR_MEM_ALIGN_STEP)) \
		)

	}
	return size_of(c.size_t)
}

lexbor_mraw_t :: struct {
	mem:       ^lexbor_mem_t,
	cache:     ^lexbor_bst_t,
	ref_count: c.size_t,
}

@(default_calling_convention = "c")
foreign lib {
	lexbor_mraw_create :: proc() -> ^lexbor_mraw_t ---
	lexbor_mraw_init :: proc(mraw: ^lexbor_mraw_t, chunk_size: c.size_t) -> lxb_status_t ---
	lexbor_mraw_clean :: proc(mraw: ^lexbor_mraw_t) ---
	lexbor_mraw_destroy :: proc(mraw: ^lexbor_mraw_t, destroy_self: bool) -> ^lexbor_mraw_t ---
	lexbor_mraw_alloc :: proc(mraw: ^lexbor_mraw_t, size: c.size_t) -> rawptr ---
	lexbor_mraw_calloc :: proc(mraw: ^lexbor_mraw_t, size: c.size_t) -> rawptr ---
	lexbor_mraw_realloc :: proc(mraw: ^lexbor_mraw_t, data: rawptr, new_size: c.size_t) -> rawptr ---
	lexbor_mraw_free :: proc(mraw: ^lexbor_mraw_t, data: rawptr) -> rawptr ---
}

@(require_results)
lexbor_mraw_data_size :: proc "c" (data: rawptr) -> c.size_t {
	return (^c.size_t)((uintptr((^c.uint8_t)(data))) - (uintptr(lexbor_mraw_meta_size())))^
}

lexbor_mraw_data_size_set :: proc "c" (data: rawptr, size: c.size_t) {
	data := data // explicit mutation
	size := size // explicit mutation
	data = (rawptr)((uintptr((^c.uint8_t)(data))) - (uintptr(lexbor_mraw_meta_size())))
	libc.memcpy(data, &size, size_of(c.size_t))
}

@(require_results)
lexbor_mraw_dup :: proc "c" (mraw: ^lexbor_mraw_t, src: rawptr, size: c.size_t) -> rawptr {
	data := lexbor_mraw_alloc(mraw, size)
	if (data != nil) {
		libc.memcpy(data, src, size)
	}
	return data
}

@(require_results)
lexbor_mraw_reference_count :: proc "c" (mraw: ^lexbor_mraw_t) -> c.size_t {
	return mraw.ref_count
}

@(default_calling_convention = "c")
foreign lib {
	lexbor_mraw_data_size_noi :: proc(data: rawptr) -> c.size_t ---
	lexbor_mraw_data_size_set_noi :: proc(data: rawptr, size: c.size_t) ---
	lexbor_mraw_dup_noi :: proc(mraw: ^lexbor_mraw_t, src: rawptr, size: c.size_t) -> rawptr ---
}

// lexbor/core/perf.h

// TODO

// lexbor/core/str.h

lexbor_str_t :: struct {
	data:   [^]lxb_char_t,
	length: c.size_t,
}

// lexbor/core/types.h

lxb_codepoint_t :: c.uint32_t
lxb_char_t :: c.uchar
lxb_status_t :: c.uint

lexbor_callback_f :: #type proc "c" (
	buffer: [^]lxb_char_t,
	size: c.size_t,
	ctx: rawptr,
) -> lxb_status_t
