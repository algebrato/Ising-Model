#include<stdlib.h>
#include<stdio.h>
#include<GL/glut.h>

#define L 1024
#define SIZE 1
#define BLACK (0.0, 0.0, 1.0)
#define WHITE (1.0, 0.0, 0.0)

void init(){
	glClearColor (0.0, 0.0, 0.0, 0.0);
	glShadeModel (GL_FLAT);
}


void draw_lattice(){
	int x=0;
	int y=0;
	int color=0;

	int FF[L][L];
	int scan=0;
	int spin_lattice;
	FILE *LATTICE_R;

	LATTICE_R=fopen("lattice.dat","r");
	
	for(int i=0; i<L; i++)
		for(int k=0; k<L; k++){
			scan=fscanf(LATTICE_R,"%i\t",&spin_lattice);
			FF[i][k]=spin_lattice;
		}
	glClear (GL_COLOR_BUFFER_BIT);
	glColor3f BLACK;
	for(x=0;x<L;x++){
		if(FF[y][x] == -1)
			glColor3f BLACK;
		else
			glColor3f WHITE;
		for(y=0; y<L; y++){
			if(FF[y][x] == -1)
				glColor3f BLACK;
			else
				glColor3f WHITE;
			glBegin(GL_QUADS);
			glVertex2f(SIZE+SIZE*x, SIZE+SIZE*y);
			glVertex2f(SIZE*x,SIZE+SIZE*y);
			glVertex2f(SIZE*x, SIZE*y);
			glVertex2f(SIZE+SIZE*x, SIZE*y);
			glEnd();
		}
	}
	glFlush();

}


void reshape (int w, int h){
	glViewport (0, 0, (GLsizei) w, (GLsizei) h);
	glMatrixMode (GL_PROJECTION);
	glLoadIdentity ();
	gluOrtho2D (0.0, (GLdouble) w, 0.0, (GLdouble) h);
}



int start(int argc, char **argv){
	glutInit(&argc, argv);
	glutInitDisplayMode (GLUT_SINGLE | GLUT_RGB);
	glutInitWindowSize(L, L);
	glutInitWindowPosition (0,0);
	glutCreateWindow ("Final Lattice");
	init();
	
		glutDisplayFunc(draw_lattice);
		glutReshapeFunc(reshape);
		glutPostRedisplay();
	
	glutMainLoop();
}
