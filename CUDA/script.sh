#!/bin/bash

. /home/algebrato/.colors

SIZE=$1
STEP_MC=$2

echo "SIZE: $SIZE "
echo "STEP: $STEP_MC"

for i in $(<temp.dat);do 
	./ising_cu.x $i $STEP_MC >> Ret_$SIZE.dat
	printf "\033[K"
	echo -e "End sessione beta: $GREEN $i $NO_COL"
	printf "\033[1A"
done
