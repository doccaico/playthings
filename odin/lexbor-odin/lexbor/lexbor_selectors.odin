package lexbor

// selectors module

import "core:c"

// Define

lxb_selectors :: struct {
	state:   lxb_selectors_state_cb_f,
	objs:    ^lexbor_dobject_t,
	nested:  ^lexbor_dobject_t,
	current: ^lxb_selectors_nested_t,
	first:   ^lxb_selectors_entry_t,
	options: lxb_selectors_opt_t,
	status:  lxb_status_t,
}
lxb_selectors_t :: lxb_selectors

lxb_selectors_entry :: struct {
	id:         c.uintptr_t,
	combinator: lxb_css_selector_combinator_t,
	selector:   ^lxb_css_selector_t,
	node:       ^lxb_dom_node_t,
	next:       ^lxb_selectors_entry_t,
	prev:       ^lxb_selectors_entry_t,
	following:  ^lxb_selectors_entry_t,
	nexted:     ^lxb_selectors_nested_t,
}
lxb_selectors_entry_t :: lxb_selectors_entry

lxb_selectors_nested :: struct {
	entry:        ^lxb_selectors_entry_t,
	return_state: lxb_selectors_state_cb_f,
	cb:           lxb_selectors_cb_f,
	ctx:          rawptr,
	root:         ^lxb_dom_node_t,
	last:         ^lxb_selectors_entry_t,
	parent:       ^lxb_selectors_nested_t,
	index:        c.size_t,
	found:        bool,
}
lxb_selectors_nested_t :: lxb_selectors_nested

lxb_selectors_state_cb_f :: #type proc "c" (
	selectors: ^lxb_selectors_t,
	entry: ^lxb_selectors_entry_t,
) -> ^lxb_selectors_entry_t

lxb_selectors_cb_f :: #type proc "c" (
	node: ^lxb_dom_node_t,
	spec: lxb_css_selector_specificity_t,
	ctx: rawptr,
) -> lxb_status_t

lxb_selectors_opt_t :: enum c.int {
	LXB_SELECTORS_OPT_DEFAULT     = 0x00,
	LXB_SELECTORS_OPT_MATCH_ROOT  = 1 << 1,
	LXB_SELECTORS_OPT_MATCH_FIRST = 1 << 2,
}

// Fucntions

@(default_calling_convention = "c")
foreign lib {
}
