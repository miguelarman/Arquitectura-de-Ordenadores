#!/bin/bash

set -e
set -u
set -o pipefail


declare -a files
declare -a dest
declare -a lines

ayudaEjec="Script usage: ./$(basename $0) -f nombre de los archivos -o columna eje x -d columnas eje -p png de la grafica\n[-s tipo de grafico] [-x xlabel] [-y ylabel] [-t titulo de la grafica] [-k posicion de la leyenda]\n[-l etiquetas de las variables] [-w anchura de linea]"
png=0
style="lines"
lines=""
key="left top"
files=0
origen=0
dest=0
xlabel=""
ylabel=""
title=""
lw=2
while getopts 'f:o:d:p:s:x:y:t:k:l:w:' opt; do
  case $opt in
    f)
      filesAux+=("$OPTARG")
      files=( $filesAux )
      ;;

    o)
      origen=$OPTARG
      ;;

    d)
      destAux+=("$OPTARG")
      dest=( $destAux )
      ;;
    s)
      style=$OPTARG
      ;;
    p)
      png=$OPTARG
      ;;
    x)
      xlabel=("$OPTARG")
      ;;
    y)
      ylabel=("$OPTARG")
      ;;
    t)
      title=("$OPTARG")
      ;;
    k)
      key=$OPTARG
      ;;
    l)
      linesAux+=("$OPTARG")
      lines=( $linesAux )
      ;;
    w)
      lw=$OPTARG
      ;;
    ?)
      echo $ayudaEjec >&2
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"
if [ "$files" = "0" ]
then
  echo -e "-f nombre de los archivos es un argumento requerido.\n$ayudaEjec"
  exit 1
elif [ "$origen" = "0" ]
then
  echo -e "-o columna eje x es un argumento requerido.\n$ayudaEjec"
  exit 1
elif [ "$dest" = "0" ]
then
  echo -e "-d columnas eje y es un argumento requerido.\n$ayudaEjec"
  exit 1
elif [ "$png" = "0" ]
then
  echo -e "-p png de la grafica es un argumento requerido.\n$ayudaEjec"
  exit 1
fi

if [ -n "$title" ]
then
  gnuplotStr+=$'\nset title'
  gnuplotStr+=' "'
  gnuplotStr="$gnuplotStr$title"
  gnuplotStr+='"'
fi
if [ -n "$ylabel" ]
then
  gnuplotStr+=$'\nset ylabel'
  gnuplotStr+=' "'
  gnuplotStr="$gnuplotStr$ylabel"
  gnuplotStr+='"'
fi
if [ -n "$xlabel" ]
then
  gnuplotStr+=$'\nset xlabel'
  gnuplotStr+=' "'
  gnuplotStr="$gnuplotStr$xlabel"
  gnuplotStr+='"'
fi
gnuplotStr+=$'\nset key'
gnuplotStr="$gnuplotStr $key"
gnuplotStr+=$'\nset grid\nset term png\nset output'
gnuplotStr+=' "'
gnuplotStr="$gnuplotStr$png"
gnuplotStr+='"'
gnuplotStr+=$'\nplot'
i=0
cont=0
aux=$((${#files[@]}*${#dest[@]}))
while [ ${#files[@]} -gt $i ]
do
  j=0
  while [ ${#dest[@]} -gt $j ]
  do
    gnuplotStr+=' "'
    gnuplotStr="$gnuplotStr${files[$i]}"
    gnuplotStr+='"'
    gnuplotStr="$gnuplotStr using $origen:${dest[$j]} with $style lw $lw"
    if [ -n "$lines" ]
    then
      if [ ${#lines[@]} -gt $cont ]
      then
        gnuplotStr="$gnuplotStr title"
        gnuplotStr+=' "'
        gnuplotStr="$gnuplotStr${lines[$cont]}"
        gnuplotStr+='"'
      fi
    fi
    cont=$((cont+1))
    if [ $aux -gt $cont ]
    then
      gnuplotStr+=', \'
      gnuplotStr+=$'\n'
    else
      gnuplotStr+=$'\n'
    fi
    j=$((j+1))
  done
  i=$((i+1))
done

gnuplotStr+=$'\nquit'
gnuplot << END_GNUPLOT
$gnuplotStr
END_GNUPLOT
