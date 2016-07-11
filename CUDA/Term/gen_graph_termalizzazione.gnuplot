#!/usr/bin/gnuplot

set terminal pdf fontscale 0.8 size 12,12 enhanced linewidth 7
set output "Term_step_GPU_04.pdf"
set multiplot
	set xrange [-1000:10000]
	set style line 1 linewidth 3
	set origin 0,0.5
	set size 0.5,0.5
	set yrange [0:1.1]
	set ylabel "Magnetizzazione per spin"
	set xlabel "Numero di Step"
	set title "Confronto termalizzazione {/Symbol b = 0.4}"
	plot "Term_04_LCG.dat" u 2 title "LCG - {/Symbol b = 0.4}" w l, "Term_04_XOR.dat" u 2 pt 7 ps 0.6 title "XorShift {/Symbol b = 0.4}" w l

	set style line 1 linewidth 3
	set yrange [15000:34000]
	set origin 0,0
	set size 0.5,0.5
	set ylabel "Energia del sistema"
	set xlabel "Numero di Step"
	set title "Confronto termalizzazione {/Symbol b = 0.4}"
	plot "Term_04_LCG.dat" u 3 title "LCG - {/Symbol b = 0.4}" w l, "Term_04_XOR.dat" u 3 pt 7 ps 0.6 title "XorShift {/Symbol b = 0.4}" w l


	set origin 0.5,0.5
	set size 0.5,0.5
	set ylabel "Magnetizzazione per spin"
	set xlabel "Numero di Step"
	set yrange [0:1.05]
	set title "Confronto termalizzazione {/Symbol b = 0.6}"
	plot "Term_06_LCG.dat" u 2 title "LCG - {/Symbol b = 0.6}" w l, "Term_06_XOR.dat" u 2 pt 7 ps 0.6 title "XorShift {/Symbol b = 0.6}" w l

	set origin 0.5,0
	set yrange [15000:34000]
	set size 0.5,0.5
	set ylabel "Energia del sistema"
	set xlabel "Numero di Step"
	set title "Confronto termalizzazione {/Symbol b = 0.6}"
	plot "Term_06_LCG.dat" u 3 title "LCG - {/Symbol b = 0.6}" w l, "Term_06_XOR.dat" u 3 pt 7 ps 0.6 title "XorShift {/Symbol b = 0.6}" w l




unset multiplot
