package lexbor

// css module

import "core:c"

// Define

lxb_css_memory_t :: struct {
	objs:      ^lexbor_dobject_t,
	mraw:      ^lexbor_mraw_t,
	tree:      ^lexbor_mraw_t,
	ref_count: c.size_t,
}

lxb_css_rule_type_t :: enum c.int {
	LXB_CSS_RULE_UNDEF = 0,
	LXB_CSS_RULE_STYLESHEET,
	LXB_CSS_RULE_LIST,
	LXB_CSS_RULE_AT_RULE,
	LXB_CSS_RULE_STYLE,
	LXB_CSS_RULE_BAD_STYLE,
	LXB_CSS_RULE_DECLARATION_LIST,
	LXB_CSS_RULE_DECLARATION,
}

lxb_css_rule :: struct {
	type:      lxb_css_rule_type_t,
	next:      ^lxb_css_rule_t,
	prev:      ^lxb_css_rule_t,
	parent:    ^lxb_css_rule_t,
	begin:     [^]lxb_char_t,
	end:       [^]lxb_char_t,
	memory:    ^lxb_css_memory_t,
	ref_count: c.size_t,
}
lxb_css_rule_t :: lxb_css_rule

lxb_css_rule_declaration_list :: struct {
	rule:  lxb_css_rule_t,
	first: ^lxb_css_rule_t,
	last:  ^lxb_css_rule_t,
	count: c.size_t,
}
lxb_css_rule_declaration_list_t :: lxb_css_rule_declaration_list

lxb_css_selectors :: struct {
	list:            ^lxb_css_selector_list_t,
	list_last:       ^lxb_css_selector_list_t,
	parent:          ^lxb_css_selector_t,
	combinator:      lxb_css_selector_combinator_t,
	comb_default:    lxb_css_selector_combinator_t,
	error:           c.uintptr_t,
	status:          bool,
	err_in_function: bool,
	failed:          bool,
}
lxb_css_selectors_t :: lxb_css_selectors

lxb_css_selector_specificity_t :: c.uint32_t

lxb_css_selector_list :: struct {
	first:       ^lxb_css_selector_t,
	last:        ^lxb_css_selector_t,
	parent:      ^lxb_css_selector_t,
	next:        ^lxb_css_selector_list_t,
	prev:        ^lxb_css_selector_list_t,
	memory:      ^lxb_css_memory_t,
	specificity: lxb_css_selector_specificity_t,
}
lxb_css_selector_list_t :: lxb_css_selector_list

lxb_css_selector :: struct {
	type:       lxb_css_selector_type_t,
	combinator: lxb_css_selector_combinator_t,
	name:       lexbor_str_t,
	ns:         lexbor_str_t,
	u:          struct #raw_union {
		attribute: lxb_css_selector_attribute_t,
		pseudo:    lxb_css_selector_pseudo_t,
	},
	next:       ^lxb_css_selector_t,
	prev:       ^lxb_css_selector_t,
	list:       ^lxb_css_selector_list_t,
}
lxb_css_selector_t :: lxb_css_selector

lxb_css_selector_type_t :: enum c.int {
	LXB_CSS_SELECTOR_TYPE__UNDEF = 0x00,
	LXB_CSS_SELECTOR_TYPE_ANY,
	LXB_CSS_SELECTOR_TYPE_ELEMENT,
	LXB_CSS_SELECTOR_TYPE_ID,
	LXB_CSS_SELECTOR_TYPE_CLASS,
	LXB_CSS_SELECTOR_TYPE_ATTRIBUTE,
	LXB_CSS_SELECTOR_TYPE_PSEUDO_CLASS,
	LXB_CSS_SELECTOR_TYPE_PSEUDO_CLASS_FUNCTION,
	LXB_CSS_SELECTOR_TYPE_PSEUDO_ELEMENT,
	LXB_CSS_SELECTOR_TYPE_PSEUDO_ELEMENT_FUNCTION,
	LXB_CSS_SELECTOR_TYPE__LAST_ENTRY,
}

