
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#include "arqo4.h"

void compute(float **m1,float **m2, float **res, int n);

int main(int argc, char *argv[]) {

  float **m1=NULL;
  float **m2=NULL;
  float **res=NULL;
  int n = 0;
  struct timeval fin,ini;

  if( argc != 2){
    printf("Error: ./%s <matrix size>\n", argv[0]);
    return -1;
  }
  n=atoi(argv[1]);
  m1 = generateMatrix(n);
  if(m1 == NULL) {
    printf("Error al crear la matriz m1\n");
    return -1;
  }
  m2 = generateMatrix(n);
  if(m2 == NULL) {
    printf("Error al crear la matriz m2\n");
    return -1;
  }
  res = generateEmptyMatrix(n);
  if(res == NULL) {
    printf("Error al crear la matriz res\n");
    return -1;
  }
  gettimeofday(&ini,NULL);
  compute(m1, m2, res, n);
  gettimeofday(&fin,NULL);
  freeMatrix(m1);
  freeMatrix(m2);
  freeMatrix(res);
  printf("Execution time: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);
}

void compute(float **m1,float **m2, float **res, int n) {
	int i,j,k;
  float resultado;

	for(i=0;i<n;i++) {
		for(j=0;j<n;j++) {
      resultado = (float)0;
      for(k=0;k<n;k++) {
        resultado += m1[i][k]*m2[k][j];
      }
			res[i][j]=resultado;
		}
	}
}
