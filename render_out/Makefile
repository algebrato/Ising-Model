CC 	:= g++
OBJ	:= ../obj/cpu_visualizzation.o ../obj/render.o
LIBS	:= -lGL -lGLU -lglut
EXE	:= ../visualizza.x


../obj/%.o : %.cpp
	$(CC) -c $< -o $@

${EXE}: ${OBJ} 
	$(CC) ${LIBS}  -o $@ $^	

