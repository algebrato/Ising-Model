#include<iostream>
#include<stdio.h>
#include<stdlib.h>
#include<curand_kernel.h>
#include<curand.h>
#include<cuda_runtime_api.h>
#include<time.h>
#define END_SCALE 4294967296.0F


using namespace std;


#define H_D cudaMemcpyHostToDevice
#define D_H cudaMemcpyDeviceToHost

#define L 516
#define BLOCKL 16


__global__ void get_max(float *arr_num, float ABSMAX){
	__shared__ float sub[BLOCKL];
	__shared__ float subsub[L/BLOCKL];
	sub[threadIdx.x] = arr_num[BLOCKL*blockIdx.x+threadIdx.x];
	__shared__ float max;
	ABSMAX=0;

	max = sub[0];
	for(int i=1; i<BLOCKL; ++i){
		if(max < sub[i]){
			max = sub[i];
		}
	}
	subsub[blockIdx.x]=max;
	__syncthreads();
	
	for(int k=0; k<L/BLOCKL; ++k){
		if(&ABSMAX < subsub[k]){
			&ABSMAX = subsub[k];
		}
	}
}





int main(){
	float *arr_num, *arr_num_d, *ABSMAX_d, *ABSMAX;
	
	//Dichiaro la mia array sulla CPU
	arr_num=(float*)malloc(L*sizeof(float));
	ABSMAX=(float*)malloc(sizeof(float));	
	//Riempio l'array con numeri random tra 0 e 10
	for(int i=0; i<L; ++i){
		arr_num[i]=10*(rand()/float(RAND_MAX));
		//printf("%f\n",arr_num[i]);
	}

	dim3 grid (L/BLOCKL);
	dim3 block(BLOCKL);


	//Copio l'array sulla scheda grafica
	cudaMalloc((void**)&arr_num_d, L*sizeof(float));
	cudaMalloc((void**)&ABSMAX_d, sizeof(float));
	cudaMemcpy(arr_num_d, arr_num, L*sizeof(float), H_D);

	get_max<<< grid , block >>>(arr_num_d,ABSMAX_d);



	cudaMemcpy(ABSMAX, ABSMAX_d, sizeof(float), D_H);

	cout << "Max = " << ABSMAX << endl;


	return 0;
}






