#!/bin/bash

pathMakefile='src'
scriptsPaths=( 'ej1/ejercicio1.sh' 'ej2/ejercicio2.sh' 'ej3/ejercicio3.sh' 'ej4/ejercicio4.sh' 'src/scripts/plotScript.sh' )


# Compilando todo

echo "-----> Compilando todo de nuevo"
cd $pathMakefile
make clean
make
cd - > /dev/null


# Damos permisos de ejecución a todos los scripts usados

for script in "${scriptsPaths[@]}"; do
  echo; echo "-----> Dando permisos de ejecución a $script"
  chmod +x $script
done
