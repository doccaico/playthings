#include "ctest.h"
#include "../src/add.h"
#include "../src/sub.h"


CTEST(suite, test_m1) {
    ASSERT_EQUAL(8, add(5, 5) - sub(10, 8));
}

CTEST(suite, test_m2) {
    ASSERT_EQUAL(8, sub(10, 2));
}

