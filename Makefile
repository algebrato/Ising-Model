VERSION 	= 0
PATHLEVEL	= 1
SUBLEVEL	= 0
EXTRAVERSION 	= 
NAME		= Ising Model - Stefano Mandelli
DATE		= 24-Giugno-2013
## Switch #######################################
#################################################

all:
	cd src; make
	cd render_out; make

.PHONY: clean
clean:
	rm -rf obj/*.o *.x
