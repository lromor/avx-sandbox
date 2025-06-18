CC?=clang
CXX?=clang++
NVCC?=nvcc
CFLAGS?=-g -O3 -march=native -fopt-info-vec -DUSE_ALIGNED_MEMORY #-DUSE_AVX_DOT_PRODUCT_ASM
LDFLAGS?=

all: mmm random-matrix-generator mmm-cuda

mmm: mmm.o matrix.o timer.o avx-dot-prod.o
	$(CC) $(LDFLAGS) -o $@  $^

random-matrix-generator: random-matrix-generator.o
	$(CC) $(LDFLAGS) -o $@  $^

mmm-cuda: mmm-cuda.o
	$(CXX) $(LDFLAGS) -lcudart -o $@  $^

%.o: %.S
	$(CC) $(CFLAGS) -c $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $^ -o $@

%.o: %.cu
	$(NVCC) -c $^ -o $@

clean:
	rm -f mmm random-matrix-generator *.o

.PHONY: clean all
