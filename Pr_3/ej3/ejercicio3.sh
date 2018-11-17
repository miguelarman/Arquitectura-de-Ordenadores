#!/bin/bash

fileAux=./dat/salidaAux.dat

Ninicio=1
Nfinal=$((Ninicio + 5))
Npaso=1
NIteraciones=1

TamCacheN1=8192
TamCacheSup=$((8*1024*1024))
TamLinea=64
NVias=1

ejecutableNormal=../src/exes/multiplicarMatrices
ejecutableTrasp=../src/exes/multiplicarMatricesTrasp
ejecutablePlotScript=../src/scripts/plotScript.sh
fFPOps=../src/exes/opsFloat

fDatos=./dat/mult.dat

# creamos arrays
declare -a D1mrNormalArray
declare -a D1mwNormalArray
declare -a D1mrTraspArray
declare -a D1mwTraspArray
declare -a TimeNormalArray
declare -a TimeTraspArray


# inicializar arrays
for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
  indice=$(((N-Ninicio)/Npaso))

  D1mrNormalArray[$indice]=0
  D1mwNormalArray[$indice]=0
  TimeNormalArray[$indice]=0
  TimeTraspArray[$indice]=0
  D1mrTraspArray[$indice]=0
  D1mwTraspArray[$indice]=0
done

for ((NAux = 1 ; NAux <= NIteraciones; NAux += 1)); do
  #echo "Iteración $NAux de $NIteraciones para caché de $TamCacheN1 empezada"

  #bucle para slow
  ejecutable=$ejecutableNormal

  for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
    #echo "Running slow $N"

    indice=$(((N-Ninicio)/Npaso))

    rm -f $fileAux
    touch $fileAux

    Time=$(valgrind --tool=cachegrind --I1=$TamCacheN1,$NVias,$TamLinea --D1=$TamCacheN1,$NVias,$TamLinea --LL=$TamCacheSup,$NVias,$TamLinea --cachegrind-out-file=$fileAux --log-file=/dev/null ./$ejecutable $N | grep 'time' | awk '{print $3}')
    TimeNormalArray[$indice]=$(./$fFPOps -s ${TimeNormalArray[$indice]} $Time | awk '{print $1}')
    # leemos los fallos de pagina
    D1mr=$(cg_annotate $fileAux | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $5}')
    D1mrNormalArray[$indice]=$(./$fFPOps -s ${D1mrNormalArray[$indice]} $D1mr | awk '{print $1}')

    D1mw=$(cg_annotate $fileAux | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $8}')
    D1mwNormalArray[$indice]=$(./$fFPOps -s ${D1mwNormalArray[$indice]} $D1mw | awk '{print $1}')
  done
  #bucle para la traspuesta
  ejecutable=$ejecutableTrasp

  for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
    #echo "Running fast $N"

    indice=$(((N-Ninicio)/Npaso))

    rm -f $fileAux
    touch $fileAux

    Time=$(valgrind --tool=cachegrind --I1=$TamCacheN1,$NVias,$TamLinea --D1=$TamCacheN1,$NVias,$TamLinea --LL=$TamCacheSup,$NVias,$TamLinea --cachegrind-out-file=$fileAux --log-file=/dev/null ./$ejecutable $N | grep 'time' | awk '{print $3}')
    TimeTraspArray[$indice]=$(./$fFPOps -s ${TimeTraspArray[$indice]} $Time | awk '{print $1}')
    # leemos los fallos de pagina
    D1mr=$(cg_annotate $fileAux | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $5}')
    D1mrTraspArray[$indice]=$(./$fFPOps -s ${D1mrTraspArray[$indice]} $D1mr | awk '{print $1}')

    D1mw=$(cg_annotate $fileAux | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $8}')
    D1mwTraspArray[$indice]=$(./$fFPOps -s ${D1mwTraspArray[$indice]} $D1mw | awk '{print $1}')

  done

  #echo "Iteración $NAux de $NIteraciones para caché de $TamCacheN1 completada"
  #echo
done

# imprimimos los datos
rm -f $fDatos
touch $fDatos

for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
  indice=$(((N-Ninicio)/Npaso))

  # dividimos para calcular la media
  D1mrNormalArray[$indice]=$(./$fFPOps -d ${D1mrNormalArray[$indice]} $NIteraciones | awk '{print $1}')
  D1mwNormalArray[$indice]=$(./$fFPOps -d ${D1mwNormalArray[$indice]} $NIteraciones | awk '{print $1}')
  D1mrTraspArray[$indice]=$(./$fFPOps -d ${D1mrTraspArray[$indice]} $NIteraciones | awk '{print $1}')
  D1mwTraspArray[$indice]=$(./$fFPOps -d ${D1mwTraspArray[$indice]} $NIteraciones | awk '{print $1}')
  TimeNormalArray[$indice]=$(./$fFPOps -d ${TimeNormalArray[$indice]} $NIteraciones | awk '{print $1}')
  TimeTraspArray[$indice]=$(./$fFPOps -d ${TimeTraspArray[$indice]} $NIteraciones | awk '{print $1}')
  echo "$N	${TimeNormalArray[$indice]} ${D1mrNormalArray[$indice]}	${D1mwNormalArray[$indice]}	${TimeTraspArray[$indice]} ${D1mrTraspArray[$indice]}	${D1mwTraspArray[$indice]}" >> $fDatos
done

rm -f $fileAux
#ploteamos las graficas
chmod +x $ejecutablePlotScript
./$ejecutablePlotScript -f $fDatos -o 1 -d "3 4 6 7" -p ./png/mult_cache.png -t "Comparison Betweem Cache Misses" -y "Number of cache misses" -x "Matrix Size" -l "FallosLecturaNormal FallosEscrituraNormal FallosLecturaTrap FallosEscrituraTrasp"
./$ejecutablePlotScript -f $fDatos -o 1 -d "2 5" -p ./png/mult_time.png -t "Comparison Between Times" -y "Execution Time" -x "Matrix Size" -l "NormalTime TraspTime"

# abrimos las imagenes
xdg-open png/mult_cache.png
xdg-open png/mult_time.png
