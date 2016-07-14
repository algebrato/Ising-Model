#include<stdlib.h>
#include<stdio.h>
#include<GL/glut.h>
#include<time.h>
#include <cmath>
#include<ctime>
#include<unistd.h>
#include "xorshift.h"
#define DIM 2
#define SIZE 1024
#define MIN(a,b) (a<b)?a:b


class ising_lattice {
	private:
		int *s_;
		int *sf_;
		int size_;
		double *boltz_;
		double beta_;
		int J_;
		double r_t_;  // frazione di spin flippati in un singolo update
		double M_;
		double E_;
		double E_2_;
		double de_;
		unsigned int seed_a_;
		unsigned int seed_b_;
		unsigned int seed_c_;
		unsigned int seed_d_;
		int ok_;
		double corr_len_;
		double corr_len_R;
		double corr_len_2R;
	public:
		ising_lattice(int N=SIZE,double BETA=0.6) : size_(N), J_(1), beta_(BETA) {
			s_ = (int*)malloc(N*N*sizeof(int));
			sf_ = (int*)malloc(N*N*sizeof(int));
			for(int i=0; i<N*N; ++i){
				if(rand()/((double)RAND_MAX) < 0.5){
					s_[i] = -1;
				}else{
					s_[i] = 1;
				}
			}
			boltz_ = (double*)malloc((4*DIM+1)*sizeof(double));
			for(int i=-2*DIM; i<=2*DIM; i++) boltz_[i+2*DIM] = MIN(1.0,exp(-2*beta_*J_*i));
		
			seed_a_=2678936131;
			seed_b_=1801065994;
			seed_c_=3925136598;
			seed_d_=285088606;

			ok_=0;
			r_t_=0;
			E_=0;
			
			for(int x = 0; x < size_; ++x)
				for(int y = 0; y < size_; ++y)
					E_ += s_[size_*y+x]*(s_[size_*y+((x==0)?size_-1:x-1)]+s_[size_*y+((x==size_-1)?0:x+1)]+s_[size_*((y==0)?size_-1:y-1)+x]+s_[size_*((y==size_-1)?0:y+1)+x]);
			E_/=2.;

		}//END CTOR



	
		void do_update(){
			int y,x;
			r_t_=0;
			for(int a=0; a<size_; ++a){
				for(int b=0; b<size_; ++b){
					x=rand() % size_;
					y=rand() % size_;
					
					int ide = s_[size_*y+x]*(s_[size_*y+((x==0)?size_-1:x-1)]+s_[size_*y+((x==size_-1)?0:x+1)]+s_[size_*((y==0)?size_-1:y-1)+x]+s_[size_*((y==size_-1)?0:y+1)+x]);
					//double r = rand()/(double)RAND_MAX;
					//double r = drand48();
					double r = MTGPU(&seed_a_,&seed_b_,&seed_c_,&seed_d_);
					if(ide <= 0 || r < boltz_[ide+2*DIM]){
						s_[size_*y+x] = -s_[size_*y+x];
						++ok_;
						++r_t_;
						de_ -= 2*ide;
					}
					//printf("%i\t%i\t%f\n",x,y,r);
				}
			}
			E_+=de_;
			r_t_/=((double)size_*size_);
			de_=0;
		}//END do_update

		void do_corr_len(){
				
			M_=0;
			corr_len_R=0;
			corr_len_2R=0;
			
			for(int i=0; i< size_*size_; ++i)
						M_ += s_[i];
			M_/=((double)size_*size_);

			for(int y=0; y<size_; ++y)
					for(int x=0; x<size_; ++x)
							corr_len_R += s_[(y*size_+x)]*s_[0];

			for(int y=0; y<size_/2; ++y)
					for(int x=0; x<size_; ++x)
							corr_len_2R += s_[(2*y*size_+x)]*s_[0];
				
			corr_len_ = (corr_len_R/((double)size_*size_) ) / (corr_len_2R/((double)size_*size_));
		}//END do_corr_len


		int get_ok_MC(){
			return ok_;
		}//END getok 
		
		
		double get_energy(){
			return E_;
		}//END get energy;
		
		
		double get_magnetization_p_s(){
			if(M_<0) 
				M_*=-1;
			return M_;
		}//END get mag

		double get_corr_len(){
				return corr_len_;
		}//END get corr len

		int *get_lattice(){
				return s_;
			}

		double get_order_par(){
			return r_t_;
		}
		



};//END Class 



void init(){
	glClearColor(0, 1, 1, 0);
	glMatrixMode(GL_PROJECTION);
	gluOrtho2D(0, SIZE, 0, SIZE);
}

void drawSquare(GLint x1, GLint y1, GLint x2, GLint y2, GLint x3, GLint y3, GLint x4, GLint y4, int si){
		if (si == 1){
			glColor3f(1, 1, 1); // white color value is 1 1 1
		}
		else{
			glColor3f(0, 0, 0); // black color value is 0 0 0
		}
		glBegin(GL_POLYGON);
		glVertex2i(x1, y1);
		glVertex2i(x2, y2);
		glVertex2i(x3, y3);
		glVertex2i(x4, y4);
		glEnd();
}

ising_lattice s(SIZE,0.1);


void chessboard(){
		s.do_update();
		int *si=s.get_lattice();
		int spin;
		
		glClear(GL_COLOR_BUFFER_BIT); // Clear display window
		GLint x, y;

		for (x = 0; x < SIZE; x++){
				for (y = 0; y < SIZE; y++){
						spin=si[x+SIZE*y];
						drawSquare(x, y + 2, x + 2, y + 2, x + 2, y, x, y,spin);
				}
		}
		glFlush();
}

void glutTimer(int value)
{
		glutPostRedisplay();
		glutTimerFunc(1, glutTimer, 1);
}

int main(int agrc, char ** argv)
{
		glutInit(&agrc, argv);
		glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);
		glutInitWindowPosition(0, 0);
		glutInitWindowSize(SIZE, SIZE);
		glutCreateWindow("Bidimensional Ising Lattice");
		init();
		glutDisplayFunc(chessboard);
		glutTimerFunc(10, glutTimer, 10);
		glutMainLoop();
}
