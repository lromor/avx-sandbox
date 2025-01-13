#include "matrix.h"
#include "stdlib.h"
#include <stdio.h>

// Allocate a new matrix.
struct matrix *matrix_create(const unsigned rows, const unsigned columns) {
  struct matrix *m = (struct matrix *)malloc(sizeof(struct matrix));
  m->rows = rows;
  m->columns = columns;
  m->stride = columns * sizeof(double);
  m->size = rows * columns * sizeof(double);
#if USE_ALIGNED_MEMORY
  if (posix_memalign((void **)&m->data, 64, m->size) != 0) {
    fprintf(stderr, "could not allocate aligned memory\n");
    exit(1);
  }
#else
  m->data = malloc(sizeof(double) * m->size);
#endif
  return m;
}

void matrix_destroy(struct matrix *m) {
  free(m->data);
  free(m);
}
