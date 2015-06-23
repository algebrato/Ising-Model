#include<iostream>
#include<stdlib.h>
#include"xorshift.h"
//#include"fill_ran.h"
using namespace std;


#define H_D cudaMemcpyHostToDevice
#define D_H cudaMemcpyDeviceToHost

#define J 1
#define DIM 2
#define L 128
#define BLOCKL 16
#define GRIDL  (L/BLOCKL)
#define BLOCKS ((GRIDL*GRIDL)/2)
#define THREADS ((BLOCKL*BLOCKL)/2)
#define N (L*L)
#define TOT_TH  (BLOCKS*THREADS) 
#define END_SCALE       4294967296.0


typedef int spin_t;
typedef unsigned int UI;


__device__ float MTGPU(unsigned int *s1, unsigned int *s2, unsigned int *s3, unsigned int *s4){

	unsigned int x, y, z, w, t;

	x=*s1;
	y=*s2;
	z=*s3;
	w=*s4;
	
	for(int i=0; i<30; i++)
		t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
	*s1 = x;
	*s2 = y;
	*s3 = z;
	*s4 = w;
	
	return w / END_SCALE;
}





texture<float,1,cudaReadModeElementType> boltzT;

__global__ void do_update(spin_t *s_, UI *a, UI *b, UI *c, UI *d, UI offset){
	int tidx = threadIdx.x + blockDim.x*blockIdx.x;
	int tidmy= threadIdx.y + blockDim.y*blockIdx.y;
	int tidy = 2*tidmy+((tidx+offset)%2);
	
	int ide = s_[L*tidy+tidx]*(s_[L*tidy+((tidx==0)?L-1:tidx-1)]+s_[L*tidy+((tidx==L-1)?0:tidx+1)]+s_[L*((tidy==0)?L-1:tidy-1)+tidx]+s_[L*((tidy==L-1)?0:tidy+1)+tidx]);

	//Inizializzo i semi
	unsigned int *aa = &a[tidy+tidx];
	unsigned int *bb = &b[tidy+tidx];
	unsigned int *cc = &c[tidy+tidx];
	unsigned int *dd = &d[tidy+tidx];
	int ie=0;

	if(MTGPU(aa, bb, cc, dd) < tex1Dfetch(boltzT, ide+2*DIM)){
		s_[L*tidy+tidx] = -s_[L*tidy+tidx];
		ie -=2*ide;
	}
	__syncthreads();
}


int main(int argc, char**argv){
	spin_t *s, *sD;
	UI *a, *a_d, *b, *b_d, *c, *c_d, *d, *d_d;

	dim3 grid(GRIDL, GRIDL/2);
	dim3 block(BLOCKL, BLOCKL/2);
	dim3 gridRES(GRIDL, GRIDL);
	dim3 blockRES(BLOCKL, BLOCKL);



	float BETA = atof(argv[3]);
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
	

	//fill_ran_vec2(a, b, c, d, TOT_TH);


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
	for(int i=0; i<10000; i++){
		do_update<<<grid, block>>>(sD, a_d, b_d, c_d, d_d, 0);
		do_update<<<grid, block>>>(sD, a_d, b_d, c_d, d_d, 1);
		cudaThreadSynchronize();

	}

	return 0;
	/* --> Tipica Domanda//Risposta
	   __device__ long d_answer;

	   __global__ void G_SearchByNameID() {
	     d_answer = 2;
	     }

	     int main() {
	     SearchByNameID<<<1,1>>>();
	     typeof(d_answer) answer;
	     cudaMemcpyFromSymbol(&answer, "d_answer", sizeof(answer), 0, cudaMemcpyDeviceToHost);
	     printf("answer: %d\n", answer);
	     return 0;
	     }
		       */




}







