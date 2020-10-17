#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

#include "pattern1.h"
#include "convkana.h"


const char *const hiragana1_map[] = {
    /* ぁ あ ぃ い ぅ う ぇ え ぉ お */
    H1_1 ,H1_2 ,H1_3 ,H1_4 ,H1_5 ,H1_6 ,H1_7 ,H1_8 ,H1_9 ,H1_10,
    /* か が き ぎ く ぐ け げ こ ご */
    H1_11 ,H1_12 ,H1_13 ,H1_14 ,H1_15 ,H1_16 ,H1_17 ,H1_18 ,H1_19 ,H1_20,
    /* さ ざ し じ す ず せ ぜ そ ぞ */
    H1_21 ,H1_22 ,H1_23 ,H1_24 ,H1_25 ,H1_26 ,H1_27 ,H1_28 ,H1_29 ,H1_30,
    /* た だ ち ぢ っ つ づ て で と */
    H1_31 ,H1_32 ,H1_33 ,H1_34 ,H1_35 ,H1_36 ,H1_37 ,H1_38 ,H1_39 ,H1_40,
    /* ど な に ぬ ね の は ば ぱ ひ */
    H1_41 ,H1_42 ,H1_43 ,H1_44 ,H1_45 ,H1_46 ,H1_47 ,H1_48 ,H1_49 ,H1_50,
    /* び ぴ ふ ぶ ぷ へ べ ぺ ほ ぼ */
    H1_51 ,H1_52 ,H1_53 ,H1_54 ,H1_55 ,H1_56 ,H1_57 ,H1_58 ,H1_59 ,H1_60,
    /* ぽ ま み */
    H1_61 ,H1_62 ,H1_63
};

const char *const hiragana2_map[] = {
    /* む め も ゃ や ゅ ゆ ょ よ ら */
    H2_1 ,H2_2 ,H2_3 ,H2_4 ,H2_5 ,H2_6 ,H2_7 ,H2_8 ,H2_9 ,H2_10,
    /* り る れ ろ ゎ わ ゐ ゑ を ん */
    H2_11 ,H2_12 ,H2_13 ,H2_14 ,H2_15 ,H2_16 ,H2_17 ,H2_18 ,H2_19 ,H2_20,
    /* ゔ ゕ ゖ */
    H2_21 ,H2_22 ,H2_23
};

const char *const katakana1_map[] = {
    /* ァ ア ィ イ ゥ ウ ェ エ ォ オ */
    K1_1 ,K1_2 ,K1_3 ,K1_4 ,K1_5 ,K1_6 ,K1_7 ,K1_8 ,K1_9 ,K1_10,
    /* カ ガ キ ギ ク グ ケ ゲ コ ゴ */
    K1_11 ,K1_12 ,K1_13 ,K1_14 ,K1_15 ,K1_16 ,K1_17 ,K1_18 ,K1_19 ,K1_20,
    /* サ ザ シ ジ ス ズ セ ゼ ソ ゾ */
    K1_21 ,K1_22 ,K1_23 ,K1_24 ,K1_25 ,K1_26 ,K1_27 ,K1_28 ,K1_29 ,K1_30,
    /* タ */
    K1_31
};

const char *const katakana2_map[] = {
    /* ダ チ ヂ ッ ツ ヅ テ デ ト ド */
    K2_1 ,K2_2 ,K2_3 ,K2_4 ,K2_5 ,K2_6 ,K2_7 ,K2_8 ,K2_9 ,K2_10,
    /* ナ ニ ヌ ネ ノ ハ バ パ ヒ ビ */
    K2_11 ,K2_12 ,K2_13 ,K2_14 ,K2_15 ,K2_16 ,K2_17 ,K2_18 ,K2_19 ,K2_20,
    /* ピ フ ブ プ ヘ ベ ペ ホ ボ ポ */
    K2_21 ,K2_22 ,K2_23 ,K2_24 ,K2_25 ,K2_26 ,K2_27 ,K2_28 ,K2_29 ,K2_30,
    /* マ ミ ム メ モ ャ ヤ ュ ユ ョ */
    K2_31 ,K2_32 ,K2_33 ,K2_34 ,K2_35 ,K2_36 ,K2_37 ,K2_38 ,K2_39 ,K2_40,
    /* ヨ ラ リ ル レ ロ ヮ ワ ヰ ヱ */
    K2_41 ,K2_42 ,K2_43 ,K2_44 ,K2_45 ,K2_46 ,K2_47 ,K2_48 ,K2_49 ,K2_50,
    /* ヲ ン ヴ ヵ ヶ ヷ ヸ ヹ ヺ */
    K2_51 ,K2_52 ,K2_53 ,K2_54 ,K2_55 ,K2_56 ,K2_57 ,K2_58 ,K2_59
};

