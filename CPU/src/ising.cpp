#include <stdlib.h>
#include <stdio.h>
#include <cstdlib>
#include <string>
#include <cmath>
#include <iostream>
#include <ctime>
#include <sys/time.h>
#include "xorshift.h"

#define DIM 2
#define TERM_STEP 1000

using namespace std;

double getTime(){
	struct timeval tp;
	static double last_timestamp = 0.0;
	double timestamp;
	gettimeofday (&tp, 0);
	timestamp = (double) tp.tv_sec * 1e6 + tp.tv_usec;
	return timestamp;
}




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
	public:
		ising_lattice(int N, string init, double BETA=0.44) : size_(N), J_(1), beta_(BETA) {
			s_ = (int*)malloc(N*N*sizeof(int));
			sf_ = (int*)malloc(N*N*sizeof(int));
			if(init == "rnd"){
				for(int i=0; i<N*N; ++i){
					if(rand()/((double)RAND_MAX) < 0.5){
						s_[i] = -1;
					}else{
						s_[i] = 1;
					}
				}
			}else if(init == "1" ){
				for(int i=0; i<N*N; ++i){
					s_[i]=1;
					sf_[i]=1;
				}
			}else if(init == "-1"){
				for(int i=0; i<N*N; ++i){
					s_[i]=-1;
					sf_[i]=-1;
				}
			}
			boltz_ = (double*)malloc((4*DIM+1)*sizeof(double));
			for(int i=-2*DIM; i<=2*DIM; i++) boltz_[i+2*DIM] = min(1.0,exp(-2*beta_*J_*i));
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
			r_t_=0;
			for(int y=0; y<size_; ++y){
				for(int x=0; x<size_; ++x){
					int ide = s_[size_*y+x]*(s_[size_*y+((x==0)?size_-1:x-1)]+s_[size_*y+((x==size_-1)?0:x+1)]+s_[size_*((y==0)?size_-1:y-1)+x]+s_[size_*((y==size_-1)?0:y+1)+x]);
					//double r = rand()/(double)RAND_MAX;
					double r = MTGPU(&seed_a_,&seed_b_,&seed_c_,&seed_d_);
					if(ide <= 0 || r < boltz_[ide+2*DIM]){
						s_[size_*y+x] = -s_[size_*y+x];
						++ok_;
						++r_t_;
						de_ -= 2*ide;
					}
				}
			}
			E_+=de_;
			r_t_/=((double)size_*size_);
			de_=0;
		}//END do_update


		int get_ok_MC(){
			return ok_;
		}//END getok 
		
		
		double get_energy(){
			return E_;
		}//END get energy;
		
		
		
		double get_magnetization_p_s(){
			M_=0;
			for(int i=0; i< size_*size_; ++i)
				M_ += s_[i];
			if(M_<0) M_*=-1;
			return M_/(size_*size_);
		}//END get mag


		void get_lattice(){
			for(int i=0; i< size_; ++i){
				for(int k=0; k< size_; ++k)
					printf(" %i ", s_[k+size_*i]);
				printf("\n");
			}
		}//END print lattice

		double get_order_par(){
			return r_t_;
		}
		



};//END Class 



int main(int argc, char**argv){
	
	//argv1 -> size;
	//argv2 -> initialization;
	//argv3 -> beta;
	//argv4 -> montecarlo step;
	
	ising_lattice s(atoi(argv[1]),argv[2],atof(argv[3]));
	
	double start = getTime();
	for(int i=0; i < TERM_STEP; ++i)
		s.do_update();
	
	double M=0;
	double E=0;
	double E2=0;
	double e=0;
	double e2=0;
	double m=0;
	double chi_sqr=0;
	double chi_sqr_2=0;
	double chi_sqr_m=0;
	double beta = atof(argv[3]);
	double size = (double)atoi(argv[1]);
	for(int i=0; i<atoi(argv[4]); i++){
		s.do_update();
		m=s.get_magnetization_p_s();
		e=s.get_energy();
		e2=pow(e,2);
		M+=m;
		E+=e;
		E2+=e2;
		chi_sqr+=pow(E/(i+1)-e,2.);
		chi_sqr_2+=pow(E2/(i+1)-e2,2.);
		chi_sqr_m+=pow(M/(i+1)-m,2.);
	}
	double end = getTime();
	E/=(double)atoi(argv[4]);
	E2/=(double)atoi(argv[4]);
	double sigma_E  = pow(chi_sqr/((double)atoi(argv[4])),0.5);
	double sigma_E2 = pow(chi_sqr_2/((double)atoi(argv[4])),0.5);
	double sigma_m  = pow(chi_sqr_m/((double)atoi(argv[4])),0.5);
	double err_per=0.5*(sigma_E/E+sigma_E2/E2);	
	double Cal_Spec=(1/(size*size)*(beta*beta)*(E2-E*E));

	printf("%f\t%f\t%f\t%f\t%f\n",atof(argv[3]), M/=(double)atoi(argv[4]), Cal_Spec, err_per*Cal_Spec , sigma_m ); //rifare la parte di errore, è sbagliata.
	//printf("Flip %i / %i\n",s.get_ok_MC(),(TERM_STEP+atoi(argv[4]))*atoi(argv[1])*atoi(argv[1]));
	//printf("%f\t%f\n", size, (end-start)/((double)(size*size)*(TERM_STEP+atoi(argv[4]))));
	return 0;


	/*for(int i=0; i<atoi(argv[4]); ++i){
		s.do_update();
		printf("%i\t%f\n",i,s.get_order_par());
	}*/

}




