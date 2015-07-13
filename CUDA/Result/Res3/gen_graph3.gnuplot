#!/usr/bin/gnuplot

set terminal pdf fontscale 0.7 size 12,6 enhanced
set output "Comp_Onsager.pdf"
set multiplot
	set origin 0,0
	set size 0.5,1
	set ylabel "Magnetizzazione per Spin"
	set title "Magnetizzazione"
	set yrange [0:1]
	set xrange [0.25:0.6]
	plot "Ret_512.dat" u 1:2:5 with yerrorbars pt 7 ps 0.6 title "512x512", "" u 1:2 w l lc 7 title "", "../../../Relazione/onsager_J_1.dat" title "Onsager" w l lt 0 lw 10

	set origin 0.5,0
	set size 0.5,1
	set autoscale
	set yrange [0:3]
	set xrange [0:0.7]
	set ylabel "Calore specifico per Spin"
	set title "Calore Specifico"
	plot "Ret_512.dat" u 1:3:4 with yerrorbars pt 7 ps 0.6 title "512x512", "" u 1:3 w l lc 9 title "", "../../../Relazione/Onsager_spec_heat.dat" title "Onsager" w l lt 0 lw 10
	
unset multiplot
