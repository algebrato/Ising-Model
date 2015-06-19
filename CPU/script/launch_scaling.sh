#!/bin/bash

#Variazione di beta

STEP_MC=10000
INIT=1
SIZE=$1

for k in $(</home/$USER/Ising-Model/temp.dat);
do
	/home/$USER/Ising-Model/CPU/src/ising_CPU.x $SIZE $INIT $k $STEP_MC >> /home/$USER/Ising-Model/CPU/Ret_$SIZE.dat
done


exit 0;
