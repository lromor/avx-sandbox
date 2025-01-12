#include <stdio.h>

extern void hello_world(void);

int main(int argc, char *argv[]) {
  hello_world();
  //test();
  printf("Hello World main\n");
}
