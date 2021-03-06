#!/bin/bash

pathMakefile='src'
scriptsPaths=( 'Ej2/ejercicio2.sh' 'Ej3/ejercicio3.sh' 'Ej3/ejercicio3parte1.sh' 'Ej3/ejercicio3parte2.sh' 'src/scripts/plotScript.sh' )


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
