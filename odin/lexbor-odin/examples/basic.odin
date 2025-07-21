package main

import "core:fmt"
import "core:os"

import lb "../lexbor"

main :: proc() {
	html := "<div>Works fine!</div>"

	document := lb.lxb_html_document_create()
	if (document == nil) {
		os.exit(1)
	}

	status := lb.lxb_html_document_parse(document, raw_data(html), len(html))
	if (lb.lexbor_status_t(status) != lb.lexbor_status_t.LXB_STATUS_OK) {
		os.exit(1)
	}

	tag_name := lb.lxb_dom_element_qualified_name(lb.lxb_dom_interface_element(document.body), nil)

	fmt.printf("Element tag name: %s\n", tag_name)

	lb.lxb_html_document_destroy(document)
}
