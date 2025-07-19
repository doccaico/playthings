#include <stdio.h>
#include <stdint.h>
#include <limits.h>

uint64_t numberFromDecStr(const char* s)
{
    const char* start = s;
    while(*s) {
        s++;
    }
    s--;

    uint64_t num = 0;
    int prod = 1;
    while (s >= start) {
        num += prod * (*s-- - '0');
        prod *= 10;
    }

    return num;
}

void hexFromNumber(char* hex, uint64_t num)
{
    int width;
    if (0 <= num && num <= (1 << 4) - 1) {
        width = 1;
    } else if ((1 << 4) - 1 < num && num <= (1 << 8) - 1) {
        width = 2;
    } else if ((1 << 8) - 1 < num && num <= (1 << 12) - 1) {
        width = 3;
    } else if ((1 << 12) - 1 < num && num <= (1 << 16) - 1) {
        width = 4;
    } else if ((1 << 16) - 1 < num && num <= (1 << 20) - 1) {
        width = 5;
    } else if ((1 << 20) - 1 < num && num <= (1 << 24) - 1) {
        width = 6;
    } else if ((1 << 24) - 1 < num && num <= (1 << 28) - 1) {
        width = 7;
    } else if ((1 << 28) - 1 < num && num <= (((uint64_t)1) << 32) - 1) {
        width = 8;
    } else if ((((uint64_t)1) << 32) - 1 < num && num <= (((uint64_t)1) << 36) - 1) {
        width = 9;
    } else if ((((uint64_t)1) << 36) - 1 < num && num <= (((uint64_t)1) << 40) - 1) {
        width = 10;
    } else if ((((uint64_t)1) << 40) - 1 < num && num <= (((uint64_t)1) << 44) - 1) {
        width = 11;
    } else if ((((uint64_t)1) << 44) - 1 < num && num <= (((uint64_t)1) << 48) - 1) {
        width = 12;
    } else if ((((uint64_t)1) << 48) - 1 < num && num <= (((uint64_t)1) << 52) - 1) {
        width = 13;
    } else if ((((uint64_t)1) << 52) - 1 < num && num <= (((uint64_t)1) << 56) - 1) {
        width = 14;
    } else if ((((uint64_t)1) << 56) - 1 < num && num <= (((uint64_t)1) << 60) - 1) {
        width = 15;
    } else if ((((uint64_t)1) << 60) - 1 < num && num <= ULLONG_MAX) {
        width = 16;
    }

    int len = 0;
    int ret = 0;
    int bits[] = {1, 1 << 1, 1 << 2, 1 << 3};
    while (1) {
        for (int i = 0; i < 4; ++i) {
            if ((num & bits[i]) == bits[i]) {
                if (i == 0) {
                   ret += 1;
                } else if (i == 1) {
                   ret += 2;
                } else if (i == 2) {
                   ret += 4;
                } else {
                   ret += 8;
                }
            }
        }
        num >>= 4;

        if (0 <= ret && ret <= 9) {
            hex[width - len - 1] = ret + '0';
        } else if (ret == 10) {
            hex[width - len - 1] = 'a';
        } else if (ret == 11) {
            hex[width - len - 1] = 'b';
        } else if (ret == 12) {
            hex[width - len - 1] = 'c';
        } else if (ret == 13) {
            hex[width - len - 1] = 'd';
        } else if (ret == 14) {
            hex[width - len - 1] = 'e';
        } else if (ret == 15) {
            hex[width - len - 1] = 'f';
        }
        len++;

        if (width <= len) {
            break;
        }

        ret = 0;
    }

    hex[width] = '\0';
}

int main(int argc, char** argv)
{
    uint64_t num = numberFromDecStr(argv[1]);

    char hex[126];

    hexFromNumber(hex, num);

    // printf("%c\n", hex[0]);
    // printf("%c\n", hex[1]);
    // printf("%s\n", hex);

    return 0;
}
