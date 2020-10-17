#include <ctype.h>
#include <errno.h>
#include <limits.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef long int SIGNED;
typedef unsigned long int UNSIGNED;

int usage(int code) {
    printf("USAGE: pbit [OPTION] NUMBER\n"
            " -s\tsigned\t\t%ld <= NUMBER >= %ld\n"
            " -u\tunsigned\t%d <= NUMBER >= %lu\n\n"
            " -h\tdisplay this help and exit\n",
            LONG_MIN, LONG_MAX, 0, ULONG_MAX);
    exit(code);
}

void convert_signed(UNSIGNED n) {
    /* set the MBS(left-most-bit) to 1 */
    UNSIGNED mask = LONG_MIN;
    for (int i = 0; i < (int)(sizeof(SIGNED) * CHAR_BIT); ++i, mask >>= 1) {
        putchar((n & mask) ? '1' : '0');
        if ((i + 1) % CHAR_BIT == 0)
            putchar(' ');
    }
    putchar('\n');
}

void convert_unsigned(SIGNED n) {
    /* set the MBS(left-most-bit) to 1 */
    UNSIGNED mask = LONG_MIN;
    for (int i = 0; i < (int)(sizeof(UNSIGNED) * CHAR_BIT); ++i, mask >>= 1) {
        putchar((n & mask) ? '1' : '0');
        if ((i + 1) % CHAR_BIT == 0)
            putchar(' ');
    }
    putchar('\n');
}

int base_check(char *nstr) {
    if ('-' == nstr[0])
        nstr++;
    if (strncmp(nstr, "0x", 2) == 0 || strncmp(nstr, "0X", 2) == 0)
        return 16;
    if (strncmp(nstr, "0o", 2) == 0 || strncmp(nstr, "0O", 2) == 0) {
        nstr[1] = '0'; /* for 'strto*' function */
        return 8;
    }
    return 10;
}

bool is_validate(char *nstr, int base) {
    if ('-' == *nstr)
        nstr++;
    if (10 == base) {
        while(*nstr) {
            if (!isdigit(*nstr))
                return false;
            nstr++;
        }
    } else if (16 == base) {
        nstr += 2;
        while(*nstr) {
            if (!isxdigit(*nstr)) {
                return false;
            }
            nstr++;
        }
    } else if (8 == base) {
        nstr += 2;
        while(*nstr) {
            if ('0' > *nstr || *nstr > '7') {
                return false;
            }
            nstr++;
        }
    }
    return true;
}

bool is_negative(char *s) {
    while(*s) {
        if (*s == '-')
            return true;
        s++;
    }
    return false;
}

void die(FILE *io, const char *format, ...) {
  va_list ap;
  va_start(ap, format);
  vfprintf(io, format, ap);
  va_end(ap);
  exit(EXIT_FAILURE);
}

int main(int argc, char **argv)
{
    int base;
    char *opt;
    char *nstr;

    if (1 == argc)
        usage(EXIT_FAILURE);
    if (3 < argc)
        die(stderr, "error: wrong number of arguments\n");
    else if (2 == argc) {
        if (strcmp(argv[1], "-h") == 0)
            usage(EXIT_SUCCESS);
    }

    /* if (argc == 3) */
    opt = argv[1];
    nstr = argv[2];

    base = base_check(nstr);
    if (!is_validate(nstr, base))
        die(stderr, "error: invalid number '%s'\n", nstr);


    if (strcmp(opt, "-s") == 0) {

        SIGNED n = strtol(nstr, NULL, base);

        if (errno == ERANGE)
            die(stderr, "error: number is out of range for '-s' (Signed)\n"
                    "input number: %s\n"
                    "support range is; %ld <= NUMBER >= %ld\n",
                    nstr, LONG_MIN, LONG_MAX);

        convert_signed(n);

    } else if (strcmp(opt, "-u") == 0) {

        if (is_negative(nstr))
            die(stderr, "error: '-u' is not support negative number '%s'\n", nstr);

        UNSIGNED n = strtoul(nstr, NULL, base);

        if (errno == ERANGE)
            die(stderr, "error: number is out of range for '-u' (Unsigned)\n"
                    "input number: %s\n"
                    "support range is; %d <= NUMBER >= %lu\n",
                    nstr, 0, ULONG_MAX);

        convert_unsigned(n);

    } else {

        die(stderr, "error: unrecognized command line option '%s'\n", opt);

    }

    return (EXIT_SUCCESS);
}
