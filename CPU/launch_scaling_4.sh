#!/bin/bash

#Variazione di beta

STEP_MC=1000000
INIT=1
SIZE=16

for i in 256;
do
	for k in $(<temp.dat);
	do
		/home/algebrato/Ising-Model/CPU/ising_CPU.x $i $INIT $k $STEP_MC >> Ret_$i.dat


exit 0
