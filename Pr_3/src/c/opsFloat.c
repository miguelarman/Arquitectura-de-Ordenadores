#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void _eliminar_comas(char *s);
int main (int argc, char **argv) {

  if (argc != 4) {
    exit(-1);
  }

  _eliminar_comas(argv[2]);
  _eliminar_comas(argv[3]);

  if (strcmp(argv[1], "-s") == 0) {
    printf("%lf", atof(argv[2]) + atof(argv[3]));
  } else if (strcmp(argv[1], "-d") == 0) {
    printf("%lf", atof(argv[2]) / atof(argv[3]));
  } else {
    exit(-1);
  }

  return 0;
}

void _eliminar_comas(char *s) {
  int i;

  for (i = strlen(s); i >= 0; i--) {
    if (s[i] == ','){
      memmove(&s[i], &s[i + 1], strlen(s) - i);
    }
  }


}
