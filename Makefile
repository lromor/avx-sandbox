CC?=gcc
CFLAGS?=-g -O3
LDFLAGS?=


all: main random-matrix-generator

main: main.o hello-world.o matrix.o timer.o
	gcc $(LDFLAGS) -o $@  $^

random-matrix-generator: random-matrix-generator.o
	gcc $(LDFLAGS) -o $@  $^

%.o: %.S
	$(CC) $(CFLAGS) -c $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $^ -o $@

clean:
	rm -f main *.o

.PHONY: clean all
