#!/usr/bin/gnuplot

set terminal pdf fontscale 0.7 size 12,16 enhanced
set output "Ising_Mag_Cv.pdf"
set xlabel "{/Symbol b} [1/J]"
set multiplot
	set origin 0,0.33
	set size 0.5,0.33
	set ylabel "Magnetizzazione"
	set title "Calcolo di {/Symbol a}"
	f(x)=a*(1-(0.44/x))**b
	set yrange [0.5:1]
	a=1.16897735438031
	b=0.115971598089104
	c=0.13143717149296
	set linestyle 2 lt -1 lw 3  
	plot "Ret_256.dat" u 1:2 every 1:1:8::15 pt 7 ps 1 title "256x256", f(x) title "M({/Symbol b})=1.152*|1-0.441/{/Symbol b}|^{0.109}" with line ls 2 
	
	set origin 0,0.66
	set size 0.5,0.33
	set ylabel "Magnetizzazione per Spin"
	set title "Magnetizzazione"
	set yrange [0:1]
	set xrange [0.25:0.6]
	plot "Ret_32.dat" u 1:2 w lp pt 7 ps 0.6 title "32x32", "Ret_64.dat" u 1:2 w lp pt 7 ps 0.6 title "64x64", "Ret_128.dat" u 1:2 w lp pt 7 ps 0.6 title "128x128", "Ret_256.dat" u 1:2 w lp pt 7 ps 0.6 title "256x256"

	set origin 0.5,0.66
	set size 0.5,0.33
	set autoscale
	set ylabel "Calore specifico per Spin"
	set title "Calore Specifico"
	plot "Ret_32.dat" u 1:3 w lp pt 7 ps 0.6 title "32x32", "Ret_64.dat" u 1:3 w lp pt 7 ps 0.6 title "64x64", "Ret_128.dat" u 1:3 w lp pt 7 ps 0.6 title "128x128", "Ret_256.dat" u 1:3 w lp pt 7 ps 0.6 title "256x256"

unset multiplot
