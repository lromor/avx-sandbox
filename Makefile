CC?=gcc
CFLAGS?=-g -O3 -fopt-info-vec -DUSE_ALIGNED_MEMORY -DUSE_AVX_DOT_PRODUCT_ASM
LDFLAGS?=

all: main random-matrix-generator

main: main.o hello-world.o matrix.o timer.o avx-dot-prod.o
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
