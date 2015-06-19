#!/usr/bin/gnuplot

set terminal pdf enhanced fontscale 0.7 size 12,16
set output "Ising_Mag_Cv.pdf"
set xlabel "{/Symbol b} [1/J]"
set multiplot

	set origin 0,0.66
	set size 0.5,0.33
	set ylabel "Magnetizzazione per Spin"
	set title "Magnetizzazione vs Beta 32x32"
	set xrange [0.25:0.6]
	plot "Ret_32.dat" u 1:2 w lp pt 7 ps 0.6 title ""
	
	set origin 0.5,0.66
	set size 0.5,0.33
	set ylabel "Calore specifico per Spin"
	set title "Calore Specifico vs Beta 32x32"
	plot "Ret_32.dat" u 1:3 w lp pt 7 ps 0.6 title ""
	
	set origin 0,0.33
	set size 0.5,0.33
	set ylabel "Magnetizzazione per Spin"
	set title "Magnetizzazione vs Beta 64x64"
	set xrange [0.25:0.6]
	plot "Ret_64.dat" u 1:2 w lp pt 7 ps 0.6 title ""

	set origin 0.5,0.33
	set size 0.5,0.33
	set ylabel "Calore specifico per Spin"
	set title "Calore Specifico vs Beta 64x64"
	plot "Ret_64.dat" u 1:3 w lp pt 7 ps 0.6 title ""
	
	set origin 0,0
	set size 0.5,0.33
	set ylabel "Magnetizzazione per Spin"
	set title "Magnetizzazione 32x32 + 64x64"
	set xrange [0.25:0.6]
	plot "Ret_32.dat" u 1:2 w lp pt 7 ps 0.6 title "32x32", "Ret_64.dat" u 1:2 w lp pt 7 ps 0.6 title "64x64", "Ret_128.dat" u 1:2 w lp pt 7 ps 0.6 title "128x128", "Ret_256.dat" u 1:2 w lp pt 7 ps 0.6 title "256x256"

	set origin 0.5,0
	set size 0.5,0.33
	set ylabel "Calore specifico per Spin"
	set title "Calore Specifico 32x32 + 64x64"
	plot "Ret_32.dat" u 1:3 w lp pt 7 ps 0.6 title "32x32", "Ret_64.dat" u 1:3 w lp pt 7 ps 0.6 title "64x64", "Ret_128.dat" u 1:3 w lp pt 7 ps 0.6 title "128x128", "Ret_256.dat" u 1:3 w lp pt 7 ps 0.6 title "256x256"

unset multiplot
