/*L'idea base del programma e` quella di spezzare il vettore principale
  in tanti piccoli vettori di dimensione 16. Trovare il massimo di ognuno
  di questi e scriverlo in un sottovettore che e` sub_array.
  Ogni volta che viene ripetuto il kernel la lunghezza di sub_array, rispetto
  ad array e` 16 volte inferiore.
  Se si parte da un vettore iniziale di 4096 elementi non e` necessario nemmeno
  usare la CPU. Iterando 3 volte il kernel, torna una matrice di dimensione 1 
  che rappresenta appunto il massimo del vettore iniziale
 */
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
	
	//Alloco la memoria per le array sulla CPU
	arr_num=(float*)malloc(L*sizeof(float));
	sub_arr=(float*)malloc((L/BLOCKL)*sizeof(float));	

	//Riempio l'array con numeri random tra 0 e 10
	for(int i=0; i<L; ++i){
		arr_num[i]=10*(rand()/float(RAND_MAX));
	}
	
	//Alloco la memoria per le array sulla GPU
	cudaMalloc((void**)&arr_num_d, L*sizeof(float));
	cudaMalloc((void**)&sub_arr_d, (L/BLOCKL)*sizeof(float));
	
	//Copio l'array di numeri random sulla GPU
	cudaMemcpy(arr_num_d, arr_num, L*sizeof(float), H_D);

	//Eseguo 3 volte il kernel invertendo arr_num e sub_arr in questo modo
	//ad ogni step la dimensione dell'array dei massimi dei sottovettori
	//allocati nella memoria shared, diminuisce di un fattore 16
	//4096 e` una potenza perfetta di 16, quindi dopo 3 passaggi
	//ritorneta` una matrice dei massimi di dimensione 1, che rappresentera`
	//proprio il massimo del vettore iniziale.
	get_max<<< L/BLOCKL , BLOCKL >>>(arr_num_d,sub_arr_d);
	get_max<<< L/(BLOCKL*16) , BLOCKL >>>(sub_arr_d,arr_num_d);
	get_max<<< L/(BLOCKL*256) , BLOCKL >>>(arr_num_d,sub_arr_d);
	
		
	cudaMemcpy(sub_arr, sub_arr_d, (L/BLOCKL)*sizeof(float), D_H);

	cout << "Massimo array = " << sub_arr[0] << endl;

	return 0;
}

