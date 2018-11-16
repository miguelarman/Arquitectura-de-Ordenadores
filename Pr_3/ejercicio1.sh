#!/bin/bash

# inicializar variables
Ninicio=10000+1024*5
Npaso=64
Nfinal=$((Ninicio + 1024))
fDAT=ej1/time_slow_fast.dat
fPNG=ej1/time_slow_fast.png
NIteraciones=10
fSlow=src/slow
fFast=src/fast
fFPOps=src/opsFloat

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

echo
echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Slow-Fast Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "$fDAT" using 1:2 with lines lw 2 title "slow", \
     "$fDAT" using 1:3 with lines lw 2 title "fast"
replot
quit
END_GNUPLOT
