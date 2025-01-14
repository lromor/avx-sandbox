CC?=gcc
CFLAGS?=-g -O3 -fopt-info-vec -DUSE_ALIGNED_MEMORY -DUSE_AVX_DOT_PRODUCT_ASM
LDFLAGS?=

all: mmm random-matrix-generator

mmm: mmm.o hello-world.o matrix.o timer.o avx-dot-prod.o
	gcc $(LDFLAGS) -o $@  $^

random-matrix-generator: random-matrix-generator.o
	gcc $(LDFLAGS) -o $@  $^

%.o: %.S
	$(CC) $(CFLAGS) -c $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $^ -o $@

clean:
	rm -f mmm random-matrix-generator *.o

.PHONY: clean all
