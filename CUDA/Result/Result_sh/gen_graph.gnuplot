#!/usr/bin/gnuplot

set terminal pdf fontscale 0.7 size 12,12 enhanced
set output "Ising_Mag_Cv.pdf"
set multiplot
	set origin 0,0
	set size 0.5,0.5
	set ylabel "Magnetizzazione"
	set xlabel "{/Symbol b} [1/J]"
	set title "Calcolo di {/Symbol a}"
	f(x)=a*(1-(b/x))**c
	set yrange [0.5:1]
	a=1.18121
	b=0.440487
	c=0.119984
	set linestyle 2 lt -1 lw 3  
	plot "Ret_512.dat" u 1:2:(0.01) every 1:1:8::15 with yerrorbars pt 7 ps 1 title "512x512", f(x) title "M({/Symbol b})=1.18121*|1-0.440487/{/Symbol b}|^{0.119984}" with line ls 2 
	
	set origin 0,0.5
	set size 0.5,0.5
	set ylabel "Magnetizzazione per Spin"
	set title "Magnetizzazione"
	set yrange [0:1]
	set xrange [0.25:0.6]
	plot "Ret_32.dat" u 1:2:(0.01) with yerrorbars pt 7 ps 0.6 title "32x32", "" u 1:2 w l lc 1  title "", "Ret_64.dat" u 1:2:(0.01) with yerrorbars pt 7 ps 0.6 title "64x64", "" u 1:2 w l lc 3  title "", "Ret_128.dat" u 1:2:(0.01) with yerrorbars pt 7 ps 0.6  title "128x128", "" u 1:2 w l lc 5 title "", "Ret_256.dat" u 1:2:(0.01) with yerrorbars pt 7 ps 0.6 title "256x256", "" u 1:2 w l lc 7 title "", "Ret_512.dat" u 1:2:(0.01) with yerrorbars pt 7 ps 0.6 title "512x512", "" u 1:2 w l lc 7 title ""

	set origin 0.5,0.5
	set size 0.5,0.5
	set autoscale
	set ylabel "Calore specifico per Spin"
	set title "Calore Specifico"
	plot "Ret_32.dat" u 1:3:(0.1) with yerrorbars pt 7 ps 0.6 title "32x32", "" u 1:3 w l lc 1  title "", "Ret_64.dat" u 1:3:(0.1) with yerrorbars pt 7 ps 0.6 title "64x64", "" u 1:3 w l lc 3  title "", "Ret_128.dat" u 1:3:(0.1) with yerrorbars pt 7 ps 0.6  title "128x128", "" u 1:3 w l lc 5 title ""#, "Ret_256.dat" u 1:3:(0.1) with yerrorbars pt 7 ps 0.6 title "256x256", "" u 1:3 w l lc 7 title "", "Ret_512.dat" u 1:3:(0.1) with yerrorbars pt 7 ps 0.6 title "512x512", "" u 1:3 w l lc 9 title ""
	
	#set origin 0.5,0
	#set size 0.5,0.5
	#set title "Persistenza"
	#set ylabel "SpinFlippati/TOTSPIN"
	#set xlabel "Iterazioni"
	#set xrange [0:50]
	#plot "Flip_512.dat" u 1:2 w lp pt 7 ps 1 title "512x512"

unset multiplot
