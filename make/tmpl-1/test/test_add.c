#include "ctest.h"

#include "../src/add.h"

CTEST(suite, test_add1) {
    ASSERT_EQUAL(3, add(1, 2));
}
CTEST(suite, test_add2) {
    ASSERT_EQUAL(10, add(3, 7));
}
CTEST(suite, test_add3) {
    ASSERT_EQUAL(10, add(3, 7));
}
CTEST(suite, test_add4) {
    ASSERT_EQUAL(10, add(3, 7));
}
CTEST(suite, test_add5) {
    ASSERT_EQUAL(10, add(3, 7));
}

CTEST(suite, test_add6) {
    ASSERT_EQUAL(10, add(3, 7));
}
