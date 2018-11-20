#!/bin/bash

pathMakefile='src'

cd $pathMakefile
make
cd - > /dev/null

scriptsPaths=( 'ej1/ejercicio1.sh' 'ej2/ejercicio2.sh' 'ej3/ejercicio3.sh' 'ej4/ejercicio4.sh' 'src/scripts/plotScript.sh' )

for script in "${scriptsPaths[@]}"; do
  chmod +x $script
done
