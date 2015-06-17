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
OBJ		:= ising.o 
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

${ESEGUIBILE}: ${OBJ}
	$(NVCC) ${FLAGS} ${ARCH} ${LIBS} -o $@ $^	

endif


.PHONY: clean

clean:
	rm -rf *.out *.x *.o


