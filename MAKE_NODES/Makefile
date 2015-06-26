CC    := g++
LIBS  := 
FLAGS := -O3
EXE1  := random_e6.x
EXE2  := random_ntl.x
OBJ1  := random_e6.o 
OBJ2  := random_ntl.o

%.o : %.cpp
	$(CC) ${LIBS} ${FLAGS}  -c $<

${EXE1}: ${OBJ1}
	$(CC) ${FLAGS} ${ARCH} ${LIBS} -o $@ $^

${EXE2}: ${OBJ2}
	$(CC) ${FLAGS} ${ARCH} ${LIBS} -o $@ $^

all: ${EXE1} ${EXE2}

.PHONY: clean

clean:
	rm -rf *.x *.o
