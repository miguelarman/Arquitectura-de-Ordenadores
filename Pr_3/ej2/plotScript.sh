#!/bin/bash


fPNGWr=cache_escritura.png
fPNGRe=cache_lectura.png


declare -a files
i=0
for size in "$@"; do
  files[$i]=cache_$size.dat
  i=$((i + 1))
done

echo "Generating reading plot..."

# llamar a gnuplot para generar el gráfico de escritura

gnuplot << END_GNUPLOT
set title "Slow-Fast Reading Cache Misses"
set ylabel "Number of cache misses"
set xlabel "Matrix Size"
set key left top
set grid
set term png
set output "$fPNGRe"
plot "${files[0]}" using 1:2 with lines lw 2 title "Cache: 1024B - slow", \
     "${files[0]}" using 1:4 with lines lw 2 title "Cache: 1024B - fast", \
     "${files[1]}" using 1:2 with lines lw 2 title "Cache: 2048B - slow", \
     "${files[1]}" using 1:4 with lines lw 2 title "Cache: 2048B - fast", \
     "${files[2]}" using 1:2 with lines lw 2 title "Cache: 4096B - slow", \
     "${files[2]}" using 1:4 with lines lw 2 title "Cache: 4096B - fast", \
     "${files[3]}" using 1:2 with lines lw 2 title "Cache: 8192B - slow", \
     "${files[3]}" using 1:4 with lines lw 2 title "Cache: 8192B - fast"
  replot
quit
END_GNUPLOT




echo "Generating writing plot..."

# llamar a gnuplot para generar el gráfico de escritura
gnuplot << END_GNUPLOT
set title "Slow-Fast Writing Cache Misses"
set ylabel "Number of cache misses"
set xlabel "Matrix Size"
set key left top
set grid
set term png
set output "$fPNGWr"
plot "${files[0]}" using 1:3 with lines lw 2 title "Cache: 1024B - slow", \
     "${files[0]}" using 1:5 with lines lw 2 title "Cache: 1024B - fast", \
     "${files[1]}" using 1:3 with lines lw 2 title "Cache: 2048B - slow", \
     "${files[1]}" using 1:5 with lines lw 2 title "Cache: 2048B - fast", \
     "${files[2]}" using 1:3 with lines lw 2 title "Cache: 4096B - slow", \
     "${files[2]}" using 1:5 with lines lw 2 title "Cache: 4096B - fast", \
     "${files[3]}" using 1:3 with lines lw 2 title "Cache: 8192B - slow", \
     "${files[3]}" using 1:5 with lines lw 2 title "Cache: 8192B - fast"
  replot
quit
END_GNUPLOT
