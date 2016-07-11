#!/usr/bin/gnuplot

set terminal pdf fontscale 1 size 12,7 enhanced linewidth 7
set output "Time_BLOCK.pdf"
set multiplot
	unset key
	set origin 0,0
	set size 1,1
	set ylabel "Time per mossa Metropolis [ns]"
	set xlabel "Dimensione Blocco Y [Threads]"
	set title "Ottimizzazione dimensione Blocco Shared"
	plot "../../BLOCK_size.dat" u 1:($3*1000) pt 7 ps 0.6 w l, ""  u 1:($3*1000) pt 7 ps 1.2
unset multiplot