lxb_css_selector_combinator_t :: enum c.int {
	LXB_CSS_SELECTOR_COMBINATOR_DESCENDANT = 0x00,
	LXB_CSS_SELECTOR_COMBINATOR_CLOSE,
	LXB_CSS_SELECTOR_COMBINATOR_CHILD,
	LXB_CSS_SELECTOR_COMBINATOR_SIBLING,
	LXB_CSS_SELECTOR_COMBINATOR_FOLLOWING,
	LXB_CSS_SELECTOR_COMBINATOR_CELL,
	LXB_CSS_SELECTOR_COMBINATOR__LAST_ENTRY,
}

lxb_css_selector_attribute_t :: struct {
	match:    lxb_css_selector_match_t,
	modifier: lxb_css_selector_modifier_t,
	value:    lexbor_str_t,
}

lxb_css_selector_match_t :: enum c.int {
	LXB_CSS_SELECTOR_MATCH_EQUAL = 0x00,
	LXB_CSS_SELECTOR_MATCH_INCLUDE,
	LXB_CSS_SELECTOR_MATCH_DASH,
	LXB_CSS_SELECTOR_MATCH_PREFIX,
	LXB_CSS_SELECTOR_MATCH_SUFFIX,
	LXB_CSS_SELECTOR_MATCH_SUBSTRING,
	LXB_CSS_SELECTOR_MATCH__LAST_ENTRY,
}

lxb_css_selector_modifier_t :: enum c.int {
	LXB_CSS_SELECTOR_MODIFIER_UNSET = 0x00,
	LXB_CSS_SELECTOR_MODIFIER_I,
	LXB_CSS_SELECTOR_MODIFIER_S,
	LXB_CSS_SELECTOR_MODIFIER__LAST_ENTRY,
}

lxb_css_selector_pseudo_t :: struct {
	type: c.uint,
	data: rawptr,
}

lxb_css_parser :: struct {
	block:           lxb_css_parser_state_f,

	// rename 'context' to 'ctx' because 'context' is a keyword.
	// context: rawptr,
	ctx:             rawptr,
	tkz:             ^lxb_css_syntax_tokenizer_t,
	selectors:       ^lxb_css_selectors_t,
	old_selectors:   ^lxb_css_selectors_t,
	memory:          ^lxb_css_memory_t,
	old_memory:      ^lxb_css_memory_t,
	rules_begin:     ^lxb_css_syntax_rule_t,
	rules_end:       ^lxb_css_syntax_rule_t,
	rules:           ^lxb_css_syntax_rule_t,
	states_begin:    ^lxb_css_parser_state_t,
	states_end:      ^lxb_css_parser_state_t,
	states:          ^lxb_css_parser_state_t,
	types_begin:     ^lxb_css_syntax_token_type_t,
	types_end:       ^lxb_css_syntax_token_type_t,
	types_pos:       ^lxb_css_syntax_token_type_t,
	chunk_cb:        lxb_css_syntax_tokenizer_chunk_f,
	chunk_ctx:       rawptr,
	pos:             [^]lxb_char_t,
	offset:          c.uintptr_t,
	str:             lexbor_str_t,
	str_size:        c.size_t,
	log:             ^lxb_css_log_t,
	stage:           lxb_css_parser_stage_t,
	loop:            bool,
	fake_null:       bool,
	my_tkz:          bool,
	receive_endings: bool,
	status:          lxb_status_t,
}
lxb_css_parser_t :: lxb_css_parser

lxb_css_parser_state_f :: #type proc "c" (
	parser: ^lxb_css_parser_t,
	token: ^lxb_css_syntax_token_t,
	ctx: rawptr,
) -> bool

lxb_css_syntax_token :: struct {
	types:  struct #raw_union {
		base:         lxb_css_syntax_token_base_t,
		comment:      lxb_css_syntax_token_comment_t,
		number:       lxb_css_syntax_token_number_t,
		dimension:    lxb_css_syntax_token_dimension_t,
		percentage:   lxb_css_syntax_token_percentage_t,
		hash:         lxb_css_syntax_token_hash_t,

		// this wrong?  
		// https://github.com/lexbor/lexbor/blob/f94d97a3d7a1779056540eeee71957ed8008e7f8/source/lexbor/css/syntax/token.h
		string:       lxb_css_syntax_token_string_t,
		bad_string:   lxb_css_syntax_token_bad_string_t,
		delim:        lxb_css_syntax_token_delim_t,
		lparenthesis: lxb_css_syntax_token_l_parenthesis_t,
		rparenthesis: lxb_css_syntax_token_r_parenthesis_t,
		cdc:          lxb_css_syntax_token_cdc_t,
		function:     lxb_css_syntax_token_function_t,
		ident:        lxb_css_syntax_token_ident_t,
		url:          lxb_css_syntax_token_url_t,
		bad_url:      lxb_css_syntax_token_bad_url_t,
		at_keyword:   lxb_css_syntax_token_at_keyword_t,
		whitespace:   lxb_css_syntax_token_whitespace_t,
		terminated:   lxb_css_syntax_token_terminated_t,
	},
	type:   lxb_css_syntax_token_type_t,
	offset: c.uintptr_t,
	cloned: bool,
}
lxb_css_syntax_token_t :: lxb_css_syntax_token

