#include "matrix.h"

// Allocate a new matrix.
struct matrix *matrix_create(const unsigned rows, const unsigned columns) {
  struct matrix *m = (struct matrix *)malloc(sizeof(struct matrix));
  m->rows = rows;
  m->columns = columns;
  m->stride = columns * sizeof(double);
  m->size = rows * columns * sizeof(double);
  m->data = (double *)malloc(m->size);
  return m;
}

void matrix_destroy(struct matrix *m) {
  free(m->data);
  free(m);
}
