#!/bin/bash

# inicializar variables
Ninicio=1000
Npaso=500
Nfinal=2000
fDAT=./dat/time_parte1_cambiada.dat
fPNG=./png/time_parte1_cambiada.png
NIteraciones=10
fMult=../src/exes/mult
fMult1=../src/exes/mult1
fMult2=../src/exes/mult2
fMult3=../src/exes/mult3
fFPOps=../src/exes/opsFloat
exePlotScript=../src/scripts/plotScript.sh

# creamos arrays para repetir las mediciones de tiempo
declare -a multArray
declare -a mult1Array
declare -a mult2Array
declare -a mult3Array


# borrar el fichero DAT y el fichero PNG
rm -f $fDAT fPNG

# generar el fichero DAT vacío
touch $fDAT

nValores=$((((Nfinal-Ninicio)/Npaso)+1))
# inicializar arrays a 0
for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
  indice=$(((N-Ninicio)/Npaso))
  multArray[$indice]=0
  for ((i = 1 ; i <= 4 ; i++)); do
    indiceAux=$((indice+(i-1)*nValores))

    mult1Array[$indiceAux]=0
    mult2Array[$indiceAux]=0
    mult3Array[$indiceAux]=0
  done

done

etiquetas="Serie 3-1 3-2 3-3 3-4 2-1 2-2 2-3 2-4 1-1 1-2 1-3 1-4"
#for N in $(seq $Ninicio $Npaso $Nfinal);
for ((NAux = 1 ; NAux <= NIteraciones; NAux += 1)); do
  echo "Iteracion $NAux"
  date "+%H:%M:%S   %d/%m/%y"
  #bucle para parallel

  for ((i = 1 ; i <= 4 ; i++)); do
    for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
      multTime=$(./$fMult1 $N $i | grep 'time' | awk '{print $3}')
      indice=$((((N-Ninicio)/Npaso)+(i-1)*nValores))
      mult1Array[$indice]=$(./$fFPOps -s $multTime ${mult1Array[$indice]} | awk '{print $1}')
    done
  done

  for ((i = 1 ; i <= 4 ; i++)); do
    for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
      multTime=$(./$fMult2 $N $i | grep 'time' | awk '{print $3}')
      indice=$((((N-Ninicio)/Npaso)+(i-1)*nValores))
      mult2Array[$indice]=$(./$fFPOps -s $multTime ${mult2Array[$indice]} | awk '{print $1}')
    done
  done

  for ((i = 1 ; i <= 4 ; i++)); do
    for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
      multTime=$(./$fMult3 $N $i | grep 'time' | awk '{print $3}')
      indice=$((((N-Ninicio)/Npaso)+(i-1)*nValores))
      mult3Array[$indice]=$(./$fFPOps -s $multTime ${mult3Array[$indice]} | awk '{print $1}')
    done
  done

  for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
    multTime=$(./$fMult $N | grep 'time' | awk '{print $3}')
    indice=$(((N-Ninicio)/Npaso))
    multArray[$indice]=$(./$fFPOps -s $multTime ${multArray[$indice]} | awk '{print $1}')
  done

done

# calcular la media e imprimir
for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
  stringAux=""
  indice=$(((N-Ninicio)/Npaso))

  # dividimos para calcular la media
  for ((i = 1 ; i <= 4 ; i++)); do
    indiceAux=$((indice+(i-1)*nValores))
    mult1Array[$indiceAux]=$(./$fFPOps -d ${mult1Array[$indiceAux]} $NIteraciones | awk '{print $1}')
    stringAux="$stringAux ${mult1Array[$indiceAux]}"
  done

  for ((i = 1 ; i <= 4 ; i++)); do
    indiceAux=$((indice+(i-1)*nValores))
    mult2Array[$indiceAux]=$(./$fFPOps -d ${mult2Array[$indiceAux]} $NIteraciones | awk '{print $1}')
    stringAux="$stringAux ${mult2Array[$indiceAux]}"
  done

  for ((i = 1 ; i <= 4 ; i++)); do
    indiceAux=$((indice+(i-1)*nValores))
    mult3Array[$indiceAux]=$(./$fFPOps -d ${mult3Array[$indiceAux]} $NIteraciones | awk '{print $1}')
    stringAux="$stringAux ${mult3Array[$indiceAux]}"
  done

  multArray[$indice]=$(./$fFPOps -d ${multArray[$indice]} $NIteraciones | awk '{print $1}')
  echo "$N ${multArray[$indice]}$stringAux" >> $fDAT
done

# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
chmod +x $exePlotScript
./$exePlotScript -f $fDAT -o 1 -d "2 3 4 5 6 7 8 9 10 11 12 13 14" -p $fPNG -t "Mult Paralelo Execution Time" -y "Execution time (s)" -x "Vector Size" -l "$etiquetas"
# abrimos las imagenes
#xdg-open $fPNG