lxb_css_syntax_token_base_t :: struct {
	begin:   [^]lxb_char_t,
	length:  c.size_t,
	user_id: c.uintptr_t,
}

lxb_css_syntax_token_ident_t :: lxb_css_syntax_token_string_t
lxb_css_syntax_token_function_t :: lxb_css_syntax_token_string_t
lxb_css_syntax_token_at_keyword_t :: lxb_css_syntax_token_string_t
lxb_css_syntax_token_hash_t :: lxb_css_syntax_token_string_t
lxb_css_syntax_token_bad_string_t :: lxb_css_syntax_token_string_t
lxb_css_syntax_token_url_t :: lxb_css_syntax_token_string_t
lxb_css_syntax_token_bad_url_t :: lxb_css_syntax_token_string_t
lxb_css_syntax_token_percentage_t :: lxb_css_syntax_token_number_t
lxb_css_syntax_token_whitespace_t :: lxb_css_syntax_token_string_t
lxb_css_syntax_token_cdc_t :: lxb_css_syntax_token_base_t
lxb_css_syntax_token_l_parenthesis_t :: lxb_css_syntax_token_base_t
lxb_css_syntax_token_r_parenthesis_t :: lxb_css_syntax_token_base_t
lxb_css_syntax_token_comment_t :: lxb_css_syntax_token_string_t
lxb_css_syntax_token_terminated_t :: lxb_css_syntax_token_base_t

lxb_css_syntax_cb_pipe_t :: lxb_css_syntax_cb_base_t
lxb_css_syntax_cb_block_t :: lxb_css_syntax_cb_base_t
lxb_css_syntax_cb_function_t :: lxb_css_syntax_cb_base_t
lxb_css_syntax_cb_components_t :: lxb_css_syntax_cb_base_t
lxb_css_syntax_cb_at_rule_t :: lxb_css_syntax_cb_base_t
lxb_css_syntax_cb_qualified_rule_t :: lxb_css_syntax_cb_base_t

lxb_css_syntax_token_string_t :: struct {
	base:   lxb_css_syntax_token_base_t,
	data:   [^]lxb_char_t,
	length: c.size_t,
}

lxb_css_syntax_token_number_t :: struct {
	base:      lxb_css_syntax_token_base_t,
	num:       c.double,
	is_float:  bool,
	have_sign: bool,
}

lxb_css_syntax_token_dimension_t :: struct {
	num: lxb_css_syntax_token_number_t,
	str: lxb_css_syntax_token_string_t,
}

lxb_css_syntax_token_delim_t :: struct {
	base:      lxb_css_syntax_token_base_t,
	character: lxb_char_t,
}

