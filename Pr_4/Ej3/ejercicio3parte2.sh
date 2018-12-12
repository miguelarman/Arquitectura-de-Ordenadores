#!/bin/bash

# inicializar variables
Ninicio=1800
Npaso=50
Nfinal=2400
fDAT=./dat/time_parte2_aux.dat
fPNG=./png/time_parte2_grande.png
fPNG2=./png/time_parte2_su_grande.png
NIteraciones=10
fMult=../src/exes/mult
fMult3=../src/exes/mult3
fFPOps=../src/exes/opsFloat
exePlotScript=../src/scripts/plotScript.sh

# creamos arrays para repetir las mediciones de tiempo
declare -a multArray
declare -a mult3Array
declare -a speedUp

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT fPNG

# generar el fichero DAT vacío
touch $fDAT
# inicializar arrays a 0
for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
  indice=$(((N-Ninicio)/Npaso))
  multArray[$indice]=0
  speedUp[$indice]=0
  mult3Array[$indice]=0
done

etiquetas="Serie Par-4Hilos"
#for N in $(seq $Ninicio $Npaso $Nfinal);
for ((NAux = 1 ; NAux <= NIteraciones; NAux += 1)); do
  echo "Iteracion $NAux"
  date "+%H:%M:%S   %d/%m/%y"
  #bucle para parallel


  for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
    indice=$(((N-Ninicio)/Npaso))
    multTime=$(./$fMult3 $N 4 | grep 'time' | awk '{print $3}')
    mult3Array[$indice]=$(./$fFPOps -s $multTime ${mult3Array[$indice]} | awk '{print $1}')
    multTime=$(./$fMult $N | grep 'time' | awk '{print $3}')
    multArray[$indice]=$(./$fFPOps -s $multTime ${multArray[$indice]} | awk '{print $1}')
  done

done

# calcular la media e imprimir
for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
  indice=$(((N-Ninicio)/Npaso))
  multArray[$indice]=$(./$fFPOps -d ${multArray[$indice]} $NIteraciones | awk '{print $1}')
  mult3Array[$indice]=$(./$fFPOps -d ${mult3Array[$indice]} $NIteraciones | awk '{print $1}')
  speedUp[$indice]=$(./$fFPOps -d ${multArray[$indice]} ${mult3Array[$indice]} | awk '{print $1}')
  echo "$N ${multArray[$indice]} ${mult3Array[$indice]} ${speedUp[$indice]}" >> $fDAT
done

# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
chmod +x $exePlotScript
./$exePlotScript -f $fDAT -o 1 -d "2 3" -p $fPNG -t "Mult Paralelo Serie Execution Time" -y "Execution time (s)" -x "Vector Size" -l "$etiquetas"
./$exePlotScript -f $fDAT -o 1 -d 4 -p $fPNG2 -t "Aceleración para 4 Hilos" -y "Aceleración" -x "Vector Size" -l "4Hilos"

# abrimos las imagenes
xdg-open $fPNG
