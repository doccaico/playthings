package lexbor

// dom module

import "core:c"

// Define

lxb_dom_document_cmode_t :: enum c.int {
	LXB_DOM_DOCUMENT_CMODE_NO_QUIRKS      = 0x00,
	LXB_DOM_DOCUMENT_CMODE_QUIRKS         = 0x01,
	LXB_DOM_DOCUMENT_CMODE_LIMITED_QUIRKS = 0x02,
}

lxb_dom_document_dtype_t :: enum c.int {
	LXB_DOM_DOCUMENT_DTYPE_UNDEF = 0x00,
	LXB_DOM_DOCUMENT_DTYPE_HTML  = 0x01,
	LXB_DOM_DOCUMENT_DTYPE_XML   = 0x02,
}

lxb_dom_attr_id_t :: c.uintptr_t

lxb_dom_document_type :: struct {
	node:      lxb_dom_node_t,
	name:      lxb_dom_attr_id_t,
	public_id: lexbor_str_t,
	system_id: lexbor_str_t,
}
lxb_dom_document_type_t :: lxb_dom_document_type

lxb_dom_interface_create_f :: #type proc "c" (
	document: ^lxb_dom_document_t,
	tag_id: lxb_tag_id_t,
	ns: lxb_ns_id_t,
) -> rawptr

lxb_dom_interface_clone_f :: #type proc "c" (
	document: ^lxb_dom_document_t,
	intrfc: rawptr,
) -> rawptr

lxb_dom_interface_destroy_f :: #type proc "c" (intrfc: rawptr) -> rawptr

lxb_dom_node_cb_remove_f :: #type proc "c" (node: ^lxb_dom_node_t) -> lxb_status_t

lxb_dom_node_cb_insert_f :: #type proc "c" (node: ^lxb_dom_node_t) -> lxb_status_t

lxb_dom_node_cb_destroy_f :: #type proc "c" (node: ^lxb_dom_node_t) -> lxb_status_t

lxb_dom_node_cb_set_value_f :: #type proc "c" (
	node: ^lxb_dom_node_t,
	value: [^]lxb_char_t,
	length: c.size_t,
) -> lxb_status_t

lxb_dom_document_node_cb_t :: struct {
	insert:    lxb_dom_node_cb_insert_f,
	remove:    lxb_dom_node_cb_remove_f,
	destroy:   lxb_dom_node_cb_destroy_f,
	set_value: lxb_dom_node_cb_set_value_f,
}

lxb_dom_document :: struct {
	node:              lxb_dom_node_t,
	compat_mode:       lxb_dom_document_cmode_t,
	type:              lxb_dom_document_dtype_t,
	doctype:           ^lxb_dom_document_type_t,
	element:           ^lxb_dom_element_t,
	create_interface:  lxb_dom_interface_create_f,
	clone_interface:   lxb_dom_interface_clone_f,
	destroy_interface: lxb_dom_interface_destroy_f,
	ev_insert:         lxb_dom_event_insert_f,
	ev_remove:         lxb_dom_event_remove_f,
	ev_destroy:        lxb_dom_event_destroy_f,
	ev_set_value:      lxb_dom_event_set_value_f,
	mraw:              ^lexbor_mraw_t,
	text:              ^lexbor_mraw_t,
	tags:              ^lexbor_hash_t,
	attrs:             ^lexbor_hash_t,
	prefix:            ^lexbor_hash_t,
	ns:                ^lexbor_hash_t,
	parser:            rawptr,
	user:              rawptr,
	tags_inherited:    bool,
	ns_inherited:      bool,
	scripting:         bool,
}
lxb_dom_document_t :: lxb_dom_document

lxb_dom_event_target :: struct {
	events: rawptr,
}
lxb_dom_event_target_t :: lxb_dom_event_target

