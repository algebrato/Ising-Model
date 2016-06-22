#!/usr/bin/gnuplot

set terminal pdf fontscale 1 size 12,7 enhanced
set output "Time_PNRG.pdf"
set multiplot
	set origin 0,0
	set size 1,1
	set ylabel "Tempo generazione di un numero random [ns]"
	set xlabel "Size del reticolo [L]"
	set title "Time scaling di due PNRG"
	plot "../../XORSHIFT.dat" pt 7 ps 0.6 title "xorshift 128-bit" w l, "../../LCG32.dat" pt 7 ps 0.6 title "LCG 32-bit" w l
unset multiplot
