#!/bin/bash

# inicializar variables
Ninicio=514
Npaso=64
Nfinal=1538
fDAT=./dat/time_parte2.dat
fPNG=./png/time_parte2.png
fPNG2=./png/time_parte2_su.png
NIteraciones=15
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

nValores=$((((Nfinal-Ninicio)/Npaso)+1))
# inicializar arrays a 0
for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
  indice=$(((N-Ninicio)/Npaso))
  multArray[$indice]=0
  for ((i = 1 ; i <= 4 ; i++)); do
    indiceAux=$((indice+(i-1)*nValores))
    speedUp[$indiceAux]=0
    mult3Array[$indiceAux]=0
  done

done



etiquetas="Serie Par-1Hilo Par-2Hilos Par-3Hilos Par-4Hilos"
#for N in $(seq $Ninicio $Npaso $Nfinal);
for ((NAux = 1 ; NAux <= NIteraciones; NAux += 1)); do
  echo "Iteracion $NAux"
  date "+%H:%M:%S   %d/%m/%y"
  #bucle para parallel


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
  multArray[$indice]=$(./$fFPOps -d ${multArray[$indice]} $NIteraciones | awk '{print $1}')
  for ((i = 1 ; i <= 4 ; i++)); do
    indiceAux=$((indice+(i-1)*nValores))
    mult3Array[$indiceAux]=$(./$fFPOps -d ${mult3Array[$indiceAux]} $NIteraciones | awk '{print $1}')
    speedUp[$indiceAux]=$(./$fFPOps -d ${multArray[$indice]} ${mult3Array[$indiceAux]} | awk '{print $1}')
    stringAux="$stringAux ${mult3Array[$indiceAux]} ${speedUp[$indiceAux]}"
  done
  echo "$N ${multArray[$indice]}$stringAux" >> $fDAT
done

# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
chmod +x $exePlotScript
./$exePlotScript -f $fDAT -o 1 -d "2 3 5 7 9" -p $fPNG -t "Mult Paralelo Execution Time" -y "Execution time (s)" -x "Vector Size" -l "$etiquetas"
./$exePlotScript -f $fDAT -o 1 -d "4 6 8 10" -p $fPNG2 -t "SpeedUp" -y "SpeedUp" -x "Vector Size" -l "1Hilo 2Hilos 3Hilos 4Hilos"

# abrimos las imagenes
#xdg-open $fPNG