/* 現在のバッファサイズ */
size_t current_buf_size;

static char *expand(char *buf, size_t buf_pos) {

    char *tmp;

    if ((tmp = malloc(current_buf_size + REALLOC_SIZE)) == NULL) {
        free(buf);
        fprintf(stderr, "Fatal: failed to malloc\n");
        exit(EXIT_FAILURE);
    }
    memcpy(tmp, buf, buf_pos);
    free(buf);
    current_buf_size += REALLOC_SIZE;

    return tmp;
}

char *convert(const char *input) {

    char *buf;
    int byte1;
    size_t buf_pos;
    size_t input_pos;

    buf_pos = input_pos = 0;
    /* 大域変数 current_buf_size は convert が呼ばれるたびに初期化(0)する */
    current_buf_size = 0;
    /* 変換文字の1バイト目 あ: (e3) 81 80 : 0xe3 */
    byte1 = 0xe3;

    if ((buf = malloc(DEFAULT_BUF_SIZE + 1)) == NULL) {
        fprintf(stderr, "Fatal: failed to malloc\n");
        exit(EXIT_FAILURE);
    }
    current_buf_size += DEFAULT_BUF_SIZE;

    while(input[input_pos]) {

        if ((input[input_pos] & 0xff) == byte1) {

            int byte;
            const char* const *map;
            int maplen;
            /* 変換文字の2バイト目と3バイト目  */
            /* e.g. あ: e3 (81 80) : 0x8180 */
            int byte2and3 = ((input[input_pos+1] & 0xff) << 8) + (input[input_pos+2] & 0xff);
            if (HIRAGANA1_BEGIN <= byte2and3 && byte2and3 <= HIRAGANA1_END) {
                byte = HIRAGANA1_BYTES;
                map = HIRAGANA1_MAP_PTR;
                maplen = HIRAGANA1_MAP_LEN;
            } else if (HIRAGANA2_BEGIN <= byte2and3 && byte2and3 <= HIRAGANA2_END) {
                byte = HIRAGANA2_BYTES;
                map = HIRAGANA2_MAP_PTR;
                maplen = HIRAGANA2_MAP_LEN;
            } else if (KATAKANA1_BEGIN <= byte2and3 && byte2and3 <= KATAKANA1_END) {
                byte = KATAKANA1_BYTES;
                map = KATAKANA1_MAP_PTR;
                maplen = KATAKANA1_MAP_LEN;
            } else if (KATAKANA2_BEGIN <= byte2and3 && byte2and3 <= KATAKANA2_END) {
                byte = KATAKANA2_BYTES;
                map = KATAKANA2_MAP_PTR;
                maplen = KATAKANA2_MAP_LEN;
            } else {
                goto NOT_FOUND;
            }

            int i;
            int byte2;
            int byte3;
            for(i = 0; i < maplen; i++, byte++) {
                /* 変換文字の2バイト目 e.g. あ: e3 (81) 80 : 0x81 */
                byte2 = ((byte) & 0xff00) >> 8;
                /* 変換文字の3バイト目 e.g. あ: e3 81 (80) : 0x80 */
                byte3 = ((byte) & 0xff);
                if ((input[input_pos+1] & 0xff) == byte2) {
                    if ((input[input_pos+2] & 0xff) == byte3) {
                        if (current_buf_size <= (buf_pos + strlen(map[i]))) {
                            buf = expand(buf, buf_pos);
                        }
                        strcpy(&buf[buf_pos], map[i]);
                        buf_pos += strlen(map[i]);
                        input_pos += 3;
                        /* continue へ */
                        break;
                    }
                }
            }
            /* while のトップへ */
            continue;
        }

NOT_FOUND:
        buf[buf_pos] = input[input_pos];
        input_pos++;
        buf_pos++;

        if (current_buf_size == buf_pos) {
            buf = expand(buf, buf_pos);
        }
    }

    buf[buf_pos] = '\0';

    return buf;
}
