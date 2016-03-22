NVCC		:= nvcc -G
ESEGUIBILE	:= find_max 
OBJ		:= find_max.o
ARCH 		:= -arch=sm_20

%.o : %.cu
	$(NVCC) ${ARCH} -c $< -o $@

${ESEGUIBILE}: ${OBJ}
	$(NVCC) ${ARCH} -o $@ $^	

