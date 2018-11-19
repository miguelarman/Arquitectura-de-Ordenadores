#!/bin/bash


scriptej1=ej1/ejercicio1.sh
scriptej2=ej2/ejercicio2.sh
scriptej3=ej3/ejercicio3.sh
scriptej4=ej4/ejercicio4.sh
scriptPlot=src/scripts/plotScript.sh


# Compilamos todo
cd src
echo ('make')
cd ..


# Damos permiso de ejecución a todos los scripts
chmod +x $scriptej1
chmod +x $scriptej2
chmod +x $scriptej3
chmod +x $scriptej4

chmod +x $scriptPlot
