#include<iostream>
#include<stdlib.h>
#include"xorshift.cu"
#include"fill_ran.h"
#include"get_time.h"

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
	
	a[tidy+tidx] = *aa;
	b[tidy+tidx] = *bb;
	c[tidy+tidx] = *cc;
	d[tidy+tidx] = *dd;

	__syncthreads();
}

void get_lattice(spin_t *s_){
	for(int y=0; y<L; ++y){
		for(int x=0; x<L; ++x)
			printf("%i\t",s_[y*L+x]);
		printf("\n");
	}

}




int main(int argc, char**argv){
	spin_t *s, *sD;
	UI *a, *a_d, *b, *b_d, *c, *c_d, *d, *d_d;
	float *vec_mag, *vec_mag_d;

	dim3 grid(GRIDL, GRIDL);
	dim3 block(BLOCKL, BLOCKL/2);
	dim3 gridRES(GRIDL, GRIDL);
	dim3 blockRES(BLOCKL, BLOCKL);



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
	

	fill_ran_vec2(a, b, c, d, TOT_TH);


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
	double m=0;
	double M=0;

	double start = getTime();
	for(int i=0; i < 1000; ++i){
		do_update<<<grid, block>>>(sD, a_d, b_d, c_d, d_d, 0);
		do_update<<<grid, block>>>(sD, a_d, b_d, c_d, d_d, 1);
	}



	for(int i=0; i < STEP_MC; ++i){
		do_update<<<grid, block>>>(sD, a_d, b_d, c_d, d_d, 0);
		do_update<<<grid, block>>>(sD, a_d, b_d, c_d, d_d, 1);
		cudaThreadSynchronize();
		
		get_magnetization<<<gridRES, blockRES>>>(sD, vec_mag_d);
		cudaMemcpy(vec_mag, vec_mag_d, (GRIDL*GRIDL)*sizeof(float), D_H);
		
		for(int bl=0; bl < (GRIDL*GRIDL); bl++ )
			m+=vec_mag[bl];
		m = m / (GRIDL*GRIDL);
		M+=m;
		m=0;
	}

	double end = getTime();

	M/=((double)STEP_MC);

	printf("%f\t%f\n", BETA, M);
	//printf("%i\t%f\n", L, (end-start)/((double)(L*L)*(STEP_MC)));
	
	return 0;

}







