#!/bin/bash

ejsPaths=( 'ej1/ejercicio1.sh' 'ej2/ejercicio2.sh' 'ej3/ejercicio3.sh' 'ej4/ejercicio4.sh' )

# Ejecutamos todos los ejercicios

for ej in "${ejsPaths[@]}"; do
  echo; echo "-----> Ejecutando $ej"
  ./$ej
done
