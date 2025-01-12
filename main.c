#include <stdio.h>
#include <getopt.h>
#include <string.h>

#include "timer.h"
#include "matrix.h"

extern void hello_world(void);

// Matrix multiplication: c = a @ b.T, where b.T is b tranpose.
void mm_multiply_naive(struct matrix *a, struct matrix *b_t, struct matrix *c){
  // Start mm_multiplication.
  double *dst = NULL;
  double src_a;
  double src_b;
  // index notation <matrix-prefix><row or column>
  // For instance index cc = matrix c, column.
  for (int cr = 0; cr < c->rows; ++cr) {
    for (int cc = 0; cc < c->columns; ++cc) {
      // Move to next destination.
      dst = &c->data[cc + cr * c->columns];
      for (int v = 0; v < a->columns; ++v) {
        src_a = a->data[cr * a->columns + v];
        src_b = b_t->data[cc * b_t->columns + v];
        *dst += src_a * src_b;
      }
    }
  }
}

typedef void (*mm_op)(struct matrix *, struct matrix *, struct matrix *);

struct mm_op_args {
  struct matrix *a;
  struct matrix *b_t;
  struct matrix *c;
};

void mm_binary_op_bench(const char *name, mm_op op, struct mm_op_args args, FILE *stream) {
  struct time_point start;
  struct time_point end;
  time_point_now(&start);
  op(args.a, args.b_t, args.c);
  time_point_now(&end);
  const struct time_diff_ms diff = time_point_diff(&start, &end);
  fprintf(stream, "%s:\tcpu:%f\twall_time:%f\n", name, diff.cpu, diff.wall_clock);
}

struct matrix *deserialize_matrix(const char *file_path) {
  FILE *file = fopen(file_path, "rb");
  if (file == NULL) {
    perror("Error opening file");
    return NULL;
  }
  unsigned rows;
  unsigned columns;
  size_t read_count = 0;
  if (fread(&rows, sizeof(unsigned), 1, file) != 1) {
    return NULL;
  }
  if (fread(&columns, sizeof(unsigned), 1, file) != 1) {
    return NULL;
  }
  struct matrix *m = matrix_create(rows, columns);
  double *row = NULL;
  for (int r = 0; r < rows; ++r) {
    row = &m->data[r * m->columns];
    read_count = fread(row, sizeof(double), m->columns, file);
    if (read_count != m->columns) {
      return NULL;
    }
  }
  fclose(file);
  return m;
}

void print_matrix(struct matrix *m, FILE *stream) {
  fprintf(stream, "%zux%zu\n", m->rows, m->columns);
  for (int r = 0; r < m->rows; ++r) {
      for (int c = 0; c < m->columns; ++c) {
        fprintf(stream,
                "%f%c", m->data[c + m->columns * r],
                c == (m->columns - 1) ? '\n' : ' ');
      }
  }
}
static int usage(const char *prog, const char *msg) {
  if (msg && strlen(msg)) {
    fprintf(stderr, "%s\n", msg);
  }
  fprintf(stderr,
          "Usage: %s <m1> <m2_t>\n"
          "Compute the matrix-matrix multiplication between m1 and m2 tranpose.\n"
          "Options:\n",
          prog);
  fprintf(stderr,
          "  -h, --help                : Display this help text and exit.\n");
  return (msg) ? 1 : 0;
}

static struct option long_options[] = {
  {"help", no_argument, 0, 'h'},
  {0, 0, 0, 0},
};

int main(int argc, char *argv[]) {
  int opt;
  while ((opt = getopt_long(argc, argv, "h", long_options, NULL)) != -1) {
    switch (opt) {
      case 'h':
        return usage(argv[0], NULL);
      case '?':
      case ':':
      default:
        return usage(argv[0], NULL);
    }
  }
  if ((argc - optind) < 2) {
    return usage(argv[0], "Invalid number of positional arguments.");
  }
  const char *ma_file_path = argv[optind];
  const char *mb_file_path = argv[optind + 1];

  // Allocate output matrix.
  // TODO: Do that outside the algorithm, pass the preallocated
  // zeroed destination matrix from the outside.
  struct matrix *a = deserialize_matrix(ma_file_path);
  if (a == NULL) {
    fprintf(stderr, "could not deserialize matrix from file: %s\n", ma_file_path);
    return 1;
  }
  struct matrix *b_t = deserialize_matrix(mb_file_path);
  if (a == NULL) {
    fprintf(stderr, "could not deserialize matrix from file: %s\n", mb_file_path);
    return 1;
  }

  struct matrix *c = matrix_create(a->rows, b_t->rows);
  memset(c->data, 0, c->size);

  struct mm_op_args args = {
    .a = a,
    .b_t = b_t,
    .c = c,
  };
  mm_binary_op_bench("naive", &mm_multiply_naive, args, stdout);
#if 0
  print_matrix(a, stdout);
  print_matrix(b_t, stdout);
  print_matrix(c, stdout);
#endif

  //hello_world();
  //test();
  /* printf("Hello World main\n"); */
  /* hello_world(); */
  /* hello_world(); */
  /* hello_world(); */
}
