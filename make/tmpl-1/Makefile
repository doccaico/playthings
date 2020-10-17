# Usage
#
# ・testする場合は下記のコマンドが必要(要curl)
#
# mkdir -p test && curl -L https://raw.githubusercontent.com/bvdberg/ctest/master/ctest.h -o test/ctest.h
#
# ・デフォルトでコンパイラの出力を抑制している(V=0)。表示するには make V=1
# ・依存関係をdepend.mkから読み込むので、make dependすること(ファイルが増えた場合も)
# 
# ## build ##
# make
#
# ## make all test files ##
# make test
#
# ## make a test ##
# make test_****
#
# ## excute all tests ##
# make testrun
#
# ## clean ##
# make clean 
#
# 変数の表示方法
# $(info $$SRC = $(SRC))

V =
ifeq ($(strip $(V)),)
	E = @echo
	Q = @
else
	E = @\#
	Q =
endif
export E Q

# CC      : gcc                    # compiler
# CFLAGS  : -Wall -I/usr/include   # compile flag or include path
# LDFLAGS : -L/usr/lib             # liblary path
# LDLIBS  : -lm                    # liblary name
# OBJS    : test1.o test2.o        # object files

.PHONY: clean depend testrun
ECHO_LINK = $(E) "  LINK    " $(1)
ECHO_CC   = $(E) "  CC      " $(1)
DEPEND = depend.mk
SRC_DIR = src
TEST_DIR = test

SRC = $(wildcard src/*.c)
OBJ = $(SRC:.c=.o)

TSRC := $(wildcard test/*.c)
TOBJ := $(TSRC:.c=.o)


PROGRAM := main
TEST := test_add test_sub test_multi

all: $(PROGRAM)

$(PROGRAM): $(OBJ)
	$(call ECHO_LINK, $@)
	$(Q) $(CC) $(LDFLAGS) $(DEFINES) -o $@ $(OBJ) $(LIBS)

test: $(TEST)

$(TEST):
	$(call ECHO_LINK, $@)
	$(Q) $(CC) $(LDFLAGS) $(DEFINES) -o $@ $^ $(LIBS)

testrun:
	@for file in $$(find . -maxdepth 1 -type f -name 'test_*'); do \
			echo -- $$file --; \
			./$$file; \
	done

$(TEST_DIR)/test%.o:$(TEST_DIR)/test%.c
	$(call ECHO_CC, $@)
	$(Q) ${CC} ${CFLAGS} ${DEFINES} -o $@ -c $^

$(SRC_DIR)/%.o:$(SRC_DIR)/%.c
	$(call ECHO_CC, $@)
	$(Q) ${CC} ${CFLAGS} ${DEFINES} -o $@ -c $^

depend:
	@$(CC) -MM $(SRC) $(TSRC) > $(DEPEND)


clean:
	rm -f $(PROGRAM) $(TEST) $(OBJ) $(TOBJ)
 
# need to add manually 
test_add: test/test_add.o src/add.o test/test_main.c
test_sub: test/test_sub.o src/sub.o test/test_main.c
test_multi: test/test_multi.o src/add.o src/sub.o test/test_main.c

-include $(DEPENDS)
