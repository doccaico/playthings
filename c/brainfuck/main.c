#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CODE_BYTES (1024 * 4)
#define LINE_BYTES (512)

unsigned char *prepare_code(char *filename) {

    FILE *fp;
    char line[LINE_BYTES];
    unsigned char *code;

    if ((fp = fopen(filename, "r")) == NULL) {
        fprintf(stderr, "ERROR: Failed to open %s.\n", filename);
        exit(EXIT_FAILURE);
    }

    if ((code = malloc(CODE_BYTES + 1)) == NULL) {
        fclose(fp);
        fprintf(stderr, "ERROR: Failed to malloc\n");
        exit(EXIT_FAILURE);
    }

    int i, code_idx;

    code_idx = 0;
    while ((fgets(line, LINE_BYTES, fp)) != NULL) {

        for (i = 0; line[i] != '\0'; i++) {

            switch (line[i]) {
                case '#':
                    i = strlen(line) - 1;
                    break;
                case '+':
                case '-':
                case '>':
                case '<':
                case '[':
                case ']':
                case '.':
                    code[code_idx++] = line[i];
                    break;
            }
        }
    }
    fclose(fp);
    code[code_idx] = '\0';

    return code;
}

unsigned char *lsb_pos(unsigned char *p) {

    int nloop = 0;

    p--;
    while (1) {

        switch (*p) {
            case ']':
                nloop++;
                break;
            case '[':
                if (nloop) nloop--;
                else return p;
                break;
        }
        p--;
    }
}

unsigned char *rsb_pos(unsigned char *p) {

    int nloop = 0;

    p++;
    while (1) {

        switch (*p) {
            case '[':
                nloop++;
                break;
            case ']':
                if (nloop) nloop--;
                else return p;
                break;
        }
        p++;
    }
}

int main(int argc, char **argv) {

    char *filename;

    if (argc == 2) {
        filename = argv[1];
    } else {
        fprintf(stderr, "Usage: bf [FILE]\n");
        exit(EXIT_FAILURE);
    }

    unsigned char memory[512] = {0};
    unsigned char *code, *orig, *ptr;

    ptr = &memory[(sizeof memory / sizeof memory[0]) / 2];

    code = orig = prepare_code(filename);

    while (*code) {

        switch (*code) {
            case '+':
                (*ptr)++;
                break;
            case '-':
                (*ptr)--;
                break;
            case '>':
                ptr++;
                break;
            case '<':
                ptr--;
                break;
            case '[':
                if (*ptr == 0) code = rsb_pos(code);
                break;
            case ']':
                if (*ptr != 0) code = lsb_pos(code);
                break;
            case '.':
                putchar(*ptr);
                break;
        }
        code++;
    }

    free(orig);

    return (EXIT_SUCCESS);
}
