#!/bin/bash

EXE="new_ising.x"

for i in $(<temp.dat) 
do
	./$EXE 128/Reticolo_128_B$i.dat 128/Mag_128_B$i.dat $i
	sleep 2
done

nodo=`hostname`
echo "Fine Job sul nodo $nodo" | mail -s "Fine Job sul nodo $nodo" linuxfree2@gmail.com


exit 0


