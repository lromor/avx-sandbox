#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

static int usage(const char *prog, const char *msg) {
  if (msg && strlen(msg)) {
    fprintf(stderr, "%s\n", msg);
  }
  fprintf(stderr,
          "Usage: %s [options]\n"
          "Options:\n",
          prog);
  fprintf(stderr,
          "  -s, --size <rowsxcolumns> : Size of the random matrix. "
          "(Default '100x100')\n"
          "  -o, --output <path>       : Output file path, '-' for stdout. (Default '-')\n"
          "  -h, --help                : Display this help text and exit.\n");
  return (msg) ? 1 : 0;
}

static struct option long_options[] = {
  {"help", no_argument, 0, 'h'},
  {"size", required_argument, 0, 's'},
  {"output", required_argument, 0, 's'},
  {0, 0, 0, 0},
};

struct matrix_size {
  unsigned rows;
  unsigned columns;
};

int matrix_size_parser(const char *s, struct matrix_size *size) {
  if (sscanf(s, "%dx%d", &size->rows, &size->columns) != 2) {
    return 0;
  }
  return 1;
};

int main(int argc, char *argv[]) {
  struct matrix_size size = {
    .rows = 100,
    .columns = 100,
  };
  char *output_file_path = "-";
  int opt;
  while ((opt = getopt_long(argc, argv, "hs:o:", long_options, NULL)) != -1) {
    switch (opt) {
      case 'h':
        return usage(argv[0], NULL);
      case 's':
        if (!matrix_size_parser(optarg, &size)) {
          return usage(argv[0], "Could not parse matrix size.");
        }
        break;
      case 'o':
        output_file_path = optarg;
        break;
      case '?':
      case ':':
      default:
        return usage(argv[0], NULL);
    }
  }
  FILE *file = stdout;
  if (strcmp(output_file_path, "-") == 0) {
    file = stdout;
  } else {
    file = fopen(output_file_path, "wb");
    if (file == NULL) {
      perror("Error opening file");
      return 1;
    }
  }

  // Random seed
  srand(time(0));
  fwrite(&size.rows, sizeof(unsigned), 1, file);
  fwrite(&size.columns, sizeof(unsigned), 1, file);
  double *row = (double *)malloc(sizeof(double) * size.columns);
  for (int r = 0; r < size.rows; ++r) {
    for (int c = 0; c < size.columns; ++c) {
      row[c] = (double) rand() / RAND_MAX;
    }
    fwrite(row, sizeof(double), size.columns, file);
  }
  free(row);
  fflush(file);
  fclose(file);
  return 0;
}
