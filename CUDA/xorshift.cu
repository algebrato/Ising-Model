#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#define END_SCALE       4294967296.0F


__device__ __host__ float MTGPU(unsigned int *s1, unsigned int *s2, unsigned int *s3, unsigned int *s4){

	unsigned int x, y, z, w, t;

	x=*s1;
	y=*s2;
	z=*s3;
	w=*s4;

	//for(int i=0; i<50; i++) //il mix potrebbe in questo caso non essere una buona idea.
	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
	*s1 = x;
	*s2 = y;
	*s3 = z;	
	*s4 = w;

	return w / END_SCALE;
}

	

