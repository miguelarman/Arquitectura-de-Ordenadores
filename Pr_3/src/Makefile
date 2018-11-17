LIBS =
LIB_DIR =
FLAGS = -g -Wall -D_GNU_SOURCE

.PHONY: clean all

all: ./exes/fast ./exes/slow ./exes/opsFloat ./exes/multiplicarMatrices ./exes/multiplicarMatricesTrasp

./exes/fast: ./c/fast.c ./c/arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/slow: ./c/slow.c ./c/arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/opsFloat: ./c/opsFloat.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/multiplicarMatrices: ./c/multiplicarMatrices.c ./c/arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

./exes/multiplicarMatricesTrasp: ./c/multiplicarMatricesTrasp.c ./c/arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

clean:
	rm -f *.o *~ ./exes/fast ./exes/slow ./exes/opsFloat ./exes/multiplicarMatrices ./exes/multiplicarMatricesTrasp
