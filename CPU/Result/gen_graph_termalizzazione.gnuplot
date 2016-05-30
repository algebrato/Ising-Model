#!/usr/bin/gnuplot

set terminal pdf fontscale 0.7 size 7,7 enhanced
set output "Term_step.pdf"
set multiplot
	set origin 0,0
	set size 1,1
	set ylabel "Magnetizzazione per spin"
	set xlabel "Numero di Step"
	set title "Confronto termalizzazione"
	set yrange [0:1.1]
	plot "Term_rand.dat" u 5 pt 7 ps 0.6 title "rand()", "Term_drand48.dat" u 5 pt 7 ps 0.6 title "drand48()", "Term_xorshift.dat" u 5 pt 7 ps 0.6 title "xorshift128()" 
unset multiplot
