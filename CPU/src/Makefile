VERSION 	= 0
PATHLEVEL	= 1
SUBLEVEL	= 0
EXTRAVERSION 	= 
NAME		= Ising Model - Stefano Mandelli
## Switch #######################################
DEVICE		:=true
DEBUGMODE	:= true
#################################################


#Makefile for the Device ########################

ifdef DEVICE
NVCC		:= nvcc -G
ESEGUIBILE	:= ising_CPU.x
OBJ		:= ising.o xorshift.o
CC		:= g++

ifdef DEBUGMODE
FLAGS 		:= -O2 -g 
LIBS		:= 
INC		:= 
else
FLAGS		:= -O2
LIBS		:=
INC		:=
endif

%.o : %.cpp
	$(CC) ${LIBS} ${FLAGS} -c $< -o $@

${ESEGUIBILE}: ${OBJ}
	$(CC) ${LIBS} ${FLAGS} -o $@ $^	

endif


.PHONY: clean

clean:
	rm -rf *.out *.x *.o


