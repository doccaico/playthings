#include <stdio.h>
#include <stdlib.h>
#include <string.h>
 
#include <curl/curl.h>
#include <lexbor/encoding/encoding.h>
#include <lexbor/html/html.h>

#undef FAILED
#define FAILED(...)                                                            \
    do {                                                                       \
        fprintf(stderr, __VA_ARGS__);                                          \
        fprintf(stderr, "\n");                                                 \
        exit(EXIT_FAILURE);                                                    \
    } while (0)

struct MemoryStruct {
  lxb_char_t *memory;
  size_t size;
};

void help(void) {
    const char *message =
        "A program to read bible.\n"
        "Usage: verse-d [Chapter] [Page]\n"
        "  Exsample: verse.exe GEN 1\n";
    fprintf(stderr, message);
}

lxb_html_document_t *parse(const lxb_char_t *html, size_t html_len)
{
    lxb_status_t status;
    lxb_html_parser_t *parser;
    lxb_html_document_t *document;

    parser = lxb_html_parser_create();
    status = lxb_html_parser_init(parser);

    if (status != LXB_STATUS_OK) {
        FAILED("Failed to create HTML parser");
    }

    document = lxb_html_parse(parser, html, html_len);
    if (document == NULL) {
        FAILED("Failed to create Document object");
    }

    lxb_html_parser_destroy(parser);

    return document;
}

void writeln(const lxb_char_t *data, size_t len)
{
    // https://github.com/lexbor/lexbor/blob/v2.4.0/examples/lexbor/encoding/single/from_to.c
    size_t size;
    lxb_status_t status, encode_status, decode_status;
    lxb_encoding_encode_t encode;
    lxb_encoding_decode_t decode;
    const lxb_encoding_data_t *from, *to;

    /* Encode */
    lxb_char_t outbuf[4096];

    /* Decode */
    lxb_codepoint_t cp[4096];
    const lxb_codepoint_t *cp_ref, *cp_end;

    // Get encoding data for 'from'
    from = lxb_encoding_data_by_pre_name((const lxb_char_t *) "utf-8", strlen("utf-8"));
    if (from == NULL) {
        FAILED( "Failed to get encoding from name: %s", "utf-8");
    }

    // Get encoding data for 'to'
    to = lxb_encoding_data_by_pre_name((const lxb_char_t *) "shift_jis", strlen("shift_jis"));
    if (to == NULL) {
        FAILED("Failed to get encoding from name: %s", "shift_jis");
    }

    // Initialization decode
    status = lxb_encoding_decode_init(&decode, from, cp, sizeof(cp) / sizeof(lxb_codepoint_t));
    if (status != LXB_STATUS_OK) {
        FAILED("Failed to initialization decoder");
    }

    status = lxb_encoding_decode_replace_set(&decode,
            LXB_ENCODING_REPLACEMENT_BUFFER, LXB_ENCODING_REPLACEMENT_BUFFER_LEN);
    if (status != LXB_STATUS_OK) {
        FAILED("Failed to set replacement code point for decoder");
    }

    // Initialization encode
    status = lxb_encoding_encode_init(&encode, to, outbuf, sizeof(outbuf));
    if (status != LXB_STATUS_OK) {
        FAILED("Failed to initialization encoder");
    }

    if (to->encoding == LXB_ENCODING_SHIFT_JIS) {
        status = lxb_encoding_encode_replace_set(&encode,
                 LXB_ENCODING_REPLACEMENT_BYTES, LXB_ENCODING_REPLACEMENT_SIZE);
    } else {
        status = lxb_encoding_encode_replace_set(&encode, (lxb_char_t *) "?", 1);
    }

    if (status != LXB_STATUS_OK) {
        FAILED("Failed to set replacement bytes for encoder");
    }

    // Decode incoming data
    const lxb_char_t *end = data + len;

    do {
        // Decode
        decode_status = from->decode(&decode, &data, end);

        cp_ref = cp;
        cp_end = cp + lxb_encoding_decode_buf_used(&decode);

        do {
            encode_status = to->encode(&encode, &cp_ref, cp_end);
            if (encode_status == LXB_STATUS_ERROR) {
                cp_ref++;
                encode_status = LXB_STATUS_SMALL_BUFFER;
            }

            size = lxb_encoding_encode_buf_used(&encode);

            // The printf function cannot print \x00, it can be in UTF-16
            if (fwrite(outbuf, 1, size, stdout) != size) {
                FAILED("Failed to write data to stdout");
            }
            puts("");

            lxb_encoding_encode_buf_used_set(&encode, 0);

        } while (encode_status == LXB_STATUS_SMALL_BUFFER);

        lxb_encoding_decode_buf_used_set(&decode, 0);

    } while (decode_status == LXB_STATUS_SMALL_BUFFER);

    lxb_encoding_decode_finish(&decode);
    lxb_encoding_encode_finish(&encode);
}

