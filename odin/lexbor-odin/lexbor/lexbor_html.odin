package lexbor

// html module

import "core:c"

// Define

lxb_html_element :: struct {
	element: lxb_dom_element_t,
	style:   ^lexbor_avl_node_t,
	list:    ^lxb_css_rule_declaration_list_t,
}
lxb_html_element_t :: lxb_html_element

lxb_html_document :: struct {
	dom_document:  lxb_dom_document_t,
	iframe_srcdoc: rawptr,
	head:          ^lxb_html_head_element_t,
	body:          ^lxb_html_body_element_t,
	css:           lxb_html_document_css_t,
	css_init:      bool,
	done:          lxb_html_document_done_cb_f,
	ready_state:   lxb_html_document_ready_state_t,
	opt:           lxb_html_document_opt_t,
}
lxb_html_document_t :: lxb_html_document

lxb_html_document_css_t :: struct {
	memory:        ^lxb_css_memory_t,
	css_selectors: ^lxb_css_selectors_t,
	parser:        ^lxb_css_parser_t,
	selectors:     ^lxb_selectors_t,
	styles:        ^lexbor_avl_t,
	stylesheets:   ^lexbor_array_t,
	weak:          ^lexbor_dobject_t,
	customs:       ^lexbor_hash_t,
	customs_id:    c.uintptr_t,
}

lxb_html_head_element :: struct {
	element: lxb_html_element_t,
}
lxb_html_head_element_t :: lxb_html_head_element

lxb_html_body_element :: struct {
	element: lxb_html_element_t,
}
lxb_html_body_element_t :: lxb_html_body_element

lxb_html_document_done_cb_f :: #type proc "c" (document: ^lxb_html_document_t) -> lxb_status_t

lxb_html_document_ready_state_t :: enum c.int {
	LXB_HTML_DOCUMENT_READY_STATE_UNDEF       = 0x00,
	LXB_HTML_DOCUMENT_READY_STATE_LOADING     = 0x01,
	LXB_HTML_DOCUMENT_READY_STATE_INTERACTIVE = 0x02,
	LXB_HTML_DOCUMENT_READY_STATE_COMPLETE    = 0x03,
}

lxb_html_document_opt_t :: c.uint

// Fucntions

@(default_calling_convention = "c")
foreign lib {
	lxb_html_document_create :: proc() -> ^lxb_html_document_t ---
	lxb_html_document_destroy :: proc(document: ^lxb_html_document_t) -> ^lxb_html_document_t ---
	lxb_html_document_parse :: proc(document: ^lxb_html_document_t, html: [^]lxb_char_t, size: c.size_t) -> lxb_status_t ---
	// lxb_html_document_parse :: proc(document: ^lxb_html_document_t, html: [^]lxb_char_t, size: c.size_t) -> lxb_status_t ---
}
