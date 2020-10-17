all: pbit

pbit: pbit.c
	gcc -o pbit pbit.c -Wall -Wextra

release:
	gcc -o pbit pbit.c -Wall -Wextra -O2 -s

.PHONY: clean

clean:
	rm -f pbit
