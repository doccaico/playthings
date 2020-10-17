#include "ctest.h"

#include "../src/sub.h"

CTEST(suite, test_sub1) {
    ASSERT_EQUAL(8, sub(10, 2));
}
CTEST(suite, test_sub2) {
    ASSERT_EQUAL(8, sub(10, 2));
}
CTEST(suite, test_sub3) {
    ASSERT_EQUAL(7, sub(9, 2));
}
CTEST(suite, test_sub4) {
    ASSERT_EQUAL(8, sub(10, 2));
}

