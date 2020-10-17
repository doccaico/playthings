#ifndef INCLUDED_OBF_KANA
#define INCLUDED_OBF_KANA


#define HIRAGANA1_BYTES (0xe38181)
#define HIRAGANA1_BEGIN (0x8181)
#define HIRAGANA1_END   (0x81bf)
#define HIRAGANA1_MAP_LEN sizeof(hiragana1_map)/sizeof(hiragana1_map[0])
#define HIRAGANA1_MAP_PTR hiragana1_map

#define HIRAGANA2_BYTES (0xe38280)
#define HIRAGANA2_BEGIN (0x8280)
#define HIRAGANA2_END   (0x8296)
#define HIRAGANA2_MAP_LEN sizeof(hiragana2_map)/sizeof(hiragana2_map[0])
#define HIRAGANA2_MAP_PTR hiragana2_map

#define KATAKANA1_BYTES (0xe382a1)
#define KATAKANA1_BEGIN (0x82a1)
#define KATAKANA1_END   (0x82bf)
#define KATAKANA1_MAP_LEN sizeof(katakana1_map)/sizeof(katakana1_map[0])
#define KATAKANA1_MAP_PTR katakana1_map

#define KATAKANA2_BYTES (0xe38380)
#define KATAKANA2_BEGIN (0x8380)
#define KATAKANA2_END   (0x83ba)
#define KATAKANA2_MAP_LEN sizeof(katakana2_map)/sizeof(katakana2_map[0])
#define KATAKANA2_MAP_PTR katakana2_map

#define DEFAULT_BUF_SIZE (1024 * 8)
#define REALLOC_SIZE (1024 * 4)

extern const char *const hiragana1_map[];
extern const char *const hiragana2_map[];
extern const char *const katakana1_map[];
extern const char *const katakana2_map[];
extern size_t current_buf_size;

char *convert(const char*);


#endif
