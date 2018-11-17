LIBS =
LIB_DIR =
FLAGS = -g -Wall -D_GNU_SOURCE

.PHONY: clean all

all: multiplicarMatrices multiplicarMatricesTrasp

multiplicarMatrices: multiplicarMatrices.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

multiplicarMatricesTrasp: multiplicarMatricesTrasp.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

clean:
	rm -f *.o *~ multiplicarMatrices multiplicarMatricesTrasp