void letsgo(struct MemoryStruct *chunk)
{
    lxb_char_t *html = chunk->memory;
    size_t html_size = chunk->size;

    const lxb_char_t name[] = "data-usfm";
    size_t name_size = sizeof(name) - 1;

    lxb_html_document_t *document = parse(html, html_size);

    lxb_dom_collection_t *col_div = lxb_dom_collection_make(&document->dom_document, 128);
    if (col_div == NULL) {
        FAILED("Failed to create col_div object");
    }

    // Get BODY element (root for search)
    lxb_html_body_element_t *body = lxb_html_document_body_element(document);
    lxb_dom_element_t *element = lxb_dom_interface_element(body);

    // Find DIV element
    lxb_status_t status = lxb_dom_elements_by_tag_name(element, col_div, (const lxb_char_t *) "div", 3);
    if (status != LXB_STATUS_OK || lxb_dom_collection_length(col_div) == 0) {
        FAILED("Failed to find DIV element");
    }

    for (size_t i = 0; i < lxb_dom_collection_length(col_div); i++) {
        element = lxb_dom_collection_element(col_div, i);
        bool is_exist = lxb_dom_element_has_attribute(element, name, name_size);
        if (is_exist) break;
    }

   lxb_dom_collection_t *col_span = lxb_dom_collection_make(&document->dom_document, 128);
    if (col_span == NULL) {
        FAILED("Failed to create col_span object");
    }

    // Find SPAN element
    status = lxb_dom_elements_by_tag_name(element, col_span, (const lxb_char_t *) "span", 4);
    if (status != LXB_STATUS_OK || lxb_dom_collection_length(col_span) == 0) {
        FAILED("Failed to find SPAN element");
    }

    for (size_t i = 0; i < lxb_dom_collection_length(col_span); i++) {
        element = lxb_dom_collection_element(col_span, i);

        bool is_exist = lxb_dom_element_has_attribute(element, name, name_size);
        if (is_exist) {
            size_t text_size;
            lxb_char_t *text = lxb_dom_node_text_content(&element->node, &text_size);
            writeln(text, text_size);
        }
    }

    lxb_dom_collection_destroy(col_span, true);
    lxb_dom_collection_destroy(col_div, true);
    lxb_html_document_destroy(document);
}
 
static size_t writeMemoryCallback(void *contents, size_t size, size_t nmemb, void *userp)
{
  size_t realsize = size * nmemb;
  struct MemoryStruct *mem = (struct MemoryStruct *)userp;
 
  lxb_char_t *ptr = realloc(mem->memory, mem->size + realsize + 1);
  if(!ptr) {
    FAILED("OOM\n");
    return 0;
  }
 
  mem->memory = ptr;
  memcpy(&(mem->memory[mem->size]), contents, realsize);
  mem->size += realsize;
  mem->memory[mem->size] = '0';
 
  return realsize;
}
 
int main(int argc, char** argv)
{
    if(argc != 3) {
        help();
        return 1;
    }

    if (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0) {
        help();
        return 0;
    }

    const char *base_url = "https://www.bible.com/ja/bible/1819";
    const char *chapter = argv[1];
    const char *page = argv[2];

    char url[64];
    sprintf(url, "%s/%s.%s", base_url, chapter, page);
    puts(url);

    CURL *curl_handle;
    CURLcode res;

    struct MemoryStruct chunk;

    chunk.memory = malloc(1);  // grown as needed by the realloc above
    chunk.size = 0;    // no data at this point

    curl_global_init(CURL_GLOBAL_ALL);

    // init the curl session
    curl_handle = curl_easy_init();

    curl_easy_setopt(curl_handle, CURLOPT_CAINFO, "curl-ca-bundle.crt");

    // specify URL to get
    curl_easy_setopt(curl_handle, CURLOPT_URL, url);

    // send all data to this function
    curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, writeMemoryCallback);

    // we pass our 'chunk' struct to the callback function
    curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, (void *)&chunk);

    // some servers do not like requests that are made without a user-agent
    // field, so we provide one
    curl_easy_setopt(curl_handle, CURLOPT_USERAGENT, "libcurl-agent/1.0");

    // get it!
    res = curl_easy_perform(curl_handle);

    // check for errors
    if(res != CURLE_OK) {
        fprintf(stderr, "curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
    } else {
        letsgo(&chunk);
    }

    // cleanup curl stuff
    curl_easy_cleanup(curl_handle);

    free(chunk.memory);

    // we are done with libcurl, so clean it up
    curl_global_cleanup();

    return 0;
}
