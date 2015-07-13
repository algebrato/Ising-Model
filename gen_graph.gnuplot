#!/usr/bin/gnuplot

set terminal pdf fontscale 0.7 size 6,6 enhanced
set output "CPU-GPU-time.pdf"
set origin 0,0
set size 1,1
set ylabel "Tempo per proposta di spin flip [ms]"
set xlabel "Size (lato)"
set title "Tempo necessario per proporre un update di uno spin"
set logscale x
set logscale y
plot "Time_cpu.dat"  w lp pt 7 ps 1 lt 1 lw 4 title "Dati CPU", "Time_gpu.dat" w lp pt 7 ps 1 lt 2 lw 4 title "Dati GPU - Global Memory", "Time_gpu_shared.dat" w lp pt 7 ps 1 lt 3 lw 4 title "Dati GPU - Sahred Memory", "Time_gpu_curand.dat" w lp pt 7 ps 1 lt 9 lw 4 title "Dati GPU - Curand"
