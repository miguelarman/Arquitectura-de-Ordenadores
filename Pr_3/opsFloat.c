#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main (int argc, char **argv) {

  if (argc != 4) {
    exit(-1);
  }

  if (strcmp(argv[1], "-s") == 0) {
    printf("%lf", atof(argv[2]) + atof(argv[3]));
  } else if (strcmp(argv[1], "-d") == 0) {
    printf("%lf", atof(argv[2]) / atof(argv[3]));
  } else {
    exit(-1);
  }

  return 0;
}
