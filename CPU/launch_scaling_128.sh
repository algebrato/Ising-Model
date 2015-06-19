#!/bin/bash

#Variazione di beta

STEP_MC=10000
INIT=1
SIZE=128

for i in 128;
do
	for k in $(<temp.dat);
	do
		/home/algebrato/Ising-Model/CPU/ising_CPU.x $i $INIT $k $STEP_MC >> Ret_$i.dat
	done
done

exit 0