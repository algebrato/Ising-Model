VERSION 	= 0
PATHLEVEL	= 1
SUBLEVEL	= 0
EXTRAVERSION 	= 
NAME		= Ising Model - Stefano Mandelli
DATE		= 24-Giugno-2013
SRCDIR		= src
## Switch #######################################
DEVICE		:=true
DEBUGMODE	:= true
#################################################


#Makefile for the Device ########################

ifdef DEVICE
NVCC		:= nvcc -G
ESEGUIBILE	:= ising_cu.x 
OBJ		:= ising.o fill_ran.o get_time.o
CC		:= g++

ifdef DEBUGMODE
FLAGS 		:= -O2 -g 
ARCH 		:= -arch=sm_20
LIBS		:= -lGL -lGLU -lglut -lcurand
INC		:= -I/home/algebrato/NVIDIA_GPU_Computing_SDK/CUDALibraries/common/inc/ -I/home/algebrato/NVIDIA_GPU_Computing_SDK/shared/inc/
else
FLAGS		:= -O2
ARCH		:= -arch=sm_20
LIBS		:= -lGL -lGLU -lglut -lcurand
INC		:= -I/home/algebrato/NVIDIA_GPU_Computing_SDK/CUDALibraries/common/inc/ -I/home/algebrato/NVIDIA_GPU_Computing_SDK/shared/inc/
endif

%.o : %.cpp
	$(CC) ${LIBS} ${FLAGS}  -c $< -o $@

%.o : %.cu
	$(NVCC) ${FLAGS} ${ARCH} ${LIBS} -c $< -o $@

${ESEGUIBILE}: ${OBJ}
	$(NVCC) ${FLAGS} ${ARCH} ${LIBS} -o $@ $^	

.PHONY: clean

clean:
	rm -rf *.x *.o

endif

