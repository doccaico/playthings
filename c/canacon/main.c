#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>

#include "pattern1.h"
#include "convkana.h"

#define BUF_SIZE (32 * 1024)


void die(const char*);
void die_free(const char*, char*);
long get_file_size(const char*);
void convert_write(const char*);
int count_divided_bytes(const char*);
void set_head(char*, const char*);
void set_tail(char*, const char*, const int);
int from_file(const char*);
int from_stdin(void);


void die(const char *msg) {
    perror(msg);
    exit(EXIT_FAILURE);
}

void die_free(const char *msg, char *p) {
    perror(msg);
    free(p);
    exit(EXIT_FAILURE);
}

long get_file_size(const char *fname) {

    FILE *fp;
    long file_size;
    struct stat stbuf;
    int fd;

    fd = open(fname, O_RDONLY);

    if (fd == -1)
        die(fname);

    fp = fdopen(fd, "rb");
    if (fp == NULL)
        die("Failed: fdopen()");

    if (fstat(fd, &stbuf) == -1)
        die("Failed: fstat()");

    file_size = stbuf.st_size;

    if (fclose(fp) != 0)
        die("Failed: fclose()");

    return file_size;
}

void convert_write(const char *buf) {

    char *output;

    output =  convert(buf);
    write(STDOUT_FILENO, output, strlen(output));
    free(output);
}

int from_file(const char *fname) {

    char *buf;
    ssize_t read_size;
    long filesize;
    int fd;

    filesize = get_file_size(fname);

    if ((buf = malloc(filesize + 1)) == NULL)
        die("Failed: malloc()");

    if ((fd = open(fname, O_RDONLY)) < 0)
        die_free(fname, buf);

    if ((read_size = read(fd, buf, filesize)) < 0) {
        close(fd);
        die_free("Failed: read()", buf);
    }

    buf[read_size] = '\0';

    convert_write(buf);

    close(fd);

    return EXIT_SUCCESS;
}

int count_divided_bytes(const char *buf_tail) {

    int i;

    for (i = 0; i < 2; i++) {
        if ((buf_tail[-i] & 0xff) == 0xe3) {
            return i + 1;
        }
    }
    return 0;
}

void set_head(char *divided_3bytes, const char *buf) {

    strcpy(divided_3bytes, buf);
}

void set_tail(char *divided_3bytes, const char *buf, const int divided_bytes) {

    divided_3bytes[divided_bytes] = buf[0];
    if (divided_bytes == 1) {
        divided_3bytes[2] = buf[1];
    }

    divided_3bytes[3] = '\0';
}

int from_stdin(void) {

    char *buf;
    ssize_t read_size;

    /* bufの末尾のバイト列が分断された場合にそのバイト列を保存 */
    char divided_3bytes[4];
    int divided_bytes, prev_divided_bytes;
    bool is_divided, headskip;

    divided_3bytes[0] = '\0';
    divided_bytes = prev_divided_bytes = 0;
    headskip = is_divided = false;

    if ((buf = malloc(BUF_SIZE+1)) == NULL)
        die("Failed: malloc()");

    while (true) {

        if ((read_size = read(STDIN_FILENO, buf, BUF_SIZE)) < 0) {
            die_free("Failed: read()", buf);
        }

        if (read_size == 0) {
            free(buf);
            return EXIT_SUCCESS;
        }

        if (read_size == -1) {
            die_free("Failed: read(), errno -1", buf);
        }

        buf[read_size] = '\0';

        /* 一つ前のループ時にbufの末尾のバイト列が分断していた場合は真 */
        if (is_divided) {
            /* set_headで1-2バイトは既にdivided_3bytesに入っているので
               残りを入れて出力できる形1文字(3バイト)に整える */
            set_tail(divided_3bytes, buf, divided_bytes);

            /* 1文字(3byte) */
            convert_write(divided_3bytes);

            if (read_size != BUF_SIZE) {

                convert_write(&buf[3-divided_bytes]);

                free(buf);
                return EXIT_SUCCESS;
            }

            divided_3bytes[0] = '\0';
            is_divided = false;
            headskip = true;
        }

        if (read_size == BUF_SIZE){

            prev_divided_bytes = divided_bytes;

            divided_bytes = count_divided_bytes(&buf[read_size-1]);

            if (divided_bytes) {
                set_head(divided_3bytes, &buf[read_size-divided_bytes]);
                buf[read_size-divided_bytes] = '\0';
                is_divided = true;
            }
        }

        if (headskip) {
            /* 変換済みのbufの先頭のバイト列をスキップする */
            convert_write(&buf[3-prev_divided_bytes]);
            headskip = false;
        } else {
            convert_write(buf);
        }
    }

    free(buf);

    return EXIT_SUCCESS;
}


int main(int argc, char **argv) {

    int rnum;

    if (argc == 2) {
        /* 引数(ファイルパス)が与えられた場合 */
        rnum = from_file(argv[1]);
    } else {
        /* 引数が無い場合、標準入力から受け取る */
        rnum = from_stdin();
    }

    return rnum;
}
