#include<stdlib.h>
#include<stdio.h>


void Info_Dev(int i){

        cudaDeviceProp prop;
        int count;

        cudaGetDeviceCount (&count);

        cudaGetDeviceProperties( &prop, i );
	
	printf("Outfit del device in uso:\n");
        printf("\n");
        printf("Device Name:\t\t %s\n",prop.name);
        printf("Shared Mem/block :\t %d\n",prop.sharedMemPerBlock);
        printf("Registri per blocco:\t %d\n",prop.regsPerBlock);
        printf("Warp size:\t\t %d\n",prop.warpSize);
        printf("Texature 1D :\t\t %d\n",prop.maxTexture1D);
        printf("\n");

}
