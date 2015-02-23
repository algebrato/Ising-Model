#include<stdlib.h>
#include<stdio.h>
#include "render.h"
#include "init.h"
#include "fill_ran.h"

#include <time.h>
#include <stdlib.h>

#include <cuda_runtime_api.h>
#include <curand.h>
#include <curand_mtgp32.h>
#include <curand_kernel.h>
#include <curand_mrg32k3a.h>
#define H_D cudaMemcpyHostToDevice
#define D_H cudaMemcpyDeviceToHost
#define DEV 0

#define DIM     2                       //Primi vicini mezzi
#define L       1024                    //Dimensione del reticolo
#define BLOCKL  16                      //Threads per blocco
#define GRIDL   (L/BLOCKL)              //N. Blocchi lineari (per colonna?) 
#define BLOCKS  ((GRIDL*GRIDL)/2)       //N. Blocchi totali nel reticolo
#define THREADS ((BLOCKL*BLOCKL)/2)     //N. Threads per blocco
#define N       (L*L)                   //N. Celle del reticolo
#define SPINS_PER_BLOCK (N/2)           //NON HA SENSO! (togliere questa follia)
#define TOT_TH  (BLOCKS*THREADS)        //N. di threads totali della griglia.

#define STEP            1000
#define TERM_STEP       100
#define VUOTO           1000
#define TOT             (STEP*VUOTO)
#define J 1
#define END_SCALE	4294967296.0F

#define sS(x,y) sS[(y+1)*(BLOCKL+2)+x+1]
#define A  1664525
#define C  1013904223
#define AA A
#define CC C
#define MULT 2.328306437080797e-10f
#define MULT2 4.6566128752457969e-10f
#define sS(x,y) sS[(y+1)*(BLOCKL+2)+x+1]
#define RAN(n) (n = AA*n + CC)



typedef int spin_t;
typedef unsigned int UI;

texture<float,1,cudaReadModeElementType> boltzT;

__device__ float MTGPU(unsigned int tid, unsigned int *s1, unsigned int *s2, unsigned int *s3, unsigned int *s4){
	unsigned int x, y, z, w, t;
	
	x=*s1;
	y=*s2;
	z=*s3;
	w=*s4;

	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;

	*s1 = x;
	*s2 = y;
	*s3 = z;
	*s4 = w;

	return w / END_SCALE;

}

__global__ void Comp_Res(spin_t *s, float *result){

        __shared__ spin_t sS[(BLOCKL)*(BLOCKL+1)];
        __shared__ float sum_part;

        sS[threadIdx.x + BLOCKL*threadIdx.y] = s[(blockIdx.x*BLOCKL + threadIdx.x )+(blockIdx.y*BLOCKL*L + threadIdx.y*L)];
        __syncthreads();


        if(threadIdx.x == 0)
                if(threadIdx.y == 0){
                        sum_part=0;
                        for(int i=0; i<BLOCKL; i++)
                                for(int k=0; k<BLOCKL; k++)
                                        sum_part += sS[i*BLOCKL+k];
                        __syncthreads();
                        result[blockIdx.x+blockIdx.y*GRIDL] = sum_part / (BLOCKL*BLOCKL);
                }
}








