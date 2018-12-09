#!/bin/bash

# inicializar variables
Ninicio=1000000
Npaso=1000000
Nfinal=10000000
fDAT=./dat/time_peq.dat
fPNG=./png/time_peq.png
NIteraciones=15
fSerie=../src/exes/pescalar_serie
fCores=../src/exes/getNCores
fParallel=../src/exes/pescalar_par2
fFPOps=../src/exes/opsFloat
exePlotScript=../src/scripts/plotScript.sh

# creamos arrays para repetir las mediciones de tiempo
declare -a serieArray
declare -a parallelArray


# borrar el fichero DAT y el fichero PNG
rm -f $fDAT fPNG

# generar el fichero DAT vacío
touch $fDAT
nValores=$((((Nfinal-Ninicio)/Npaso)+1))
nCores=$(./$fCores | awk '{print $1}')
# inicializar arrays a 0
for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
  indice=$(((N-Ninicio)/Npaso))
  for ((i = 2 ; i <= nCores ; i++)); do
    indiceAux=$((indice+(i-2)*nValores))
    parallelArray[$indiceAux]=0
  done
  serieArray[$indice]=0
done

stringAux=""
dAux="2 "
for ((i = 2 ; i <= nCores ; i++)); do
  dAux="$dAux $((i+1)) "
done
etiquetas="Serie "
#for N in $(seq $Ninicio $Npaso $Nfinal);
for ((NAux = 1 ; NAux <= NIteraciones; NAux += 1)); do
  echo "Iteracion $NAux"
  #bucle para parallel

  for ((i = 2 ; i <= nCores ; i++)); do
    for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
      parallelTime=$(./$fParallel $N $i| grep 'Tiempo' | awk '{print $2}')

      indice=$((((N-Ninicio)/Npaso)+(i-2)*nValores))
      parallelArray[$indice]=$(./$fFPOps -s $parallelTime ${parallelArray[$indice]} | awk '{print $1}')

    done
  done
  #bucle para fast
  for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do

    serieTime=$(./$fSerie $N | grep 'Tiempo' | awk '{print $2}')

    indice=$(((N-Ninicio)/Npaso))
    serieArray[$indice]=$(./$fFPOps -s $serieTime ${serieArray[$indice]} | awk '{print $1}')
  done

done

# calcular la media e imprimir
for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
  stringAux=""
  indice=$(((N-Ninicio)/Npaso))

  # dividimos para calcular la media
  for ((i = 2 ; i <= nCores ; i++)); do
    indiceAux=$((indice+(i-2)*nValores))
    parallelArray[$indiceAux]=$(./$fFPOps -d ${parallelArray[$indiceAux]} $NIteraciones | awk '{print $1}')
    stringAux="$stringAux ${parallelArray[$indiceAux]}"
    etiquetas+="Paralelo$i "
  done
  serieArray[$indice]=$(./$fFPOps -d ${serieArray[$indice]} $NIteraciones | awk '{print $1}')
  echo "$N ${serieArray[$indice]}$stringAux" >> $fDAT
done

# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
chmod +x $exePlotScript
./$exePlotScript -f $fDAT -o 1 -d "$dAux" -p $fPNG -t "Serie-Paralelo Execution Time" -y "Execution time (s)" -x "Vector Size" -l "$etiquetas"
# abrimos las imagenes
#xdg-open $fPNG