lxb_css_syntax_token_type_t :: enum c.int {
	LXB_CSS_SYNTAX_TOKEN_UNDEF = 0x00,
	LXB_CSS_SYNTAX_TOKEN_IDENT,
	LXB_CSS_SYNTAX_TOKEN_FUNCTION,
	LXB_CSS_SYNTAX_TOKEN_AT_KEYWORD,
	LXB_CSS_SYNTAX_TOKEN_HASH,
	LXB_CSS_SYNTAX_TOKEN_STRING,
	LXB_CSS_SYNTAX_TOKEN_BAD_STRING,
	LXB_CSS_SYNTAX_TOKEN_URL,
	LXB_CSS_SYNTAX_TOKEN_BAD_URL,
	LXB_CSS_SYNTAX_TOKEN_COMMENT,
	LXB_CSS_SYNTAX_TOKEN_WHITESPACE,
	LXB_CSS_SYNTAX_TOKEN_DIMENSION,
	LXB_CSS_SYNTAX_TOKEN_DELIM,
	LXB_CSS_SYNTAX_TOKEN_NUMBER,
	LXB_CSS_SYNTAX_TOKEN_PERCENTAGE,
	LXB_CSS_SYNTAX_TOKEN_CDO,
	LXB_CSS_SYNTAX_TOKEN_CDC,
	LXB_CSS_SYNTAX_TOKEN_COLON,
	LXB_CSS_SYNTAX_TOKEN_SEMICOLON,
	LXB_CSS_SYNTAX_TOKEN_COMMA,
	LXB_CSS_SYNTAX_TOKEN_LS_BRACKET,
	LXB_CSS_SYNTAX_TOKEN_RS_BRACKET,
	LXB_CSS_SYNTAX_TOKEN_L_PARENTHESIS,
	LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS,
	LXB_CSS_SYNTAX_TOKEN_LC_BRACKET,
	LXB_CSS_SYNTAX_TOKEN_RC_BRACKET,
	LXB_CSS_SYNTAX_TOKEN__EOF,
	LXB_CSS_SYNTAX_TOKEN__TERMINATED,
	LXB_CSS_SYNTAX_TOKEN__END = LXB_CSS_SYNTAX_TOKEN__TERMINATED,
	LXB_CSS_SYNTAX_TOKEN__LAST_ENTRY,
}

lxb_css_syntax_tokenizer :: struct {
	cache:        ^lxb_css_syntax_tokenizer_cache_t,
	tokens:       ^lexbor_dobject_t,
	parse_errors: ^lexbor_array_obj_t,
	in_begin:     [^]lxb_char_t,
	in_end:       [^]lxb_char_t,
	begin:        [^]lxb_char_t,
	offset:       c.uintptr_t,
	cache_pos:    c.size_t,
	prepared:     c.size_t,
	mraw:         ^lexbor_mraw_t,
	chunk_cb:     lxb_css_syntax_tokenizer_chunk_f,
	chunk_ctx:    rawptr,
	start:        [^]lxb_char_t,
	pos:          [^]lxb_char_t,
	end:          [^]lxb_char_t,
	buffer:       [128]lxb_char_t,
	token_data:   lxb_css_syntax_token_data_t,
	opt:          c.uint,
	status:       lxb_status_t,
	eof:          bool,
	with_comment: bool,
}
lxb_css_syntax_tokenizer_t :: lxb_css_syntax_tokenizer

lxb_css_syntax_tokenizer_cache_t :: struct {
	list:   ^^lxb_css_syntax_token_t,
	size:   c.size_t,
	length: c.size_t,
}

lxb_css_syntax_tokenizer_chunk_f :: #type proc "c" (
	tkz: ^lxb_css_syntax_tokenizer_t,
	data: ^[^]lxb_char_t,
	end: ^[^]lxb_char_t,
	ctx: rawptr,
) -> lxb_status_t

lxb_css_syntax_token_data :: struct {
	cb:      lxb_css_syntax_token_data_cb_f,
	status:  lxb_status_t,
	count:   c.int,
	num:     c.uint32_t,
	is_last: bool,
}
lxb_css_syntax_token_data_t :: lxb_css_syntax_token_data

lxb_css_syntax_token_data_cb_f :: #type proc "c" (
	begin: [^]lxb_char_t,
	end: [^]lxb_char_t,
	str: ^lexbor_str_t,
	mraw: ^lexbor_mraw_t,
	td: ^lxb_css_syntax_token_data_t,
) -> [^]lxb_char_t

