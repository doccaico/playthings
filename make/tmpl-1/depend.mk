main.o: src/main.c src/add.h
add.o: src/add.c
sub.o: src/sub.c
test_sub.o: test/test_sub.c test/ctest.h test/../src/sub.h
test_add.o: test/test_add.c test/ctest.h test/../src/add.h
test_multi.o: test/test_multi.c test/ctest.h test/../src/add.h \
 test/../src/sub.h
test_main.o: test/test_main.c test/ctest.h