lxb_dom_node_type_t :: enum c.int {
	LXB_DOM_NODE_TYPE_UNDEF                  = 0x00,
	LXB_DOM_NODE_TYPE_ELEMENT                = 0x01,
	LXB_DOM_NODE_TYPE_ATTRIBUTE              = 0x02,
	LXB_DOM_NODE_TYPE_TEXT                   = 0x03,
	LXB_DOM_NODE_TYPE_CDATA_SECTION          = 0x04,
	LXB_DOM_NODE_TYPE_ENTITY_REFERENCE       = 0x05,
	LXB_DOM_NODE_TYPE_ENTITY                 = 0x06,
	LXB_DOM_NODE_TYPE_PROCESSING_INSTRUCTION = 0x07,
	LXB_DOM_NODE_TYPE_COMMENT                = 0x08,
	LXB_DOM_NODE_TYPE_DOCUMENT               = 0x09,
	LXB_DOM_NODE_TYPE_DOCUMENT_TYPE          = 0x0A,
	LXB_DOM_NODE_TYPE_DOCUMENT_FRAGMENT      = 0x0B,
	LXB_DOM_NODE_TYPE_NOTATION               = 0x0C,
	LXB_DOM_NODE_TYPE_LAST_ENTRY             = 0x0D,
}

lxb_dom_node :: struct {
	event_target:   lxb_dom_event_target_t,
	local_name:     c.uintptr_t,
	prefix:         c.uintptr_t,
	ns:             c.uintptr_t,
	owner_document: ^lxb_dom_document_t,
	next:           ^lxb_dom_node_t,
	prev:           ^lxb_dom_node_t,
	parent:         ^lxb_dom_node_t,
	first_child:    ^lxb_dom_node_t,
	last_child:     ^lxb_dom_node_t,
	user:           rawptr,
	type:           lxb_dom_node_type_t,
}
lxb_dom_node_t :: lxb_dom_node

lxb_dom_element_custom_state_t :: enum c.int {
	LXB_DOM_ELEMENT_CUSTOM_STATE_UNDEFINED    = 0x00,
	LXB_DOM_ELEMENT_CUSTOM_STATE_FAILED       = 0x01,
	LXB_DOM_ELEMENT_CUSTOM_STATE_UNCUSTOMIZED = 0x02,
	LXB_DOM_ELEMENT_CUSTOM_STATE_CUSTOM       = 0x03,
}

lxb_dom_element :: struct {
	node:           lxb_dom_node_t,
	upper_name:     lxb_dom_attr_id_t,
	qualified_name: lxb_dom_attr_id_t,
	is_value:       ^lexbor_str_t,
	first_attr:     ^lxb_dom_attr_t,
	last_attr:      ^lxb_dom_attr_t,
	attr_id:        ^lxb_dom_attr_t,
	attr_class:     ^lxb_dom_attr_t,
	costom_state:   lxb_dom_element_custom_state_t,
}
lxb_dom_element_t :: lxb_dom_element

lxb_dom_attr :: struct {
	node:           lxb_dom_node_t,
	upper_name:     lxb_dom_attr_id_t,
	qualified_name: lxb_dom_attr_id_t,
	value:          ^lexbor_str_t,
	owner:          ^lxb_dom_element_t,
	next:           ^lxb_dom_attr_t,
	prev:           ^lxb_dom_attr_t,
}
lxb_dom_attr_t :: lxb_dom_attr

lxb_dom_event_insert_f :: #type proc "c" (node: ^lxb_dom_node_t) -> lxb_status_t
lxb_dom_event_remove_f :: #type proc "c" (node: ^lxb_dom_node_t) -> lxb_status_t
lxb_dom_event_destroy_f :: #type proc "c" (node: ^lxb_dom_node_t) -> lxb_status_t
lxb_dom_event_set_value_f :: #type proc "c" (
	node: ^lxb_dom_node_t,
	value: [^]lxb_char_t,
	length: c.size_t,
) -> lxb_status_t

lxb_dom_interface_element :: #force_inline proc "c" (obj: rawptr) -> ^lxb_dom_element_t {
	return cast(^lxb_dom_element_t)obj
}


// Fucntions

@(default_calling_convention = "c")
foreign lib {
	lxb_dom_element_qualified_name :: proc(element: ^lxb_dom_element_t, len: ^c.size_t) -> [^]lxb_char_t ---
	// dom_element_qualified_name :: proc(element: ^lxb_dom_element_t, len: ^c.size_t) -> [^]lxb_char_t ---
}
