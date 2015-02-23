#!/bin/bash

echo -n "Size: "
read size
echo -n "Elapse time: "
read elapse

for i in $(seq 0 100); do 
	clear
       	$size/GEN_GRAPH/make_graph.x $size/Energie.dat $size/cal_spec.dat $size
	
	gnuplot $size/script.gpl

	sleep $elapse


done





