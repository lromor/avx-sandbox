#ifndef TIMER_H
#define TIMER_H

#include <time.h>

// Timer instance.
struct time_point {
  clock_t cpu;
  struct timespec wall_clock;
};

int time_point_now(struct time_point *t);

// Cpu and wall-clock time elapsed milliseconds.
struct time_diff_ms {
  // User cpu time.
  double cpu;

  // Wall-clock time.
  double wall_clock;
};

// Returns p2 - p1 in ms.
struct time_diff_ms time_point_diff(struct time_point *p1, struct time_point *p2);
#endif
