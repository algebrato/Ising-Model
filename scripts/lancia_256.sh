#!/bin/bash

EXE="new_ising_256.x"

for i in $(<temp.dat) 
do
	./$EXE 256/Reticolo_256_B$i.dat 256/Mag_256_B$i.dat $i
	sleep 2
done

nodo=`hostname`
echo "Fine Job sul nodo $nodo" | mail -s "Fine Job sul nodo $nodo" linuxfree2@gmail.com


exit 0


