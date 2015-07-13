#!/usr/bin/gnuplot

set terminal pdf fontscale 0.7 size 12,12 enhanced
set output "Ising_Mag_Cv.pdf"
set multiplot
	set origin 0,0
	set size 0.5,0.5
	set ylabel "Magnetizzazione"
	set xlabel "{/Symbol b} [1/J]"
	set title "Calcolo di {/Symbol a}"
	f(x)=a*(1-(0.44/x))**b
	set yrange [0.5:1]
	a=1.16897735438031
	b=0.115971598089104
	c=0.13143717149296
	set linestyle 2 lt -1 lw 3  
	plot "Ret_512.dat" u 1:2:5 every 1:1:8::15 with yerrorbars pt 7 ps 1 title "512x512", f(x) title "M({/Symbol b})=1.152*|1-0.441/{/Symbol b}|^{0.109}" with line ls 2 
	
	set origin 0,0.5
	set size 0.5,0.5
	set ylabel "Magnetizzazione per Spin"
	set title "Magnetizzazione"
	set yrange [0:1]
	set xrange [0.25:0.6]
	plot "Ret_32.dat" u 1:2:5 with yerrorbars pt 7 ps 0.6 title "32x32", "" u 1:2 w l lc 1  title "", "Ret_64.dat" u 1:2:5 with yerrorbars pt 7 ps 0.6 title "64x64", "" u 1:2 w l lc 3  title "", "Ret_128.dat" u 1:2:5 with yerrorbars pt 7 ps 0.6  title "128x128", "" u 1:2 w l lc 5 title "", "Ret_256.dat" u 1:2:5 with yerrorbars pt 7 ps 0.6 title "256x256", "" u 1:2 w l lc 7 title "", "Ret_512.dat" u 1:2:5 with yerrorbars pt 7 ps 0.6 title "512x512", "" u 1:2 w l lc 7 title "", "../../../Relazione/onsager_J_1.dat" title "Onsager" w l lt 0 lw 10

	set origin 0.5,0.5
	set size 0.5,0.5
	set autoscale
	set yrange [0:3]
	set xrange [0:0.7]
	set ylabel "Calore specifico per Spin"
	set title "Calore Specifico"
	plot "Ret_32.dat" u 1:3:4 with yerrorbars pt 7 ps 0.6 title "32x32", "" u 1:3 w l lc 1  title "", "Ret_64.dat" u 1:3:4 with yerrorbars pt 7 ps 0.6 title "64x64", "" u 1:3 w l lc 3  title "", "Ret_128.dat" u 1:3:4 with yerrorbars pt 7 ps 0.6  title "128x128", "" u 1:3 w l lc 5 title "", "Ret_256.dat" u 1:3:4 with yerrorbars pt 7 ps 0.6 title "256x256", "" u 1:3 w l lc 7 title "", "Ret_512.dat" u 1:3:4 with yerrorbars pt 7 ps 0.6 title "512x512", "" u 1:3 w l lc 9 title "", "../../../Relazione/Onsager_spec_heat.dat" title "Onsager" w l lt 0 lw 10
	
unset multiplot
