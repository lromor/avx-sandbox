#ifndef MATRIX_H
#define MATRIX_H

#include <stdlib.h>
#include <stddef.h>

// 2-d matrix definition.
// Rows count is size / stride;
struct matrix {
  size_t rows;
  size_t columns;

  // Base address of the array.
  double *data;

  // Size of data in bytes.
  size_t size;

  // Length of a row in bytes.
  size_t stride;
};

struct matrix *matrix_create(unsigned rows, unsigned columns);
void matrix_destroy(struct matrix *m);
#endif  // MATRIX_H
