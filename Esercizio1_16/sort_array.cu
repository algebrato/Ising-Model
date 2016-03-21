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

#define L 4096
#define BLOCKL 16


__global__ void get_max(float *arr_num, float *sub_arr){
	__shared__ float sub[BLOCKL];
	sub[threadIdx.x] = arr_num[BLOCKL*blockIdx.x+threadIdx.x];
	__shared__ float max;

	max = sub[0];
	for(int i=1; i<BLOCKL; ++i){
		if(max < sub[i]){
			max = sub[i];
		}
	}
	sub_arr[blockIdx.x]=max;
	__syncthreads();
}


int main(){
	float *arr_num, *arr_num_d, *sub_arr_d, *sub_arr;
	
	//Dichiaro la mia array sulla CPU
	arr_num=(float*)malloc(L*sizeof(float));
	sub_arr=(float*)malloc((L/BLOCKL)*sizeof(float));	
	//Riempio l'array con numeri random tra 0 e 10
	for(int i=0; i<L; ++i){
		arr_num[i]=10*(rand()/float(RAND_MAX));
		//printf("%f\n",arr_num[i]);
	}

	dim3 grid (L/BLOCKL);
	dim3 block(BLOCKL);


	//Copio l'array sulla scheda grafica
	cudaMalloc((void**)&arr_num_d, L*sizeof(float));
	cudaMalloc((void**)&sub_arr_d, (L/BLOCKL)*sizeof(float));
	cudaMemcpy(arr_num_d, arr_num, L*sizeof(float), H_D);

	get_max<<< L/BLOCKL , block >>>(arr_num_d,sub_arr_d);
	get_max<<< L/(BLOCKL*16) , block >>>(sub_arr_d,arr_num_d);
	get_max<<< L/(BLOCKL*256) , block >>>(arr_num_d,sub_arr_d);
	
	
	cudaMemcpy(sub_arr, sub_arr_d, (L/BLOCKL)*sizeof(float), D_H);

	cout << "Massimo array = " << sub_arr[i] << endl;

	return 0;
}

