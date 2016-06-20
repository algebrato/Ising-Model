#include<iostream>
#include<stdlib.h>
#include<curand_kernel.h>
#include"xorshift.cu"
#include"fill_ran.h"
#include"get_time.h"
#include<time.h>
using namespace std;


#define H_D cudaMemcpyHostToDevice
#define D_H cudaMemcpyDeviceToHost

#define J 1
#define DIM 2
#define L 4096
#define BLOCKL 16
#define GRIDL  (L/BLOCKL)
#define BLOCKS ((GRIDL*GRIDL)/2)
#define THREADS ((BLOCKL*BLOCKL)/2)
#define N (L*L)
#define TOT_TH  (BLOCKS*THREADS) 
#define sS(x,y) sS[(y+1)*(BLOCKL+2)+x+1]

typedef int spin_t;
typedef unsigned int UI;


texture<float,1,cudaReadModeElementType> boltzT;

__global__ void get_magnetization(spin_t *s_, float *vec_mag){
	__shared__ spin_t sS[(BLOCKL)*(BLOCKL+1)];
	__shared__ float sum_part;

	sS[threadIdx.x + BLOCKL*threadIdx.y] = s_[(blockIdx.x*BLOCKL + threadIdx.x )+(blockIdx.y*BLOCKL*L + threadIdx.y*L)];
	__syncthreads();
	if(threadIdx.x == 0)
		if(threadIdx.y == 0){
			sum_part=0;
			for(int i=0; i<BLOCKL; i++)
				for(int k=0; k<BLOCKL; k++)
					sum_part += sS[i*BLOCKL+k];
			__syncthreads();
			vec_mag[blockIdx.x+blockIdx.y*GRIDL] = sum_part / (BLOCKL*BLOCKL);
		}
}


__global__ void do_update(spin_t *s_, UI *a, UI *b, UI *c, UI *d, UI offset, int *energie){
	int tidx = threadIdx.x + blockDim.x*blockIdx.x;
	int tidmy= threadIdx.y + blockDim.y*blockIdx.y;
	int tidy = 2*tidmy+(tidx+offset)%2;
	printf("%i\n",tidy);


	int ide = s_[L*tidy+tidx]*(s_[L*tidy+((tidx==0)?L-1:tidx-1)]+s_[L*tidy+((tidx==L-1)?0:tidx+1)]+s_[L*((tidy==0)?L-1:tidy-1)+tidx]+s_[L*((tidy==L-1)?0:tidy+1)+tidx]);

	//Inizializzo i semi
	unsigned int n = threadIdx.y*BLOCKL+threadIdx.x;
	//curandState localState = globalState[n];
	//float stopId = curand_uniform(&localState);
	unsigned int *aa = &a[(blockIdx.y*GRIDL+blockIdx.x)*THREADS+n];
	unsigned int *bb = &b[(blockIdx.y*GRIDL+blockIdx.x)*THREADS+n];
	unsigned int *cc = &c[(blockIdx.y*GRIDL+blockIdx.x)*THREADS+n];
	unsigned int *dd = &d[(blockIdx.y*GRIDL+blockIdx.x)*THREADS+n];
	
	__syncthreads();



	int ie=0;
	if(MTGPU(aa, bb, cc, dd) < tex1Dfetch(boltzT, ide+2*DIM)){
		s_[L*tidy+tidx] = -s_[L*tidy+tidx];
		ie -=2*ide;
	}
	
	__syncthreads();
	
	//globalState[n] = localState;
	a[(blockIdx.y*GRIDL+blockIdx.x)*THREADS+n] = *aa;
	b[(blockIdx.y*GRIDL+blockIdx.x)*THREADS+n] = *bb;
	c[(blockIdx.y*GRIDL+blockIdx.x)*THREADS+n] = *cc;
	d[(blockIdx.y*GRIDL+blockIdx.x)*THREADS+n] = *dd;
	

	__shared__ int deltaE[THREADS];
	deltaE[n] = ie;
	for(int stride = THREADS>>1; stride > 0 ; stride >>=1){
		__syncthreads();
		if(n < stride) deltaE[n] += deltaE[n+stride];
	}
	if(n == 0) energie[blockIdx.y*GRIDL+blockIdx.x] += deltaE[0];		

	__syncthreads();
}

__global__ void do_update_testB(spin_t *s, UI *a, UI offset, int *energie){
	//Qui ci vanno un po' di variabili per inizializzare MTGPU
	unsigned int n = threadIdx.y*BLOCKL+threadIdx.x;
	unsigned int *aa = &a[(blockIdx.y*GRIDL+blockIdx.x)*THREADS+n];
	//Fine*************

	LCG32(aa);

	a[(blockIdx.y*GRIDL+blockIdx.x)*THREADS+n] = *aa;

}

