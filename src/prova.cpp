#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#define END_SCALE       4294967296.0F



using namespace std;


float MTGPU(unsigned int *s1, unsigned int *s2, unsigned int *s3, unsigned int *s4){
	unsigned int x, y, z, w, t;
	
	x=*s1;
	y=*s2;
	z=*s3;
	w=*s4;

	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
    	t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;

 
	*s1 = x;
	*s2 = y;
	*s3 = z;
	*s4 = w;

	return w / END_SCALE;

}





int main(){
	unsigned int a=853892247, b=491968251, c=3073685529, d=3631446976;

	for(int i=0; i<10000; ++i){
		cout << MTGPU(&a,&b,&c,&d) << endl;
	}




	return 0;





}

