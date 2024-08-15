#ifndef INCLUDE_DA_H
#define INCLUDE_DA_H

#include <stdlib.h> // for 'realloc' 'free'

#define DA_INITIAL_CAPACITY 16

#define da_init(da) da_init_capacity(da, DA_INITIAL_CAPACITY)

#define da_init_capacity(da, cap)                          \
    do {                                                   \
        (da)->items = realloc(NULL,                        \
                              cap*sizeof((da)->items[0])); \
        (da)->len = 0;                                     \
        (da)->capacity = cap;                              \
    } while (0)

#define da_deinit(da)       \
    do {                    \
        free((da)->items);  \
        (da)->items = NULL; \
    } while (0)

#define da_clear_retaining_capacity(da) ((da)->len = 0)

#define da_clear_and_free(da) \
    do {                      \
        da_deinit(da);        \
        (da)->len = 0;        \
        (da)->capacity = 0;   \
    } while (0)

#define da_append(da, item)                                             \
    do {                                                                \
        if ((da)->len >= (da)->capacity) {                              \
            size_t new_capacity = (da)->capacity*2;                     \
            if (new_capacity == 0) {                                    \
                new_capacity = DA_INITIAL_CAPACITY;                     \
            }                                                           \
                                                                        \
            (da)->items = realloc((da)->items,                          \
                                  new_capacity*sizeof((da)->items[0])); \
            (da)->capacity = new_capacity;                              \
        }                                                               \
                                                                        \
        (da)->items[(da)->len++] = (item);                              \
    } while (0)

#define da_get_last(da) (da)->items[(da)->len-1]

#endif // INCLUDE_DA_H
