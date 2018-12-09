
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <omp.h>

#include "arqo4.h"

void compute(float **m1,float **m2, float **res, int n);
void trasponer(float **m2, float **m2_trasp, int n);

int main(int argc, char *argv[]) {

  float **m1=NULL;
  float **m2=NULL;
  float **m2_trasp=NULL;
  float **res=NULL;
  int n = 0, nthr;
  struct timeval fin,ini;

  if( argc != 3){
    printf("Error: ./%s <matrix size>\n", argv[0]);
    return -1;
  }
  n=atoi(argv[1]);
  nthr=atoi(argv[2]);
  omp_set_num_threads(nthr);
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
  m2_trasp = generateEmptyMatrix(n);
  if(res == NULL) {
    printf("Error al crear la matriz m2_trasp\n");
    return -1;
  }
  gettimeofday(&ini,NULL);
  trasponer(m2, m2_trasp, n);
  compute(m1, m2_trasp, res, n);
  gettimeofday(&fin,NULL);
  freeMatrix(m1);
  freeMatrix(m2);
  freeMatrix(m2_trasp);
  freeMatrix(res);
  printf("Execution time: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);
}

void compute(float **m1,float **m2, float **res, int n) {
	int i,j,k;
  float resultado;

	for(i=0;i<n;i++) {
		for(j=0;j<n;j++) {
      resultado = (float)0;
      #pragma omp parallel for reduction(+:resultado)
      for(k=0;k<n;k++) {
        resultado += m1[i][k]*m2[k][j];
      }
			res[i][j]=resultado;
		}
	}
}

void trasponer(float **m2, float **m2_trasp, int n){
  int i,j;
  for(i=0;i<n;i++) {
    for(j=0;j<n;j++) {
      m2_trasp[j][i] = m2[i][j];
    }
  }
}
