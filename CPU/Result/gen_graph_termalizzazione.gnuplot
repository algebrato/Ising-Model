#!/usr/bin/gnuplot

set terminal pdf fontscale 1.2 size 12,7 enhanced linewidth 7
set output "Term_step.pdf"
set multiplot
	set origin 0,0
	set size 1,1
	set autoscale
	set ylabel "Magnetizzazione per spin"
	set xlabel "Numero di Step"
	set title "Confronto termalizzazione {/Symbol b = 0.6}"
	plot "Term_rand.dat" u 5 pt 7 ps 0.6 title "rand()" w l, "Term_drand48.dat" u 5 pt 7 ps 0.6 title "drand48()" w l, "Term_xorshift.dat" u 5 pt 7 ps 0.6 title "xorshift128()" w l
unset multiplot
