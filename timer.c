#include "timer.h"

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int time_point_now(struct time_point *t) {
  t->cpu = clock();
  if (clock_gettime(CLOCK_MONOTONIC, &t->wall_clock) != 0) {
    // Die horribly
    perror("clock_gettime()");
    exit(1);
  }
  return 1;
}

// Compute the difference between two timespec structures
static struct timespec timespec_diff(const struct timespec *start, const struct timespec *end) {
  struct timespec result;

  // Calculate the difference in seconds
  result.tv_sec = end->tv_sec - start->tv_sec;

  // Calculate the difference in nanoseconds
  result.tv_nsec = end->tv_nsec - start->tv_nsec;

  // Handle nanosecond underflow
  if (result.tv_nsec < 0) {
    result.tv_nsec += 1000000000;
    result.tv_sec -= 1;
  }
  return result;
}

// Stop the timer and calculate elapsed time
struct time_diff_ms time_point_diff(struct time_point *p1, struct time_point *p2) {
  const clock_t cpu_diff = p2->cpu - p1->cpu;
  const struct timespec wall_clock_diff = timespec_diff(&p1->wall_clock, &p2->wall_clock);
  const double cpu_time_ms = (double)cpu_diff * 1e-3 / CLOCKS_PER_SEC;
  const double wall_clock_time_ms = (double)wall_clock_diff.tv_sec + (double)wall_clock_diff.tv_nsec / 1e9;
  struct time_diff_ms diff = {
    .cpu = cpu_time_ms,
    .wall_clock = wall_clock_time_ms,
  };
  return diff;
}
