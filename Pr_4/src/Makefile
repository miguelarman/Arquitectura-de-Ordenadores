LIBS =
LIB_DIR =
FLAGS = -g -lgomp -Wall -D_GNU_SOURCE -fopenmp

.PHONY: clean all

all: ./exes/omp1 ./exes/omp2 ./exes/pescalar_serie ./exes/pescalar_par1 ./exes/pescalar_par2 ./exes/opsFloat ./exes/getNCores ./exes/pi_serie ./exes/pi_par1 ./exes/pi_par2 ./exes/pi_par3 ./exes/pi_par4 ./exes/pi_par5 ./exes/pi_par6 ./exes/pi_par7 ./exes/mult ./exes/mult1 ./exes/mult2 ./exes/mult3 ./exes/multTrasp ./exes/multTrasp1 ./exes/multTrasp2 ./exes/multTrasp3 clear

./exes/omp1: ./c/omp1.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/omp2: ./c/omp2.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/pescalar_serie: ./c/pescalar_serie.c ./c/arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/pescalar_par1: ./c/pescalar_par1.c ./c/arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/pescalar_par2: ./c/pescalar_par2.c ./c/arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/opsFloat: ./c/opsFloat.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/getNCores: ./c/getNCores.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/pi_serie: ./c/pi_serie.c ./c/arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/pi_par1: ./c/pi_par1.c ./c/arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/pi_par2: ./c/pi_par2.c ./c/arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/pi_par3: ./c/pi_par3.c ./c/arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/pi_par4: ./c/pi_par4.c ./c/arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/pi_par5: ./c/pi_par5.c ./c/arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/pi_par6: ./c/pi_par6.c ./c/arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/pi_par7: ./c/pi_par7.c ./c/arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/mult: ./c/mult.c ./c/arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/mult1: ./c/mult1.c ./c/arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/mult2: ./c/mult2.c ./c/arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/mult3: ./c/mult3.c ./c/arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/multTrasp: ./c/multTrasp.c ./c/arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/multTrasp1: ./c/multTrasp1.c ./c/arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/multTrasp2: ./c/multTrasp2.c ./c/arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/multTrasp3: ./c/multTrasp3.c ./c/arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

clean:
	rm -f *.o *~ ./exes/omp1 ./exes/omp2 ./exes/pescalar_serie ./exes/pescalar_par1 ./exes/pescalar_par2 ./exes/opsFloat ./exes/getNCores ./exes/pi_serie ./exes/pi_par1 ./exes/pi_par2 ./exes/pi_par3 ./exes/pi_par4 ./exes/pi_par5 ./exes/pi_par6 ./exes/pi_par7 ./exes/mult ./exes/multTrasp ./exes/mult1 ./exes/mult2 ./exes/mult3 ./exes/multTrasp1 ./exes/multTrasp2 ./exes/multTrasp3

clear:
	rm -f *.o *~
