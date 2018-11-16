#!/bin/bash

fileAux=salidaAux.dat

Ninicio=10
Nfinal=$((Ninicio + 90))
Npaso=10
NIteraciones=10

TamsCacheN1=( 1024 2048 4096 8192 )
TamCacheSup=$((8*1024*1024))
TamLinea=64
NVias=1

ejecutableSlow=../src/slow
ejecutableFast=../src/fast
fFPOps=../src/opsFloat

# creamos arrays
declare -a D1mrSlowArray
declare -a D1mwSlowArray
declare -a D1mrFastArray
declare -a D1mwFastArray


for TamCacheN1 in "${TamsCacheN1[@]}"; do

  # inicializar arrays
  for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
    indice=$(((N-Ninicio)/Npaso))

    D1mrSlowArray[$indice]=0
    D1mwSlowArray[$indice]=0
    D1mrFastArray[$indice]=0
    D1mwFastArray[$indice]=0
  done

  for ((NAux = 1 ; NAux <= NIteraciones; NAux += 1)); do
    echo "Iteración $NAux de $NIteraciones para caché de $TamCacheN1 empezada"

    #bucle para slow
    ejecutable=$ejecutableSlow

    for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
      echo "Running slow $N"

      indice=$(((N-Ninicio)/Npaso))

      rm -f $fileAux
      touch $fileAux

      valgrind --tool=cachegrind --I1=$TamCacheN1,$NVias,$TamLinea --D1=$TamCacheN1,$NVias,$TamLinea --LL=$TamCacheSup,$NVias,$TamLinea --cachegrind-out-file=$fileAux ./$ejecutable $N > salida.txt

      # leemos los fallos de pagina
      D1mr=$(cg_annotate $fileAux | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $5}')
      D1mrSlowArray[$indice]=$(./$fFPOps -s ${D1mrSlowArray[$indice]} $D1mr | awk '{print $1}')

      D1mw=$(cg_annotate $fileAux | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $8}')
      D1mwSlowArray[$indice]=$(./$fFPOps -s ${D1mwSlowArray[$indice]} $D1mw | awk '{print $1}')
    done

    echo


    #bucle para fast
    ejecutable=$ejecutableFast

    for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
      echo "Running fast $N"

      indice=$(((N-Ninicio)/Npaso))

      rm -f $fileAux
      touch $fileAux

      valgrind --tool=cachegrind --I1=$TamCacheN1,$NVias,$TamLinea --D1=$TamCacheN1,$NVias,$TamLinea --LL=$TamCacheSup,$NVias,$TamLinea --cachegrind-out-file=$fileAux ./$ejecutable $N > salida.txt

      # leemos los fallos de pagina
      D1mr=$(cg_annotate $fileAux | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $5}')
      D1mrFastArray[$indice]=$(./$fFPOps -s ${D1mrFastArray[$indice]} $D1mr | awk '{print $1}')

      D1mw=$(cg_annotate $fileAux | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $8}')
      D1mwFastArray[$indice]=$(./$fFPOps -s ${D1mwFastArray[$indice]} $D1mw | awk '{print $1}')

    done

    echo "Iteración $NAux de $NIteraciones para caché de $TamCacheN1 completada"
    echo
  done

  # imprimimos los datos
  fDatos=cache_$TamCacheN1.dat
  rm -f $fDatos
  touch $fDatos

  for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
    indice=$(((N-Ninicio)/Npaso))

    # dividimos para calcular la media
    D1mrSlowArray[$indice]=$(./$fFPOps -d ${D1mrSlowArray[$indice]} $NIteraciones | awk '{print $1}')
    D1mwSlowArray[$indice]=$(./$fFPOps -d ${D1mwSlowArray[$indice]} $NIteraciones | awk '{print $1}')
    D1mrFastArray[$indice]=$(./$fFPOps -d ${D1mrFastArray[$indice]} $NIteraciones | awk '{print $1}')
    D1mwFastArray[$indice]=$(./$fFPOps -d ${D1mwFastArray[$indice]} $NIteraciones | awk '{print $1}')

    echo "$N	${D1mrSlowArray[$indice]}	${D1mwSlowArray[$indice]}	${D1mrFastArray[$indice]}	${D1mwFastArray[$indice]}" >> $fDatos
  done

done

#ploteamos las graficas
chmod +x plotScript.sh
./plotScript.sh ${TamsCacheN1[@]}

rm -f $fileAux salida.txt