__global__ void update_metropolis_shared(spin_t *s, unsigned int* a, unsigned int* b, unsigned int* c, unsigned int* d, int* energie, unsigned int offset){
//__global__ void update_metropolis_shared(spin_t *s, int *ranvec, int* energie, unsigned int offset, curandStateMRG32k3a *state){


	unsigned int n = threadIdx.y*BLOCKL+threadIdx.x;
	unsigned int Xoffset = blockIdx.x*BLOCKL;
	unsigned int Yoffset = (2*blockIdx.y+(blockIdx.x+offset)%2)*BLOCKL;

	__shared__ spin_t sS[(BLOCKL+2)*(BLOCKL+2)];

	//se non sono sui bordi completo con la doppia scacchiera
	sS[(2*threadIdx.y+1)*(BLOCKL+2)+threadIdx.x+1] = s[(Yoffset+2*threadIdx.y)*L+(Xoffset+threadIdx.x)];
	sS[(2*threadIdx.y+2)*(BLOCKL+2)+threadIdx.x+1] = s[(Yoffset+2*threadIdx.y+1)*L+(Xoffset+threadIdx.x)];
	
	//bordo in alto
	if(threadIdx.y == 0)
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
	__syncthreads();

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
		if(MTGPU(n, aa, bb, cc, dd) < tex1Dfetch(boltzT, ide+2*DIM)){
			sS(x,y1) = -sS(x,y1);
			ie -=2*ide;
		}
		__syncthreads();
		
		ide = sS(x,y2)*(sS(x-1,y2)+sS(x+1,y2)+sS(x,y2+1)+sS(x,y2-1));
		if(MTGPU(n, aa, bb, cc, dd) < tex1Dfetch(boltzT, ide+2*DIM)){
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


int cpu_energy(spin_t *s){
	int ie = 0;
	for(int x = 0; x < L; ++x)
		for(int y = 0; y < L; ++y)
			ie += s[L*y+x]*(s[L*y+((x==0)?L-1:x-1)]+s[L*y+((x==L-1)?0:x+1)]+s[L*((y==0)?L-1:y-1)+x]+s[L*((y==L-1)?0:y+1)+x]);
	return ie/2;
}

int main(int pippo, char **pero){

	spin_t *s, *sD;

	float *risultati, *risultatiD;
	int *energie, *energieD;

	//Magnetizzazzione (ora non usata)
	risultati = (float*)malloc( (GRIDL*GRIDL)*sizeof(float));
	cudaMalloc((void**)&risultatiD, (GRIDL*GRIDL)*sizeof(float));

	//Valori delle energie
	energie = (int*)malloc(BLOCKS*sizeof(int));
	cudaMalloc((void**)&energieD, BLOCKS*sizeof(int));
	for(int i=0; i<BLOCKS; i++)
		energie[i]=0;
	cudaMemcpy(energieD, energie, BLOCKS*(sizeof(int)), H_D);

	//Vettore di numeri inizialmente random
	unsigned int *a, *a_d, *b, *b_d, *c, *c_d, *d, *d_d;
	float BETA = atof (pero[3]);
	
	float boltzGPU[4*DIM+1];
	for(int i=-2*DIM; i<=2*DIM; i++) boltzGPU[i+2*DIM] = min(1.0,exp(-2*BETA*J*i));
        float *boltzTex;
	cudaMalloc((void**)&boltzTex, (4*DIM+1)*sizeof(float));
	cudaMemcpy(boltzTex, boltzGPU,(4*DIM+1)*sizeof(float), H_D);
	cudaBindTexture(NULL, boltzT, boltzTex, (4*DIM+1)*sizeof(float));

	dim3 grid(GRIDL, GRIDL/2);
	dim3 block(BLOCKL, BLOCKL/2);

	dim3 gridRES(GRIDL, GRIDL);
	dim3 blockRES(BLOCKL, BLOCKL);

	//*************Accocazione e Generazione seed iniziali                 
	a=(unsigned int*)malloc(TOT_TH*2*sizeof(unsigned int));
	b=(unsigned int*)malloc(TOT_TH*2*sizeof(unsigned int));
	c=(unsigned int*)malloc(TOT_TH*2*sizeof(unsigned int));
	d=(unsigned int*)malloc(TOT_TH*2*sizeof(unsigned int));
	
	fill_ran_vec(a, b, c, d, TOT_TH);

	cudaMalloc((void**)&a_d, 2*TOT_TH*(sizeof(unsigned int)));
	cudaMalloc((void**)&b_d, 2*TOT_TH*(sizeof(unsigned int)));
	cudaMalloc((void**)&c_d, 2*TOT_TH*(sizeof(unsigned int)));
	cudaMalloc((void**)&d_d, 2*TOT_TH*(sizeof(unsigned int)));

	cudaMemcpy(a_d, a, TOT_TH*(sizeof(unsigned int)), H_D);
	cudaMemcpy(b_d, b, TOT_TH*(sizeof(unsigned int)), H_D);
	cudaMemcpy(c_d, c, TOT_TH*(sizeof(unsigned int)), H_D);
	cudaMemcpy(d_d, d, TOT_TH*(sizeof(unsigned int)), H_D);

	//*********Fine parte di generazione seed


	s = (spin_t*)malloc(N*sizeof(spin_t));
	for(int i=0; i<N; i++) s[i]=1;

	cudaMalloc((void**)&sD, N*sizeof(spin_t));
	cudaMemcpy(sD, s, N*sizeof(spin_t), H_D);
	int ie = cpu_energy(s); // Energia Iniziale.

	//printf("Energia iniziale: %i\n",ie);


	for(int i=0; i<TERM_STEP; i++){
		update_metropolis_shared<<<grid, block>>>(sD, a_d, b_d, c_d, d_d, energieD, 0);
		update_metropolis_shared<<<grid, block>>>(sD, a_d, b_d, c_d, d_d, energieD, 1);
		cudaThreadSynchronize();
	}


	double M=0;
	double Magnetizzazione=0;
	double E = ie;	
	int sumE=0;
	double E_2=0;
	int sub_iter=0;
	for(int i=0; i<STEP; i++){
		for(int j=0; j<VUOTO; j++){
	                update_metropolis_shared<<<grid, block>>>(sD, a_d, b_d, c_d, d_d, energieD, 0);
	                update_metropolis_shared<<<grid, block>>>(sD, a_d, b_d, c_d, d_d, energieD, 1);
			cudaThreadSynchronize();
		}
		sub_iter+=VUOTO;
		Comp_Res<<<gridRES, blockRES>>>(sD, risultatiD);
		cudaMemcpy(risultati, risultatiD, (GRIDL*GRIDL)*sizeof(float), D_H);

		for(int bl=0; bl < (GRIDL*GRIDL); bl++ )
			M+=risultati[bl];
		M = M / (GRIDL*GRIDL);
		
		//printf("%f\n",M);

		cudaMemcpy(energie, energieD, BLOCKS*sizeof(int), D_H);
		for(int bl=0; bl < BLOCKS; bl++)
			E+=energie[bl];
		sumE += E;
		E_2 += pow(E,2.);
		E=ie;
		
		Magnetizzazione +=M;
		M=0;
	}


	E_2 = E_2/STEP;
	E = sumE/STEP ;
	Magnetizzazione/=STEP;
	
	
	
	
	
	
	
	
	
	
	if(Magnetizzazione < 0)
		Magnetizzazione*=-1;

	printf("%f\t\t%f\t\t%f\t%f\n", BETA, Magnetizzazione, E, E_2);




	cudaFree(sD);
	cudaFree(a_d);
	cudaFree(b_d);
	cudaFree(c_d);
	cudaFree(d_d);
	cudaFree(energieD);



	return 0;



}