__global__ void do_update_shared(spin_t *s, UI *a, UI *b, UI *c, UI *d, UI offset, int *energie){


	unsigned int n = threadIdx.y*BLOCKL+threadIdx.x;
	unsigned int Xoffset = blockIdx.x*BLOCKL;
	unsigned int Yoffset = (2*blockIdx.y+(blockIdx.x+offset)%2)*BLOCKL;

	__shared__ spin_t sS[(BLOCKL+2)*(BLOCKL+2)];

	//se non sono sui bordi completo con la doppia scacchiera
	sS[(2*threadIdx.y+1)*(BLOCKL+2)+threadIdx.x+1] = s[(Yoffset+2*threadIdx.y)*L+(Xoffset+threadIdx.x)];
	sS[(2*threadIdx.y+2)*(BLOCKL+2)+threadIdx.x+1] = s[(Yoffset+2*threadIdx.y+1)*L+(Xoffset+threadIdx.x)];
	
	//bordo in alto
	/*if(threadIdx.y == 0)
		sS[threadIdx.x+1] = (Yoffset == 0) ? s[(L-1)*L+Xoffset+threadIdx.x] : s[(Yoffset-1)*L+Xoffset+threadIdx.x];
	if(threadIdx.y == (BLOCKL/2)-1)
		sS[(BLOCKL+1)*(BLOCKL+2)+(threadIdx.x+1)] = (Yoffset == L-BLOCKL) ? s[Xoffset+threadIdx.x] : s[(Yoffset+BLOCKL)*L+Xoffset+threadIdx.x];
	
	
	if(threadIdx.x == 0){
		if(blockIdx.x == 0){
			sS[(2*threadIdx.y+1)*(BLOCKL+2)] = s[(Yoffset+2*threadIdx.y)*L+(L-1)];
			sS[(2*threadIdx.y+2)*(BLOCKL+2)] = s[(Yoffset+2*threadIdx.y+1)*L+(L-1)];
		}
		else{
			sS[(2*threadIdx.y+1)*(BLOCKL+2)] = s[(Yoffset+2*threadIdx.y)*L+(Xoffset-1)];
			sS[(2*threadIdx.y+2)*(BLOCKL+2)] = s[(Yoffset+2*threadIdx.y+1)*L+(Xoffset-1)];
		}
	}

	if(threadIdx.x == BLOCKL-1){
		if(blockIdx.x == GRIDL-1){
			sS[(2*threadIdx.y+1)*(BLOCKL+2)+BLOCKL+1] = s[(Yoffset+2*threadIdx.y)*L];
			sS[(2*threadIdx.y+2)*(BLOCKL+2)+BLOCKL+1] = s[(Yoffset+2*threadIdx.y+1)*L];
		}
		else{
			sS[(2*threadIdx.y+1)*(BLOCKL+2)+BLOCKL+1] = s[(Yoffset+2*threadIdx.y)*L+Xoffset+BLOCKL];
			sS[(2*threadIdx.y+2)*(BLOCKL+2)+BLOCKL+1] = s[(Yoffset+2*threadIdx.y+1)*L+Xoffset+BLOCKL];
		}
	}
	__syncthreads();*/

	//Qui ci vanno un po' di variabili per inizializzare MTGPU
	unsigned int *aa = &a[(blockIdx.y*GRIDL+blockIdx.x)*THREADS+n];
	unsigned int *bb = &b[(blockIdx.y*GRIDL+blockIdx.x)*THREADS+n];
	unsigned int *cc = &c[(blockIdx.y*GRIDL+blockIdx.x)*THREADS+n];
	unsigned int *dd = &d[(blockIdx.y*GRIDL+blockIdx.x)*THREADS+n];
	//Fine*************
	int ie=0;
	unsigned int x = threadIdx.x;
	unsigned int y1= 2*threadIdx.y+(threadIdx.x%2);
        unsigned int y2= 2*threadIdx.y+((threadIdx.x+1)%2);
		
		int ide = sS(x,y1)*(sS(x-1,y1)+sS(x+1,y1)+sS(x,y1+1)+sS(x,y1-1));
		if(MTGPU(aa, bb, cc, dd) < tex1Dfetch(boltzT, ide+2*DIM)){
			sS(x,y1) = -sS(x,y1);
			ie -=2*ide;
		}
		__syncthreads();
		
		ide = sS(x,y2)*(sS(x-1,y2)+sS(x+1,y2)+sS(x,y2+1)+sS(x,y2-1));
		if(MTGPU(aa, bb, cc, dd) < tex1Dfetch(boltzT, ide+2*DIM)){
			sS(x,y2) = -sS(x,y2);
			ie -= 2*ide;
		}
		__syncthreads();

		s[(Yoffset+2*threadIdx.y)*L+Xoffset+threadIdx.x] = sS[(2*threadIdx.y+1)*(BLOCKL+2)+threadIdx.x+1];
		s[(Yoffset+2*threadIdx.y+1)*L+Xoffset+threadIdx.x] = sS[(2*threadIdx.y+2)*(BLOCKL+2)+threadIdx.x+1];
		a[(blockIdx.y*GRIDL+blockIdx.x)*THREADS+n] = *aa;
		b[(blockIdx.y*GRIDL+blockIdx.x)*THREADS+n] = *bb;
		c[(blockIdx.y*GRIDL+blockIdx.x)*THREADS+n] = *cc;
		d[(blockIdx.y*GRIDL+blockIdx.x)*THREADS+n] = *dd;
	
		__shared__ int deltaE[THREADS];
		deltaE[n] = ie;
		for(int stride = THREADS>>1; stride > 0 ; stride >>=1){
			__syncthreads();
			if(n < stride) deltaE[n] += deltaE[n+stride];
		}
		if(n == 0) energie[blockIdx.y*GRIDL+blockIdx.x] += deltaE[0];
		__syncthreads();

}



