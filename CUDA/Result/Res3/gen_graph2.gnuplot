#!/usr/bin/gnuplot

set terminal pdf fontscale 0.7 size 12,18 enhanced
set output "Ising_Mag_Cv_curand.pdf"
set multiplot
	set origin 0,0.66
	set size 0.5,0.33
	set ylabel "Magnetizzazione per Spin"
	set title "Magnetizzazione"
	set yrange [0:1]
	set xrange [0.25:0.6]
	plot "Ret_64.dat" u 1:2:5 with yerrorbars pt 7 ps 0.6 title "64x64-xorshift", "" u 1:2 w l lc 1  title "", "Ret_64_cur.dat" u 1:2:5 with yerrorbars pt 7 ps 0.6 title "64x64-curand", "" u 1:2 w l lc 5  title ""

	set origin 0,0.33
	set size 0.5,0.33
	set ylabel "Magnetizzazione per Spin"
	set title "Magnetizzazione"
	set yrange [0:1]
	set xrange [0.25:0.6]
	plot "Ret_128.dat" u 1:2:5 with yerrorbars pt 7 ps 0.6 title "128x128-xorshift", "" u 1:2 w l lc 1  title "", "Ret_128_cur.dat" u 1:2:5 with yerrorbars pt 7 ps 0.6 title "128x128-curand", "" u 1:2 w l lc 5  title ""


	set origin 0,0
	set size 0.5,0.33
	set ylabel "Magnetizzazione per Spin"
	set title "Magnetizzazione"
	set yrange [0:1]
	set xrange [0.25:0.6]
	plot "Ret_512.dat" u 1:2:5 with yerrorbars pt 7 ps 0.6 title "512x512-xorshift", "" u 1:2 w l lc 1  title "", "Ret_512_cur.dat" u 1:2:5 with yerrorbars pt 7 ps 0.6 title "512x512-curand", "" u 1:2 w l lc 5  title ""



#"Ret_128.dat" u 1:2:5 with yerrorbars pt 7 ps 0.6  title "128x128-xorshift", "" u 1:2 w l lc 3 title "", "Ret_64_cur.dat" u 1:2:5 with yerrorbars pt 7 ps 0.6 title "64x64-curand", "" u 1:2 w l lc 5  title "", "Ret_128_cur.dat" u 1:2:5 with yerrorbars pt 7 ps 0.6  title "128x128-curand", "" u 1:2 w l lc 7 title "", "Ret_512.dat" u 1:2:5 with yerrorbars pt 9 ps 0.6 title "512x512-xorshift", "" u 1:2 w l lc 1  title "", "Ret_512_cur.dat" u 1:2:5 with yerrorbars pt 7 ps 0.6 title "512x512-curand", "" u 1:2 w l lc 11  title "",  "../../../Relazione/onsager_J_1.dat" title "Onsager" w l lt 0 lw 10


#Specific Heat
	set origin 0.5,0.66
	set size 0.5,0.33
	set autoscale
	set yrange [0:3]
	set xrange [0:0.7]
	set ylabel "Calore specifico per Spin"
	set title "Calore Specifico"
	plot "Ret_64.dat" u 1:3:4 with yerrorbars pt 7 ps 0.6 title "64x64-xorshift", "" u 1:3 w l lc 1  title "", "Ret_64_cur.dat" u 1:3:4 with yerrorbars pt 7 ps 0.6 title "64x64-curand", "" u 1:3 w l lc 5  title ""

	set origin 0.5,0.33
	set size 0.5,0.33
	set autoscale
	set yrange [0:3]
	set xrange [0:0.7]
	set ylabel "Calore specifico per Spin"
	set title "Calore Specifico"
	plot "Ret_128.dat" u 1:3:4 with yerrorbars pt 7 ps 0.6 title "128x128-xorshift", "" u 1:3 w l lc 1  title "", "Ret_128_cur.dat" u 1:3:4 with yerrorbars pt 7 ps 0.6 title "128x128-curand", "" u 1:3 w l lc 5  title ""

	set origin 0.5,0
	set size 0.5,0.33
	set autoscale
	set yrange [0:3]
	set xrange [0:0.7]
	set ylabel "Calore specifico per Spin"
	set title "Calore Specifico"
	plot "Ret_512.dat" u 1:3:4 with yerrorbars pt 7 ps 0.6 title "512x512-xorshift", "" u 1:3 w l lc 1  title "", "Ret_512_cur.dat" u 1:3:4 with yerrorbars pt 7 ps 0.6 title "512x512-curand", "" u 1:3 w l lc 5  title ""




# "Ret_128.dat" u 1:3:4 with yerrorbars pt 7 ps 0.6  title "128x128-xorshift", "" u 1:3 w l lc 3 title "", "Ret_64_cur.dat" u 1:3:4 with yerrorbars pt 7 ps 0.6 title "64x64-curand", "" u 1:3 w l lc 5  title "", "Ret_128_cur.dat" u 1:3:4 with yerrorbars pt 7 ps 0.6  title "128x128-curand", "" u 1:3 w l lc 7 title "", "Ret_512.dat" u 1:3:4 with yerrorbars pt 7 ps 0.6  title "512x512-xorshift", "Ret_512_cur.dat" u 1:3:4 with yerrorbars pt 7 ps 0.6  title "512x512-curand", "" u 1:3 w l lc 7 title "", "" u 1:3 w l lc 3 title "", "../../../Relazione/Onsager_spec_heat.dat" title "Onsager" w l lt 0 lw 10
	
unset multiplot