lxb_css_syntax_rule :: struct {
	phase:        lxb_css_syntax_state_f,
	state:        lxb_css_parser_state_f,
	state_back:   lxb_css_parser_state_f,
	back:         lxb_css_syntax_state_f,
	cbx:          struct #raw_union {
		cb:             ^lxb_css_syntax_cb_base_t,
		list_rules:     ^lxb_css_syntax_cb_list_rules_t,
		at_rule:        ^lxb_css_syntax_cb_at_rule_t,
		qualified_rule: ^lxb_css_syntax_cb_qualified_rule_t,
		declarations:   ^lxb_css_syntax_cb_declarations_t,
		components:     ^lxb_css_syntax_cb_components_t,
		func:           ^lxb_css_syntax_cb_function_t,
		block:          ^lxb_css_syntax_cb_block_t,
		pipe:           ^lxb_css_syntax_cb_pipe_t,
		user:           rawptr,
	},

	// rename 'context' to 'ctx' because 'context' is a keyword.
	// context: rawptr,
	ctx:          rawptr,
	offset:       c.uintptr_t,
	deep:         c.size_t,
	block_end:    lxb_css_syntax_token_type_t,
	skip_ending:  bool,
	skip_consume: bool,
	important:    bool,
	failed:       bool,
	top_level:    bool,
	u:            struct #raw_union {
		list_rules:   lxb_css_syntax_list_rules_offset_t,
		at_rule:      lxb_css_syntax_at_rule_offset_t,
		qualified:    lxb_css_syntax_qualified_offset_t,
		declarations: lxb_css_syntax_declarations_offset_t,
		user:         rawptr,
	},
}
lxb_css_syntax_rule_t :: lxb_css_syntax_rule

lxb_css_syntax_state_f :: #type proc "c" (
	parser: ^lxb_css_parser_t,
	token: ^lxb_css_syntax_token_t,
	rule: ^lxb_css_syntax_rule_t,
) -> ^lxb_css_syntax_token_t

lxb_css_syntax_cb_base_t :: struct {
	state:  lxb_css_parser_state_f,
	block:  lxb_css_parser_state_f,
	failed: lxb_css_parser_state_f,
	end:    lxb_css_syntax_cb_done_f,
}

lxb_css_syntax_cb_done_f :: #type proc "c" (
	parser: ^lxb_css_parser_t,
	token: ^lxb_css_syntax_token_t,
	ctx: rawptr,
	failed: bool,
) -> lxb_status_t

lxb_css_syntax_cb_list_rules_t :: struct {
	cb:             lxb_css_syntax_cb_base_t,
	next:           lxb_css_parser_state_f,
	at_rule:        ^lxb_css_syntax_cb_at_rule_t,
	qualified_rule: ^lxb_css_syntax_cb_qualified_rule_t,
}

lxb_css_syntax_cb_declarations_t :: struct {
	cb:              lxb_css_syntax_cb_base_t,
	declaration_end: lxb_css_syntax_declaration_end_f,
	at_rule:         ^lxb_css_syntax_cb_at_rule_t,
}

lxb_css_syntax_declaration_end_f :: #type proc "c" (
	parser: ^lxb_css_parser_t,
	ctx: rawptr,
	important: bool,
	failed: bool,
) -> lxb_status_t

lxb_css_syntax_list_rules_offset_t :: struct {
	begin: c.uintptr_t,
	end:   c.uintptr_t,
}

lxb_css_syntax_at_rule_offset_t :: struct {
	name:        c.uintptr_t,
	prelude:     c.uintptr_t,
	prelude_end: c.uintptr_t,
	block:       c.uintptr_t,
	block_end:   c.uintptr_t,
}

lxb_css_syntax_qualified_offset_t :: struct {
	prelude:     c.uintptr_t,
	prelude_end: c.uintptr_t,
	block:       c.uintptr_t,
	block_end:   c.uintptr_t,
}

lxb_css_syntax_declarations_offset_t :: struct {
	begin:            c.uintptr_t,
	end:              c.uintptr_t,
	name_begin:       c.uintptr_t,
	name_end:         c.uintptr_t,
	value_begin:      c.uintptr_t,
	before_important: c.uintptr_t,
	value_end:        c.uintptr_t,
}

lxb_css_parser_state :: struct {
	state: lxb_css_parser_state_f,
	ctx:   rawptr,
	root:  bool,
}
lxb_css_parser_state_t :: lxb_css_parser_state

lxb_css_log_t :: struct {
	messages:  lexbor_array_obj_t,
	mraw:      ^lexbor_mraw_t,
	self_mraw: bool,
}

lxb_css_parser_stage_t :: enum c.int {
	LXB_CSS_PARSER_CLEAN = 0,
	LXB_CSS_PARSER_RUN,
	LXB_CSS_PARSER_STOP,
	LXB_CSS_PARSER_END,
}

// Fucntions

@(default_calling_convention = "c")
foreign lib {
}
