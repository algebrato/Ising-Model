#!/bin/bash

EXE="new_ising_4096.x"

for i in $(<temp.dat) 
do
	./$EXE 4096/Reticolo_4096_B$i.dat 4096/Mag_4096_B$i.dat $i
	sleep 2
done

nodo=`hostname`
echo "Fine Job sul nodo $nodo" | mail -s "Fine Job sul nodo $nodo" linuxfree2@gmail.com


exit 0


