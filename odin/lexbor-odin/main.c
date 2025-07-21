// #include <lexbor/html/parser.h>
// #include <lexbor/dom/interfaces/element.h>
#include <lexbor/core/mraw.h>
// #include <lexbor/html/interfaces/element.h> // lxb_html_head_element_t
// #include <lexbor/html/interfaces/body_element.h> // lxb_html_head_element_t
// #include <lexbor/html/interface.h> // lxb_html_head_element_t
// #include <lexbor/dom/interfaces/node.h> // lxb_html_head_element_t
// #include <lexbor/dom/interfaces/document.h> // lxb_html_head_element_t

int
main(int argc, const char *argv[])
{
    lexbor_mraw_t mraw = {0};
    lexbor_mraw_init(&mraw, 1024);

    void *data = lexbor_mraw_alloc(&mraw, 127);
    // test_ne(data, NULL);
    printf("%d\n", lexbor_mraw_data_size(data)); //128
    printf("%d\n", lexbor_mem_align(127)); // 128
    printf("%d\n", lexbor_mraw_meta_size()); // 8
    // test_eq_size(lexbor_mraw_data_size(data), lexbor_mem_align(127));
    //
    // test_eq_size(mraw.mem->chunk_length, 1UL);
    // test_eq_size(mraw.mem->chunk->length,
    //              lexbor_mem_align(127) + lexbor_mraw_meta_size());
    //
    // printf("--------------\n");
	// printf("%d\n", sizeof(lxb_dom_node_t)); // 1
	// printf("%d\n", sizeof(lxb_dom_element_t)); // 1
	// printf("%d\n", sizeof(lxb_dom_attr_t)); // 1
	// printf("%d\n", sizeof(lxb_dom_event_target_t)); // 1
	// // printf("%d\n", sizeof(struct lxb_dom_document_node_cb_t)); // 1
	// printf("%d\n", sizeof(lxb_dom_document_type_t)); // 1
	// printf("%d\n", sizeof(uintptr_t)); // 1
	// printf("%d\n", sizeof(lexbor_mraw_t)); // 1
	// printf("%d\n", sizeof(lexbor_hash_t)); // 1
    // // printf("%p\n", &document->dom_document);
    // // printf("%p\n", &document->dom_document.compat_mode);
    // // printf("%d\n", &document->dom_document.node.local_name);
    // // printf("%p\n", &document->dom_document.compat_mode);
    // // printf("%p\n", &document->dom_document.type);
	// // printf("%p\n", &(document->dom_document.node)); // 1
	// // printf("%p\n", &(document->dom_document.scripting)); // 1
	// // printf("%d\n", sizeof(lxb_dom_event_target_t)); // 1
    //
    // printf("--------------\n");
    //
    //
	// // printf("lxb_html_head_element_t: %d\n", sizeof(struct lxb_html_head_element)); // 368
	// // printf("lxb_html_head_element_t: %d\n", sizeof(lxb_html_head_element_t)); // 368
    //
	// printf("%p\n", document->dom_document); // why ok ?!?!?!?
	// // fmt.printf("%v\n", document.iframe_srcdoc) // 0x0
	// // fmt.printf("%v\n", document.head) // nil
	// // fmt.printf("%v\n", document.body) // nil
	// // fmt.printf("%v\n", document.css) // ok
	// // fmt.printf("%v\n", document.css_init) // false
	// // fmt.printf("%v\n", document.done) // nil
	// // printf("%d\n", document->ready_state); // LXB_HTML_DOCUMENT_READY_STATE_UNDEF
	// // fmt.printf("%v\n", document.opt) // 0
    //
    // printf("document: %p\n", document); // 12345
    // printf("body: %p\n", document->body); // 0
    //
    //
    // status = lxb_html_document_parse(document, html, html_len);
    // if (status != LXB_STATUS_OK) {
    //     exit(EXIT_FAILURE);
    // }
    //
    // printf("document: %p\n", document); // 12345
    // printf("body: %p\n", document->body); // 98766
    //
    // tag_name = lxb_dom_element_qualified_name(lxb_dom_interface_element(document->body), NULL);
    //
    // printf("Element tag name: %s\n", tag_name);
    //
    // lxb_html_document_destroy(document);

    return 0;
}