void get_lattice(spin_t *s_){
	for(int y=0; y<L; ++y){
		for(int x=0; x<L; ++x)
			printf("%i\t",s_[y*L+x]);
		printf("\n");
	}

}

int cpu_energy(spin_t *s){
        int ie = 0;
        for(int x = 0; x < L; ++x)
                for(int y = 0; y < L; ++y)
                        ie += s[L*y+x]*(s[L*y+((x==0)?L-1:x-1)]+s[L*y+((x==L-1)?0:x+1)]+s[L*((y==0)?L-1:y-1)+x]+s[L*((y==L-1)?0:y+1)+x]);
        return ie/2;
}


/*__global__ void setup_kernel ( curandState * state, unsigned long seed ){
	int id = threadIdx.x  + blockIdx.x + blockDim.x;
	curand_init ( seed, id , id, &state[id] );
}*/



int main(int argc, char**argv){
	cudaSetDevice(1);
	spin_t *s, *sD;
	UI *a, *a_d, *b, *b_d, *c, *c_d, *d, *d_d;
	float *vec_mag, *vec_mag_d;
	int *energie, *energie_d;	
	time_t t;
	time(&t);

	dim3 grid(GRIDL, GRIDL/2);
	dim3 block(BLOCKL, BLOCKL/2);
	dim3 gridRES(GRIDL, GRIDL);
	dim3 blockRES(BLOCKL, BLOCKL);
	
	/*curandState* devStates;
	cudaMalloc ( &devStates, TOT_TH*sizeof( curandState ) );
	setup_kernel <<< grid, block >>> ( devStates, (unsigned long) t );*/


	float BETA    = atof(argv[1]);
	int   STEP_MC = atoi(argv[2]);
	float boltzGPU[4*DIM+1];
	
	for(int i=-2*DIM; i<=2*DIM; i++){
		boltzGPU[i+2*DIM] = min(1.0,exp(-2*BETA*J*i));
	}

	float *boltzTex;
	cudaMalloc((void**)&boltzTex, (4*DIM+1)*sizeof(float));
	cudaMemcpy(boltzTex, boltzGPU,(4*DIM+1)*sizeof(float), H_D);
	cudaBindTexture(NULL, boltzT, boltzTex, (4*DIM+1)*sizeof(float));

	a=(unsigned int*)malloc(TOT_TH*2*sizeof(unsigned int));
	b=(unsigned int*)malloc(TOT_TH*2*sizeof(unsigned int));
	c=(unsigned int*)malloc(TOT_TH*2*sizeof(unsigned int));
	d=(unsigned int*)malloc(TOT_TH*2*sizeof(unsigned int));
	

	fill_ran_vec4(a, b, c, d, TOT_TH);
	
	cudaMalloc((void**)&a_d, 2*TOT_TH*(sizeof(unsigned int)));
	cudaMalloc((void**)&b_d, 2*TOT_TH*(sizeof(unsigned int)));
	cudaMalloc((void**)&c_d, 2*TOT_TH*(sizeof(unsigned int)));
	cudaMalloc((void**)&d_d, 2*TOT_TH*(sizeof(unsigned int)));

	cudaMemcpy(a_d, a, TOT_TH*(sizeof(unsigned int)), H_D);
	cudaMemcpy(b_d, b, TOT_TH*(sizeof(unsigned int)), H_D);
	cudaMemcpy(c_d, c, TOT_TH*(sizeof(unsigned int)), H_D);
	cudaMemcpy(d_d, d, TOT_TH*(sizeof(unsigned int)), H_D);
	

	s = (spin_t*)malloc(N*sizeof(spin_t));
	for(int i=0; i<N; i++) s[i]=1;
	cudaMalloc((void**)&sD, N*sizeof(spin_t));
	cudaMemcpy(sD, s, N*sizeof(spin_t), H_D);


	vec_mag = (float*)malloc( (GRIDL*GRIDL)*sizeof(float));
	cudaMalloc((void**)&vec_mag_d, (GRIDL*GRIDL)*sizeof(float));
	energie = (int*)malloc(BLOCKS*sizeof(int));
	cudaMalloc((void**)&energie_d, BLOCKS*sizeof(int));	
		for(int i=0; i<BLOCKS; i++)
			energie[i]=0;
	cudaMemcpy(energie_d, energie, BLOCKS*(sizeof(int)), H_D);

	int ie = cpu_energy(s);
	int sumE = ie;
	double E=0;
	double E_2=0;
	double m=0;
	double M=0;
	double chi_sqr=0;
	double chi_sqr_2=0;
	double chi_sqr_m=0;	
	
	for(int i=0; i < 1000; ++i){
		//do_update_shared<<<grid, block>>>(sD, a_d, b_d, c_d, d_d, 0, energie_d);
		//do_update_shared<<<grid, block>>>(sD, a_d, b_d, c_d, d_d, 1, energie_d);
		do_update_testB<<<grid, block>>>(sD, a_d, 0, energie_d);
		do_update_testB<<<grid, block>>>(sD, a_d, 1, energie_d);
	}


	double start = getTime();
	for(int i=0; i < STEP_MC; ++i){
		//do_update_shared<<<grid, block>>>(sD, a_d, b_d, c_d, d_d, 0, energie_d);
		//do_update_shared<<<grid, block>>>(sD, a_d, b_d, c_d, d_d, 1, energie_d);
		do_update_testB<<<grid, block>>>(sD, a_d, 0, energie_d);
		do_update_testB<<<grid, block>>>(sD, a_d, 1, energie_d);
			
		cudaThreadSynchronize();
		
		//get_magnetization<<<gridRES, blockRES>>>(sD, vec_mag_d);
		//cudaMemcpy(vec_mag, vec_mag_d, (GRIDL*GRIDL)*sizeof(float), D_H);
		
		//for(int bl=0; bl < (GRIDL*GRIDL); bl++ )
		//	m+=vec_mag[bl];
		//m = m / (GRIDL*GRIDL);
		//M+=fabs(m);
		
		//cudaMemcpy(energie, energie_d, BLOCKS*sizeof(int), D_H);
		//for(int bl=0; bl < BLOCKS; bl++)
		//	sumE+=energie[bl];
		//E += (double)sumE;
		//chi_sqr+=pow(E/(i+1)-sumE,2.);
		//E_2 += pow((double)sumE,2.);
		//chi_sqr_2+=pow(E_2/(i+1)-pow((double)sumE,2.),2.);
		//chi_sqr_m+=pow(M/(i+1)-fabs(m),2.);			
		
		//m=0;	
		//sumE=ie;
	}
	double end = getTime();
	//cudaMemcpy(s, sD, N*sizeof(spin_t), D_H);
	//get_lattice(s);
	
	E_2 /= (long double)STEP_MC;
	E   /= (double)STEP_MC;
	double Cal_Spec=(1/((double)N))*(E_2-E*E)*((double)BETA*(double)BETA);
	double sigma_E  = pow(chi_sqr/((double)STEP_MC),0.5);
	double sigma_E2 = pow(chi_sqr_2/((double)STEP_MC),0.5);
	double sigma_m  = pow(chi_sqr_m/((double)STEP_MC),0.5);
	double err_per=0.5*(sigma_E/E+sigma_E2/E_2);
		

	M/=((double)STEP_MC);

	//printf("%f\t%f\t%f\t%f\t%f\n", BETA, M, Cal_Spec, err_per*Cal_Spec, sigma_m);
	printf("%i\t%f\n", L, (end-start)/((double)(L*L)*(STEP_MC)));
	
	return 0;

}







