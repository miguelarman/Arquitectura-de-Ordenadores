#!/bin/bash

# inicializar variables
Ninicio=10000+1024*5
Npaso=1
Nfinal=$((Ninicio + 1024))
fDAT=time_slow_fast.dat
fPNG=time_slow_fast.png
NIteraciones=1
fSlow=../src/slow
fFast=../src/fast
fFPOps=../src/opsFloat
ejecutablePlotScript=../src/plotScriptAux.sh

# creamos arrays para repetir las mediciones de tiempo
declare -a slowArray
declare -a fastArray

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT fPNG

# generar el fichero DAT vacío
touch $fDAT

# inicializar arrays a 0
for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
  indice=$(((N-Ninicio)/Npaso))

  slowArray[$indice]=0
  fastArray[$indice]=0
done

#for N in $(seq $Ninicio $Npaso $Nfinal);
for ((NAux = 1 ; NAux <= NIteraciones; NAux += 1)); do
  echo "Iteración $NAux de $NIteraciones empezada"

  #bucle para slow
  for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
    echo "Running slow $N"

    slowTime=$(./$fSlow $N | grep 'time' | awk '{print $3}')

    indice=$(((N-Ninicio)/Npaso))

    slowArray[$indice]=$(./$fFPOps -s $slowTime ${slowArray[$indice]} | awk '{print $1}')
  done

  echo

  #bucle para fast
  for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
    echo "Running fast $N"

    fastTime=$(./$fFast $N | grep 'time' | awk '{print $3}')

    indice=$(((N-Ninicio)/Npaso))

    fastArray[$indice]=$(./$fFPOps -s $fastTime ${fastArray[$indice]} | awk '{print $1}')
  done

  echo "Iteración $NAux de $NIteraciones completada"
  echo
done

# calcular la media e imprimir
for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
  indice=$(((N-Ninicio)/Npaso))

  # dividimos para calcular la media
  slowArray[$indice]=$(./$fFPOps -d ${slowArray[$indice]} $NIteraciones | awk '{print $1}')
  fastArray[$indice]=$(./$fFPOps -d ${fastArray[$indice]} $NIteraciones | awk '{print $1}')

  echo "$N	${slowArray[$indice]}	${fastArray[$indice]}" >> $fDAT
done

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
chmod +x $ejecutablePlotScript
./$ejecutablePlotScript -f $fDAT -o 1 -d "2 3" -p time_slow_fast_prueba.png -t "Slow-Fast Execution Time" -y "Execution time (s)" -x "Matrix Size" -l "slow fast"
