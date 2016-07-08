#!/usr/bin/gnuplot

set terminal pdf fontscale 1.2 size 12,7 enhanced
set output "CPU-GPU-time.pdf"
set origin 0,0
set size 1,1
set yrange [0.005:1]
set ylabel "Tempo per proposta di spin flip [ms]"
set xlabel "Size (lato)"
set title "Tempo necessario per proporre un update di uno spin"
set logscale x
set logscale y
plot "Time_cpu.dat"  w lp pt 7 ps 1 lt 1 lw 4 title "Dati CPU", "Time_gpu_shared.dat" w lp pt 7 ps 1 lt 3 lw 4 title "Dati GPU - Sahred Memory", "Time_gpu.dat" w lp pt 7 ps 1 lt 5 lw 4 title "Dati GPU - Global Memory"
