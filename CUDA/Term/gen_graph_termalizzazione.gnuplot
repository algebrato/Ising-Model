#!/usr/bin/gnuplot

set terminal pdf fontscale 1.2 size 12,7 enhanced
set output "Term_step_GPU.pdf"
set multiplot
	set origin 0,0
	set size 1,1
	set ylabel "Magnetizzazione per spin"
	set xlabel "Numero di Step"
	set title "Confronto termalizzazione"
	set yrange [0:1.3]
	plot "Term_256_04_XOR.dat" u 2 pt 7 ps 0.6 title "XorShift 128-bit" w l, "Term_256_04_LCG.dat" u 2 pt 7 ps 0.6 title "LCG 32-bit" w l
unset multiplot
