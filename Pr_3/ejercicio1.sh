#!/bin/bash

# inicializar variables
Ninicio=1024*5
Npaso=64
Nfinal=$((Ninicio + 1024))
fDAT=slow_fast_time.dat
fPNG=slow_fast_time.png
NIteraciones=1

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

    slowTime=$(./slow $N | grep 'time' | awk '{print $3}')

    indice=$(((N-Ninicio)/Npaso))

    slowArray[$indice]+=$slowTime
  done

  echo

  #bucle fast
  for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
    echo "Running fast $N"

    fastTime=$(./fast $N | grep 'time' | awk '{print $3}')

    indice=$(((N-Ninicio)/Npaso))

    fastArray[$indice]+=$slowTime
  done

  echo "Iteración $NAux de $NIteraciones completada"
  echo
done

# calcular la media e imprimir
for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
  indice=$(((N-Ninicio)/Npaso))

  # dividimos para calcular la media
  slowArray[$indice]=$((${slowArray[$indice]}/$NIteraciones))
  fastArray[$indice]=$((${fastArray[$indice]}/$NIteraciones))

  echo "$N	${slowArray[$indice]}	${fastArray[$indice]}"
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
