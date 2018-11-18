#!/bin/bash

fileAux=./dat/salidaAux.dat

Ninicio=64+64*5
Nfinal=$((Ninicio + 64))
Npaso=4
NIteraciones=25

TamsCacheN1=( 1024 2048 4096 8192 )
TamCacheSup=$((8*1024*1024))
TamLinea=64
NVias=1

ejecutableNormal=../src/exes/multiplicarMatrices
ejecutableTrasp=../src/exes/multiplicarMatricesTrasp
ejecutablePlotScript=../src/scripts/plotScript.sh
fFPOps=../src/exes/opsFloat

plotFiles="./dat/mult_1024.dat ./dat/mult_2048.dat ./dat/mult_4096.dat ./dat/mult_8192.dat"
plotXColumn=1
plotYColumnNorm="3 6"
plotYColumnTrasp="4 7"
plotYColumnTime="2 5"
plotNormPng=./png/multNorm_cache.png
plotTraspPng=./png/multTrasp_cache.png
plotTimePng=./png/mult_time.png
plotNormTitle="Comparison Between Cache Misses Normal"
plotTraspTitle="Comparison Between Cache Misses Trasp"
plotTimeTitle="Comparison Between Times"
plotYLabelCache="Number of cache misses"
plotYLabelTime="Execution Time"
plotXLabel="Matrix Size"
plotNormEtiquetas="FallosRdNormal-1024 FallosWrNormal-1024 FallosRdNormal-2048 FallosWrNormal-2048 FallosRdNormal-4096 FallosWrNormal-4096 FallosRdNormal-8192 FallosWrNormal-8192"
plotTraspEtiquetas="FallosRdTrasp-1024 FallosWrTrasp-1024 FallosRdTrasp-2048 FallosWrTrasp-2048 FallosRdTrasp-4096 FallosWrTrasp-4096 FallosRdTrasp-8192 FallosWrTrasp-8192"
plotTimeEtiquetas="NormalTime-1024 TraspTime-1024 NormalTime-2048 TraspTime-2048 NormalTime-4096 TraspTime-4096 NormalTime-8192 TraspTime-8192"

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

for TamCacheN1 in "${TamsCacheN1[@]}"; do
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
  fDatos=./dat/mult_$TamCacheN1.dat
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
done
rm -f $fileAux
#ploteamos las graficas
chmod +x $ejecutablePlotScript
./$ejecutablePlotScript -f "$plotFiles" -o $plotXColumn -d "$plotYColumnNorm" -p $plotNormPng -t "$plotNormTitle" -y "$plotYLabelCache" -x "$plotXLabel" -l "$plotNormEtiquetas"
./$ejecutablePlotScript -f "$plotFiles" -o $plotXColumn -d "$plotYColumnTrasp" -p $plotTraspPng -t "$plotTraspTitle" -y "$plotYLabelCache" -x "$plotXLabel" -l "$plotTraspEtiquetas"
./$ejecutablePlotScript -f "$plotFiles" -o $plotXColumn -d "$plotYColumnTime" -p $plotTimePng -t "$plotTimeTitle" -y "$plotYLabelTime" -x "$plotXLabel" -l "$plotTimeEtiquetas"

# abrimos las imagenes
#xdg-open png/multNorm_cache.png
#xdg-open png/multTrasp_cache.png
#xdg-open png/mult_time.png
