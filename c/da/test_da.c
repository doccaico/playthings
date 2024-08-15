#include <assert.h> 
#include <stdio.h> 

#include "./da.h"

typedef struct {
    int age;
    char *name;
    char *sex;
} Person;

typedef struct {
    Person *items;
    size_t len;
    size_t capacity;
} DAPersons;

typedef struct {
    int *items;
    size_t len;
    size_t capacity;
} DAInts;

void test_da_append(void) {
    {
        DAInts da;
        da_init(&da); // len == 0; capacity == 16;

        for (int i = 0; i < 16; i++) da_append(&da, i);

        assert(da.len == 16 && da.capacity == 16);

        da_append(&da, 16);
        assert(da.len == 17 && da.capacity == 32);

        da_deinit(&da);
    }
    {
        DAPersons da;
        da_init_capacity(&da, 2); // len == 0; capacity == 2; 

        da_append(&da, ((Person){18, "Roy", "Male"})); assert(da.len == 1 && da.capacity == 2);
        da_append(&da, ((Person){18, "Roy", "Male"})); assert(da.len == 2 && da.capacity == 2);
        da_append(&da, ((Person){18, "Roy", "Male"})); assert(da.len == 3 && da.capacity == 4);
        da_append(&da, ((Person){18, "Roy", "Male"})); assert(da.len == 4 && da.capacity == 4);
        da_append(&da, ((Person){18, "Roy", "Male"})); assert(da.len == 5 && da.capacity == 8);
        da_append(&da, ((Person){18, "Roy", "Male"})); assert(da.len == 6 && da.capacity == 8);
        da_append(&da, ((Person){18, "Roy", "Male"})); assert(da.len == 7 && da.capacity == 8);
        da_append(&da, ((Person){18, "Roy", "Male"})); assert(da.len == 8 && da.capacity == 8);
        da_append(&da, ((Person){18, "Roy", "Male"})); assert(da.len == 9 && da.capacity == 16);
        da_append(&da, ((Person){18, "Roy", "Male"})); assert(da.len == 10 && da.capacity == 16);

        da_deinit(&da);
    }
}

void test_da_deinit(void) {
    DAInts da;
    da_init(&da);

    da_append(&da, 0); assert(da.len == 1 && da.capacity == 16);

    da_deinit(&da);
    assert(da.items == NULL);
}

void test_da_clear_retaining_capacity(void) {
    DAInts da;
    da_init(&da);

    da_append(&da, 0); assert(da.len == 1 && da.capacity == 16);

    da_clear_retaining_capacity(&da);
    assert(da.len == 0 && da.capacity == 16); 
}

void test_da_clear_and_free(void) {
    DAInts da;
    da_init(&da);

    da_append(&da, 0); assert(da.len == 1 && da.capacity == 16);

    da_clear_and_free(&da);
    assert(da.len == 0 && da.capacity == 0 && da.items == NULL); 
}

void test_da_get_last(void) {
    DAInts da;
    da_init(&da);

    da_append(&da, 10);
    assert(da_get_last(&da) == 10);
    da_append(&da, 20);
    assert(da_get_last(&da) == 20);
    da_append(&da, 30);
    assert(da_get_last(&da) == 30);

    da_deinit(&da);
}

void test_for_loop(void) {
    DAInts da;
    da_init(&da);

    da_append(&da, 10);
    da_append(&da, 20);
    da_append(&da, 30);

    for (size_t i = 0; i < da.len; i++) printf("%d\n", da.items[i]);

    da_deinit(&da);
}

int main(void) {

    test_da_append();
    test_da_deinit();
    test_da_clear_retaining_capacity();
    test_da_clear_and_free();
    test_da_get_last();

    // test_for_loop();

    return 0;
}
