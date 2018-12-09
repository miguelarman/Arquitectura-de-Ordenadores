#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

int main() {

  printf("%d", omp_get_num_procs());
  return 0;
}
